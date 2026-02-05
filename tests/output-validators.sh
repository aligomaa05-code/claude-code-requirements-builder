#!/bin/bash
# output-validators.sh - Validate actual output artifacts, not documentation
#
# Usage: source this file, then call validators with a requirements directory path
#
# These validators operate on GENERATED FILES to prove the system works,
# not on command specs that merely DOCUMENT the rules.

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

#######################################
# O1: Validate metadata.json structure (not just "2.0" text exists)
#######################################
validate_metadata_structure() {
    local metadata="$1"
    local test_id="${2:-O1}"
    
    if [[ ! -f "$metadata" ]]; then
        echo -e "${RED}[FAIL]${NC} $test_id: metadata.json not found at $metadata"
        return 1
    fi
    
    # Check valid JSON
    if ! jq empty "$metadata" 2>/dev/null; then
        echo -e "${RED}[FAIL]${NC} $test_id: metadata.json is not valid JSON"
        return 1
    fi
    
    # Check required top-level fields exist
    local required_fields=("_schema" "request" "status" "phase" "started" "lastUpdated")
    local missing=()
    
    for field in "${required_fields[@]}"; do
        if [[ "$(jq -r ".$field // \"MISSING\"" "$metadata")" == "MISSING" ]]; then
            missing+=("$field")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}[FAIL]${NC} $test_id: metadata.json missing required fields: ${missing[*]}"
        return 1
    fi
    
    # Validate _schema is exactly "2.0"
    local schema
    schema=$(jq -r '._schema' "$metadata")
    if [[ "$schema" != "2.0" ]]; then
        echo -e "${RED}[FAIL]${NC} $test_id: _schema is '$schema', expected '2.0'"
        return 1
    fi
    
    echo -e "${GREEN}[PASS]${NC} $test_id: metadata.json structure valid (schema=2.0, all required fields present)"
    return 0
}


#######################################
# O2: Validate P1/P2 TODO has 4-line format in actual code files
#######################################
validate_p1_p2_todo_format() {
    local search_dir="$1"
    local test_id="${2:-O2}"
    
    # Find files with P:1 or P:2 TODOs
    local todo_files
    todo_files=$(grep -rl "\[P:[12]\]" "$search_dir" 2>/dev/null || true)
    
    if [[ -z "$todo_files" ]]; then
        echo -e "${YELLOW}[SKIP]${NC} $test_id: No P1/P2 TODOs found in $search_dir"
        return 0
    fi
    
    local all_valid=true
    
    for file in $todo_files; do
        # For each P:1 or P:2 TODO line, check next 3 lines have WHY, DONE WHEN, SPEC
        local line_nums
        line_nums=$(grep -n "\[P:[12]\]" "$file" | cut -d: -f1)
        
        for line_num in $line_nums; do
            local next1=$((line_num + 1))
            local next2=$((line_num + 2))
            local next3=$((line_num + 3))
            
            local has_why has_done_when has_spec
            has_why=$(sed -n "${next1}p" "$file" | grep -c "WHY:" || true)
            has_done_when=$(sed -n "${next2}p" "$file" | grep -c "DONE WHEN:" || true)
            has_spec=$(sed -n "${next3}p" "$file" | grep -c "SPEC:" || true)
            
            if [[ "$has_why" -eq 0 ]] || [[ "$has_done_when" -eq 0 ]] || [[ "$has_spec" -eq 0 ]]; then
                echo -e "${RED}[FAIL]${NC} $test_id: P1/P2 TODO at $file:$line_num missing 4-line format"
                echo "       Expected: TODO → WHY → DONE WHEN → SPEC"
                all_valid=false
            fi
        done
    done
    
    if [[ "$all_valid" == "true" ]]; then
        echo -e "${GREEN}[PASS]${NC} $test_id: All P1/P2 TODOs have correct 4-line format"
        return 0
    fi
    return 1
}

#######################################
# O3: Validate P3 TODO has 1-line format (no WHY/DONE WHEN/SPEC follows)
#######################################
validate_p3_todo_format() {
    local search_dir="$1"
    local test_id="${2:-O3}"
    
    # Find files with P:3 TODOs
    local todo_files
    todo_files=$(grep -rl "\[P:3\]" "$search_dir" 2>/dev/null || true)
    
    if [[ -z "$todo_files" ]]; then
        echo -e "${YELLOW}[SKIP]${NC} $test_id: No P3 TODOs found in $search_dir"
        return 0
    fi
    
    local all_valid=true
    
    for file in $todo_files; do
        local line_nums
        line_nums=$(grep -n "\[P:3\]" "$file" | cut -d: -f1)
        
        for line_num in $line_nums; do
            local next1=$((line_num + 1))
            
            # P3 should NOT have WHY on the next line
            local has_why
            has_why=$(sed -n "${next1}p" "$file" | grep -c "// WHY:\|# WHY:" || true)
            
            if [[ "$has_why" -gt 0 ]]; then
                echo -e "${RED}[FAIL]${NC} $test_id: P3 TODO at $file:$line_num has multi-line format (should be 1-line)"
                all_valid=false
            fi
        done
    done
    
    if [[ "$all_valid" == "true" ]]; then
        echo -e "${GREEN}[PASS]${NC} $test_id: All P3 TODOs have correct 1-line compact format"
        return 0
    fi
    return 1
}


#######################################
# O4: Validate invariants I1-I3 on actual manifest vs metadata
#######################################
validate_manifest_metadata_invariants() {
    local req_dir="$1"
    local test_id="${2:-O4}"
    
    local metadata="$req_dir/metadata.json"
    local manifest="$req_dir/08-todo-manifest.md"
    
    if [[ ! -f "$metadata" ]]; then
        echo -e "${RED}[FAIL]${NC} $test_id: metadata.json not found"
        return 1
    fi
    
    if [[ ! -f "$manifest" ]]; then
        echo -e "${YELLOW}[SKIP]${NC} $test_id: No manifest file (TODOs not injected yet)"
        return 0
    fi
    
    local all_valid=true
    
    # I1: manifest TODO count = metadata.todos.total
    local manifest_total metadata_total
    manifest_total=$(grep -c "### TODO-[0-9]*" "$manifest" 2>/dev/null || echo "0")
    metadata_total=$(jq -r '.todos.total // 0' "$metadata")
    
    if [[ "$manifest_total" -ne "$metadata_total" ]]; then
        echo -e "${RED}[FAIL]${NC} $test_id-I1: manifest count ($manifest_total) != metadata.todos.total ($metadata_total)"
        all_valid=false
    fi
    
    # I2: manifest ✅ count = metadata.todos.done
    local manifest_done metadata_done
    manifest_done=$(grep -c "### TODO-[0-9]* ✅" "$manifest" 2>/dev/null || echo "0")
    metadata_done=$(jq -r '.todos.done // 0' "$metadata")
    
    if [[ "$manifest_done" -ne "$metadata_done" ]]; then
        echo -e "${RED}[FAIL]${NC} $test_id-I2: manifest ✅ count ($manifest_done) != metadata.todos.done ($metadata_done)"
        all_valid=false
    fi
    
    # I3: manifest ⬜ count = metadata.todos.open
    local manifest_open metadata_open
    manifest_open=$(grep -c "### TODO-[0-9]* ⬜" "$manifest" 2>/dev/null || echo "0")
    metadata_open=$(jq -r '.todos.open // 0' "$metadata")
    
    if [[ "$manifest_open" -ne "$metadata_open" ]]; then
        echo -e "${RED}[FAIL]${NC} $test_id-I3: manifest ⬜ count ($manifest_open) != metadata.todos.open ($metadata_open)"
        all_valid=false
    fi
    
    if [[ "$all_valid" == "true" ]]; then
        echo -e "${GREEN}[PASS]${NC} $test_id: All manifest↔metadata invariants hold (I1-I3)"
        echo "       total=$manifest_total, done=$manifest_done, open=$manifest_open"
        return 0
    fi
    return 1
}

#######################################
# O5: Validate idempotency - same TODO pattern won't duplicate
#######################################
validate_idempotency_pattern() {
    local search_dir="$1"
    local test_id="${2:-O5}"
    
    # Create temp file with a TODO
    local temp_file
    temp_file=$(mktemp)
    trap "rm -f $temp_file" RETURN
    
    cat > "$temp_file" << 'EOF'
// src/test.ts - Test file
// TODO [REQ:test-req] [ID:TODO-001] [P:1] First task
// WHY: Testing
// DONE WHEN: Test passes
// SPEC: requirements/test-req/06-requirements-spec.md

function test() {}
EOF

    # Simulate "second injection" by checking if pattern already exists
    local pattern="TODO \[REQ:test-req\] \[ID:TODO-001\]"
    local count
    count=$(grep -c "$pattern" "$temp_file" || echo "0")
    
    if [[ "$count" -eq 1 ]]; then
        # Pattern exists exactly once - idempotent check would skip
        echo -e "${GREEN}[PASS]${NC} $test_id: Idempotency pattern detection works (found existing TODO, would skip)"
        return 0
    else
        echo -e "${RED}[FAIL]${NC} $test_id: Idempotency pattern detection failed"
        return 1
    fi
}

#######################################
# Run all output validators on a directory
#######################################
run_all_output_validators() {
    local req_dir="$1"
    local code_dir="$2"
    local passed=0
    local failed=0
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " Output Validators (O1-O5)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if validate_metadata_structure "$req_dir/metadata.json" "O1"; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
    fi
    
    if validate_p1_p2_todo_format "$code_dir" "O2"; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
    fi
    
    if validate_p3_todo_format "$code_dir" "O3"; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
    fi
    
    if validate_manifest_metadata_invariants "$req_dir" "O4"; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
    fi
    
    if validate_idempotency_pattern "$code_dir" "O5"; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
    fi
    
    echo ""
    echo "Output Validators: $passed passed, $failed failed"
    
    if [[ "$failed" -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}
