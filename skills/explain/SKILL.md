---
name: explain
description: Invoke when producing a non-trivial synthesis or report — multi-source work (multiple files, multi-step investigation, external research), repository overviews, long single-file overviews, research outcomes, or final reports handed off from /research, /debug, or /code-review. Does not fire when the user has constrained the response to a short form.
---

Produce a structured report on a non-trivial synthesis or investigation. The report must follow a fixed section structure, apply two linguistic-style rules throughout, and pass a cold-read verification before being sent.

**Workflow.** Every triggering response goes through three steps in order.

1. Produce — draft the report following the structure and style rules below.
2. Review — send the draft to a cold-read subagent for verification.
3. Update — revise the draft to clarify anything the subagent flagged, then send it.

**Report structure.** The report must contain the following sections, in this exact order.

1. Restatement — a handful of prose sentences naming what the user asked. Comes first so misinterpretation is visible before the answer is read.
2. TL;DR — a list (not prose) of the most important findings, ordered most-important first. Each item at most three sentences.
3. Preview — a bulleted list of the body section titles that follow, in the order they appear.
4. Body — the previewed sections, in order.

**Linguistic style.** Both rules apply to every part of the report.

1. Prefer concrete, well-defined terms over ambiguous ones, even when the ambiguous term is shorter or a better domain fit.
2. Spell things out. Define jargon inline. Make every file or code reference self-contained — path, location in the file, and what is at that location. Do not assume the user has read what you have read.

**Cold-read verification.** Run exactly one successful cold-read before sending. Steps:

1. Spawn a subagent via the Agent tool with `subagent_type: general-purpose`.
2. Build the subagent prompt: the full draft report, a blank line, then this exact suffix:
   > Do not read any documents, do not explore the filesystem, do not run any code. Based only on the text above, report (a) what you understood about the user's question and the answer, and (b) a summary of any ambiguities — places where the meaning is unclear or open to multiple interpretations.
3. Pass no other context — no conversation history, no user profile, no description of the user.
4. Wait for the subagent's report.
5. If the report flags ambiguities or misunderstanding, revise the draft to clarify them. Do not remove flagged content.
6. Send the (possibly revised) report.

If the Agent tool errors, retry — a tool failure is not a cold-read. The no-second-pass rule below applies only once a cold-read has returned a report. If retries keep failing, tell the user the cold-read failed and send the unrevised draft.

Do not iterate. Once a cold-read has returned a report for a given draft, do not spawn a second subagent for it.
