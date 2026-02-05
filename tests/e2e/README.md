# E2E Behavioral Oracle

Tests that validate **generated outputs**, not documentation patterns.

## Purpose

The existing test suite (36 tests) validates that spec files contain expected text.
This E2E oracle validates that the actual workflow produces conformant artifacts.

## How It Works

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Runner    │ ──▶ │  Artifacts  │ ──▶ │  Validator  │
│ (LLM/Mock)  │     │  (JSON/MD)  │     │  (Checks)   │
└─────────────┘     └─────────────┘     └─────────────┘
```

1. **Runner**: Executes workflow (real LLM or fixture fallback)
2. **Artifacts**: Generated files in temp workspace
3. **Validator**: Schema + invariant + format checks

## Usage

```bash
# Default: fail-closed if no runner available
bash tests/e2e/run_e2e.sh

# Allow skip if no runner (for CI without LLM access)
E2E_ALLOW_SKIP=1 bash tests/e2e/run_e2e.sh

# Use fixture runner (validates the validator itself)
E2E_RUNNER=fixture bash tests/e2e/run_e2e.sh
```

## Runner Interface

The script checks for runners in order:
1. `claude` CLI (Anthropic Claude Code)
2. `E2E_RUNNER=fixture` (built-in test fixtures)
3. Fail-closed with `SKIP_BEHAVIORAL: no runner`

## Validations Performed

| Check | Description |
|-------|-------------|
| V1 | metadata.json is valid JSON with required fields |
| V2 | metadata._schema == "2.0" |
| V3 | Timestamps are ISO-8601 |
| V4 | Enum values are valid (status, phase, todos.status) |
| V5 | Invariant: todos.open + todos.done == todos.total |
| V6 | TODO format: [P:N] not [P:PN] |
| V7 | TODO IDs zero-padded (TODO-001) |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All checks passed |
| 1 | Validation failed |
| 2 | No runner available (fail-closed) |
| 77 | Skipped (E2E_ALLOW_SKIP=1, no runner) |

## Files

- `run_e2e.sh` - Main test harness
- `fixtures/` - Known-good outputs for validator testing
- `README.md` - This file
