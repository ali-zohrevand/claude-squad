---
description: DEBUG phase — systematic debugging. Reproduce first, fan out only the lenses the symptom implicates to form root-cause hypotheses, and converge on the proven cause before any fix.
argument-hint: <bug / failure / unexpected behavior>
---

You are orchestrating the squad's **DEBUG** phase for: **$ARGUMENTS**

<goal>
A verified root cause with the evidence that proves it, plus the minimal fix and the regression test that should accompany it. A list of guesses is not the deliverable. No patches here; `/squad:implement` makes the change.
</goal>

<principles>
Load `squad:method` once and follow it. Every claim has a source: a log line, a failing test, a `path:line`. Make routine calls yourself and log them under Decisions.
</principles>

<inputs>
- Manifests present: !`ls package.json go.mod composer.json nest-cli.json phpstan.neon .golangci.yml 2>/dev/null | tr '\n' ' '`
- Scripts: !`node -e "try{console.log(Object.keys(require('./package.json').scripts||{}).join(' '))}catch(e){}" 2>/dev/null`
- Recent commits: !`git log --oneline -8 2>/dev/null`
- Working tree: !`git status --short 2>/dev/null | head -20`
- House rules: !`head -40 CLAUDE.md 2>/dev/null || echo '(no CLAUDE.md)'`
</inputs>

<workflow>
1. **Discipline.** Run `superpowers:systematic-debugging`; it is the spine (reproduce → isolate → hypothesize → test → confirm).
2. **Brief.** Write the stack report yourself from the signals above. Write `squad-brief.md` to your scratchpad: stack, verify commands, the symptom in the reporter's words, recent commits, what has already been ruled out.
3. **Reproduce first.** Dispatch **tester** with the brief path to produce a minimal reliable repro: command, expected vs actual, failing output, `path:line`, consistent or intermittent. If it cannot reproduce, gather the missing facts before going further. Append the repro to the brief.
4. **Hypotheses, only the lenses the symptom implicates, in ONE message (parallel, read-only).** Each returns ≤ 3 ranked hypotheses with evidence and the cheapest check that confirms or kills each:
   - **tech-lead** → integration, config, concurrency, recent-change causes.
   - **backend-dev** → only if server/data/logic is involved.
   - **frontend-dev** → only if the symptom is UI-side.
   - **qa** → which test was missing and how to capture the regression.
   A symptom that clearly lives in one layer needs one lens, not four.
5. **Converge.** Dedupe and rank. Confirm the top hypothesis with evidence you ran (a targeted check, a log, a failing test). If it dies, test the next; do not stop at a plausible story.
</workflow>

<delivery>
Report: the repro · **Root cause** (one paragraph, with the proving evidence pasted) · hypotheses considered and how each was killed · minimal fix (files, change) · regression test to add · **Decisions**. Hand off to `/squad:implement` with the failing test first.
</delivery>

<verification>
Run the checks; do not just claim them. The root cause is stated only after a check you executed shows it. If you could not prove it, say so and list what evidence is missing.
</verification>
