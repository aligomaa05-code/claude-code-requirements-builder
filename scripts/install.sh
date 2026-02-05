#!/bin/bash
# install.sh - Install claude-code-requirements-builder commands
#
# Usage:
#   bash scripts/install.sh              # Install to current project
#   bash scripts/install.sh --global     # Install to ~/.claude/commands/
#   bash scripts/install.sh --force      # Overwrite existing files
#   bash scripts/install.sh --help       # Show help
#
# Installs:
#   - Command files to .claude/commands/
#   - requirements/ directory structure
#   - .current-requirement tracker file

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Defaults
GLOBAL=false
FORCE=false
TARGET_DIR=""


#######################################
# Help
#######################################
show_help() {
    cat << 'EOF'
claude-code-requirements-builder installer

USAGE:
    bash scripts/install.sh [OPTIONS]

OPTIONS:
    --global    Install to ~/.claude/commands/ (user-wide)
    --force     Overwrite existing files without prompting
    --help      Show this help message

EXAMPLES:
    # Install to current project (recommended)
    bash scripts/install.sh

    # Install globally for all projects
    bash scripts/install.sh --global

    # Reinstall, overwriting existing files
    bash scripts/install.sh --force

WHAT GETS INSTALLED:
    Commands:     .claude/commands/requirements-*.md (12 files)
    Directory:    requirements/
    Tracker:      requirements/.current-requirement

EOF
    exit 0
}

#######################################
# Parse Arguments
#######################################
while [[ $# -gt 0 ]]; do
    case "$1" in
        --global)
            GLOBAL=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done


#######################################
# Determine Target Directory
#######################################
if [[ "$GLOBAL" == "true" ]]; then
    TARGET_DIR="$HOME/.claude/commands"
    REQ_DIR="$HOME/.claude/requirements"
    echo -e "${BLUE}Installing globally to ~/.claude/${NC}"
else
    TARGET_DIR="$(pwd)/.claude/commands"
    REQ_DIR="$(pwd)/requirements"
    echo -e "${BLUE}Installing to current project: $(pwd)${NC}"
fi

#######################################
# Safety Check: Existing Files
#######################################
check_existing() {
    local conflicts=()
    
    if [[ -d "$TARGET_DIR" ]] && [[ "$FORCE" != "true" ]]; then
        local existing
        existing=$(ls -1 "$TARGET_DIR"/requirements-*.md 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$existing" -gt 0 ]]; then
            conflicts+=("$TARGET_DIR (contains $existing command files)")
        fi
    fi
    
    if [[ ${#conflicts[@]} -gt 0 ]]; then
        echo -e "${RED}Error: Would overwrite existing files:${NC}"
        for c in "${conflicts[@]}"; do
            echo "  - $c"
        done
        echo ""
        echo "Use --force to overwrite, or remove existing files first."
        exit 1
    fi
}

check_existing


#######################################
# Install Commands
#######################################
echo ""
echo "Installing commands..."

mkdir -p "$TARGET_DIR"

CMD_COUNT=0
for cmd_file in "$PROJECT_ROOT"/commands/requirements-*.md; do
    if [[ -f "$cmd_file" ]]; then
        cp "$cmd_file" "$TARGET_DIR/"
        CMD_COUNT=$((CMD_COUNT + 1))
    fi
done

echo -e "${GREEN}✓${NC} Installed $CMD_COUNT command files to $TARGET_DIR"

#######################################
# Bootstrap Requirements Directory
#######################################
echo ""
echo "Bootstrapping requirements directory..."

mkdir -p "$REQ_DIR"

# Create .current-requirement if it doesn't exist
TRACKER="$REQ_DIR/.current-requirement"
if [[ ! -f "$TRACKER" ]]; then
    touch "$TRACKER"
    echo -e "${GREEN}✓${NC} Created $TRACKER"
else
    echo -e "${YELLOW}→${NC} $TRACKER already exists (kept)"
fi

# Create index.md if it doesn't exist
INDEX="$REQ_DIR/index.md"
if [[ ! -f "$INDEX" ]]; then
    cat > "$INDEX" << 'EOF'
# Requirements Index

| Date | Name | Status | Spec |
|------|------|--------|------|
<!-- Requirements will be listed here -->
EOF
    echo -e "${GREEN}✓${NC} Created $INDEX"
else
    echo -e "${YELLOW}→${NC} $INDEX already exists (kept)"
fi


#######################################
# Summary
#######################################
echo ""
echo "════════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ Installation complete!${NC}"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Commands installed to: $TARGET_DIR"
echo "Requirements dir:      $REQ_DIR"
echo ""
echo "Next steps:"
echo "  1. Open Claude Code in your project"
echo "  2. Type: /requirements-start \"your feature description\""
echo "  3. Answer the questions"
echo "  4. Get your requirements spec!"
echo ""
echo "Run tests:  bash scripts/demo.sh"
echo "Full docs:  cat README.md"
echo ""
