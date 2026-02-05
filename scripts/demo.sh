#!/bin/bash
# demo.sh - Run a demonstration of claude-code-requirements-builder
#
# Usage:
#   bash scripts/demo.sh              # Create demo workspace with example artifacts
#   bash scripts/demo.sh --e2e        # Run E2E harness if runner available
#   bash scripts/demo.sh --clean      # Remove demo workspace
#
# Creates a temporary demo workspace with example artifacts to show
# what the requirements gathering workflow produces.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Demo workspace location
DEMO_DIR="${DEMO_DIR:-$PROJECT_ROOT/demo-workspace}"


#######################################
# Parse Arguments
#######################################
RUN_E2E=false
CLEAN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --e2e)
            RUN_E2E=true
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --help|-h)
            echo "Usage: bash scripts/demo.sh [--e2e|--clean]"
            echo ""
            echo "Options:"
            echo "  --e2e    Run E2E harness instead of creating demo"
            echo "  --clean  Remove demo workspace"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

#######################################
# Clean Mode
#######################################
if [[ "$CLEAN" == "true" ]]; then
    if [[ -d "$DEMO_DIR" ]]; then
        rm -rf "$DEMO_DIR"
        echo -e "${GREEN}✓${NC} Removed demo workspace: $DEMO_DIR"
    else
        echo -e "${YELLOW}→${NC} No demo workspace to clean"
    fi
    exit 0
fi

#######################################
# E2E Mode
#######################################
if [[ "$RUN_E2E" == "true" ]]; then
    echo -e "${BLUE}Running E2E harness...${NC}"
    echo ""
    E2E_RUNNER=fixture bash "$PROJECT_ROOT/tests/e2e/run_e2e.sh"
    exit $?
fi


#######################################
# Demo Mode: Create Example Artifacts
#######################################
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     claude-code-requirements-builder DEMO                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Create demo workspace
mkdir -p "$DEMO_DIR/requirements/demo-user-login"
mkdir -p "$DEMO_DIR/src"

echo -e "${BLUE}Creating demo workspace...${NC}"
echo ""

# Create metadata.json
cat > "$DEMO_DIR/requirements/demo-user-login/metadata.json" << 'EOF'
{
  "_schema": "2.0",
  "request": "Add user login with email and password",
  "status": "complete",
  "phase": "complete",
  "started": "2025-02-05T10:00:00Z",
  "lastUpdated": "2025-02-05T12:00:00Z",
  "complexity": {
    "level": "moderate",
    "questionCounts": { "discovery": 5, "detail": 5 }
  },
  "progress": {
    "discovery": { "answered": 5, "total": 5 },
    "detail": { "answered": 5, "total": 5 }
  },
  "validation": {
    "status": "passed",
    "score": 90,
    "blocking": 0,
    "warnings": 1
  },
  "todos": {
    "status": "injected",
    "total": 3,
    "open": 2,
    "done": 1,
    "files": ["src/auth.ts", "src/login.tsx"]
  }
}
EOF
echo -e "${GREEN}✓${NC} Created metadata.json"


# Create 00-initial-request.md
cat > "$DEMO_DIR/requirements/demo-user-login/00-initial-request.md" << 'EOF'
# Initial Request

**User**: Add user login with email and password

**Received**: 2025-02-05T10:00:00Z
EOF
echo -e "${GREEN}✓${NC} Created 00-initial-request.md"

# Create 06-requirements-spec.md
cat > "$DEMO_DIR/requirements/demo-user-login/06-requirements-spec.md" << 'EOF'
# Requirements Specification: User Login

## Overview
Implement email/password authentication for users.

## Functional Requirements
1. Users can log in with email and password
2. Invalid credentials show error message
3. Successful login redirects to dashboard

## Implementation Map

| # | Requirement | Target File | Priority | Notes |
|---|-------------|-------------|----------|-------|
| 1 | Auth service with login method | src/auth.ts | P1 | Core logic |
| 2 | Login form component | src/login.tsx | P1 | UI |
| 3 | Rate limiting | src/auth.ts | P3 | Security |
EOF
echo -e "${GREEN}✓${NC} Created 06-requirements-spec.md"

# Create 08-todo-manifest.md
cat > "$DEMO_DIR/requirements/demo-user-login/08-todo-manifest.md" << 'EOF'
# TODO Manifest: demo-user-login

**Generated**: 2025-02-05T12:00:00Z
**Status**: 2 open, 1 done of 3 total

## TODOs

### TODO-001 ✅
**File**: `src/auth.ts:4`
**Priority**: P1
**Task**: Create auth service with login method

### TODO-002 ⬜
**File**: `src/login.tsx:4`
**Priority**: P1
**Task**: Create login form component

### TODO-003 ⬜
**File**: `src/auth.ts:15`
**Priority**: P3
**Task**: Add rate limiting
EOF
echo -e "${GREEN}✓${NC} Created 08-todo-manifest.md"


# Create src/auth.ts with TODOs
cat > "$DEMO_DIR/src/auth.ts" << 'EOF'
// auth.ts - Created for requirement: demo-user-login
// Generated: 2025-02-05T12:00:00Z

// TODO [REQ:demo-user-login] [ID:TODO-001] [P:1] Create auth service with login method
// WHY: Core authentication required for user access
// DONE WHEN: login(email, password) returns JWT token or error
// SPEC: requirements/demo-user-login/06-requirements-spec.md

// Implementation goes below
export class AuthService {
  async login(email: string, password: string): Promise<string> {
    // TODO: Implement actual login logic
    return "jwt-token";
  }
}

// TODO [REQ:demo-user-login] [ID:TODO-003] [P:3] Add rate limiting
EOF
echo -e "${GREEN}✓${NC} Created src/auth.ts (with P1 + P3 TODOs)"

# Create src/login.tsx with TODO
cat > "$DEMO_DIR/src/login.tsx" << 'EOF'
// login.tsx - Created for requirement: demo-user-login
// Generated: 2025-02-05T12:00:00Z

// TODO [REQ:demo-user-login] [ID:TODO-002] [P:1] Create login form component
// WHY: Users need UI to enter credentials
// DONE WHEN: Form submits email/password to AuthService
// SPEC: requirements/demo-user-login/06-requirements-spec.md

// Implementation goes below
export function LoginForm() {
  return <form>Login form here</form>;
}
EOF
echo -e "${GREEN}✓${NC} Created src/login.tsx (with P1 TODO)"


#######################################
# Run Validators on Demo
#######################################
echo ""
echo -e "${BLUE}Running validators on demo artifacts...${NC}"
echo ""

# Source validators
source "$PROJECT_ROOT/tests/output-validators.sh"

# Run validation
REQ_DIR="$DEMO_DIR/requirements/demo-user-login"
CODE_DIR="$DEMO_DIR/src"

DEMO_PASSED=0
DEMO_FAILED=0

if validate_metadata_structure "$REQ_DIR/metadata.json" "DEMO-O1"; then
    DEMO_PASSED=$((DEMO_PASSED + 1))
else
    DEMO_FAILED=$((DEMO_FAILED + 1))
fi

if validate_p1_p2_todo_format "$CODE_DIR" "DEMO-O2"; then
    DEMO_PASSED=$((DEMO_PASSED + 1))
else
    DEMO_FAILED=$((DEMO_FAILED + 1))
fi

if validate_p3_todo_format "$CODE_DIR" "DEMO-O3"; then
    DEMO_PASSED=$((DEMO_PASSED + 1))
else
    DEMO_FAILED=$((DEMO_FAILED + 1))
fi

if validate_manifest_metadata_invariants "$REQ_DIR" "DEMO-O4"; then
    DEMO_PASSED=$((DEMO_PASSED + 1))
else
    DEMO_FAILED=$((DEMO_FAILED + 1))
fi


#######################################
# Summary
#######################################
echo ""
echo "════════════════════════════════════════════════════════════"
if [[ "$DEMO_FAILED" -eq 0 ]]; then
    echo -e "${GREEN}✅ Demo complete! All $DEMO_PASSED validators passed.${NC}"
else
    echo -e "${RED}⚠️  Demo complete with $DEMO_FAILED validator failures.${NC}"
fi
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Demo artifacts created in: $DEMO_DIR"
echo ""
echo "Explore the outputs:"
echo "  cat $DEMO_DIR/requirements/demo-user-login/metadata.json"
echo "  cat $DEMO_DIR/requirements/demo-user-login/06-requirements-spec.md"
echo "  cat $DEMO_DIR/requirements/demo-user-login/08-todo-manifest.md"
echo "  cat $DEMO_DIR/src/auth.ts"
echo ""
echo "Clean up:  bash scripts/demo.sh --clean"
echo "Run E2E:   bash scripts/demo.sh --e2e"
echo ""

if [[ "$DEMO_FAILED" -eq 0 ]]; then
    exit 0
else
    exit 1
fi
