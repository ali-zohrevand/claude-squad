# TypeScript conventions

## Compiler / config

- `"strict": true` is the floor. Also enable what strict does NOT cover: **`noUncheckedIndexedAccess`**, **`exactOptionalPropertyTypes`**, `noImplicitOverride`, `noFallthroughCasesInSwitch`. Use `verbatimModuleSyntax` for clean ESM import/export.
- Target/module match the runtime; use `"moduleResolution": "bundler"` or `"nodenext"` as appropriate.

## Style

- **No `any`.** Prefer `unknown` at boundaries and narrow. Reserve `as` for genuinely unavoidable casts.
- Model state with **discriminated unions**; make switches exhaustive with a `never` default.
- Prefer `type`/`interface` over loose objects; type function signatures, not just variables.
- Prefer immutable data (`readonly`, `as const`) and pure functions; isolate side-effects.

## Tooling

- **ESLint flat config** (`eslint.config.js`) with `typescript-eslint` `strictTypeChecked` + `stylisticTypeChecked`, `parserOptions.projectService: true`.
- **Prettier** for formatting (don't let ESLint format).
- **Vitest** for new projects; Jest for legacy.

## Verify commands

```bash
tsc --noEmit                 # typecheck — a SEPARATE gate from lint
eslint .                     # lint (flat config)
prettier --check .           # format check (fail if non-empty)
vitest run --coverage        # or: jest --ci --coverage
```

Run the repo's own `npm run typecheck|lint|test|build` scripts when defined.
