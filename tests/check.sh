#!/bin/bash
# check.sh - Single entrypoint for all Tier-1 checks
# Usage: bash tests/check.sh
#
# Runs in order:
#   1. Drift Oracle (schema & contract consistency)
#   2. Test Suite (contract tests against example)
#
# Exit: 0 if all pass, non-zero on any failure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           claude-code-requirements-builder                   ║"
echo "║                   Tier-1 Checks                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Propagate EXAMPLE_DIR to child scripts if set
if [[ -n "${EXAMPLE_DIR:-}" ]]; then
    export EXAMPLE_DIR
    echo "Using EXAMPLE_DIR: $EXAMPLE_DIR"
    echo ""
fi

# Track overall status
FAILED=0

#######################################
# 1. Drift Oracle
#######################################
echo "▶ Running Drift Oracle..."
echo ""
if bash "$SCRIPT_DIR/drift-oracle.sh"; then
    echo ""
    echo "✓ Drift Oracle: PASSED"
else
    echo ""
    echo "✗ Drift Oracle: FAILED"
    FAILED=1
fi
echo ""

#######################################
# 2. Test Suite
#######################################
echo "▶ Running Test Suite..."
echo ""
if bash "$SCRIPT_DIR/run-tests.sh"; then
    echo ""
    echo "✓ Test Suite: PASSED"
else
    echo ""
    echo "✗ Test Suite: FAILED"
    FAILED=1
fi
echo ""

#######################################
# Summary
#######################################
echo "══════════════════════════════════════════════════════════════"
if [[ "$FAILED" -eq 0 ]]; then
    echo "✅ All Tier-1 checks passed"
    exit 0
else
    echo "❌ Some checks failed"
    exit 1
fi
