# Go conventions

Follow **Effective Go** + the Google Go Style Guide.

## Style

- Names: short, clear; no `Get` prefix on getters. **Accept interfaces, return concrete types.** Keep interfaces small and defined by the consumer.
- **Errors, not panics** for expected failures. Wrap with `fmt.Errorf("...: %w", err)`; inspect with `errors.Is` / `errors.As`; define sentinel errors (`var ErrNotFound = errors.New(...)`). Handle every error — no blank `_ =` on error returns without reason.
- Use `context.Context` as the first param for request-scoped work; honor cancellation.
- Concurrency: don't leak goroutines; protect shared state; prefer channels/`sync` primitives deliberately. Run with `-race`.

## Layout

- `golang-standards/project-layout` is **not** official — don't cargo-cult it. Start flat or feature-based; add `internal/` for non-exported packages and `cmd/<bin>/` for entrypoints only when you actually need them.

## Tests

- **Table-driven** tests with `t.Run(name, ...)`; add `t.Parallel()` where safe. Use `testdata/` for fixtures.

## Verify commands

```bash
go build ./...
go vet ./...
gofmt -l .                   # must print nothing (or: gofmt -w .)
goimports -l .
staticcheck ./...            # or: golangci-lint run
go test ./... -race -cover
govulncheck ./...            # dependency vulns
```

Prefer a repo `Makefile` target when present.
