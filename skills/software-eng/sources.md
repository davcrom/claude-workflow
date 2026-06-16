# Sources

The "reuse by generalizing" and "remove what the change supersedes" rules are
concrete encodings of established software-engineering canon:

- David Parnas, *On the Criteria to Be Used in Decomposing Systems into Modules*
  (1972) — information hiding; decompose by what is likely to change. Grounds the
  "core operation" test.
- Robert C. Martin — Single Responsibility Principle ("gather what changes for the
  same reasons; separate what changes for different reasons") and the Boy Scout
  Rule (leave code cleaner than you found it). Grounds "unify shared cores" and
  "a ticket is not done until superseded code is gone."
- Martin Fowler, *Refactoring* and the "Yagni" bliki entry — the "speculative
  generality" and "dead code" smells; YAGNI forbids speculative features but not
  refactoring. Grounds the deletion audit and the ban on mode-flag branches.
  https://martinfowler.com/bliki/Yagni.html
- Hunt & Thomas, *The Pragmatic Programmer* — DRY (one authoritative
  representation of each piece of knowledge) and Broken Windows.

Caveat encoded in the 4-step test: DRY targets duplicated *knowledge*, not
duplicated text. The mode-flag tell (step 4) is the guard against the wrong
abstraction (Sandi Metz: "duplication is far cheaper than the wrong abstraction").
