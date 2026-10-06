---
description: VERIFY phase — review a change from every lens that applies (tech-lead, tester, and conditionally PO, frontend, backend, QA, security/OWASP) in parallel, then consolidate into one severity-ranked, high-signal GO / NO-GO.
argument-hint: [scope — path, ref range, or empty for the current diff]
---

You are orchestrating the squad's **VERIFY** phase. Scope: **$ARGUMENTS** (default: staged + unstaged changes plus unpushed commits).

<goal>
One trustworthy GO / NO-GO with only findings that matter, each with `path:line`, why it matters, and a concrete fix. A long list of nitpicks is not the deliverable.
</goal>

<principles>
Load `squad:method` once and follow it. Skip a lens before you shrink one. Every finding has a source. Make routine calls yourself and log them under Decisions.
</principles>

<inputs>
Already read for you; do not dispatch an agent to rediscover them:
- Manifests present: !`ls package.json go.mod composer.json nest-cli.json phpstan.neon .golangci.yml 2>/dev/null | tr '\n' ' '`
- Scripts: !`node -e "try{console.log(Object.keys(require('./package.json').scripts||{}).join(' '))}catch(e){}" 2>/dev/null`
- Changed files: !`git diff --stat HEAD 2>/dev/null | tail -25`
- Unpushed commits: !`git log --oneline @{upstream}..HEAD 2>/dev/null | head -10`
- House rules: !`head -40 CLAUDE.md 2>/dev/null || echo '(no CLAUDE.md)'`
</inputs>

<workflow>
1. **Classify (you, not an agent).** From the changed files decide which areas are touched: frontend, backend, tests, docs-only, and security-sensitive (auth, data access, input handling, secrets, external/LLM calls). Write the stack report from the signals above.
2. **Brief.** Capture the diff once (`git diff HEAD` plus `git diff @{upstream}..HEAD` when there are unpushed commits, or the diff for the given scope) into `squad-diff.patch` in your scratchpad, and write `squad-brief.md` next to it with the stack, verify commands, touched areas, and acceptance criteria if a plan exists. Pass both paths; never paste the diff into delegations.
3. **Cost gate.** Small and single-domain (one area, a handful of files): dispatch **tester** in the background and **tech-lead** as the single reviewer, then go to step 5. Docs-only or pure formatting: tester only. Fan out only when the diff is large or spans domains.
4. **Fan out, only the lenses that apply, in ONE message (parallel, read-only).**
   - **tester** → always, `run_in_background`: run the verify suite, PASS/FAIL with output.
   - **tech-lead** → always: correctness, conventions, reuse vs duplication, complexity.
   - **product-owner** → only if acceptance criteria exist or the change is user-facing: MET / NOT MET per criterion.
   - **frontend-dev** → only if frontend files changed; use `playwright` for user-facing flows when available.
   - **backend-dev** → only if backend files changed: contracts, data integrity, error handling, hot spots.
   - **qa** → only if logic changed: which edge case is untested.
   - **security-owasp** → only if security-sensitive code changed. Optionally also run the built-in `/security-review` as a second gate.
   Agents run at their pinned effort; do not raise it unless a finding needs deeper analysis. If the user has opted into multi-agent workflows (ultracode / "use a workflow"), the Workflow tool's pipeline pattern fits this fan-out; otherwise use the Agent tool.
5. **Consolidate.** Collect the background tester result. Merge and dedupe into ONE report by severity (Critical → High → Medium), confidence ≥ 80 only. If the `ReportFindings` tool is available, also report the findings through it so the editor renders them.
</workflow>

<delivery>
Report: verify table (PASS/FAIL per command) · findings, each `path:line` · what is wrong · why it matters · concrete fix · acceptance verdicts when criteria exist · **GO / NO-GO** with the ordered blockers if no-go · **Decisions** (which lenses were skipped and why).
</delivery>

<verification>
Every finding cites a line that exists in the diff; every PASS cites command output from tester, not a claim. A NO-GO names at least one blocker a writer can act on.
</verification>
