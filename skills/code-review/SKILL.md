---
name: code-review
description: Invoke when reviewing a codebase or a section of it for structure, documentation, and code quality.
---

Review a whole codebase, or the sections the prompt names. Read how the parts
connect before judging how each one reads. This is your own review skill — use
it in place of the built-in /simplify.

**Map the structure:**
- Build the dependency graph: what imports what, what calls what. Note cycles
  and tangles.
- Separate the user-facing surface — the interface others call — from the
  hidden internals. The surface should be small; the internals carry the
  complexity.
- Check modularity: does each module own one concern, or are concerns smeared
  across many?

**Check the code:**
- Enforce the coding practices in /tdd — Pythonic, KISS, YAGNI, DRY, SOLID,
  fail loud, separation of concerns, type hints.
- Flag duplicated logic, shallow functions, leaky interfaces, dead code.

**Documentation:**
- Fill documentation blind spots — undocumented modules, functions, and public
  interfaces.
- Insert comments where the underlying logic is not obvious from the code
  alone. Do not comment what the code already says plainly.

**Report:**
- Invoke `/explain` to format the report.
- The body contains one prioritized list: bugs first, then structural issues, then blind spots, then next steps.
- Each item: location (`file:line`), what is wrong, why it matters, the concrete fix.
- Make documentation and comment changes directly. Flag bugs and structural changes for approval before touching them.
