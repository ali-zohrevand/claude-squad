<!-- Thanks for contributing to squad! Keep PRs focused on one change. -->

## What & why

<!-- What does this change and what problem does it solve? -->

## Type

- [ ] New stack-conventions (language/framework)
- [ ] Agent change
- [ ] Command change
- [ ] Docs
- [ ] Other

## Checklist

- [ ] Follows the house style in [CONTRIBUTING.md](../CONTRIBUTING.md) (frontmatter, persona structure, model aliases, least-privilege tools)
- [ ] `claude plugin validate .` passes
- [ ] Smoke-tested the affected command/agent in a real project (describe below)
- [ ] Bumped `version` in `.claude-plugin/plugin.json` if the plugin surface changed
- [ ] Keeps the core principles intact (fan-out for read-only phases, single-writer for code, deterministic commands)

## How I tested

<!-- Which command/agent, on what kind of project, and what you observed. -->
