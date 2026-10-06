# squad — a role-based, stack-adaptive workflow for Claude Code

`squad` packages a complete development workflow as a Claude Code plugin: **plan → debug → implement → verify**. Each phase dispatches only the specialist subagents that apply (product owner, tech lead, frontend, backend, QA, tester, security/OWASP). They **detect your project's stack** — TypeScript, Vue, NestJS, Go, PHP, plain HTML/JS — and apply the right conventions and verify commands automatically.

Every phase states its **goal**, the exact **deliverable**, the **verification it must run** (not claim), and when it may act on its own. Routine calls are made and logged in a one-line Decisions list, so a phase finishes instead of stopping to ask.

One install serves every project. It composes with the official plugins you already have (superpowers, code-review, security-review, context7, playwright) instead of reinventing them.

## Quick install

```text
/plugin marketplace add ali-zohrevand/claude-squad
/plugin install squad@claude-squad
```

Then reload Claude Code (Command Palette → "Developer: Reload Window"). Full details in [Install](#install).

> ⏳ **Coming to the Claude community directory.** Once approved, you'll also be able to install it directly: `/plugin marketplace add anthropics/claude-plugins-community` then `/plugin install squad@claude-community`.

---

## Table of contents

- [Install](#install)
- [Commands](#commands)
- [Examples](#examples)
- [The agents](#the-agents)
- [Stack conventions](#stack-conventions)
- [Design principles](#design-principles)
- [Composes with](#composes-with)
- [Per-project customization](#per-project-customization)
- [Layout](#layout)
- [Updating / developing](#updating--developing)
- [Troubleshooting](#troubleshooting)
- [License](#license)

---

## Install

```text
/plugin marketplace add ali-zohrevand/claude-squad
/plugin install squad@claude-squad
```

Then **reload Claude Code** (a new plugin's commands/agents load at session start): VS Code → Command Palette → "Developer: Reload Window"; CLI → `/exit` and relaunch.

Local development (before pushing changes):

```text
/plugin marketplace add ~/projects/claude-squad
/plugin install squad@claude-squad
# or one-off:  claude --plugin-dir ~/projects/claude-squad
```

---

## Commands

| Command | Phase | What it does |
|---|---|---|
| `/squad:plan <feature>` | Plan | Stack from injected context, one brief, then only the lenses that apply (PO / tech-lead / frontend / backend / QA) in parallel → a written plan with **Directions** (2–3 side by side, winner marked), build list with ownership, verify commands, and a Decisions log. |
| `/squad:debug <issue>` | Debug | Systematic debugging: reproduce first, then only the lenses the symptom implicates form ranked hypotheses, converge on the **proven** cause (evidence pasted) before any fix. |
| `/squad:implement <plan>` | Implement | Hybrid single-writer: brief once → design review in parallel → write serially by file ownership with TDD → verify suite in the background → fresh-context review gate. Before/after test output is part of the deliverable. |
| `/squad:verify [scope]` | Verify | Classify the diff without an agent, cost-gate, then only the lenses that apply in parallel → one severity-ranked, high-signal GO / NO-GO (also rendered via ReportFindings in the editor when available). |

---

## Examples

```text
/squad:plan add a "favorites" feature so users can bookmark cartoons
/squad:debug magic-link login intermittently returns ?err=link_invalid
/squad:implement docs/plans/favorites.md
/squad:verify                 # reviews the current git diff
/squad:verify src/payments    # scope to a subtree
```

Typical loop: `/squad:plan` → review the written plan → `/squad:implement` → `/squad:verify` before opening a PR. Use `/squad:debug` whenever something misbehaves.

---

## The agents

Seven specialist subagents (in `agents/`). Each has a focused persona, a least-privilege tool set, a turn cap, and a strict output cap. Each reads the phase's **brief** (one file the orchestrator writes once) instead of re-detecting the stack; only when no brief is given does it detect the stack and load `squad:stack-conventions` itself. Read-only by default; the writer agents only edit during `implement`, and only the paths they own.

| Agent | Model / effort | Max turns | Tools | Responsibility |
|---|---|---|---|---|
| `product-owner` | sonnet / medium | 20 | Read, Grep, Glob, WebFetch, WebSearch, Skill | Stories, acceptance criteria, cut list; benchmark only for novel user-facing features |
| `tech-lead` | opus / high | 30 | Read, Grep, Glob, Bash, WebFetch, WebSearch, Skill | Architecture anchored to real paths, directions, build list, file ownership, risk; single reviewer for small diffs. Keeps a project memory of the stack report |
| `frontend-dev` | sonnet / medium | 40 | Read, Grep, Glob, Edit, Write, Bash, Skill | Vue / TS / HTML-JS UI, state (Pinia), a11y; writer for FE-owned paths |
| `backend-dev` | sonnet / medium | 40 | Read, Grep, Glob, Edit, Write, Bash, Skill | NestJS / Go / PHP / Node APIs, data layer, logic; writer for BE-owned paths |
| `qa` | sonnet / medium | 30 | Read, Grep, Glob, Edit, Write, Bash, Skill | Test plan mapped to acceptance criteria; writes the failing tests first |
| `tester` | haiku | 20 | Read, Grep, Glob, Bash, Skill | Runs lint/typecheck/test/build in the background, reproduces bugs, reports pass/fail with output |
| `security-owasp` | opus / high | 30 | Read, Grep, Glob, Bash, Skill | OWASP Top 10 (2021) + API Top 10 (2023) + LLM-facing code; runs scanners; ≥ High-confidence findings only |

Aliases (`opus`/`sonnet`/`haiku`) are used, never pinned ids, so they never age. Every agent sets a 1-hour prompt-cache TTL (`experimental.cacheTtl`) so its system prompt stays cached across the plan → implement → verify loop on a subscription. See [Cost controls](#cost-controls).

> `tech-lead` uses `memory: project`, which stores its stack report under `.claude/agent-memory/tech-lead/` in your repo so later sessions skip re-detection. Remove that line from `agents/tech-lead.md` (or add the directory to `.gitignore`) if you'd rather not.

---

## Stack conventions

The `stack-conventions` skill (`skills/stack-conventions/`) holds the idiomatic rules **and the exact verify commands** per stack. Agents detect the stack and read the matching file; your project's `CLAUDE.md` overrides anything here.

| Stack | Verify commands the agents run |
|---|---|
| TypeScript | `tsc --noEmit` · `eslint .` · `prettier --check .` · `vitest run --coverage` |
| Vue 3 | `vue-tsc --noEmit` · `eslint .` · `vitest run` · `playwright test` |
| NestJS | `nest build` · `eslint .` · `jest --coverage` · `jest -c test/jest-e2e.json` |
| Go | `go build ./...` · `go vet ./...` · `gofmt -l .` · `staticcheck ./...` · `golangci-lint run` · `go test ./... -race -cover` |
| PHP | `phpstan analyse --level=max` · `phpunit --coverage-text` · `php-cs-fixer fix --dry-run --diff` · `composer validate` |
| HTML / JS | `eslint .` · `prettier --check .` · `node --test` / `vitest run` · `npx axe <url>` · `npx html-validate` |

Polyglot repos (e.g. Vue front + Go back) load multiple files automatically.

---

## Design principles

The working method lives in one shared skill, `squad:method` (`skills/method/SKILL.md`), loaded once per phase. It borrows from how Anthropic's design team describes its own process:

- **Shape before polish.** Settle the idea and the user outcome first; naming and style are the last pass.
- **Ask the review questions before designing.** Who is this for, what changes for them, does it need a new name or can it stay invisible?
- **Never start from nothing.** Every design is anchored to real paths in the repo; reuse is named before new code is proposed.
- **Go wide, then decide.** Real forks get 2–3 directions side by side with the winner marked and one line of why. The plan doubles as the decision log.
- **Restraint is taste.** Fewer files, fewer layers, fewer agents.
- **Every claim has a source.** Findings carry `path:line`, passes carry command output, numbers carry where they came from.
- **Run the checks; do not claim them.** Each command ends with a `<verification>` block that must be executed before "done".

Structural rules that follow from this:

- **Fan out for read-only breadth; single-writer for code.** Parallel *writer* agents corrupt shared state, so `implement` designs in parallel but writes serially by file ownership.
- **Deterministic commands**, not auto-routing — each command scripts which agents run, in what order, and under which conditions.
- **One adaptive agent set, not N-per-language** — agents read the stack from the brief, or detect it at runtime.
- **Autonomy with a log.** Routine calls are made, not asked, and written as one-line Decisions. A phase stops only for missing rights, unsafe actions, or an ambiguity that changes the goal.
- **High signal** — reviews report only findings at confidence ≥ 80.

---

## Cost controls

The fan-out phases (`verify`, `implement`) are the token-heavy ones. squad keeps them lean:

- **Stack detection is free.** Each command injects the manifests, scripts, and `CLAUDE.md` into its own context at load time (`!` dynamic context), so the orchestrator writes the stack report itself. No opus dispatch just to find `package.json`.
- **One brief, passed by path.** The orchestrator writes `squad-brief.md` (and `squad-diff.patch` for verify) to its scratchpad once and hands agents the path. The diff is never pasted into N delegation prompts, and agents skip re-detection and skill reloads when a brief exists.
- **Skip a lens before you shrink one.** `verify` classifies the diff without an agent, then cost-gates: docs-only → tester only; small single-domain → tester + tech-lead; fan-out only for large or multi-domain diffs. `plan`, `debug`, and `implement` dispatch only the lenses the change implicates.
- **Per-agent effort and turn caps.** `high` for tech-lead and security-owasp, `medium` for the rest, `haiku` for the mechanical tester, and a `maxTurns` on every agent so a confused agent returns partial instead of spending the budget.
- **Background + continue.** The tester runs with `run_in_background` while reviewers work. A failing check goes back to the **same** writer agent (context intact) rather than a fresh dispatch that re-reads the repo.
- **Cheaper model per dispatch.** Classification-only or mechanical tasks pass the Agent tool's `model` override (`sonnet`/`haiku`) regardless of the agent's default.
- **Summaries back, never code dumps.** Every agent has an output cap (~300 words or ≤ 10 ranked items).
- **1-hour prompt cache per agent.** `experimental.cacheTtl: 1h` keeps each agent's system prompt cached across phases within an hour on subscription plans.

Extra knobs: set `CLAUDE_CODE_SUBAGENT_MODEL=haiku` (or `sonnet`) to force **every** subagent onto a cheaper model for a session; scope a review with `/squad:verify <subdir>`; for tiny changes skip the squad and use the built-in `/code-review`. Inspect the plugin's own context cost with `claude plugin details squad` or `/skill-doctor`.

---

## Composes with

- **superpowers** — `brainstorming`, `writing-plans`, `systematic-debugging`, `test-driven-development`, `using-git-worktrees`, `verification-before-completion` are invoked by the phase commands.
- **code-review** + the built-in **`/security-review`** — used as gates in `implement`/`verify`.
- **context7** — live library docs during `plan`.
- **playwright** — browser testing in `verify`.
- **typescript-lsp / php-lsp** — language intelligence while editing.
- **Workflow tool (ultracode)** — if you've opted into multi-agent workflows, `verify`'s fan-out maps onto the pipeline pattern; otherwise the Agent tool is used.
- **ReportFindings** — `verify` also reports findings through the editor's findings UI when the tool is available.

---

## Per-project customization

Declare your stack and house rules in the project's `CLAUDE.md`. The `tech-lead` reads it and threads it into every delegation, so project conventions take precedence over the generic ones shipped here. No per-project agent files needed.

---

## Layout

```text
.claude-plugin/   plugin.json + marketplace.json
agents/           7 role subagents
commands/         4 phase orchestrators (plan, debug, implement, verify), each with goal / principles / inputs / workflow / delivery / verification blocks
skills/method/    the shared working method: principles, brief format, decision log, token rules, output caps
skills/stack-conventions/   SKILL.md + typescript, vue, nestjs, go, php, html-js
evals/            `claude plugin eval` cases (cost discipline of verify, anchoring of plan)
```

---

## Updating / developing

```text
# edit files in ~/projects/claude-squad, then:
git commit -am "…" && git push
/plugin update squad        # in Claude Code; restart to apply
```

Validate before pushing: `claude plugin validate ~/projects/claude-squad`. Inspect the component inventory + token cost: `claude plugin details squad`.

Run the eval suite (each case scaffolds a tiny repo and runs a real session, so it costs tokens):

```text
claude plugin eval ~/projects/claude-squad --scaffold --runs 1 --max-cost-usd 5
```

> Note: if `/plugin update` reports "Plugin not found" after a `marketplace update`, do a clean cycle: `claude plugin uninstall squad && claude plugin install squad@claude-squad`.

---

## Troubleshooting

- **Commands don't appear / "unknown command":** reload the window — a freshly installed plugin loads at the next session start.
- **`/squad:verify` vs the built-in `/verify`:** they coexist; the namespaced `/squad:verify` is this plugin's.
- **An agent didn't run the right verify commands:** make sure your stack is detectable (a `package.json` / `go.mod` / `composer.json`) or declared in `CLAUDE.md`.

---

## Contributing

Contributions welcome — new stack support, sharper agents, better commands, docs. See **[CONTRIBUTING.md](CONTRIBUTING.md)** for setup, house style, and the PR flow, and the **[Code of Conduct](CODE_OF_CONDUCT.md)**. Found a security issue? See **[SECURITY.md](SECURITY.md)**. Bugs and ideas → open an issue (templates provided).

## License

[MIT](LICENSE) © ali zohrevand.
