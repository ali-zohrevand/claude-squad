# squad — a role-based, stack-adaptive workflow for Claude Code

`squad` packages a complete development workflow as a Claude Code plugin: **plan → debug → implement → verify**. Each phase fans out to a team of specialist subagents (product owner, tech lead, frontend, backend, QA, tester, security/OWASP) that **detect your project's stack** — TypeScript, Vue, NestJS, Go, PHP, plain HTML/JS — and apply the right conventions and verify commands automatically.

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
| `tester` | haiku | Read, Grep, Glob, Bash, Skill | Runs the stack's lint/typecheck/test/build, reproduces bugs, reports pass/fail with evidence |
| `security-owasp` | opus | Read, Grep, Glob, Bash, Skill | OWASP Top 10 (2021) + API Top 10 (2023) review; runs scanners; confidence-filtered findings |

**Models & effort are tuned for cost.** Each agent pins a reasoning `effort` so it doesn't inherit an expensive session default: `high` for the deep roles (tech-lead, security-owasp), `medium` for the advisory/writer roles, and the mechanical `tester` runs on the cheap **haiku** tier (which has no effort knob). Aliases (`opus`/`sonnet`/`haiku`) are used — never pinned ids — so they never age. See [Cost controls](#cost-controls).

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

## Cost controls

The fan-out phases (`verify`, `implement`) are the token-heavy ones. squad keeps them lean three ways:

- **Per-agent effort.** Every agent pins an `effort` (`high` for tech-lead + security-owasp, `medium` for the rest) so it doesn't inherit an expensive session-wide `xhigh`/`max`. Lower effort = far fewer thinking tokens. Raise an agent's `effort` in its frontmatter only if you need deeper analysis.
- **Cheap mechanical tier.** `tester` runs on **haiku** — it just executes lint/test/build and reports, no deep reasoning needed.
- **Conditional fan-out.** `verify` and `implement` first do one cheap `tech-lead` pass to classify the change, then dispatch **only the lenses that apply** (no frontend reviewer for a backend-only diff, no security pass unless security-sensitive code changed), and for a small/single-domain change they skip the fan-out entirely and use one reviewer. Skipping a lens is the single biggest saving — a one-file change might run two agents, not seven.
- **Context passed once, summaries back.** The orchestrator extracts the diff/design once and passes it inline to each agent (instead of every agent re-running `git diff` and re-reading the repo in its own fresh context), and each agent returns a short severity-ranked summary rather than the code it read.

Extra knobs: set `CLAUDE_CODE_SUBAGENT_MODEL=haiku` (or `sonnet`) to force **every** subagent onto a cheaper model for a session; scope a review with `/squad:verify <subdir>` instead of the whole diff; and for tiny changes, skip the squad and use the built-in `/code-review` directly.

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

## Contributing

Contributions welcome — new stack support, sharper agents, better commands, docs. See **[CONTRIBUTING.md](CONTRIBUTING.md)** for setup, house style, and the PR flow, and the **[Code of Conduct](CODE_OF_CONDUCT.md)**. Found a security issue? See **[SECURITY.md](SECURITY.md)**. Bugs and ideas → open an issue (templates provided).

## License

[MIT](LICENSE) © ali zohrevand.
