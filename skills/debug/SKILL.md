---
name: debug
description: Invoke when tracking down why code produces wrong or unexpected results.
---

**Build a way to check, before guessing at causes.**
- Make a small, fast check that runs the broken code on a fixed input and says
  plainly whether the bug is present. Keep it narrow and quick.
- Make it repeatable: same result every run (fix the input, fix any random
  number generator) and have it report the specific wrong value.
- If you cannot build one, stop. Say what you tried and ask the user for what
  is missing. Do not guess without a check.

**For bugs that come and go, make them happen more often.** A bug that appears
once in a hundred runs cannot be studied; run the trigger repeatedly until it
fails often enough to work with.

**Confirm the bug before explaining it.** State what happens now versus what
should happen, with the exact error. Make sure the check reproduces the problem
the user described — not a different one nearby.

**List several possible causes before testing any.** Write down three to five,
ranked — the first plausible idea anchors you. Each must predict something you
can check. Show the list to the user; they often know which is likely.

**Test one thing at a time.** Change one thing, see what happens, change it
back. Read the existing code and logs before adding print statements. Mark
anything you add for debugging so it is easy to remove. Never hide an error you
do not understand. After three wrong guesses, question the approach, not the
details.

**Fix it and confirm.** Where sensible, add a test that would catch this bug
again; if there is no sensible place, say so. Re-run the original check to
confirm the bug is gone, remove your debugging additions, and state the cause
in the commit message.

**Reporting findings:**
- When the root cause or fix synthesizes findings across multiple files, checks, or components, invoke `/explain` to format the final report.
- Short single-cause fixes do not need `/explain`; the commit message suffices.
