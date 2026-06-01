#!/usr/bin/env bash
set -euo pipefail

SETTINGS="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/ralph-loop-settings.json"

LOOP_PROMPT='Read every specs/*.md whose Status is Approved. Find every ticket file under tickets/ whose Spec: field matches an approved spec slug, whose Status is Todo, and whose every Blocked by entry refers to a ticket with Status: Done. Same-spec entries take the form <NN>; cross-spec entries take the form <spec-slug>/<NN>. From the eligible set, pick the ticket with the lowest <NN>, ties broken by ascending spec slug. Invoke /tdd on that ticket. Exit when the tickets Status is Done or Blocked.'

DRY_RUN_PROMPT='Read every specs/*.md whose Status is Approved. Find every ticket file under tickets/ whose Spec: field matches an approved spec slug, whose Status is Todo, and whose every Blocked by entry refers to a ticket with Status: Done. From the eligible set, pick the ticket with the lowest <NN>, ties broken by ascending spec slug. Print the picked ticket as <spec-slug>/<NN> on stdout and exit without modifying any file.'

usage() {
    cat >&2 <<'EOF'
usage: ralph-loop [--branch <name>] [--dry-run]
  --branch <name>  create <name> off HEAD, switch to it, then run
  --dry-run        print the next ticket that would be picked, exit
EOF
    exit 2
}

# Argument parsing
DRY_RUN=0
BRANCH=""
while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) DRY_RUN=1; shift ;;
        --branch)
            [ $# -ge 2 ] || usage
            BRANCH="$2"
            shift 2
            ;;
        *) usage ;;
    esac
done

preflight() {
    if [ -z "${VIRTUAL_ENV:-}" ] && [ -z "${CONDA_PREFIX:-}" ]; then
        echo "ralph-loop: no python env active. Activate a venv/uv/conda env first." >&2
        exit 1
    fi
    if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
        echo "ralph-loop: tracked files have uncommitted changes. Commit or stash before running." >&2
        exit 1
    fi
    if [ -n "$BRANCH" ]; then
        if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
            echo "ralph-loop: branch '$BRANCH' already exists." >&2
            exit 1
        fi
        git checkout -b "$BRANCH"
    fi
}

invoke_claude() {
    local prompt="$1"
    claude -p \
        --settings "$SETTINGS" \
        --permission-mode dontAsk \
        "$prompt"
}

preflight

if [ "$DRY_RUN" -eq 1 ]; then
    invoke_claude "$DRY_RUN_PROMPT"
    exit $?
fi

LOG_DIR=".claude"
LOG_FILE="$LOG_DIR/ralph-loop.log"
MAX_ITERS="${RALPH_MAX_ITERS:-50}"

mkdir -p "$LOG_DIR"

# Return 0 if any approved spec still has a Todo ticket whose Spec: matches.
# Spec format: a `## Status` header line followed by `Approved` on its own line.
approved_slugs() {
    local f
    for f in specs/*.md; do
        [ -e "$f" ] || continue
        if grep -A1 '^## Status$' "$f" | grep -q '^Approved$'; then
            basename "$f" .md
        fi
    done
}

# Print the path of every ticket whose Spec: matches an approved spec.
approved_tickets() {
    local slug t
    while IFS= read -r slug; do
        [ -z "$slug" ] && continue
        for t in tickets/*.md; do
            [ -e "$t" ] || continue
            grep -q "^Spec: $slug\$" "$t" || continue
            echo "$t"
        done
    done < <(approved_slugs)
}

todos_remain() {
    local t
    while IFS= read -r t; do
        grep -q "^Status: Todo\$" "$t" && return 0
    done < <(approved_tickets)
    return 1
}

# Status value of a single ticket file (empty if the line is absent).
ticket_status() {
    grep -m1 '^Status:' "$1" 2>/dev/null | sed 's/^Status:[[:space:]]*//'
}

# Snapshot approved-spec ticket statuses into the associative array named $1.
snapshot_status() {
    local -n _snap="$1"
    _snap=()
    local t
    while IFS= read -r t; do
        _snap["$t"]=$(ticket_status "$t")
    done < <(approved_tickets)
}

# Print, to stderr, how each approved-spec ticket moved between loop start
# (START_STATUS) and now. Installed as the EXIT trap so it fires on every exit.
print_summary() {
    local -A end_status
    snapshot_status end_status
    echo "=== ralph-loop summary (exit: ${EXIT_REASON:-unknown}) ===" >&2
    {
        local t old new label mark
        for t in "${!end_status[@]}"; do
            old="${START_STATUS[$t]:-}"
            new="${end_status[$t]}"
            label=$(ticket_label "$t")
            if [ "$old" != "$new" ]; then
                mark=""
                [ "$new" = "Blocked" ] && mark=" *"
                printf '  %-28s %s -> %s%s\n' "$label" "$old" "$new" "$mark"
            else
                printf '  %-28s %s (unchanged)\n' "$label" "$new"
            fi
        done
    } | sort >&2
}

# Extract <spec-slug>/<NN> from a ticket file path and its Spec: line.
ticket_label() {
    local f="$1"
    [ -z "$f" ] && { echo "unknown"; return; }
    local slug
    slug=$(grep -m1 '^Spec: ' "$f" | sed 's/^Spec: //')
    local nn
    nn=$(basename "$f" | sed -E 's/^([0-9]+)-.*/\1/')
    echo "${slug:-unknown}/${nn:-??}"
}

log_line() {
    local label="$1" reason="$2"
    printf '%s ticket=%s exit=%s\n' "$(date -Iseconds)" "$label" "$reason" >> "$LOG_FILE"
}

# Baseline for the exit summary, and the trap that prints it on every exit path
# (clean finish, error, uncommitted, no_progress, blocked, cap).
declare -A START_STATUS before_status after_status
snapshot_status START_STATUS
EXIT_REASON="finished"
trap print_summary EXIT

# Print the detected ticket set up front so the user sees the starting state
# before any agent runs.
print_initial_status() {
    echo "=== ralph-loop start: detected tickets ===" >&2
    {
        local t
        for t in "${!START_STATUS[@]}"; do
            printf '  %-28s %s\n' "$(ticket_label "$t")" "${START_STATUS[$t]}"
        done
    } | sort >&2
}
print_initial_status

iter=0
while todos_remain; do
    iter=$((iter + 1))
    if [ "$iter" -gt "$MAX_ITERS" ]; then
        log_line "unknown" "cap_hit"
        EXIT_REASON="cap_hit"
        echo "ralph-loop: iteration cap ($MAX_ITERS) hit." >&2
        exit 1
    fi

    snapshot_status before_status
    head_before=$(git rev-parse HEAD)
    echo "ralph-loop: launching agent (iter $iter/$MAX_ITERS)" >&2
    stderr_file=$(mktemp)
    set +e
    invoke_claude "$LOOP_PROMPT" 2> "$stderr_file"
    rc=$?
    set -e
    head_after=$(git rev-parse HEAD)
    snapshot_status after_status

    # Identify the ticket whose status changed this iteration. If more than one
    # changed, the last wins for the log label (cosmetic — any change counts).
    changed=""
    status_changed=0
    for t in "${!after_status[@]}"; do
        if [ "${after_status[$t]}" != "${before_status[$t]:-}" ]; then
            changed="$t"
            status_changed=1
        fi
    done
    label=$(ticket_label "$changed")

    if [ "$rc" -ne 0 ]; then
        tail=$(tr '\n' ' ' < "$stderr_file" | cut -c1-200)
        log_line "$label" "error:$tail"
        rm -f "$stderr_file"
        EXIT_REASON="error"
        echo "ralph-loop: claude exited $rc." >&2
        exit 1
    fi
    rm -f "$stderr_file"

    # Commit gate: a ticket was resolved but HEAD did not move -> uncommitted work.
    if [ "$status_changed" -eq 1 ] && [ "$head_after" = "$head_before" ]; then
        log_line "$label" "uncommitted"
        EXIT_REASON="uncommitted"
        echo "ralph-loop: ticket resolved but HEAD unchanged — work not committed." >&2
        exit 1
    fi

    # No ticket resolved: agent did nothing, or committed without resolving.
    if [ "$status_changed" -eq 0 ]; then
        log_line "${label:-unknown}" "no_progress"
        EXIT_REASON="no_progress"
        echo "ralph-loop: no ticket status changed after iteration." >&2
        exit 1
    fi

    if [ "${after_status[$changed]}" = "Blocked" ]; then
        reason=$(awk '/^## Block reason/{flag=1; next} /^## /{flag=0} flag' "$changed" | tr '\n' ' ' | cut -c1-200)
        log_line "$label" "blocked:$reason"
        EXIT_REASON="blocked"
        echo "ralph-loop: ticket blocked." >&2
        exit 1
    fi

    log_line "$label" "done"
done

if [ "$iter" -eq 0 ]; then
    EXIT_REASON="no_eligible_tickets"
    echo "ralph-loop: no eligible tickets found — nothing to do." >&2
    echo "  Expected work? Check that a spec's '## Status' line reads exactly 'Approved'," >&2
    echo "  and that tickets have 'Spec:' matching the spec filename and 'Status: Todo'." >&2
else
    echo "ralph-loop: finished — completed $iter ticket(s); no Todo tickets remain." >&2
fi
exit 0
