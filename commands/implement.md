---
description: IMPLEMENT phase — hybrid single-writer build. Fan out design in parallel, then write serially by file ownership with TDD, run the verify suite, and gate on a fresh review before claiming done.
argument-hint: <plan, task, or path to a plan file>
---

You are orchestrating the squad's **IMPLEMENT** phase for: **$ARGUMENTS**

**Critical rule: never run two writer agents at once.** Parallel writers corrupt shared files. Design fans out; writing is serial and partitioned by file ownership.

## 1. Confirm design & ownership

Dispatch **tech-lead** to: detect the stack (load `squad:stack-conventions`), confirm the approach (reusing existing code where possible), and assign **non-overlapping file ownership** to each writer (e.g. backend-dev owns `src/api/**`, frontend-dev owns `src/ui/**`). Output an ordered build list marking sequential vs independent tasks.

## 2. Isolate the workspace (optional but preferred)

For anything non-trivial, use the `superpowers:using-git-worktrees` skill to build in an isolated worktree so the main checkout stays clean.

## 3. Design review (parallel, read-only — only the lenses that apply)

Before writing, dispatch **only** the specialists whose domain the change touches (skipping a lens is the main cost saving): frontend-dev if there's UI, backend-dev if there's server/data work, qa for test design, and security-owasp **only** if the change touches auth/data/input/secrets/external/LLM calls. For a small or single-domain task, one or two agents is enough — don't fan out the whole squad. Fold their input into the plan. Agents run at their pinned effort; that's deliberate — reserve higher effort for genuinely hard design problems.

## 4. Write — serially, with TDD

Drive the `superpowers:test-driven-development` skill. Then, **one writer at a time**:

1. **qa** writes the failing tests for the slice (test files only).
2. **backend-dev** implements its owned backend paths until those tests pass.
3. **frontend-dev** implements its owned frontend paths until its tests pass.

Each writer touches only the paths it owns. Wait for one to finish before starting the next. Keep changes minimal and matched to existing patterns.

## 5. Verify

Dispatch **tester** to run the full stack verify suite (typecheck, lint, format, tests, build — from stack-conventions / the repo's own scripts) and report PASS/FAIL with output. Loop back to the owning writer for any failure.

## 6. Gate before done

Run the `superpowers:verification-before-completion` skill, then dispatch a **fresh-context review** (the `feature-dev:code-reviewer` agent, or `/code-review`) scoped to correctness and requirement gaps only. Do not claim the work is complete until the verify suite is green and the review is clean. Suggest `/squad:verify` for the full multi-lens sign-off.
