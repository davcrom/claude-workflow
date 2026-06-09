---
name: software-eng
description: Invoke after a spec is approved, to review it and break it into implementation tickets.
---

This skill plans implementation. It does not write code — see `/tdd` for that.
Its job: review the approved spec, survey the codebase, and parse the spec into
tickets that an implementer can pick up and build one at a time.

**Review the spec first:**
- A spec must exist, be Approved, and survive your review. See `/spec-write`.
- If there is no spec, it is still Draft, or your review raises issues, stop and
  report. Do not ticket an unapproved or broken spec.
- If the spec is wrong or incomplete, return to `/spec-write`, fix it, and get
  re-approval before ticketing.
- Trivial tasks (one function, no new module) may skip ticketing — confirm the
  request with the user, then go straight to `/tdd`.

**Survey the codebase before slicing:**
- Read the code the spec will touch. Note existing conventions — style,
  structure, naming.
- Find existing solutions and utilities. Tickets should reuse them, not reinvent.
- Identify where new code belongs. Flag poor structural fit before ticketing it.

**Verify external data before ticketing it:**
- When a ticket depends on the shape of external data — an API response, a file
  format, a library's return value — confirm that shape before writing the
  ticket. You have network access: fetch a real sample. If you cannot, ask the
  user.
- Write the verified facts into the ticket: exact field names, types, one example
  value, and any gotcha (a number served as a string, an unexpected page size).
  Date-stamp the verification.
- Do not write mock data or fixtures into test modules. Capturing the data shape
  in the ticket is your job; building the mock from it is the implementer's job
  under `/tdd`.

**Slice the spec into tickets:**
- Each ticket is a **vertical slice**: it touches every layer needed to deliver
  one testable behavior end to end. Not a horizontal layer ("all the I/O"), not a
  whole subsystem.
- Each ticket is **independently testable** — it has a concrete acceptance check
  that proves the behavior works, allowing immediate feedback.
- Give every ticket at least one automated acceptance check the implementer can
  run. Never let a manual check — GUI, browser, live network — be a ticket's only
  acceptance. Pair it with an automated check and label the manual part "not a
  gate".
- Separate pure logic from UI and I/O. Put the logic in a dependency-free
  function the test calls directly; leave the thin UI or network wrapper for the
  manual check. Test the logic. Do not write integration or GUI tests.
- Write every ticket to pass in the implementer's environment: headless, no
  display, no network. If verifying a ticket needs a display or live network,
  split out the part that does not and move the rest to the manual check.
- Each ticket is **self-contained** — explicit inputs and outputs, names the
  files and functions it touches, names the existing patterns it should reuse. An
  implementer should not need to re-derive context from the spec.
- Each ticket is **sized to roughly one commit** — one logical change.
- Order by dependency. A ticket lists the tickets that must land before it.
- Every behavior in the spec maps to a ticket. Nothing in a ticket goes beyond
  the spec.

**Ticket files:**
- One file per ticket: `tickets/<spec-slug>/<NN>-<short-slug>.md`, under a
  per-spec subdirectory, numbered in dependency order restarting at `01` for
  each spec.
- Don't commit specs or tickets; both are local working files, not
  version-controlled.
- Always adhere to this structure:

# Ticket: <title>

Spec: <spec-slug>
Status: Todo | In progress | Blocked | Done
Blocked by: <ticket numbers, or "none">  (same-spec: `<NN>`; cross-spec: `<spec-slug>/<NN>`)

## Goal
The one testable behavior this slice delivers.

## Touches
Files, functions, and modules this ticket creates or modifies.

## Approach
Existing patterns, utilities, and conventions to reuse. How it fits the codebase.

## Acceptance
The concrete check that proves it works — inputs and expected outputs.

**After ticketing:**
- Populate the spec's `## Implementation plan` section with one bullet per ticket
  in dependency order (`tickets/<spec-slug>/<NN>-<slug>.md`). Write this once at slice time;
  do not update it as tickets change state — status lives in the ticket files.
- Report the ticket list and dependency order to the user.
- Implementation happens under `/tdd`, one ticket at a time.
