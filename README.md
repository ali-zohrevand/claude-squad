# squad — a role-based, stack-adaptive workflow for Claude Code

`squad` packages a four-phase development workflow as a Claude Code plugin: **plan → debug → implement → verify**. Each phase fans out to a team of specialist subagents (product owner, tech lead, frontend, backend, QA, tester, security/OWASP) that **detect your project's stack** (TypeScript, Vue, NestJS, Go, PHP, plain HTML/JS) and apply the right conventions and verify commands automatically.

It works across every project from a single install, and composes with the official plugins you already have (superpowers, code-review, security-review, context7, playwright) instead of reinventing them.

## Install

```text
/plugin marketplace add ali-zohrevand/claude-squad
/plugin install squad@claude-squad
```

Local development (before pushing):

```text
/plugin marketplace add ~/projects/claude-squad
/plugin install squad@claude-squad
# or: claude --plugin-dir ~/projects/claude-squad
```

## Commands

| Command | Phase | What it does |
|---|---|---|
| `/squad:plan <feature>` | Plan | Research + competitor benchmark, then PO/tech-lead/frontend/backend/QA design in parallel → a written, stack-aware plan. |
| `/squad:debug <issue>` | Debug | Systematic debugging: reproduce, then fan out root-cause hypotheses per lens, converge on the proven cause. |
| `/squad:implement <plan>` | Implement | Hybrid single-writer: parallel design → serial writing by file ownership with TDD → verify suite → fresh-review gate. |
| `/squad:verify [scope]` | Verify | Full-squad parallel review (incl. OWASP) → one severity-ranked, high-signal go/no-go. |

## Design principles

- **Fan out for read-only breadth, single-writer for code.** Parallel *writer* agents corrupt shared state, so `implement` designs in parallel but writes serially by file ownership.
- **Phases are deterministic commands**, not unreliable auto-routing — each command scripts exactly which agents run and in what order.
- **One adaptive agent set, not N-per-language.** Agents detect the stack and read `skills/stack-conventions/<lang>.md` for the rules + exact verify commands; your project's `CLAUDE.md` overrides generic conventions.
- **High signal.** Reviews report only findings at confidence ≥ 80; the security agent mirrors Anthropic's security-review false-positive filtering.

## Layout

```
.claude-plugin/   plugin.json + marketplace.json
agents/           7 role subagents
commands/         4 phase orchestrators
skills/stack-conventions/   SKILL.md + per-language conventions & verify commands
```

## Customizing per project

Declare your stack and house rules in the project's `CLAUDE.md` — the `tech-lead` reads it and threads it into every delegation, so project conventions take precedence over the generic ones shipped here. Polyglot repos load multiple conventions files automatically.
