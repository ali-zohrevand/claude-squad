---
description: IMPLEMENT phase — hybrid single-writer build. Brief once, design in parallel with only the lenses that apply, then write serially by file ownership with TDD, run the verify suite in the background, and gate on a fresh review before claiming done.
argument-hint: <plan, task, or path to a plan file>
---

You are orchestrating the squad's **IMPLEMENT** phase for: **$ARGUMENTS**

<goal>
Working, verified code on a branch, with tests that failed before and pass after. Green verify output pasted, review clean. "Implemented, should work" is not the deliverable.
</goal>

<principles>
Load `squad:method` once and follow it. **Never run two writer agents at once**; parallel writers corrupt shared files. Design fans out; writing is serial and partitioned by file ownership. Make routine calls yourself and log them under Decisions.
</principles>

<inputs>
- Manifests present: !`ls package.json go.mod composer.json nest-cli.json phpstan.neon .golangci.yml 2>/dev/null | tr '\n' ' '`
- Scripts: !`node -e "try{console.log(Object.keys(require('./package.json').scripts||{}).join(' '))}catch(e){}" 2>/dev/null`
- Branch / tree: !`git branch --show-current 2>/dev/null`, !`git status --short 2>/dev/null | wc -l | tr -d ' '` changed files
- House rules: !`head -40 CLAUDE.md 2>/dev/null || echo '(no CLAUDE.md)'`
</inputs>

<workflow>
1. **Brief.** If `$ARGUMENTS` is a plan file, read it. Write the stack report yourself from the signals above. Write `squad-brief.md` to your scratchpad: stack, verify commands, the agreed design, acceptance criteria, and a first draft of file ownership. Pass its path to every agent.
2. **Ownership.** Dispatch **tech-lead** with the brief path to confirm the approach (reuse over new code) and return **non-overlapping file ownership** per writer plus an ordered build list. Skip this when the plan already carries ownership and a build list; a plan from `/squad:plan` does.
3. **Workspace.** For anything non-trivial, use `superpowers:using-git-worktrees` so the main checkout stays clean.
4. **Design review, only the lenses the change touches, in ONE message (parallel, read-only).** frontend-dev if UI; backend-dev if server/data; qa for test design; security-owasp **only** if auth, data access, input handling, secrets, or external/LLM calls are involved. For a small single-domain task, one agent or none. Each returns a diff plan, not code. Fold it into the brief.
5. **Write, serially, test-first.** Drive `superpowers:test-driven-development`. One writer at a time, each told its owned paths and the brief path:
   1. **qa** writes the failing tests and pastes the failing run.
   2. **backend-dev** makes its tests pass in its owned paths.
   3. **frontend-dev** makes its tests pass in its owned paths.
   Wait for each to finish before the next starts. Keep changes minimal and matched to existing patterns.
6. **Verify suite.** Dispatch **tester** with `run_in_background` to run the full suite from the brief. While it runs, start step 7. On a failure, **continue the owning writer** (same agent, context intact) with the failing lines; do not start a fresh writer. Loop until green.
7. **Fresh review.** Run `superpowers:verification-before-completion`, then a fresh-context review (`feature-dev:code-reviewer` or `/code-review`) scoped to correctness and requirement gaps. Fix real findings via the owning writer.
</workflow>

<delivery>
Report: files changed per writer · the failing-then-passing test output (before/after pair) · the verify table from tester · review result · **Decisions** · what was left out and why. List only the checks that were actually run. Suggest `/squad:verify` for the multi-lens sign-off.
</delivery>

<verification>
Run these; do not just claim them: the new tests fail before the change and pass after; the full verify suite is green with output pasted; the fresh review has no open correctness finding. Do not claim done until all three are true.
</verification>
