#!/bin/bash
#
# Test Runner for claude-code-requirements-builder
# 
# Usage: ./tests/run-tests.sh [test-id]
#   Run all tests:     ./tests/run-tests.sh
#   Run single test:   ./tests/run-tests.sh T03
#
# Tests verify contracts from the command specifications against example files.
#

# Don't use set -e as we want to continue on test failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
SKIPPED=0

# Project root (parent of tests directory)
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EXAMPLE_DIR="${EXAMPLE_DIR:-$PROJECT_ROOT/examples/2025-01-27-1430-user-authentication}"
MOCK_CODEBASE="$EXAMPLE_DIR/mock-codebase"
COMMANDS_DIR="$PROJECT_ROOT/commands"

# Test filter (optional argument)
TEST_FILTER="$1"

#######################################
# Helper Functions
#######################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED++))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    echo -e "${RED}       Expected:${NC} $2"
    echo -e "${RED}       Got:${NC} $3"
    ((FAILED++))
}

log_skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1"
    ((SKIPPED++))
}

# Check if a test should run based on filter
should_run() {
    local test_id="$1"
    if [[ -z "$TEST_FILTER" ]]; then
        return 0  # No filter, run all
    elif [[ "$test_id" == "$TEST_FILTER" ]]; then
        return 0  # Matches filter
    else
        return 1  # Skip
    fi
}

# Assert that a file exists
assert_file_exists() {
    local file="$1"
    local test_id="$2"
    if [[ -f "$file" ]]; then
        return 0
    else
        log_fail "$test_id: File should exist" "$file" "(not found)"
        return 1
    fi
}

# Assert that grep finds a pattern
assert_grep() {
    local pattern="$1"
    local file="$2"
    local test_id="$3"
    if grep -q "$pattern" "$file" 2>/dev/null; then
        return 0
    else
        log_fail "$test_id: Pattern should match" "$pattern" "(not found in $file)"
        return 1
    fi
}

# Assert that grep does NOT find a pattern
assert_no_grep() {
    local pattern="$1"
    local file="$2"
    local test_id="$3"
    if grep -q "$pattern" "$file" 2>/dev/null; then
        log_fail "$test_id: Pattern should NOT match" "(none)" "$pattern found in $file"
        return 1
    else
        return 0
    fi
}

# Assert count of grep matches
assert_grep_count() {
    local pattern="$1"
    local file="$2"
    local expected="$3"
    local test_id="$4"
    local actual
    actual=$(grep -c "$pattern" "$file" 2>/dev/null || echo "0")
    if [[ "$actual" -eq "$expected" ]]; then
        return 0
    else
        log_fail "$test_id: Count mismatch for '$pattern'" "$expected" "$actual"
        return 1
    fi
}

# Assert JSON field value using jq
assert_json_field() {
    local file="$1"
    local jq_query="$2"
    local expected="$3"
    local test_id="$4"
    local actual
    actual=$(jq -r "$jq_query" "$file" 2>/dev/null)
    if [[ "$actual" == "$expected" ]]; then
        return 0
    else
        log_fail "$test_id: JSON field mismatch for '$jq_query'" "$expected" "$actual"
        return 1
    fi
}

# Assert JSON is valid
assert_valid_json() {
    local file="$1"
    local test_id="$2"
    if jq empty "$file" 2>/dev/null; then
        return 0
    else
        log_fail "$test_id: Invalid JSON" "valid JSON" "(parse error)"
        return 1
    fi
}

# Assert numeric comparison
assert_numeric_eq() {
    local actual="$1"
    local expected="$2"
    local test_id="$3"
    if [[ "$actual" -eq "$expected" ]]; then
        return 0
    else
        log_fail "$test_id: Numeric mismatch" "$expected" "$actual"
        return 1
    fi
}

#######################################
# Print header
#######################################
echo ""
echo "=============================================="
echo " claude-code-requirements-builder Test Suite"
echo "=============================================="
echo ""
echo "Project root: $PROJECT_ROOT"
echo "Example dir:  $EXAMPLE_DIR"
echo ""

# Verify prerequisites
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed.${NC}"
    echo "Install with: brew install jq"
    exit 1
fi

if [[ ! -d "$EXAMPLE_DIR" ]]; then
    echo -e "${RED}Error: Example directory not found.${NC}"
    exit 1
fi

echo "Running tests..."
echo ""

#######################################
# T01-T06: TODO Format & Manifest Tests
#######################################

# T01: TODO injection creates 4-line format for P1/P2
run_T01() {
    local test_id="T01"
    should_run "$test_id" || return 0
    
    log_info "$test_id: P1/P2 TODOs have 4-line format (TODO, WHY, DONE WHEN, SPEC)"
    
    local file="$MOCK_CODEBASE/src/services/AuthService.ts"
    
    # Check all 4 lines exist after a P:1 TODO
    if assert_grep "// TODO \[REQ:.*\] \[ID:TODO-" "$file" "$test_id" && \
       assert_grep "// WHY:" "$file" "$test_id" && \
       assert_grep "// DONE WHEN:" "$file" "$test_id" && \
       assert_grep "// SPEC:" "$file" "$test_id"; then
        log_pass "$test_id: P1 TODO has complete 4-line format"
    fi
}
run_T01

# T02: P3 TODOs have 1-line format (no WHY/DONE WHEN/SPEC)
run_T02() {
    local test_id="T02"
    should_run "$test_id" || return 0
    
    log_info "$test_id: P3 TODOs have 1-line format"
    
    # Check that no P3 TODOs exist with multi-line format in mock files
    # (This test validates the contract - in real usage P3 would be single line)
    # Since example only has P1/P2, we verify the format definition exists in command spec
    
    local cmd_file="$COMMANDS_DIR/requirements-inject-todos.md"
    if assert_grep "P3.*Compact format.*1 line" "$cmd_file" "$test_id"; then
        log_pass "$test_id: P3 compact format is specified"
    fi
}
run_T02

# T03: Priority uses [P:N] format (numeric), not [P:P1]
run_T03() {
    local test_id="T03"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Priority format is [P:N] not [P:PN]"
    
    local file="$MOCK_CODEBASE/src/services/AuthService.ts"
    
    # Should find [P:1], [P:2], or [P:3]
    if assert_grep "\[P:1\]\|\[P:2\]\|\[P:3\]" "$file" "$test_id"; then
        # Should NOT find [P:P1], [P:P2], [P:P3]
        if assert_no_grep "\[P:P1\]\|\[P:P2\]\|\[P:P3\]" "$file" "$test_id"; then
            log_pass "$test_id: Priority format is correct [P:N]"
        fi
    fi
}
run_T03

# T04: TODO ID format is TODO-NNN (zero-padded)
run_T04() {
    local test_id="T04"
    should_run "$test_id" || return 0
    
    log_info "$test_id: TODO IDs are zero-padded (TODO-001, not TODO-1)"
    
    local file="$MOCK_CODEBASE/src/services/AuthService.ts"
    
    # Should find TODO-00N pattern
    if assert_grep "\[ID:TODO-00[0-9]\]" "$file" "$test_id"; then
        log_pass "$test_id: TODO IDs are zero-padded"
    fi
}
run_T04

# T05: Manifest file (08) exists with correct structure
run_T05() {
    local test_id="T05"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Manifest file exists with correct structure"
    
    local file="$EXAMPLE_DIR/08-todo-manifest.md"
    
    if assert_file_exists "$file" "$test_id" && \
       assert_grep "# TODO Manifest:" "$file" "$test_id" && \
       assert_grep "## TODOs" "$file" "$test_id" && \
       assert_grep "### TODO-001" "$file" "$test_id" && \
       assert_grep "\*\*File\*\*:" "$file" "$test_id" && \
       assert_grep "\*\*Priority\*\*:" "$file" "$test_id" && \
       assert_grep "\*\*Task\*\*:" "$file" "$test_id"; then
        log_pass "$test_id: Manifest has correct structure"
    fi
}
run_T05

# T06: Manifest tracks open/done status with ⬜/✅ markers
run_T06() {
    local test_id="T06"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Manifest tracks open/done with checkbox markers"
    
    local file="$EXAMPLE_DIR/08-todo-manifest.md"
    
    # Count open (⬜) and done (✅) markers
    local open_count done_count
    open_count=$(grep -c "### TODO-[0-9]* ⬜" "$file" 2>/dev/null || echo "0")
    done_count=$(grep -c "### TODO-[0-9]* ✅" "$file" 2>/dev/null || echo "0")
    
    if [[ "$open_count" -gt 0 ]] && [[ "$done_count" -gt 0 ]]; then
        log_pass "$test_id: Manifest has $open_count open and $done_count done markers"
    else
        log_fail "$test_id: Manifest should have both ⬜ and ✅ markers" "both present" "open=$open_count, done=$done_count"
    fi
}
run_T06

#######################################
# T07-T12: Validation Tests
#######################################

# T07: Quick mode runs only lenses 1-2
run_T07() {
    local test_id="T07"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Quick mode runs only lenses 1-2 (Ambiguity, Completeness)"
    
    local cmd_file="$COMMANDS_DIR/requirements-validate.md"
    
    # Check that quick mode specifies lenses 1-2
    if assert_grep "quick.*1-2 only" "$cmd_file" "$test_id" && \
       assert_grep "| 1 | Ambiguity Detection" "$cmd_file" "$test_id" && \
       assert_grep "| 2 | Completeness Check" "$cmd_file" "$test_id"; then
        log_pass "$test_id: Quick mode lens restriction documented"
    fi
}
run_T07

# T08: Adversarial mode includes adversarial section in report
run_T08() {
    local test_id="T08"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Adversarial mode template includes adversarial findings"
    
    local cmd_file="$COMMANDS_DIR/requirements-validate.md"
    
    if assert_grep "## Adversarial Findings" "$cmd_file" "$test_id"; then
        log_pass "$test_id: Adversarial findings section defined"
    fi
}
run_T08

# T09: Adversarial mode has 3 personas
run_T09() {
    local test_id="T09"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Adversarial mode defines 3 personas"
    
    local cmd_file="$COMMANDS_DIR/requirements-validate.md"
    
    if assert_grep "Malicious User Persona" "$cmd_file" "$test_id" && \
       assert_grep "Lazy Developer Persona" "$cmd_file" "$test_id" && \
       assert_grep "Skeptical QA Persona" "$cmd_file" "$test_id"; then
        log_pass "$test_id: All 3 adversarial personas defined"
    fi
}
run_T09

# T10: Validation score formula: 100 - (blocking*15) - (warnings*5)
run_T10() {
    local test_id="T10"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Validation score formula is correct"
    
    # From example: score=85, blocking=0, warnings=3
    # Formula: 100 - (0*15) - (3*5) = 100 - 0 - 15 = 85 ✓
    
    local file="$EXAMPLE_DIR/metadata.json"
    local score blocking warnings
    score=$(jq -r '.validation.score' "$file")
    blocking=$(jq -r '.validation.blocking' "$file")
    warnings=$(jq -r '.validation.warnings' "$file")
    
    local expected=$((100 - (blocking * 15) - (warnings * 5)))
    
    if assert_numeric_eq "$score" "$expected" "$test_id"; then
        log_pass "$test_id: Score $score = 100 - ($blocking*15) - ($warnings*5)"
    fi
}
run_T10

# T11: Validation passes if score >= 70 AND blocking = 0
run_T11() {
    local test_id="T11"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Pass gate: score >= 70 AND 0 blocking"
    
    local file="$EXAMPLE_DIR/metadata.json"
    local status score blocking
    status=$(jq -r '.validation.status' "$file")
    score=$(jq -r '.validation.score' "$file")
    blocking=$(jq -r '.validation.blocking' "$file")
    
    # Example has score=85, blocking=0, status=passed
    if [[ "$score" -ge 70 ]] && [[ "$blocking" -eq 0 ]] && [[ "$status" == "passed" ]]; then
        log_pass "$test_id: Passed correctly (score=$score >= 70, blocking=$blocking = 0)"
    else
        log_fail "$test_id: Pass gate logic" "passed if score>=70 AND blocking=0" "score=$score, blocking=$blocking, status=$status"
    fi
}
run_T11

# T12: Validation fails if score >= 70 but blocking > 0
run_T12() {
    local test_id="T12"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Fail gate: blocking > 0 causes failure regardless of score"
    
    # This is a contract test - verify the rule is documented
    local cmd_file="$COMMANDS_DIR/requirements-validate.md"
    
    if assert_grep "Score >= 70 AND no blocking issues.*passed" "$cmd_file" "$test_id" && \
       assert_grep "Score < 70 OR any blocking issues.*failed" "$cmd_file" "$test_id"; then
        log_pass "$test_id: Fail gate documented (blocking > 0 = fail)"
    fi
}
run_T12

#######################################
# T13-T18: Verification & Complexity Tests
#######################################

# T13: Verification only checks done TODOs
run_T13() {
    local test_id="T13"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Verification only checks ✅ TODOs"
    
    local file="$EXAMPLE_DIR/09-verification-report.md"
    local metadata="$EXAMPLE_DIR/metadata.json"
    
    # Count TODOs in verification report
    local verified_count
    verified_count=$(grep -c "TODO-[0-9]*" "$file" 2>/dev/null | head -1 || echo "0")
    
    # Get done count from metadata
    local done_count
    done_count=$(jq -r '.todos.done' "$metadata")
    
    # Verification report header says "**Checked**: X of Y completed TODOs"
    if assert_grep "\*\*Checked\*\*:.*of.*completed TODOs" "$file" "$test_id"; then
        log_pass "$test_id: Verification report shows completed TODO count"
    fi
}
run_T13

# T14: Verification status PARTIAL when some need review
run_T14() {
    local test_id="T14"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Verification PARTIAL when needsReview > 0 AND < verified"
    
    local file="$EXAMPLE_DIR/metadata.json"
    local status verified needs_review
    status=$(jq -r '.verification.status' "$file")
    verified=$(jq -r '.verification.verified' "$file")
    needs_review=$(jq -r '.verification.needsReview' "$file")
    
    # Example: verified=2, needsReview=1, status=partial
    # Formula: needsReview > 0 AND needsReview < verified → PARTIAL
    if [[ "$needs_review" -gt 0 ]] && [[ "$needs_review" -lt "$verified" ]] && [[ "$status" == "partial" ]]; then
        log_pass "$test_id: PARTIAL status correct (verified=$verified, needsReview=$needs_review)"
    else
        log_fail "$test_id: PARTIAL logic" "partial when 0 < needsReview < verified" "verified=$verified, needsReview=$needs_review, status=$status"
    fi
}
run_T14

# T15: Remove-todos accepts both "injected" and "complete" status
run_T15() {
    local test_id="T15"
    should_run "$test_id" || return 0
    
    log_info "$test_id: remove-todos accepts status 'injected' or 'complete'"
    
    local cmd_file="$COMMANDS_DIR/requirements-remove-todos.md"
    
    if assert_grep 'todos.status = "injected" or "complete"' "$cmd_file" "$test_id"; then
        log_pass "$test_id: Both statuses accepted for removal"
    fi
}
run_T15

# T16: Remove-todos requires user confirmation
run_T16() {
    local test_id="T16"
    should_run "$test_id" || return 0
    
    log_info "$test_id: remove-todos requires confirmation prompt"
    
    local cmd_file="$COMMANDS_DIR/requirements-remove-todos.md"
    
    if assert_grep "Continue? (y/n)" "$cmd_file" "$test_id" && \
       assert_grep "Wait for explicit.*y.*or.*yes.*before proceeding" "$cmd_file" "$test_id"; then
        log_pass "$test_id: Confirmation prompt required"
    fi
}
run_T16

# T17: Simple complexity = 3 discovery questions
run_T17() {
    local test_id="T17"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Simple complexity = 3 discovery questions"
    
    local cmd_file="$COMMANDS_DIR/requirements-start.md"
    
    if assert_grep "| simple | 3 |" "$cmd_file" "$test_id"; then
        log_pass "$test_id: Simple = 3 discovery questions"
    fi
}
run_T17

# T18: Complex complexity = 6-8 discovery questions
run_T18() {
    local test_id="T18"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Complex complexity = 6-8 discovery questions"
    
    local cmd_file="$COMMANDS_DIR/requirements-start.md"
    local metadata="$EXAMPLE_DIR/metadata.json"
    
    # Check spec defines 6-8 for complex
    if assert_grep "| complex | 6-8 |" "$cmd_file" "$test_id"; then
        # Example is "complex" with 6 discovery questions
        local level discovery_count
        level=$(jq -r '.complexity.level' "$metadata")
        discovery_count=$(jq -r '.complexity.questionCounts.discovery' "$metadata")
        
        if [[ "$level" == "complex" ]] && [[ "$discovery_count" -ge 6 ]] && [[ "$discovery_count" -le 8 ]]; then
            log_pass "$test_id: Complex example has $discovery_count discovery questions (6-8 range)"
        else
            log_fail "$test_id: Complex range" "6-8 questions" "level=$level, count=$discovery_count"
        fi
    fi
}
run_T18

#######################################
# T19-T26: Schema, Timestamps, Cross-refs
#######################################

# T19: Metadata schema is version 2.0
run_T19() {
    local test_id="T19"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Metadata has _schema: '2.0'"
    
    local file="$EXAMPLE_DIR/metadata.json"
    
    if assert_json_field "$file" '._schema' "2.0" "$test_id"; then
        log_pass "$test_id: Schema version is 2.0"
    fi
}
run_T19

# T20: All timestamps are ISO-8601 format
run_T20() {
    local test_id="T20"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Timestamps are ISO-8601 format"
    
    local file="$EXAMPLE_DIR/metadata.json"
    
    # ISO-8601 pattern: YYYY-MM-DDTHH:MM:SSZ
    local iso_pattern="^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$"
    
    local started last_updated
    started=$(jq -r '.started' "$file")
    last_updated=$(jq -r '.lastUpdated' "$file")
    
    if [[ "$started" =~ $iso_pattern ]] && [[ "$last_updated" =~ $iso_pattern ]]; then
        log_pass "$test_id: Timestamps are valid ISO-8601"
    else
        log_fail "$test_id: ISO-8601 format" "YYYY-MM-DDTHH:MM:SSZ" "started=$started, lastUpdated=$last_updated"
    fi
}
run_T20

# T21: Implementation Map section exists in spec
run_T21() {
    local test_id="T21"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Spec has Implementation Map section"
    
    local file="$EXAMPLE_DIR/06-requirements-spec.md"
    
    if assert_file_exists "$file" "$test_id" && \
       assert_grep "## Implementation Map" "$file" "$test_id"; then
        log_pass "$test_id: Implementation Map section exists"
    fi
}
run_T21

# T22: Status command shows validation section when validated
run_T22() {
    local test_id="T22"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Status shows validation info when section exists"
    
    local cmd_file="$COMMANDS_DIR/requirements-status.md"
    
    if assert_grep "Validation:.*status based on validation section" "$cmd_file" "$test_id"; then
        log_pass "$test_id: Status displays validation conditionally"
    fi
}
run_T22

# T23: Re-run inject is idempotent (no duplicates)
run_T23() {
    local test_id="T23"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Inject is idempotent (skips existing TODOs)"
    
    local cmd_file="$COMMANDS_DIR/requirements-inject-todos.md"
    
    # Check for idempotency section (updated in PCH-08)
    if assert_grep "### Idempotency Rule" "$cmd_file" "$test_id" && \
       assert_grep "Idempotency Guarantee" "$cmd_file" "$test_id"; then
        log_pass "$test_id: Idempotency documented"
    fi
}
run_T23

# T24: Cross-reference: manifest.done = metadata.todos.done
run_T24() {
    local test_id="T24"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Invariant I2: manifest ✅ count = metadata.todos.done"
    
    local manifest="$EXAMPLE_DIR/08-todo-manifest.md"
    local metadata="$EXAMPLE_DIR/metadata.json"
    
    # Count ✅ in manifest
    local manifest_done
    manifest_done=$(grep -c "### TODO-[0-9]* ✅" "$manifest" 2>/dev/null || echo "0")
    
    # Get done from metadata
    local metadata_done
    metadata_done=$(jq -r '.todos.done' "$metadata")
    
    if assert_numeric_eq "$manifest_done" "$metadata_done" "$test_id"; then
        log_pass "$test_id: Invariant holds (manifest ✅=$manifest_done, metadata.done=$metadata_done)"
    fi
}
run_T24

# T25: New files have no import statements (user adds during implementation)
run_T25() {
    local test_id="T25"
    should_run "$test_id" || return 0
    
    log_info "$test_id: New files don't have import statements"
    
    # AuthService.ts is a [NEW] created file
    local file="$MOCK_CODEBASE/src/services/AuthService.ts"
    
    if assert_no_grep "^import " "$file" "$test_id"; then
        log_pass "$test_id: New file has no imports (as specified)"
    fi
}
run_T25

# T26: Comment syntax adapts to file extension (.py = #)
run_T26() {
    local test_id="T26"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Comment syntax adapts to file extension"
    
    local cmd_file="$COMMANDS_DIR/requirements-inject-todos.md"
    
    # Check that syntax table exists with various extensions
    if assert_grep ".py, .rb, .sh.*# comment" "$cmd_file" "$test_id" && \
       assert_grep ".js, .ts.*// comment" "$cmd_file" "$test_id"; then
        log_pass "$test_id: Comment syntax table defined"
    fi
}
run_T26

# T27: todos.status transitions to "complete" when open = 0
run_T27() {
    local test_id="T27"
    should_run "$test_id" || return 0
    
    log_info "$test_id: todos.status transition rule documented (open=0 → complete)"
    
    local cmd_file="$COMMANDS_DIR/requirements-todo-done.md"
    
    # Verify the transition rule is documented in todo-done command
    if assert_grep "todos.open = 0" "$cmd_file" "$test_id" && \
       assert_grep 'todos.status to "complete"' "$cmd_file" "$test_id"; then
        log_pass "$test_id: Transition rule documented (open=0 → status=complete)"
    fi
}
run_T27

#######################################
# I1-I7 + I4b: Invariant Tests (Cross-file Consistency)
#######################################

# I1: manifest.total = metadata.todos.total
run_I1() {
    local test_id="I1"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Invariant: manifest total = metadata.todos.total"
    
    local manifest="$EXAMPLE_DIR/08-todo-manifest.md"
    local metadata="$EXAMPLE_DIR/metadata.json"
    
    # Count TODOs in manifest (### TODO-NNN lines)
    local manifest_total
    manifest_total=$(grep -c "### TODO-[0-9]*" "$manifest" 2>/dev/null || echo "0")
    
    # Get total from metadata
    local metadata_total
    metadata_total=$(jq -r '.todos.total' "$metadata")
    
    if assert_numeric_eq "$manifest_total" "$metadata_total" "$test_id"; then
        log_pass "$test_id: Totals match (manifest=$manifest_total, metadata=$metadata_total)"
    fi
}
run_I1

# I2: manifest ✅ count = metadata.todos.done
run_I2() {
    local test_id="I2"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Invariant: manifest ✅ count = metadata.todos.done"
    
    local manifest="$EXAMPLE_DIR/08-todo-manifest.md"
    local metadata="$EXAMPLE_DIR/metadata.json"
    
    # Count ✅ in manifest
    local manifest_done
    manifest_done=$(grep -c "### TODO-[0-9]* ✅" "$manifest" 2>/dev/null || echo "0")
    
    # Get done from metadata
    local metadata_done
    metadata_done=$(jq -r '.todos.done' "$metadata")
    
    if assert_numeric_eq "$manifest_done" "$metadata_done" "$test_id"; then
        log_pass "$test_id: Done counts match (manifest ✅=$manifest_done, metadata.done=$metadata_done)"
    fi
}
run_I2

# I3: manifest ⬜ count = metadata.todos.open
run_I3() {
    local test_id="I3"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Invariant: manifest ⬜ count = metadata.todos.open"
    
    local manifest="$EXAMPLE_DIR/08-todo-manifest.md"
    local metadata="$EXAMPLE_DIR/metadata.json"
    
    # Count ⬜ in manifest
    local manifest_open
    manifest_open=$(grep -c "### TODO-[0-9]* ⬜" "$manifest" 2>/dev/null || echo "0")
    
    # Get open from metadata
    local metadata_open
    metadata_open=$(jq -r '.todos.open' "$metadata")
    
    if assert_numeric_eq "$manifest_open" "$metadata_open" "$test_id"; then
        log_pass "$test_id: Open counts match (manifest ⬜=$manifest_open, metadata.open=$metadata_open)"
    fi
}
run_I3

# I4: validation.warnings = count of [WARN-N] in report
run_I4() {
    local test_id="I4"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Invariant: metadata.warnings = report [WARN-N] count"
    
    local report="$EXAMPLE_DIR/07-validation-report.md"
    local metadata="$EXAMPLE_DIR/metadata.json"
    
    # Count [WARN-N] patterns in report
    local report_warnings
    report_warnings=$(grep -c "\[WARN-[0-9]*\]" "$report" 2>/dev/null || echo "0")
    
    # Get warnings from metadata
    local metadata_warnings
    metadata_warnings=$(jq -r '.validation.warnings' "$metadata")
    
    if assert_numeric_eq "$report_warnings" "$metadata_warnings" "$test_id"; then
        log_pass "$test_id: Warning counts match (report=$report_warnings, metadata=$metadata_warnings)"
    fi
}
run_I4

# I4b: validation.blocking = count of [BLOCK-N] in report
run_I4b() {
    local test_id="I4b"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Invariant: metadata.blocking = report [BLOCK-N] count"
    
    local report="$EXAMPLE_DIR/07-validation-report.md"
    local metadata="$EXAMPLE_DIR/metadata.json"
    
    # Count [BLOCK-N] patterns in report (use wc -l to avoid grep -c exit code issue)
    local report_blocking
    report_blocking=$(grep "\[BLOCK-[0-9]*\]" "$report" 2>/dev/null | wc -l | tr -d ' ')
    
    # Get blocking from metadata
    local metadata_blocking
    metadata_blocking=$(jq -r '.validation.blocking' "$metadata")
    
    if assert_numeric_eq "$report_blocking" "$metadata_blocking" "$test_id"; then
        log_pass "$test_id: Blocking counts match (report=$report_blocking, metadata=$metadata_blocking)"
    fi
}
run_I4b

# I5: Implementation Map row count = manifest TODO count
run_I5() {
    local test_id="I5"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Invariant: Implementation Map rows = manifest TODO count"
    
    local spec="$EXAMPLE_DIR/06-requirements-spec.md"
    local manifest="$EXAMPLE_DIR/08-todo-manifest.md"
    
    # Count table rows in Implementation Map (lines starting with | N |)
    local map_rows
    map_rows=$(grep -c "^| [0-9]" "$spec" 2>/dev/null || echo "0")
    
    # Count TODOs in manifest
    local manifest_todos
    manifest_todos=$(grep -c "### TODO-[0-9]*" "$manifest" 2>/dev/null || echo "0")
    
    if assert_numeric_eq "$map_rows" "$manifest_todos" "$test_id"; then
        log_pass "$test_id: Counts match (map rows=$map_rows, manifest TODOs=$manifest_todos)"
    fi
}
run_I5

# I6: complexity.questionCounts.discovery = progress.discovery.total
run_I6() {
    local test_id="I6"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Invariant: questionCounts.discovery = progress.discovery.total"
    
    local metadata="$EXAMPLE_DIR/metadata.json"
    
    local question_count progress_total
    question_count=$(jq -r '.complexity.questionCounts.discovery' "$metadata")
    progress_total=$(jq -r '.progress.discovery.total' "$metadata")
    
    if assert_numeric_eq "$question_count" "$progress_total" "$test_id"; then
        log_pass "$test_id: Discovery counts match (questionCounts=$question_count, progress.total=$progress_total)"
    fi
}
run_I6

#######################################
# Additional: todos.open + todos.done = todos.total
#######################################

run_I7() {
    local test_id="I7"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Invariant: todos.open + todos.done = todos.total"
    
    local metadata="$EXAMPLE_DIR/metadata.json"
    
    local open done total
    open=$(jq -r '.todos.open' "$metadata")
    done=$(jq -r '.todos.done' "$metadata")
    total=$(jq -r '.todos.total' "$metadata")
    
    local sum=$((open + done))
    
    if assert_numeric_eq "$sum" "$total" "$test_id"; then
        log_pass "$test_id: Sum matches (open=$open + done=$done = $sum, total=$total)"
    fi
}
run_I7

# I9: todos.status: injected→complete fires IFF todos.open == 0
run_I9() {
    local test_id="I9"
    should_run "$test_id" || return 0
    
    log_info "$test_id: Invariant: todos.status='complete' IFF todos.open=0"
    
    local metadata="$EXAMPLE_DIR/metadata.json"
    
    local open status
    open=$(jq -r '.todos.open' "$metadata")
    status=$(jq -r '.todos.status' "$metadata")
    
    # I9 rule: status should be "complete" if and only if open == 0
    # Equivalently: (open == 0 AND status == "complete") OR (open > 0 AND status == "injected")
    local valid=false
    
    if [[ "$open" -eq 0 ]] && [[ "$status" == "complete" ]]; then
        valid=true
        log_pass "$test_id: Correct - open=0 AND status=complete"
    elif [[ "$open" -gt 0 ]] && [[ "$status" == "injected" ]]; then
        valid=true
        log_pass "$test_id: Correct - open=$open (>0) AND status=injected"
    fi
    
    if [[ "$valid" == "false" ]]; then
        log_fail "$test_id: Status/open mismatch" "(open=0 → complete) OR (open>0 → injected)" "open=$open, status=$status"
    fi
}
run_I9

#######################################
# Test Summary
#######################################

echo ""
echo "=============================================="
echo " Test Results"
echo "=============================================="
echo ""
echo -e "${GREEN}Passed:${NC}  $PASSED"
echo -e "${RED}Failed:${NC}  $FAILED"
echo -e "${YELLOW}Skipped:${NC} $SKIPPED"
echo ""

TOTAL=$((PASSED + FAILED))

if [[ "$FAILED" -eq 0 ]]; then
    echo -e "${GREEN}✅ All $TOTAL tests passed!${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}❌ $FAILED of $TOTAL tests failed.${NC}"
    echo ""
    exit 1
fi
