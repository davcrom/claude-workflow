---
name: spec-write
description: Invoke when writing or updating a spec — a standalone design artifact in specs/ that defines inputs, outputs, and behavior before implementation.
---

A spec concisely captures all the essential information the implementation needs.
It is not a design discussion (/discuss), not a literature review (/research),
not implementation notes.

**When to write one:**
- Any non-trivial task: anything touching more than one function, any new module,
  any analysis plan, experiment design, or data pipeline.
- One file per task: specs/<short-task-slug>.md

**Verified facts only:**
- Every input, output, type, path, name, and dependency must be something you have
  observed — read in a file, seen in real data, or stated by the user.
- Verifying is part of the work: read the underlying APIs and codebases to confirm
  signatures, types, schemas, and behavior. Do not infer them.
- Anything you cannot verify, and any decision not yet made, goes in Open
  questions — never stated as fact in the body.

**Decisions:**
- Design (what it does) and rationale (why) stay separate. The body says what;
  the Decisions section says why.
- Record each design decision in the Decisions section with its stated source or
  reason. Generic principles are not reasons.

**Scope:**
- Enumerate every file the change touches in Behavior. Nothing implicit.

**No appending:**
- Never bolt new content onto a finished spec as an appendix, trailer, or ad-hoc subsection. Integrate every fact into the template section where it belongs, restructuring existing prose if needed.

**Review re-entry:**
- If an ambiguity, gap, or unresolved decision surfaces during spec review, stop editing and re-invoke /discuss to resolve it. Do not patch the spec from your own inference.

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
Each design decision with its stated source or reason. Rationale and
metacommentary live here, not in the body.

## Open questions
Anything unverified or unresolved. Must be empty before Approved.
