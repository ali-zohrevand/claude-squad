#!/usr/bin/env bash
# A docs-only change in a tiny TypeScript repo. verify must not dispatch security-owasp.
set -e
git init -q .
printf '{"name":"demo","private":true,"scripts":{"typecheck":"tsc --noEmit","test":"node --test"},"devDependencies":{"typescript":"^5"}}\n' > package.json
printf '{"compilerOptions":{"strict":true,"noEmit":true}}\n' > tsconfig.json
mkdir -p src && printf 'export const add = (a: number, b: number): number => a + b;\n' > src/add.ts
printf '# demo\n' > README.md
git add -A && git -c user.email=e@x -c user.name=e commit -qm init
printf '# demo\n\nAdds two numbers.\n' > README.md
