---
name: tdd
description: Invoke when writing or modifying code — no exceptions.
---

This skill implements one change at a time. The caller names a ticket file, a
free-text description of the work, or both; that named content is the scope.
Tickets come from `/software-eng`, which slices an approved spec into them. If
a ticket was named, set its Status to In progress before starting.

**Before writing code:**
- Read what the caller named. If a ticket was named, read the ticket file, the
  code it names under "Touches", and the spec section it points to. Otherwise
  read the code the work will touch.
- Sample actual data values before hardcoding thresholds, bins, mappings, or
  category sets.
- Reuse existing patterns and utilities; if a ticket names them under
  "Approach", start there. Do not reinvent.
- If the work cannot be built as described — the spec is wrong, a dependency is
  missing, scope is unclear — stop and report. If a ticket was named, set its
  Status to Blocked and write a `## Block reason` section into the ticket file
  quoting the concrete obstacle in one short paragraph, then return to
  `/software-eng` or `/spec-write`. Otherwise return to `/discuss` or
  `/spec-write` as appropriate. Do not improvise a fix in code.
- Stay within the named scope. Flag out-of-scope findings for approval; do not
  act on them.

**RED-GREEN-REFACTOR-COMMIT:**
Every change, no exceptions. Work one behavior at a time — one test, then the
code to pass it, then the next. Never write all the tests up front: tests
written in bulk check imagined behavior, not real behavior.
1. RED: stub the function, write a test with concrete inputs and assertions that
   checks observable behavior through the public interface, not internal
   details, so it survives refactoring. Run it. Failure must come from missing
   logic, not a missing symbol.
2. GREEN: write the minimum code to pass. Run it.
3. REFACTOR: with tests passing, answer each question below explicitly as
   "yes — fixed," "yes — out of scope, flagged," or "no." No new features.
   - Does the code follow the repo's existing organizational patterns?
   - Did you write code when a built-in method or existing utility could have been used?
   - Is there duplicated logic that could be replaced with a reusable function or method?
   - Are there intermediate variables used only once that don't clarify anything?
   - Are there names that don't describe what the thing is or does?
   - Are there loops where a comprehension or vectorized operation could have been used?
   - Does any function do more than one thing and want splitting?
   - Is there anything a cold reader couldn't understand from the code alone?
4. COMMIT: one logical change per commit. You cannot report the work complete
   until you make a commit.

**Coding principles:**
- **Pythonic**: prefer list comprehensions, context managers, generators, and built-in functions. Follow PEP 8.
- **KISS**: minimum code that solves the problem.
- **YAGNI**: do not build features, abstractions, guards, null checks, or fallbacks until they are actually needed. Solve today's problem, not tomorrow's hypothetical.
- **DRY**: extract logic that appears twice; leave it inline if once.
- **SOLID**: one responsibility per function; open for extension, closed for modification; depend on abstractions, not concretions.
- **Vectorize**: use array operations over Python loops.
- **Fail loud**: catch specific exceptions; never bare `except`; never `assert` for runtime validation.
- **Separation of concerns**: keep data, logic, and I/O in distinct layers.
- **Explicit defaults**: put meaningful defaults in the function signature, not buried in the body.
- **Imports at the top**: no lazy/function-level imports. Exception: optional dependencies that should not be required at module load.
- **Type hints** on all function signatures.
- Functions: ≤40 lines, ≤5 parameters, one clear purpose.

**For data science:**
- Set and document random seeds for all stochastic operations.
- Pin dependencies and document the environment.
- Design pipelines to be idempotent: re-running produces the same result.
- Separate data loading, preprocessing, modeling, and evaluation.

**Debugging:**
- When code produces wrong or unexpected results, see `/debug`.

**Before claiming the work complete:**
- Run code snippets to verify actual behavior.
- Inspect output data structures: shapes, types, null counts, value ranges.
- If a ticket was named, confirm its Acceptance check passes end to end;
  otherwise confirm the change behaves as the caller described.
- If a ticket was named, set its Status to Done.
- If a ticket was named, read the spec slug from its `Spec:` field. When every
  ticket file whose `Spec:` matches that slug has `Status: Done`, set the spec's
  `## Status` value line to `Implemented` (the word alone), with the date on the
  line directly below it.

**Status formats — write them exactly:**
A tool greps these as whole lines, so the status line carries only the status
word — no trailing date or punctuation.
- Ticket status is a single inline line:
  `Status: In progress` / `Status: Done` / `Status: Blocked`
- A blocked ticket also gets a `## Block reason` section.
- A spec's status is the value line under its `## Status` header; when every
  ticket for the spec is done, write:
  ```
  ## Status
  Implemented
  <date>
  ```

**If asked to skip tests:**
- Confirm with the user before proceeding.
