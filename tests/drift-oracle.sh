#!/bin/bash
# drift-oracle.sh - Mechanical drift detection for claude-code-requirements-builder
# Part of the test suite - run via ./tests/run-tests.sh or standalone
#
# Checks:
# 1. Schema consistency (no legacy fields under v2.0)
# 2. Authority statements exist and are non-contradictory
# 3. Test accounting references source of truth
# 4. Command list matches actual commands
# 5. Invariant definitions are consistent

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
EXAMPLE_DIR="$PROJECT_ROOT/examples/2025-01-27-1430-user-authentication"
COMMANDS_DIR="$PROJECT_ROOT/commands"

PASSED=0
FAILED=0

log_pass() { echo -e "${GREEN}[DRIFT-OK]${NC} $1"; PASSED=$((PASSED + 1)); }
log_fail() { echo -e "${RED}[DRIFT-FAIL]${NC} $1"; FAILED=$((FAILED + 1)); }
log_info() { echo -e "${YELLOW}[DRIFT-CHECK]${NC} $1"; }

echo ""
echo "=============================================="
echo " Drift Oracle - Schema & Contract Consistency"
echo "=============================================="
echo ""

#######################################
# Check 1: Schema v2.0 field consistency
#######################################
log_info "Check 1: Schema v2.0 has no legacy 'id' field"

METADATA="$EXAMPLE_DIR/metadata.json"

# Check that 'id' field does NOT exist (legacy)
if jq -e '.id' "$METADATA" > /dev/null 2>&1; then
    log_fail "metadata.json has legacy 'id' field (should be removed in v2.0)"
else
    log_pass "No legacy 'id' field in metadata.json"
fi

# Check that 'request' field DOES exist (required in v2.0)
if jq -e '.request' "$METADATA" > /dev/null 2>&1; then
    log_pass "'request' field present in metadata.json"
else
    log_fail "metadata.json missing required 'request' field"
fi

# Check that top-level 'context' field does NOT exist (was removed)
if jq -e '.context' "$METADATA" > /dev/null 2>&1; then
    log_fail "metadata.json has legacy top-level 'context' field (should be removed)"
else
    log_pass "No legacy top-level 'context' field"
fi

# Check schema version is 2.0
SCHEMA_VER=$(jq -r '._schema' "$METADATA")
if [[ "$SCHEMA_VER" == "2.0" ]]; then
    log_pass "Schema version is 2.0"
else
    log_fail "Schema version is '$SCHEMA_VER', expected '2.0'"
fi

#######################################
# Check 2: Command count matches
#######################################
log_info "Check 2: Command file count matches expected (12)"

CMD_COUNT=$(ls -1 "$COMMANDS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
if [[ "$CMD_COUNT" -eq 12 ]]; then
    log_pass "Found 12 command files"
else
    log_fail "Found $CMD_COUNT command files, expected 12"
fi

# Verify specific commands exist
EXPECTED_COMMANDS=(
    "requirements-start"
    "requirements-status"
    "requirements-current"
    "requirements-end"
    "requirements-list"
    "requirements-remind"
    "requirements-validate"
    "requirements-inject-todos"
    "requirements-todo-done"
    "requirements-todos"
    "requirements-verify"
    "requirements-remove-todos"
)

for cmd in "${EXPECTED_COMMANDS[@]}"; do
    if [[ -f "$COMMANDS_DIR/$cmd.md" ]]; then
        log_pass "Command file exists: $cmd.md"
    else
        log_fail "Missing command file: $cmd.md"
    fi
done

#######################################
# Check 3: Test count stability
#######################################
log_info "Check 3: Test count is exactly 36"

TEST_FILE="$SCRIPT_DIR/run-tests.sh"
TEST_COUNT=$(grep -oE "run_(T[0-9]+|I[0-9]+[a-z]?)" "$TEST_FILE" | sort -u | wc -l | tr -d ' ')

if [[ "$TEST_COUNT" -eq 36 ]]; then
    log_pass "Test count is stable at 36"
else
    log_fail "Test count is $TEST_COUNT, expected 36"
fi

#######################################
# Check 4: Invariant count matches
#######################################
log_info "Check 4: Invariants I1-I9 + I4b all tested"

INVARIANT_TESTS=$(grep -oE "run_I[0-9]+[a-z]?" "$TEST_FILE" | sort -u)
EXPECTED_INVARIANTS="run_I1 run_I2 run_I3 run_I4 run_I4b run_I5 run_I6 run_I7 run_I9"

for inv in $EXPECTED_INVARIANTS; do
    if echo "$INVARIANT_TESTS" | grep -q "^${inv}$"; then
        log_pass "Invariant test exists: $inv"
    else
        log_fail "Missing invariant test: $inv"
    fi
done

#######################################
# Check 5: remove-todos has dual anchor
#######################################
log_info "Check 5: remove-todos uses dual-anchor pattern"

REMOVE_CMD="$COMMANDS_DIR/requirements-remove-todos.md"
if grep -q '\[REQ:' "$REMOVE_CMD" && grep -q '\[ID:TODO-' "$REMOVE_CMD"; then
    log_pass "remove-todos requires both [REQ:] and [ID:TODO-] anchors"
else
    log_fail "remove-todos missing dual-anchor safety pattern"
fi

#######################################
# Check 6: Enum consistency in metadata
#######################################
log_info "Check 6: Enum values are valid"

STATUS=$(jq -r '.status' "$METADATA")
PHASE=$(jq -r '.phase' "$METADATA")
TODO_STATUS=$(jq -r '.todos.status // "null"' "$METADATA")
VERIFY_STATUS=$(jq -r '.verification.status // "null"' "$METADATA")

# status enum
if [[ "$STATUS" =~ ^(active|complete|incomplete)$ ]]; then
    log_pass "status enum valid: $STATUS"
else
    log_fail "Invalid status enum: $STATUS"
fi

# phase enum
if [[ "$PHASE" =~ ^(setup|discovery|context|detail|complete)$ ]]; then
    log_pass "phase enum valid: $PHASE"
else
    log_fail "Invalid phase enum: $PHASE"
fi

# todos.status enum (if present)
if [[ "$TODO_STATUS" != "null" ]]; then
    if [[ "$TODO_STATUS" =~ ^(injected|complete|removed)$ ]]; then
        log_pass "todos.status enum valid: $TODO_STATUS"
    else
        log_fail "Invalid todos.status enum: $TODO_STATUS"
    fi
fi

# verification.status enum (if present)
if [[ "$VERIFY_STATUS" != "null" ]]; then
    if [[ "$VERIFY_STATUS" =~ ^(no_data|passed|partial|failed)$ ]]; then
        log_pass "verification.status enum valid: $VERIFY_STATUS"
    else
        log_fail "Invalid verification.status enum: $VERIFY_STATUS"
    fi
fi

#######################################
# Check 7: No legacy 'context' field in schema definitions
#######################################
log_info "Check 7: No legacy 'context' field in metadata schema definitions"

# Scan command files for legacy "context": field in JSON blocks (metadata schema drift)
CONTEXT_OFFENDERS=$(grep -rn --include='*.md' '"context":' "$COMMANDS_DIR" 2>/dev/null || true)

if [[ -n "$CONTEXT_OFFENDERS" ]]; then
    echo -e "${RED}DRIFT-ORACLE FAIL: legacy 'context' field found in schema definitions${NC}"
    echo "$CONTEXT_OFFENDERS"
    echo -e "${RED}Replace 'context' with 'request' per metadata schema v2.0${NC}"
    log_fail "Legacy 'context' field found in command files"
else
    log_pass "No legacy 'context' field in command file schemas"
fi

# Check for dot-notation references to context object (e.g., context.filesAnalyzed)
CONTEXT_DOT_OFFENDERS=$(grep -rn --include='*.md' 'context\.[a-zA-Z]' "$COMMANDS_DIR" 2>/dev/null | grep -v "context\.md\|03-context" || true)

if [[ -n "$CONTEXT_DOT_OFFENDERS" ]]; then
    echo -e "${RED}DRIFT-ORACLE FAIL: dot-notation 'context.X' found (legacy schema reference)${NC}"
    echo "$CONTEXT_DOT_OFFENDERS"
    echo -e "${RED}Remove legacy context.* references per metadata schema v2.0${NC}"
    log_fail "Legacy 'context.*' dot-notation found in command files"
else
    log_pass "No legacy 'context.*' dot-notation in command files"
fi

# Also check that commands/requirements-start.md contains 'request' in its schema
if grep -q '"request":' "$COMMANDS_DIR/requirements-start.md"; then
    log_pass "requirements-start.md schema has 'request' field"
else
    log_fail "requirements-start.md schema missing 'request' field"
fi

#######################################
# Summary
#######################################
echo ""
echo "=============================================="
echo " Drift Oracle Results"
echo "=============================================="
echo ""
echo -e "${GREEN}Passed:${NC}  $PASSED"
echo -e "${RED}Failed:${NC}  $FAILED"
echo ""

if [[ "$FAILED" -eq 0 ]]; then
    echo -e "${GREEN}✅ Drift oracle passed - no contract drift detected${NC}"
    exit 0
else
    echo -e "${RED}❌ Drift oracle FAILED - $FAILED contract violations${NC}"
    exit 1
fi
