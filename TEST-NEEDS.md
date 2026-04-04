# TEST-NEEDS.md — pandoc-k9

## CRG Grade: C — ACHIEVED 2026-04-04

> Generated 2026-03-29 by punishing audit.

## Current State

| Category     | Count | Notes |
|-------------|-------|-------|
| Unit tests   | 0     | None |
| Integration  | 1     | src/interface/ffi/test/integration_test.zig |
| E2E          | 0     | None |
| Benchmarks   | 0     | None |

**Source modules:** 4 Lua files (K9 pandoc filter, reader, writer, filter) + 3 Idris2 ABI + 1 Zig FFI + 1 ReScript.

## What's Missing

### P2P (Property-Based) Tests
- [ ] K9 reader: arbitrary K9 contract document parsing
- [ ] K9 writer: output format validity property tests
- [ ] Roundtrip: read -> write -> read = identity

### E2E Tests
- [ ] Full conversion: K9 input -> pandoc filter -> target format
- [ ] All supported output formats
- [ ] K9 contract validation through filter

### Aspect Tests
- **Security:** No tests for injection through K9 content, Lua sandbox escape
- **Performance:** No conversion benchmarks
- **Concurrency:** N/A
- **Error handling:** No tests for malformed K9, invalid contracts, encoding issues

### Build & Execution
- [ ] Pandoc filter execution test
- [ ] Zig FFI test
- [ ] Lua syntax validation

### Benchmarks Needed
- [ ] Conversion throughput
- [ ] Memory usage per document size

### Self-Tests
- [ ] Filter can process its own K9 documentation

## Priority

**HIGH.** Same story as pandoc-a2ml: 4 Lua modules, ZERO unit tests. The FFI integration test does not test the core Lua filter logic. Roundtrip testing is mandatory for any document converter.

## FAKE-FUZZ ALERT

- `tests/fuzz/placeholder.txt` is a scorecard placeholder inherited from rsr-template-repo — it does NOT provide real fuzz testing
- Replace with an actual fuzz harness (see rsr-template-repo/tests/fuzz/README.adoc) or remove the file
- Priority: P2 — creates false impression of fuzz coverage
