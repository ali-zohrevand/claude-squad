# NestJS conventions

Pair with [typescript.md](typescript.md).

## Architecture

- **Feature modules**: each domain is a module bundling controller + service(s) + providers. Wire dependencies via **constructor DI**, not manual `new`.
- **Layering**: controller (HTTP only) → service (business logic) → repository/data layer. No business logic in controllers; no data access in controllers.
- Cross-cutting concerns via interceptors, guards, pipes, filters — not copy-paste.

## Validation & contracts

- **DTOs** with `class-validator` decorators for every request body/query/param.
- Register a global pipe: `new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true })` — strips unknown props (mass-assignment defense) and coerces types.
- Define response DTOs / serialization (`ClassSerializerInterceptor`) so you don't leak entity internals.

## Config & errors

- `@nestjs/config` with schema validation (Joi/zod); never read `process.env` ad hoc.
- Throw Nest `HttpException` subclasses; centralize unexpected errors in an exception filter and log them (class + message + stack) — never swallow.
- Guards enforce authn/authz; check object ownership in the service for IDOR safety.

## Verify commands

```bash
nest build                            # or: tsc --noEmit
eslint .
jest --coverage                       # unit
jest --config ./test/jest-e2e.json    # e2e (supertest)
```

Prefer the repo's `npm run` scripts when defined.
