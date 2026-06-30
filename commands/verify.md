---
description: VERIFY phase — fan out the full squad (PO, tech-lead, frontend, backend, QA+tester, security/OWASP) in parallel to review the change from every lens, then consolidate into one severity-ranked, high-signal report.
argument-hint: [scope — defaults to the current git diff]
---

You are orchestrating the squad's **VERIFY** phase. Scope: **$ARGUMENTS** (default: unstaged + staged changes from `git diff`).

Read-only, parallel review. Goal: a single, trustworthy go/no-go with only findings that matter.

## 1. Detect stack + scope the review (one cheap pass — controls cost)

Dispatch **tech-lead** to detect the stack (load `squad:stack-conventions`) **and classify the changed files** so we only spend tokens on lenses that apply. Capture: the stack report, the exact verify commands for this repo, and which of these are touched — frontend files, backend files, tests, and security-sensitive code (auth, data access, input handling, secrets, external/LLM calls). Pass this to the fan-out.

## 2. Fan out — only the lenses that apply (parallel, read-only, one message)

Dispatch **only** the relevant agents (skipping a lens is the biggest cost saving — don't run all seven on a one-file change):

- **tester** → always. Run the stack verify suite (typecheck, lint, format, tests, build) and report PASS/FAIL with output.
- **tech-lead** → always. Architecture & code quality: conventions adherence, reuse vs duplication, complexity, maintainability.
- **product-owner** → only if acceptance criteria exist or the change is user-facing. Does it meet them? (MET/NOT MET per criterion.)
- **frontend-dev** → only if frontend files changed. UX/correctness; use `playwright` for user-facing flows when applicable.
- **backend-dev** → only if backend files changed. API contracts, data integrity, error handling, performance hot spots.
- **qa** → only if logic/behavior changed (skip for pure styling/docs). Coverage gaps: what edge case is untested.
- **security-owasp** → only if security-sensitive code changed. OWASP Top 10 (2021) + API Top 10 (2023) + scanners. Optionally also run the built-in `/security-review` as a deterministic second gate.

Agents run at the effort pinned in their frontmatter (tester on the cheap `haiku` tier; advisory roles `medium`; tech-lead/security `high`) — don't raise it unless a finding needs deeper analysis.

## 3. Consolidate

Merge and dedupe findings into ONE report, grouped by severity (Critical → High → Medium). **Keep signal high: only include findings at confidence ≥ 80** (drop nitpicks and theoretical issues). For each: `path:line`, what's wrong, why it matters, concrete fix. End with a clear **GO / NO-GO** and, if no-go, the ordered list of blockers.
