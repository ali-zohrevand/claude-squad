---
description: PLAN phase — research + benchmark a feature, then fan out the squad (product-owner, tech-lead, frontend-dev, backend-dev, qa) in parallel to produce a written, stack-aware implementation plan.
argument-hint: <feature or problem to plan>
---

You are orchestrating the squad's **PLAN** phase for: **$ARGUMENTS**

This is read-only research and design — **no code is written**. Follow these steps.

## 1. Brainstorm intent (greenfield/ambiguous only)

If the request is open-ended, first run the `superpowers:brainstorming` skill to nail down intent and requirements before fanning out. Skip for a well-specified change.

## 2. Detect the stack

Dispatch the **tech-lead** subagent to detect the stack (read `CLAUDE.md`, `package.json`, `go.mod`, `composer.json`, etc.) and load the matching `squad:stack-conventions`. Capture the stack report — you will paste it into every other delegation so each specialist is stack-aware.

## 3. Fan out (parallel, read-only)

Dispatch these subagents **in a single message so they run concurrently**. Give each: the feature (`$ARGUMENTS`), the tech-lead's stack report, and the relevant project context.

- **product-owner** → problem, competitor/benchmark scan (web research), user stories, acceptance criteria, scope cuts.
- **tech-lead** (architecture pass) → where code lives, patterns/utilities to reuse (with paths), interfaces, decomposition with file-ownership boundaries, trade-offs + risks.
- **frontend-dev** → UI/UX approach and component/state plan (only if the feature has a frontend).
- **backend-dev** → API/data/logic approach (only if the feature has a backend).
- **qa** → test strategy mapping each acceptance criterion to test cases.

## 4. Synthesize

Reconcile the outputs (resolve any conflicts between PO scope and TL design — surface them, don't bury them). Then produce the plan via the `superpowers:writing-plans` skill: Context → approach → file-level changes (reusing existing code, cited by path) → task order with ownership → test strategy → verification commands (from stack-conventions) → open questions.

Present the plan and stop — do not start implementing. Suggest `/squad:implement` as the next step.
