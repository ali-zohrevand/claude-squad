---
description: VERIFY phase — fan out the full squad (PO, tech-lead, frontend, backend, QA+tester, security/OWASP) in parallel to review the change from every lens, then consolidate into one severity-ranked, high-signal report.
argument-hint: [scope — defaults to the current git diff]
---

You are orchestrating the squad's **VERIFY** phase. Scope: **$ARGUMENTS** (default: unstaged + staged changes from `git diff`).

Read-only, parallel review. Goal: a single, trustworthy go/no-go with only findings that matter.

## 1. Detect the stack

Dispatch **tech-lead** to detect the stack and load `squad:stack-conventions`. Capture the stack report + the exact verify commands for this repo; pass them to the relevant reviewers.

## 2. Fan out (parallel, read-only — one message)

- **product-owner** → does the change meet the acceptance criteria? (MET/NOT MET per criterion). If no criteria exist, infer them from `CLAUDE.md`/the request and say so.
- **tech-lead** → architecture & code quality: conventions adherence, reuse vs duplication, complexity, maintainability.
- **frontend-dev** → UX/correctness of UI changes; use `playwright` to drive the app for user-facing flows when applicable.
- **backend-dev** → API contracts, data integrity, error handling, performance hot spots.
- **tester** → run the stack verify suite (typecheck, lint, format, tests, build) and report PASS/FAIL with output.
- **qa** → coverage gaps: what behavior/edge case is untested.
- **security-owasp** → OWASP Top 10 (2021) + API Top 10 (2023) audit + available scanners. Optionally also run the built-in `/security-review` as a deterministic second gate.

## 3. Consolidate

Merge and dedupe findings into ONE report, grouped by severity (Critical → High → Medium). **Keep signal high: only include findings at confidence ≥ 80** (drop nitpicks and theoretical issues). For each: `path:line`, what's wrong, why it matters, concrete fix. End with a clear **GO / NO-GO** and, if no-go, the ordered list of blockers.
