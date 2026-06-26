# squad — a role-based, stack-adaptive workflow for Claude Code

`squad` packages a complete development workflow as a Claude Code plugin: **plan → debug → implement → verify**. Each phase fans out to a team of specialist subagents (product owner, tech lead, frontend, backend, QA, tester, security/OWASP) that **detect your project's stack** — TypeScript, Vue, NestJS, Go, PHP, plain HTML/JS — and apply the right conventions and verify commands automatically.

One install serves every project. It composes with the official plugins you already have (superpowers, code-review, security-review, context7, playwright) instead of reinventing them.

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
| `/squad:plan <feature>` | Plan | Research + competitor benchmark, then PO / tech-lead / frontend / backend / QA design in parallel → a written, stack-aware implementation plan. |
| `/squad:debug <issue>` | Debug | Systematic debugging: reproduce first, then fan out root-cause hypotheses per lens, converge on the **proven** cause before any fix. |
| `/squad:implement <plan>` | Implement | Hybrid single-writer: design in parallel → write serially by file ownership with TDD → run the verify suite → fresh-context review gate. |
| `/squad:verify [scope]` | Verify | Full-squad parallel review (incl. security/OWASP) → one severity-ranked, high-signal GO / NO-GO. |

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

Seven specialist subagents (in `agents/`). Each has a focused persona, a least-privilege tool set, and is told to detect the stack and load `squad:stack-conventions` before giving stack-specific advice. Read-only by default; the writer agents only edit during `implement`, and only the paths they own.

| Agent | Model | Tools | Responsibility |
|---|---|---|---|
| `product-owner` | sonnet | Read, Grep, Glob, WebFetch, WebSearch, Skill | Requirements, user stories, acceptance criteria, competitor benchmarking, scope cuts |
| `tech-lead` | opus | Read, Grep, Glob, Bash, WebFetch, WebSearch, Skill | Stack detection, architecture, decomposition, file-ownership boundaries, trade-offs, risk |
| `frontend-dev` | sonnet | Read, Grep, Glob, Edit, Write, Bash, Skill | Vue / TS / HTML-JS UI, components, state (Pinia), a11y; writer for FE-owned paths |
| `backend-dev` | sonnet | Read, Grep, Glob, Edit, Write, Bash, Skill | NestJS / Go / PHP / Node APIs, data layer, business logic; writer for BE-owned paths |
| `qa` | sonnet | Read, Grep, Glob, Edit, Write, Bash, Skill | Test strategy, edge cases, coverage gaps; writes test files |
| `tester` | sonnet | Read, Grep, Glob, Bash, Skill | Runs the stack's lint/typecheck/test/build, reproduces bugs, reports pass/fail with evidence |
| `security-owasp` | opus | Read, Grep, Glob, Bash, Skill | OWASP Top 10 (2021) + API Top 10 (2023) review; runs scanners; confidence-filtered findings |

Models follow the wshobson/VoltAgent consensus (opus for architecture + security, sonnet for the rest) and use aliases — never pinned ids — so they never age. Override every subagent with `CLAUDE_CODE_SUBAGENT_MODEL` if you want.

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

- **Fan out for read-only breadth; single-writer for code.** Parallel *writer* agents corrupt shared state (Anthropic and Cognition both document this), so `implement` designs in parallel but writes serially by file ownership.
- **Deterministic commands**, not unreliable auto-routing — each command scripts exactly which agents run and in what order.
- **One adaptive agent set, not N-per-language** — agents detect the stack at runtime.
- **High signal** — reviews report only findings at confidence ≥ 80.

---

## Composes with

- **superpowers** — `brainstorming`, `writing-plans`, `systematic-debugging`, `test-driven-development`, `using-git-worktrees`, `verification-before-completion` are invoked by the phase commands.
- **code-review** + the built-in **`/security-review`** — used as gates in `implement`/`verify`.
- **context7** — live library docs during `plan`.
- **playwright** — browser testing in `verify`.
- **typescript-lsp / php-lsp** — language intelligence while editing.

---

## Per-project customization

Declare your stack and house rules in the project's `CLAUDE.md`. The `tech-lead` reads it and threads it into every delegation, so project conventions take precedence over the generic ones shipped here. No per-project agent files needed.

---

## Layout

```text
.claude-plugin/   plugin.json + marketplace.json
agents/           7 role subagents
commands/         4 phase orchestrators (plan, debug, implement, verify)
skills/stack-conventions/   SKILL.md + typescript, vue, nestjs, go, php, html-js
```

---

## Updating / developing

```text
# edit files in ~/projects/claude-squad, then:
git commit -am "…" && git push
/plugin update squad        # in Claude Code; restart to apply
```

Validate before pushing: `claude plugin validate ~/projects/claude-squad`. Inspect the component inventory + token cost: `claude plugin details squad`.

> Note: if `/plugin update` reports "Plugin not found" after a `marketplace update`, do a clean cycle: `claude plugin uninstall squad && claude plugin install squad@claude-squad`.

---

## Troubleshooting

- **Commands don't appear / "unknown command":** reload the window — a freshly installed plugin loads at the next session start.
- **`/squad:verify` vs the built-in `/verify`:** they coexist; the namespaced `/squad:verify` is this plugin's.
- **An agent didn't run the right verify commands:** make sure your stack is detectable (a `package.json` / `go.mod` / `composer.json`) or declared in `CLAUDE.md`.

---

## License

MIT.
