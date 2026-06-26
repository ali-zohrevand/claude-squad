---
name: stack-conventions
description: Per-technology conventions and the exact lint/typecheck/test/build commands the squad agents must run. Use when you need the idiomatic rules and verify commands for a project's stack (TypeScript, Vue, NestJS, Go, PHP, plain HTML/JS).
---

# Stack conventions

This skill carries the conventions and **verify commands** for each stack the squad supports. Don't apply generic advice — detect the project's actual stack, then read the matching file(s) below. A repo can be polyglot (e.g. a Vue frontend with a Go or NestJS backend); load every file that applies.

## How to detect the stack

Read-only signals, in priority order:

1. **`CLAUDE.md` / `README.md`** — a declared stack and house rules. **These override anything here** when they conflict.
2. **`package.json`** deps → `typescript` (`tsconfig.json`), `vue` → [vue.md](vue.md), `@nestjs/*` → [nestjs.md](nestjs.md), otherwise Node/plain JS → [html-js.md](html-js.md) + [typescript.md](typescript.md).
3. **`go.mod`** → [go.md](go.md). **`composer.json`** → [php.md](php.md).
4. Confirm with `nest-cli.json`, `vite.config.*`, `*.vue`, `phpstan.neon`, `.golangci.yml`, the test runner in use.

## Reconcile with the repo

The commands below are the standard for each stack, but **always prefer the repo's own configured scripts** when they exist (`package.json` scripts, `composer.json` scripts, `Makefile`, CI workflow) — they encode the real flags/paths. Use these files to know *what* to check (typecheck, lint, format, test, build) and fall back to these commands when the repo defines no script. If a tool isn't installed, say so and give the install command — never silently skip a gate.

## Files

- [typescript.md](typescript.md) — TypeScript (any TS project)
- [vue.md](vue.md) — Vue 3 SFC apps
- [nestjs.md](nestjs.md) — NestJS services
- [go.md](go.md) — Go modules
- [php.md](php.md) — modern PHP
- [html-js.md](html-js.md) — plain HTML + JS / Node
