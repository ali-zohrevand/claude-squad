# Plain HTML / JS / Node conventions

For projects without a frontend framework, and Node libraries/scripts. If TypeScript is present, also see [typescript.md](typescript.md).

## HTML & accessibility

- **Semantic HTML**: real `<button>`/`<nav>`/`<main>`/`<label>`, headings in order, `lang` on `<html>`.
- Accessibility: `alt` on images, labels tied to inputs, keyboard operability, visible focus, sufficient color contrast. Add ARIA only to fill real gaps — correct minimal ARIA beats lots of wrong ARIA.
- Progressive enhancement: core content/works without JS where feasible.

## JavaScript

- **ES modules** (`import`/`export`); `const`/`let`, never `var`; strict equality (`===`).
- Small pure functions; avoid global state; handle async errors (no unhandled rejections).
- For Node: target a supported LTS; prefer `node:`-prefixed core imports; `eslint-plugin-n` for Node rules.

## Tooling & tests

- **ESLint flat config**; **Prettier** for formatting.
- Tests: `node:test` for libraries/scripts; **Vitest** for apps/bundled code.

## Verify commands

```bash
eslint .
prettier --check .
node --test                  # or: vitest run --coverage
npx axe <url>                # accessibility (when serving a page)
npx html-validate "**/*.html"
```

Prefer the repo's `npm run` scripts when defined.
