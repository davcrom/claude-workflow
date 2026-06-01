---
name: skill-write
description: Invoke when writing or editing a skill — the SKILL.md files in claude/skills/ that define how I work.
---

A skill is a set of standing instructions for one activity. It is loaded when
its description matches the task, so the description is the routing signal —
get it right first.

**Description:**
- Start with "Invoke when..." and name concrete triggers — the activities or
  task types that should load this skill.
- It is the only part seen when deciding whether to load the skill. Vague
  description, and the skill loads at the wrong times or not at all.

**Scope:**
- One skill, one activity. If it covers two distinct activities, split it.
- Confirm the activity and its triggers with the user before drafting.
- Check the existing skills first — extend or fix one rather than overlap it.

**Content:**
- Write instructions to follow, not background prose. Every line should change
  what the agent does.
- Terse imperative bullets or short enumerated steps. No background prose.
- Plain language — no jargon the user cannot audit.
- One SKILL.md per skill. Split into supporting files only if it genuinely
  outgrows a single readable page.

**Structure:**
- Open the body with one sentence naming the activity the agent is performing.
- If the skill is a multi-step procedure, list the steps directly after the opening sentence, before detailing any one step.
- Each section: a bold-period header, one sentence stating the rule or scope, then the content. Do not put scope information in parentheses inside the header.

**Mechanics:**
- One folder per skill: claude/skills/<name>/SKILL.md. Name is kebab-case and
  matches the folder. Files are symlinked into ~/.claude — changes are live.
- Frontmatter: name and description only.
- After adding, renaming, or removing a skill, update the skill table in
  claude/CLAUDE.md.

**Sources:**
- If the skill's content draws on external sources (books, papers, articles), track them in `sources.md` alongside `SKILL.md`.
- Do not cite sources in the body of `SKILL.md` — keep it imperative.
- Add or update an entry in `sources.md` whenever a new source informs the skill.

**Before finishing:**
- Re-read as a cold agent: would the description load it at the right time,
  and do the instructions stand without the conversation that created them?
