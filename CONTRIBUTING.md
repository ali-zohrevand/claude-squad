# Contributing to squad

Thanks for helping improve `squad` — a role-based, stack-adaptive workflow plugin for Claude Code. This guide gets you from clone to merged PR.

By participating you agree to the [Code of Conduct](CODE_OF_CONDUCT.md).

## Ways to contribute

- **New stack support** — add a `skills/stack-conventions/<lang>.md` (conventions + exact verify commands) for a language/framework not yet covered.
- **Improve an agent** — sharpen a persona's checklist, tools, or output contract in `agents/`.
- **Improve a phase command** — refine the orchestration in `commands/` (plan, debug, implement, verify).
- **Docs** — fix or expand the README / this guide.
- **Bugs & ideas** — open an issue (templates provided).

## Project layout

```text
.claude-plugin/   plugin.json + marketplace.json (the manifests)
agents/           7 role subagents (one .md per role)
commands/         4 phase orchestrators (plan, debug, implement, verify)
skills/stack-conventions/   SKILL.md (router) + one file per stack
```

## Local development setup

1. Fork and clone your fork.
2. Install it into Claude Code from your local checkout:
   ```text
   /plugin marketplace add /path/to/your/claude-squad
   /plugin install squad@claude-squad
   ```
   or run a one-off session: `claude --plugin-dir /path/to/your/claude-squad`.
3. After editing files, reload Claude Code (Command Palette → "Developer: Reload Window") so changes load.

## House style (match the existing files)

- **Agents** — YAML frontmatter (`name`, `description`, `tools`, `model`, `color`) then a body of: persona → "When invoked" steps → stack-aware checklist → output contract. Keep `description` a *triage rule* (when to use). Least-privilege `tools`. Models use **aliases** (`opus`/`sonnet`) — never a pinned model id.
- **Commands** — frontmatter (`description`, `argument-hint`); the body scripts the fan-out (which agents, in what order) and references `$ARGUMENTS`.
- **stack-conventions** — each language file lists idiomatic rules **and the exact verify commands** an agent must run; prefer the repo's own scripts when present.
- Keep the design principles intact: **fan out for read-only phases, single-writer for code**; deterministic commands over auto-routing; compose with existing plugins rather than reinventing.

## Validate before you push

```bash
claude plugin validate /path/to/your/claude-squad   # manifests must pass
claude plugin details squad                          # check the component inventory loads
```

Then smoke-test the changed command/agent in a real project (e.g. run `/squad:verify` and confirm the right stack/verify commands are chosen).

## Submitting a PR

1. Branch from `main`: `git checkout -b feat/<short-name>`.
2. Make focused changes; keep PRs scoped to one thing.
3. If you change the plugin's surface, **bump the `version`** in `.claude-plugin/plugin.json` (semver) and keep `marketplace.json` consistent.
4. Use clear commit messages (e.g. `feat: add Kotlin stack-conventions`, `fix: tech-lead stack detection for monorepos`).
5. Run the validation above and note what you tested in the PR description.
6. Open the PR against `ali-zohrevand/claude-squad:main` using the PR template.

A maintainer will review for correctness, house-style fit, and that it doesn't regress the core principles. Thanks again!
