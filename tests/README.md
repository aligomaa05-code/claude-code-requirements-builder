# Test Suite

Automated tests for claude-code-requirements-builder.

**Total: 36 tests** (T01-T27 + I1-I7 + I4b + I9)

## Quick Start

```bash
# Run all tests
./tests/run-tests.sh

# Run a single test
./tests/run-tests.sh T03
```

## Requirements

- `jq` - JSON processor (install: `brew install jq`)
- Bash 4+

## Test Categories

### T01-T06: TODO Format & Manifest
| Test | Description | Contract |
|------|-------------|----------|
| T01 | P1/P2 TODOs have 4-line format | C13 |
| T02 | P3 TODOs have 1-line format | C14 |
| T03 | Priority format is [P:N] not [P:PN] | C15 |
| T04 | TODO IDs are zero-padded (TODO-001) | C16 |
| T05 | Manifest file exists with structure | C17 |
| T06 | Manifest tracks ⬜/✅ markers | C17 |

### T07-T12: Validation
| Test | Description | Contract |
|------|-------------|----------|
| T07 | Quick mode runs lenses 1-2 only | C19 |
| T08 | Adversarial section in report | C19 |
| T09 | 3 adversarial personas defined | C20 |
| T10 | Score formula: 100-(blocking×15)-(warnings×5) | C21 |
| T11 | Pass gate: score≥70 AND blocking=0 | C22 |
| T12 | Fail gate: blocking>0 causes failure | C22 |

### T13-T18: Verification & Complexity
| Test | Description | Contract |
|------|-------------|----------|
| T13 | Verify only checks ✅ TODOs | C23 |
| T14 | PARTIAL when some need review | C24 |
| T15 | Remove accepts "injected"/"complete" | C26 |
| T16 | Remove requires confirmation | C25 |
| T17 | Simple = 3 discovery questions | C5 |
| T18 | Complex = 6-8 discovery questions | C5 |

### T19-T27: Schema & Cross-refs
| Test | Description | Contract |
|------|-------------|----------|
| T19 | Schema version 2.0 | C1 |
| T20 | ISO-8601 timestamps | C8 |
| T21 | Implementation Map exists | C9 |
| T22 | Status shows validation conditionally | C29 |
| T23 | Inject is idempotent | C31 |
| T24 | manifest.done = metadata.todos.done | C33 |
| T25 | New files have no imports | IR5 |
| T26 | Comment syntax adapts to extension | C30 |
| T27 | todos.status transition rule | H2 |

### I1-I7 + I4b + I9: Invariants (Cross-file Consistency)
| Test | Invariant |
|------|-----------|
| I1 | manifest.total = metadata.todos.total |
| I2 | manifest.✅count = metadata.todos.done |
| I3 | manifest.⬜count = metadata.todos.open |
| I4 | validation.warnings = [WARN-N] count in report |
| I4b | validation.blocking = [BLOCK-N] count in report |
| I5 | Implementation Map rows = manifest TODO count |
| I6 | questionCounts.discovery = progress.discovery.total |
| I7 | todos.open + todos.done = todos.total |
| I9 | todos.status = "complete" IFF todos.open = 0 |

## Adding New Tests

1. Create a function: `run_TXX() { ... }`
2. Use helper assertions:
   - `assert_file_exists <file> <test_id>`
   - `assert_grep <pattern> <file> <test_id>`
   - `assert_no_grep <pattern> <file> <test_id>`
   - `assert_grep_count <pattern> <file> <expected> <test_id>`
   - `assert_json_field <file> <jq_query> <expected> <test_id>`
   - `assert_valid_json <file> <test_id>`
   - `assert_numeric_eq <actual> <expected> <test_id>`
3. Call the function at the end: `run_TXX`

## Exit Codes

- `0` - All tests passed
- `1` - One or more tests failed
