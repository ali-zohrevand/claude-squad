# PHP conventions

## Standards & language

- **PSR-1 / PSR-4 (autoload) / PSR-12 → PER-CS** coding style.
- Modern PHP 8.x: `declare(strict_types=1);` at the top of every file; typed properties; **constructor property promotion**; `readonly` props; **enums**; `match` over long `switch`; named args where they aid clarity; first-class callable syntax.
- **No closing `?>`** in PHP-only files (trailing whitespace breaks headers/JSON — this is a hard rule in repos like cartoonicate).

## Architecture

- Keep data access behind a **Manager / repository class** — no inline SQL in endpoints/controllers/pages. Use **prepared statements with named parameters** (`:name`), never string-concatenated queries.
- Provider/driver abstractions behind interfaces; callers depend on the interface, not the SDK.
- Errors: catch `\Throwable`, **log class + message + stack** via the project logger, then degrade gracefully — never an empty catch or `@` suppression.
- Money in integer cents; secrets from config/env, never hardcoded.

## Static analysis & tests

- **PHPStan level max** (or Psalm) — treat findings as gates.
- **PHPUnit** with attributes (`#[Test]`, `#[DataProvider]`); prefer the project's offline/fake adapters in tests.

## Verify commands

```bash
phpstan analyse --level=max          # or per phpstan.neon
psalm                                 # if configured instead
phpunit --coverage-text
php-cs-fixer fix --dry-run --diff     # or: phpcs
composer validate
composer audit                        # dependency vulns
```

Prefer the repo's `composer` scripts / configured levels when present.
