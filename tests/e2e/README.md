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

# Use real Claude CLI (local testing only)
E2E_RUNNER=claude bash tests/e2e/run_e2e.sh
```

## Real Runner Mode

The `E2E_RUNNER=claude` mode uses the Claude CLI to generate actual artifacts, providing true behavioral validation.

### Requirements

1. **Claude CLI installed**: `npm install -g @anthropic-ai/claude-cli` or `brew install claude`
2. **Authenticated**: `claude auth login`

### What It Does

1. Creates a temporary workspace with a minimal mock codebase
2. Invokes `claude -p` with a structured prompt to generate:
   - `metadata.json` (schema 2.0 compliant)
   - `sample-code.ts` (with TODO markers)
3. Runs validators V1–V7 on the generated output
4. Cleans up temp workspace

### What It Validates

- The LLM can produce schema-compliant `metadata.json`
- Generated TODOs follow correct format (`[P:N]`, zero-padded IDs)
- Invariants hold (e.g., `todos.open + todos.done == todos.total`)

### What It Does NOT Validate

- Full slash-command workflow (requires interactive Claude Code session)
- Multi-phase discovery process
- File injection into actual codebase

### Failure Modes

| Symptom | Cause | Fix |
|---------|-------|-----|
| Exit 2: "CLI not found" | Claude CLI not installed | Install and authenticate |
| Exit 1: "Could not extract JSON" | LLM output unparseable | Check prompt or retry |
| Exit 1: Validator failure | LLM produced non-conformant output | Review generated artifacts |

## Runner Interface

Runner selection logic:
1. `E2E_RUNNER=fixture` → use fixture data
2. `E2E_RUNNER=claude` → use Claude CLI (fail-closed if missing)
3. Auto-detect: prefer `claude` CLI if available
4. Fail-closed with `SKIP_BEHAVIORAL: no runner`

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
