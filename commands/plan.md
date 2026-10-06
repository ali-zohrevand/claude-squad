---
description: PLAN phase — turn a feature into a written, stack-aware implementation plan. Cheap stack detection from injected context, then only the lenses that apply (product-owner, tech-lead, frontend-dev, backend-dev, qa) in parallel, reconciled into one plan with directions, decisions, and verification commands.
argument-hint: <feature or problem to plan>
---

You are orchestrating the squad's **PLAN** phase for: **$ARGUMENTS**

<goal>
A written plan a single writer could follow without asking questions. Read-only: no product code is written. A list of ideas, a survey of options, or a plan with "TBD" in it is not the deliverable.
</goal>

<principles>
Load `squad:method` once (Skill tool) and follow it: shape before polish, ask the review questions first, never start from nothing, go wide then decide, restraint. Make routine calls yourself and log them under Decisions.
</principles>

<inputs>
Stack signals (already read for you; do not dispatch an agent to rediscover them):
- Manifests present: !`ls package.json go.mod composer.json nest-cli.json vite.config.ts vite.config.js phpstan.neon .golangci.yml pyproject.toml 2>/dev/null | tr '\n' ' '`
- package.json deps: !`node -e "try{const p=require('./package.json');console.log(Object.keys({...p.dependencies,...p.devDependencies}).join(' '))}catch(e){console.log('(none)')}" 2>/dev/null`
- Scripts: !`node -e "try{console.log(Object.keys(require('./package.json').scripts||{}).join(' '))}catch(e){}" 2>/dev/null`
- House rules (CLAUDE.md, first 60 lines): !`head -60 CLAUDE.md 2>/dev/null || echo '(no CLAUDE.md)'`
</inputs>

<workflow>
1. **Intent (open-ended requests only).** If the request is vague, run `superpowers:brainstorming` to settle the one-sentence idea and the user outcome. Skip for a well-specified change.
2. **Brief.** From the stack signals, write the stack report yourself (languages, frameworks, key dirs, verify commands from the repo's scripts, else from `squad:stack-conventions`). Write `squad-brief.md` to your scratchpad with the stack, the request, and the one question the feature answers. Pass its path to every agent.
3. **Fan out, only the lenses that apply, in ONE message (parallel, read-only).**
   - **product-owner** → stories, acceptance criteria, cut list. Benchmark only if user-facing and novel.
   - **tech-lead** → approach anchored to real paths, directions table for any fork, build list with file ownership, risks.
   - **frontend-dev** → only if there is UI work. **backend-dev** → only if there is server/data work.
   - **qa** → test strategy mapping each acceptance criterion to a case.
   A small, single-domain feature needs tech-lead + qa, not five agents.
4. **Synthesize.** Reconcile PO scope with TL design; surface conflicts, do not bury them. Produce the plan via `superpowers:writing-plans`.
</workflow>

<delivery>
The plan document contains, in order: one-sentence idea and user outcome · stack report · **Directions** (2 or 3 side by side, winner marked, why) · approach with file-level changes citing existing code by path · build list with ownership and sequential/independent marks · acceptance criteria · test strategy · exact verification commands · **Decisions** (one line each) · open questions for a human. If the plan will be shared with a team, offer to publish it as an Artifact page.
</delivery>

<verification>
Before presenting: every "reuse X" names a real path (check with Glob); every verify command exists in the repo's scripts or the conventions file; no "TBD". Then present the plan and stop. Suggest `/squad:implement <plan path>`.
</verification>
