# Vue 3 conventions

Pair with [typescript.md](typescript.md) — Vue projects are TS-first.

## Components

- **Composition API + `<script setup lang="ts">`** is the default.
- **Style Guide Priority A (essential):**
  - Multi-word component names (`TodoItem`, not `Todo`).
  - Detailed prop definitions with types + defaults; validate where it matters.
  - Always `:key` with `v-for`.
  - **Never** `v-if` and `v-for` on the same element.
  - Scoped styles (`<style scoped>`) or CSS modules — avoid leaking global styles from components.
- Keep components thin: presentation in the component, logic in **composables** (`useX()`), shared state in stores.
- Type `defineProps`/`defineEmits` with the generic form; use `withDefaults` for prop defaults.

## State — Pinia

- **Setup stores** (`defineStore('x', () => { ... })`); expose state via `ref`/`computed`, actions as functions.
- One store per domain; don't reach across stores for unrelated concerns.

## UX

- Handle loading / error / empty states explicitly. Accessibility: semantic elements, labels, keyboard support, focus management on route/modal changes.

## Verify commands

```bash
vue-tsc --noEmit             # typecheck SFCs (not plain tsc)
eslint .                     # eslint-plugin-vue + typescript-eslint
prettier --check .
vitest run                   # Vue Test Utils
playwright test              # e2e flows (when present)
```

Prefer the repo's `npm run` scripts when defined.
