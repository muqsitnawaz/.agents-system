# Strict Testing

- **Test file = source file, 1:1.** Name mirrors the source: `read.go` → `read_test.go`, `parser.ts` → `parser.test.ts`. One source, one test file.
- **Tests live in the codebase, not `/tmp`.** Fixtures in `testdata/` near source.
- **No mocking.** Real services only. Tests must exercise the actual critical path.
- **Only write tests that catch real bugs:** merge logic, state corruption, edge cases in algorithms. Skip tests that verify constants or trivial guards — if the test would pass with a broken implementation, it's ceremony.
- **Unit tests are necessary but not sufficient.** Verify the feature works end-to-end before claiming done (see `core-hard-lines.md` rule #1).

## Design before code

Before writing code that changes how something works or looks, show the design. Use the right diagram for the situation:

- **User flow** — screens, clicks, transitions (UI changes)
- **System diagram** — components, data flow, request paths (architecture changes)
- **Data flow** — transformations, storage, handoffs (pipeline changes)
- **Before/after** — current vs. proposed (any change with tradeoffs)

Show the full context, not just the new piece. The diagram is the spec; implementation details come after the user approves.
