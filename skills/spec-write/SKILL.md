---
name: spec-write
description: Invoke when writing or updating a spec — a standalone design artifact in specs/ that defines inputs, outputs, and behavior before implementation.
---

A spec concisely captures all the essential information the implementation needs.
It is technical specification, not narrative. It is not a design discussion
(/software-align), not a literature review (/research), not implementation notes.

**When to write one:**
- Any non-trivial task: anything touching more than one function, any new module,
  any analysis plan, experiment design, or data pipeline.
- One file per task: specs/<short-task-slug>.md

**Starting from a draft:**
- /software-align leaves its resolved decisions in that same file, in the order
  they were made.
- Rewrite it in place into the template. No second file, no raw log left behind.
- Place every decision: what it does in the body, binding constraints in
  Decisions, anything marked open in Open questions.
- Discard the draft's narrative — quotes, options considered, order of
  discussion, reasoning that binds nothing.
- Reorder freely so the spec reads top to bottom.
- Verify anything the draft omits. Do not infer it.

**Verified facts only:**
- Every input, output, type, path, name, and dependency must be something you have
  observed — read in a file, seen in real data, or stated by the user.
- Verifying is part of the work: read the underlying APIs and codebases to confirm
  signatures, types, schemas, and behavior. Do not infer them.
- Anything you cannot verify, and any decision not yet made, goes in Open
  questions — never stated as fact in the body.

**No narrative:**
- No user quotes, no conversation history, no account of how a decision was
  reached, no options that were rejected.
- No background or motivation beyond the one-paragraph Problem statement.
- No notes to the reader, no summary of what changed in the spec.
- Every line must tell the implementer what to build or what not to build. Cut
  anything else, however true.

**Decisions:**
- Design (what it does) and rationale (why) stay separate. The body says what;
  the Decisions section says why.
- Record a decision only where the implementation would plausibly go another way
  without it. Justification exists to prevent stray implementation, nothing else.
- One line each, stating the constraint. Add the reason only when the reason is
  what makes it binding. No attribution, no quoted reasoning.
- Generic principles are not reasons. A decision that constrains nothing is not
  recorded.

**Scope:**
- Enumerate every file the change touches in Behavior. Nothing implicit.

**No appending:**
- Never bolt new content onto a finished spec as an appendix, trailer, or ad-hoc subsection. Integrate every fact into the template section where it belongs, restructuring existing prose if needed.

**Review re-entry:**
- If an ambiguity, gap, or unresolved decision surfaces during spec review, stop editing and re-invoke /software-align to resolve it. Do not patch the spec from your own inference.

**Lifecycle:**
- Update the spec before the code change that implements a decision, not after.
- Keep it in sync with the conversation — every design decision gets written back
  before proceeding.
- A stale spec is a bug.
- Open questions must be empty before Status moves to Approved.
- Only the user moves Status to Approved.

**Template — always adhere to this structure:**

# Spec: <task name>

## Status
Draft | Approved | Implemented
<date>

## Problem
What needs to exist and why. One paragraph.

## Inputs
Each input: name, type, source, constraints. Verified entries only.

## Outputs
Each output: name, type, destination, constraints.

## Behavior
What it does, step by step. Edge cases and error handling. No rationale here.

## Out of scope
What this explicitly does not do.

## Implementation plan
*Populated by /software-eng at slice time. Not maintained as tickets change state.*

## Decisions
Constraints that would otherwise be implemented some other way, one line each.
Reason only where the reason is what binds. Empty is a valid section.

## Open questions
Anything unverified or unresolved. Must be empty before Approved.
