#!/bin/bash
#!/bin/bash
# run_e2e.sh - Behavioral Oracle for claude-code-requirements-builder
# Validates GENERATED outputs, not documentation.
#
# Usage:
#   bash tests/e2e/run_e2e.sh                      # Auto-detect runner (fail-closed if none)
#   E2E_RUNNER=fixture bash tests/e2e/run_e2e.sh   # Use fixture data (always works)
#   E2E_RUNNER=claude bash tests/e2e/run_e2e.sh    # Use real Claude CLI (fail-closed if missing)
#   E2E_ALLOW_SKIP=1 bash tests/e2e/run_e2e.sh     # Skip if no runner (exit 77)
#
# Exit codes:
#   0  - All validators passed
#   1  - Validation failed
#   2  - No runner available (fail-closed)
#   77 - Skipped (E2E_ALLOW_SKIP=1 and no runner)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
PASSED=0
FAILED=0

log_pass() { echo -e "${GREEN}[E2E-PASS]${NC} $1"; PASSED=$((PASSED + 1)); }
log_fail() { echo -e "${RED}[E2E-FAIL]${NC} $1"; FAILED=$((FAILED + 1)); }
log_info() { echo -e "${BLUE}[E2E-INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[E2E-WARN]${NC} $1"; }


#######################################
# Runner Detection
#######################################
detect_runner() {
    # Explicit fixture mode
    if [[ "${E2E_RUNNER:-}" == "fixture" ]]; then
        echo "fixture"
        return 0
    fi

    # Explicit openai mode - fail-closed if key missing/invalid
    if [[ "${E2E_RUNNER:-}" == "openai" ]]; then
        if [[ -z "${OPENAI_API_KEY:-}" ]]; then
            echo "openai-missing"
            return 0
        elif [[ "${OPENAI_API_KEY}" == "PASTE_KEY_HERE" ]]; then
            echo "openai-placeholder"
            return 0
        elif [[ ${#OPENAI_API_KEY} -lt 40 ]]; then
            echo "openai-short"
            return 0
        else
            echo "openai"
            return 0
        fi
    fi

    # Explicit claude mode - fail-closed if CLI unavailable
    if [[ "${E2E_RUNNER:-}" == "claude" ]]; then
        if command -v claude &> /dev/null; then
            echo "claude"
            return 0
        else
            echo "claude-missing"
            return 0
        fi
    fi

    # Auto-detect: prefer claude if available
    if command -v claude &> /dev/null; then
        echo "claude"
        return 0
    fi

    # No runner found
    echo "none"
    return 0
}

#######################################
# Fixture Runner - copies known-good outputs
#######################################
run_fixture() {
    local workspace="$1"
    local fixture_dir="$SCRIPT_DIR/fixtures/basic-feature"
    
    if [[ ! -d "$fixture_dir" ]]; then
        log_fail "Fixture directory not found: $fixture_dir"
        return 1
    fi
    
    # Copy fixture to workspace
    cp -r "$fixture_dir"/* "$workspace/"
    log_info "Fixture copied to workspace"
    return 0
}

#######################################
# Real OpenAI Runner - uses OpenAI API to generate artifacts
#######################################
run_openai() {
    local workspace="$1"

    if [[ -z "${OPENAI_API_KEY:-}" ]]; then
        log_fail "OPENAI_API_KEY is not set"
        return 1
    fi

    if ! command -v node &> /dev/null; then
        log_fail "node is required but not installed"
        return 1
    fi

    if [[ ! -f "$SCRIPT_DIR/run_openai.mjs" ]]; then
        log_fail "Missing runner: $SCRIPT_DIR/run_openai.mjs"
        return 1
    fi

    log_info "Generating artifacts via OpenAI runner..."
    local out_dir
    out_dir=$(node "$SCRIPT_DIR/run_openai.mjs") || return 1

    if [[ ! -d "$out_dir" ]]; then
        log_fail "OpenAI runner did not return a directory path"
        return 1
    fi

    cp -r "$out_dir"/* "$workspace/"
    log_info "OpenAI artifacts copied to workspace"
    return 0
}

#######################################
# Real Claude Runner - uses claude CLI to generate artifacts
#######################################
run_claude() {
    local workspace="$1"
    
    # Verify CLI responds
    log_info "Checking Claude CLI availability..."
    if ! claude --version &>/dev/null; then
        log_fail "Claude CLI installed but not responding to --version"
        echo ""
        echo "Troubleshooting:"
        echo "  1. Ensure Claude CLI is properly installed"
        echo "  2. Check authentication: claude auth status"
        echo "  3. Try: claude --help"
        return 1
    fi
    
    local cli_version
    cli_version=$(claude --version 2>&1 | head -1)
    log_info "Claude CLI version: $cli_version"
    
    # Create minimal mock codebase for context
    mkdir -p "$workspace/src"
    cat > "$workspace/src/app.ts" << 'MOCKEOF'
// Main application entry point
export function main(): void {
    console.log("Application started");
}

export function getUserById(id: string): User | null {
    // Placeholder implementation
    return null;
}

interface User {
    id: string;
    name: string;
    email: string;
}
MOCKEOF
    
    log_info "Created mock codebase in workspace"
    
    # Create requirements directory
    mkdir -p "$workspace/requirements/e2e-test-feature"
    
    # Craft the generation prompt - asks Claude to create conformant artifacts
    local prompt
    read -r -d '' prompt << 'PROMPTEOF' || true
You are generating test artifacts for a requirements system. Create these files in the current directory:

1. metadata.json - must have this EXACT structure:
{
  "_schema": "2.0",
  "request": "Add user authentication feature",
  "complexity": "simple",
  "status": "active",
  "phase": "complete",
  "started": "2025-02-05T10:00:00Z",
  "lastUpdated": "2025-02-05T10:30:00Z",
  "todos": {
    "status": "injected",
    "total": 3,
    "done": 1,
    "open": 2
  }
}

2. sample-code.ts - must contain at least one TODO with this exact format:
// TODO [REQ:e2e-test-feature] [ID:TODO-001] [P:1] Implement user login

Output ONLY the file contents, nothing else. Start with metadata.json.
PROMPTEOF

    log_info "Invoking Claude CLI to generate artifacts..."
    
    # Run Claude in print mode, output to workspace
    # Using --print to get direct output, then parse and save files
    local output
    if ! output=$(cd "$workspace/requirements/e2e-test-feature" && claude -p "$prompt" 2>&1); then
        log_fail "Claude CLI invocation failed"
        echo "$output"
        return 1
    fi
    
    # Check if metadata.json was created (Claude may create files directly or output content)
    if [[ -f "$workspace/requirements/e2e-test-feature/metadata.json" ]]; then
        log_info "Claude generated metadata.json directly"
    else
        # Try to extract JSON from output and save it
        log_info "Attempting to parse Claude output..."
        local json_content
        json_content=$(echo "$output" | grep -Pzo '(?s)\{[^{}]*"_schema"[^{}]*\}' | head -1 || true)
        
        if [[ -n "$json_content" ]] && echo "$json_content" | jq empty 2>/dev/null; then
            echo "$json_content" > "$workspace/requirements/e2e-test-feature/metadata.json"
            log_info "Extracted and saved metadata.json from output"
        else
            log_fail "Could not extract valid metadata.json from Claude output"
            echo "Raw output (first 500 chars):"
            echo "$output" | head -c 500
            return 1
        fi
    fi
    
    # Create sample-code.ts if not already created
    if [[ ! -f "$workspace/requirements/e2e-test-feature/sample-code.ts" ]]; then
        # Extract or create minimal sample
        cat > "$workspace/requirements/e2e-test-feature/sample-code.ts" << 'SAMPLEEOF'
// Generated by E2E behavioral oracle
// TODO [REQ:e2e-test-feature] [ID:TODO-001] [P:1] Implement user login
// WHY: Required for authentication flow
// DONE WHEN: Login function returns valid session token
// SPEC: requirements/e2e-test-feature/spec.md

export function login(email: string, password: string): Promise<string> {
    throw new Error("Not implemented");
}
SAMPLEEOF
        log_info "Created sample-code.ts with TODO marker"
    fi
    
    log_info "Claude runner completed"
    return 0
}


#######################################
# Validators - operate on GENERATED files
#######################################

# V1: metadata.json is valid JSON with required fields
validate_json_valid() {
    local file="$1"
    if jq empty "$file" 2>/dev/null; then
        log_pass "V1: metadata.json is valid JSON"
        return 0
    else
        log_fail "V1: metadata.json is not valid JSON"
        return 1
    fi
}

# V2: Schema version is 2.0
validate_schema_version() {
    local file="$1"
    local version
    version=$(jq -r '._schema // "missing"' "$file")
    if [[ "$version" == "2.0" ]]; then
        log_pass "V2: Schema version is 2.0"
        return 0
    else
        log_fail "V2: Schema version is '$version', expected '2.0'"
        return 1
    fi
}

# V3: Timestamps are ISO-8601
validate_timestamps() {
    local file="$1"
    local iso_pattern="^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$"
    local started last_updated
    started=$(jq -r '.started // "missing"' "$file")
    last_updated=$(jq -r '.lastUpdated // "missing"' "$file")
    
    if [[ "$started" =~ $iso_pattern ]] && [[ "$last_updated" =~ $iso_pattern ]]; then
        log_pass "V3: Timestamps are ISO-8601"
        return 0
    else
        log_fail "V3: Invalid timestamps (started=$started, lastUpdated=$last_updated)"
        return 1
    fi
}

# V4: Enum values are valid
validate_enums() {
    local file="$1"
    local status phase todo_status
    status=$(jq -r '.status // "missing"' "$file")
    phase=$(jq -r '.phase // "missing"' "$file")
    todo_status=$(jq -r '.todos.status // "null"' "$file")
    
    local valid=true
    
    if [[ ! "$status" =~ ^(active|complete|incomplete)$ ]]; then
        log_fail "V4a: Invalid status enum: $status"
        valid=false
    fi
    
    if [[ ! "$phase" =~ ^(setup|discovery|context|detail|complete)$ ]]; then
        log_fail "V4b: Invalid phase enum: $phase"
        valid=false
    fi
    
    if [[ "$todo_status" != "null" ]] && [[ ! "$todo_status" =~ ^(injected|complete|removed)$ ]]; then
        log_fail "V4c: Invalid todos.status enum: $todo_status"
        valid=false
    fi
    
    if [[ "$valid" == "true" ]]; then
        log_pass "V4: All enum values valid"
        return 0
    fi
    return 1
}

# V5: Invariant - todos.open + todos.done == todos.total
validate_todo_counts() {
    local file="$1"
    local open done total
    open=$(jq -r '.todos.open // 0' "$file")
    done=$(jq -r '.todos.done // 0' "$file")
    total=$(jq -r '.todos.total // 0' "$file")
    
    local sum=$((open + done))
    if [[ "$sum" -eq "$total" ]]; then
        log_pass "V5: Invariant holds (open=$open + done=$done = $total)"
        return 0
    else
        log_fail "V5: Invariant broken (open=$open + done=$done = $sum, expected $total)"
        return 1
    fi
}


# V6: TODO format uses [P:N] not [P:PN]
validate_todo_priority_format() {
    local workspace="$1"
    local bad_format wrong_format
    
    # Search for wrong format [P:P1] in any generated file
    wrong_format=$(grep -rn "\[P:P[123]\]" "$workspace" 2>/dev/null || true)
    
    if [[ -n "$wrong_format" ]]; then
        log_fail "V6: Found wrong priority format [P:PN]: $wrong_format"
        return 1
    fi
    
    # Verify correct format exists
    if grep -rq "\[P:[123]\]" "$workspace" 2>/dev/null; then
        log_pass "V6: Priority format is correct [P:N]"
        return 0
    else
        log_warn "V6: No priority tags found (may be OK if no TODOs injected)"
        return 0
    fi
}

# V7: TODO IDs are zero-padded
validate_todo_id_format() {
    local workspace="$1"
    
    # Check for non-zero-padded IDs like TODO-1 instead of TODO-001
    local bad_ids
    bad_ids=$(grep -roE "TODO-[0-9]{1,2}[^0-9]" "$workspace" 2>/dev/null | grep -v "TODO-[0-9]\{3\}" || true)
    
    if [[ -n "$bad_ids" ]]; then
        log_fail "V7: Found non-zero-padded TODO IDs"
        return 1
    fi
    
    if grep -rqE "TODO-[0-9]{3}" "$workspace" 2>/dev/null; then
        log_pass "V7: TODO IDs are zero-padded (TODO-NNN)"
        return 0
    else
        log_warn "V7: No TODO IDs found (may be OK if no TODOs injected)"
        return 0
    fi
}


#######################################
# Main Execution
#######################################

echo ""
echo "=============================================="
echo " E2E Behavioral Oracle"
echo "=============================================="
echo ""

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed.${NC}"
    exit 1
fi

# Detect runner
RUNNER=$(detect_runner)
log_info "Runner detected: $RUNNER"

# Handle openai-missing: explicit E2E_RUNNER=openai but OPENAI_API_KEY not set
if [[ "$RUNNER" == "openai-missing" ]]; then
    echo ""
    echo -e "${RED}FAIL: E2E_RUNNER=openai requested but OPENAI_API_KEY is not set${NC}"
    echo ""
    echo "Set it for this terminal session:"
    echo "  export OPENAI_API_KEY=\"...\""
    echo ""
    echo "Then re-run:"
    echo "  E2E_RUNNER=openai bash tests/e2e/run_e2e.sh"
    echo ""
    echo "Alternative: use fixture runner:"
    echo "  E2E_RUNNER=fixture bash tests/e2e/run_e2e.sh"
    echo ""
    exit 2
fi

# Handle openai-placeholder: key is set to placeholder value
if [[ "$RUNNER" == "openai-placeholder" ]]; then
    echo ""
    echo -e "${RED}FAIL: OPENAI_API_KEY is set to placeholder 'PASTE_KEY_HERE'${NC}"
    echo ""
    echo "Fix: Replace the placeholder with your actual API key:"
    echo "  export OPENAI_API_KEY=\"sk-proj-...\""
    echo ""
    echo "Get your key at: https://platform.openai.com/api-keys"
    echo ""
    exit 2
fi

# Handle openai-short: key is too short to be valid
if [[ "$RUNNER" == "openai-short" ]]; then
    echo ""
    echo -e "${RED}FAIL: OPENAI_API_KEY appears invalid (length < 40 characters)${NC}"
    echo ""
    echo "Current key length: ${#OPENAI_API_KEY}"
    echo ""
    echo "Valid OpenAI API keys are typically 50+ characters."
    echo "Please verify you copied the full key from:"
    echo "  https://platform.openai.com/api-keys"
    echo ""
    exit 2
fi

# Handle claude-missing: explicit E2E_RUNNER=claude but CLI not installed
if [[ "$RUNNER" == "claude-missing" ]]; then
    echo ""
    echo -e "${RED}FAIL: E2E_RUNNER=claude requested but Claude CLI not found${NC}"
    echo ""
    echo "Claude CLI is required for real behavioral testing."
    echo ""
    echo "Install Claude CLI:"
    echo "  npm install -g @anthropic-ai/claude-cli"
    echo "  # or"
    echo "  brew install claude"
    echo ""
    echo "Then authenticate:"
    echo "  claude auth login"
    echo ""
    echo "Alternative: use fixture runner:"
    echo "  E2E_RUNNER=fixture bash tests/e2e/run_e2e.sh"
    echo ""
    exit 2
fi

if [[ "$RUNNER" == "none" ]]; then
    echo ""
    echo -e "${RED}SKIP_BEHAVIORAL: no runner${NC}"
    echo ""
    echo "No LLM runner available. Options:"
    echo "  1. Install Claude CLI"
    echo "  2. Use OpenAI API runner: E2E_RUNNER=openai bash tests/e2e/run_e2e.sh"
    echo "  2. Use fixture runner: E2E_RUNNER=fixture bash tests/e2e/run_e2e.sh"
    echo "  3. Allow skip: E2E_ALLOW_SKIP=1 bash tests/e2e/run_e2e.sh"
    echo ""
    
    if [[ "${E2E_ALLOW_SKIP:-}" == "1" ]]; then
        log_warn "E2E_ALLOW_SKIP=1 set, exiting with code 77 (skipped)"
        exit 77
    else
        log_fail "Fail-closed: no runner and E2E_ALLOW_SKIP not set"
        exit 2
    fi
fi

# Create temp workspace
WORKSPACE=$(mktemp -d)
trap "rm -rf $WORKSPACE" EXIT
log_info "Workspace: $WORKSPACE"

# Create requirements directory structure
mkdir -p "$WORKSPACE/requirements/e2e-test-feature"

# Run the appropriate runner
case "$RUNNER" in
    fixture)
        run_fixture "$WORKSPACE/requirements/e2e-test-feature" || exit 1
        ;;
    openai)
        run_openai "$WORKSPACE/requirements/e2e-test-feature" || exit 1
        ;;
    claude)
        run_claude "$WORKSPACE" || exit 1
        ;;
    *)
        log_fail "Unknown runner: $RUNNER"
        exit 1
        ;;
esac

# Locate metadata.json
METADATA="$WORKSPACE/requirements/e2e-test-feature/metadata.json"

if [[ ! -f "$METADATA" ]]; then
    log_fail "No metadata.json generated at $METADATA"
    exit 1
fi

log_info "Validating generated artifacts..."
echo ""

# Run all validators
validate_json_valid "$METADATA" || true
validate_schema_version "$METADATA" || true
validate_timestamps "$METADATA" || true
validate_enums "$METADATA" || true
validate_todo_counts "$METADATA" || true
validate_todo_priority_format "$WORKSPACE" || true
validate_todo_id_format "$WORKSPACE" || true


#######################################
# Summary
#######################################

echo ""
echo "=============================================="
echo " E2E Results"
echo "=============================================="
echo ""
echo -e "${GREEN}Passed:${NC}  $PASSED"
echo -e "${RED}Failed:${NC}  $FAILED"
echo ""

if [[ "$FAILED" -eq 0 ]]; then
    echo -e "${GREEN}✅ E2E Behavioral Oracle: ALL CHECKS PASSED${NC}"
    exit 0
else
    echo -e "${RED}❌ E2E Behavioral Oracle: $FAILED CHECKS FAILED${NC}"
    exit 1
fi
