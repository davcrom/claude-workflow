---
name: reflect
description: Invoke after any completed task where workflow, process, or project knowledge changed — including when a tool call was rejected, the user interrupted a task, or asked to fix something that was already done.
---

Review the completed task and check each of the following:

1. **Workflow/process**: did anything about how we work change? Does any skill or the global CLAUDE.md need updating?
2. **User-level knowledge**: did you learn something about the user's preferences, tools, or environment that should persist across sessions? Update memory files (`MEMORY.md` and topic files) accordingly — but ONLY for personal/user-specific knowledge (see memory rule below).
3. **Project structure**: did you discover or establish anything about this project's structure, conventions, or architecture? Update project-level docs (README, architecture notes, etc.) if they exist.
4. **Friction signals**: did the user reject a tool call, interrupt a task, or ask you to go back and fix something? For each instance, check whether an existing rule already covers it.

**Rule-failures vs rule-gaps:**
- **Existing rule failed**: you must do one of the following — (a) sharpen the rule's wording, (b) add a concrete trigger or smell so the situation is recognizable, or (c) escalate to a settings.json hook if rules have repeatedly failed for this pattern.
- **No existing rule**: draft a new one.

**Organize your output:** group all findings as "rule-failures (N)" vs "rule-gaps (N)" and rank by how often each pattern appeared in the session.

**When writing or editing agent instructions** (skills, CLAUDE.md, hooks): use compact, imperative language. State rules as commands. No hedging, no conversational register. Every word must earn its place.
- Cap each proposed rule at one sentence.
- No metacommentary or rationale in the rule itself — the reason goes in the conversation, not the file.
- No examples specific to the case that prompted the change.
- When proposing an edit, quote the two lines above and below the insertion point from the target file so placement is visible.

**Optional compression pass:** re-read the whole target file after the edit. Look for repeated information, or a reorganization or restatement that would strengthen the described behavior. Propose the revised version.

**Rules:**
- Do NOT put project-specific information into `~/.claude/CLAUDE.md` or global skills
- Do NOT update docs for trivial tasks — only when something genuinely changed or was newly learned
- For changes to global skills or CLAUDE.md: propose the change to the user, do not make it unilaterally
- For project docs and memory files: make the update, then briefly tell the user what was updated and why
- **Memory vs. project files**: workflow, process, and project-specific knowledge MUST go into version-controlled project files (e.g., `CLAUDE.md`, `workflows/`, README). Memory is only for user-specific preferences (tone, style, background, environment). Never save workflow or process improvements to memory — they are not version-controlled and cannot be shared across machines or with collaborators.
