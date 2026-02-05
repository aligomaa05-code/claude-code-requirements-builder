# Claude Requirements Gathering System

[![CI](https://github.com/aligomaa05-code/claude-code-requirements-builder/actions/workflows/ci.yml/badge.svg)](https://github.com/aligomaa05-code/claude-code-requirements-builder/actions/workflows/ci.yml)

A requirements gathering system for Claude Code with **contract-enforced validation** at every layer.

## Quick Start

```bash
git clone https://github.com/aligomaa05-code/claude-code-requirements-builder.git
cd claude-code-requirements-builder
bash scripts/install.sh
bash scripts/demo.sh
```

Then in Claude Code: `/requirements-start "your feature description"`

## What It Does

1. **Discovers** — AI analyzes your codebase, asks yes/no questions
2. **Documents** — Generates spec with Implementation Map
3. **Injects** — Creates scoped TODOs in your code (`[REQ:...] [ID:TODO-NNN] [P:N]`)
4. **Validates** — Checks spec for ambiguity, completeness, feasibility
5. **Verifies** — Confirms implementation matches plan


## Trust Ladder

Every PR runs through escalating validation tiers:

| Tier | Name | Checks | Script |
|------|------|--------|--------|
| 0 | Spec Lint | Command files exist, schema version | `drift-oracle.sh` |
| 1 | Schema + Invariants | 36 contract tests (T01-T27, I1-I9) | `run-tests.sh` |
| 2 | Output Validators | 5 artifact checks (O1-O5) on real files | `output-validators.sh` |
| 3 | Behavioral Oracle | 7 validators (V1-V7) on generated output | `e2e/run_e2e.sh` |
| 4 | Stress (future) | Mutation testing, adversarial inputs | — |

```bash
# Run all tiers locally
bash tests/check.sh                    # Tiers 0-2
E2E_RUNNER=fixture bash tests/e2e/run_e2e.sh  # Tier 3
```

CI runs Tiers 0-2 on every push/PR: [`.github/workflows/ci.yml`](.github/workflows/ci.yml)

## Commands

| Command | Purpose |
|---------|---------|
| `/requirements-start "desc"` | Begin new requirement |
| `/requirements-status` | Check progress |
| `/requirements-end` | Generate spec |
| `/validate` | Check spec quality |
| `/inject-todos` | Insert TODOs into code |
| `/todo-done TODO-001` | Mark complete |
| `/verify` | Validate implementation |
| `/remove-todos` | Clean up TODOs |

Full reference: [`docs/RUNBOOK.md`](docs/RUNBOOK.md)


## Project Structure

```
├── commands/           # 12 Claude command definitions
├── scripts/
│   ├── install.sh     # One-command installer
│   └── demo.sh        # One-command demonstration
├── tests/
│   ├── check.sh       # Tier-1 test harness
│   ├── run-tests.sh   # 36 contract tests
│   ├── drift-oracle.sh # Schema consistency
│   ├── output-validators.sh  # Artifact validation
│   └── e2e/           # Behavioral oracle
├── docs/
│   └── RUNBOOK.md     # Full step-by-step guide
└── examples/          # Reference implementation
```

## Installation Options

```bash
# Project-local (recommended)
bash scripts/install.sh

# Global (all projects)
bash scripts/install.sh --global

# Reinstall
bash scripts/install.sh --force
```

## License

MIT — see [LICENSE](LICENSE)
