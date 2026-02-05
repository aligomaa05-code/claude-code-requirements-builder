# QUICKSTART

An intelligent requirements gathering system for Claude Code that progressively builds context through automated discovery, generates comprehensive specs, and tracks implementation via TODO injection.

---

## 1. Clone & Verify

```bash
git clone https://github.com/YOUR_USERNAME/claude-code-requirements-builder.git
cd claude-code-requirements-builder
```

## 2. Run Tier-1 Checks

```bash
bash tests/check.sh
```

Expected output:
```
✅ All Tier-1 checks passed
```

This runs:
- **Drift Oracle** (35 checks): Schema consistency, command contracts, enum validation
- **Test Suite** (36 tests): Contract tests against example artifacts

## 3. Try It Out

In Claude Code, run:
```
/requirements-start user authentication
```

Then follow the prompts. Claude will ask discovery questions, analyze your codebase, and generate a requirements spec.

---

## Running Tests Against a Different Example

By default, tests run against `examples/2025-01-27-1430-user-authentication/`.

To use a different example directory:

```bash
EXAMPLE_DIR="/path/to/your/example" bash tests/check.sh
```

Or just the test suite:

```bash
EXAMPLE_DIR="/path/to/your/example" bash tests/run-tests.sh
```

---

## Command Reference (Quick)

| Command | What It Does |
|---------|--------------|
| `/requirements-start <description>` | Begin gathering requirements |
| `/requirements-status` | Check current progress |
| `/requirements-current` | View active requirement details |
| `/requirements-end` | Finalize the requirement |
| `/validate` | Check spec for ambiguity/gaps |
| `/inject-todos` | Insert TODO comments into codebase |
| `/todo-done TODO-001` | Mark a TODO as complete |
| `/verify` | Verify implementation matches spec |

---

## Deep Dive

For comprehensive documentation, recovery procedures, and edge cases:

📖 **[RUNBOOK_FINAL_vNEXT19_SHIP.md](./RUNBOOK_FINAL_vNEXT19_SHIP.md)**

---

## CI Status

This repo runs Tier-1 checks on every push and PR via GitHub Actions.

See: `.github/workflows/ci.yml`
