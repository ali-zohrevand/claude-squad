---
description: DEBUG phase — drive systematic debugging, fan out the squad to form root-cause hypotheses from each lens, reproduce the bug, and converge on the verified cause before any fix.
argument-hint: <bug / failure / unexpected behavior>
---

You are orchestrating the squad's **DEBUG** phase for: **$ARGUMENTS**

Investigation only — find and **prove the root cause** before proposing a fix. Do not patch symptoms.

## 1. Drive systematic debugging

Run the `superpowers:systematic-debugging` skill — it sets the discipline (reproduce → isolate → hypothesize → test the hypothesis → confirm). Use it as the spine of this phase.

## 2. Detect the stack

Dispatch **tech-lead** to detect the stack and load `squad:stack-conventions`. Capture the stack report for the other delegations.

## 3. Reproduce first

Dispatch **tester** to produce a minimal, reliable repro: exact steps/command, expected vs actual, the failing output (log/stack/assertion) and where it surfaces (`path:line`), and whether it's consistent or intermittent. If it can't be reproduced, gather the missing info before going further.

## 4. Fan out hypotheses (parallel, read-only)

With the repro in hand, dispatch in one message — each forms a root-cause hypothesis from its lens, ranked by likelihood, with the evidence and the cheapest way to confirm or kill it:

- **tech-lead** → architectural/integration causes (boundaries, config, concurrency, recent changes).
- **backend-dev** → server/data/logic causes (queries, transactions, error handling, types).
- **frontend-dev** → client/state/render causes (only if the symptom is UI-side).
- **qa** → what test was missing that let this through; how to capture it as a regression test.

## 5. Converge

Collect hypotheses, dedupe, and rank. Confirm the top one with evidence (a targeted check, log, or failing test) — **state the verified root cause**, not a guess. Then propose the minimal fix and the regression test that should accompany it. Hand off to `/squad:implement` to make the change (with a failing test first).
