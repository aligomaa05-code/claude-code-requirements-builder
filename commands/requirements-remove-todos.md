# Remove TODOs

Remove injected TODO comments from codebase files for a specific requirement.

## Aliases
- /requirements-remove-todos
- /remove-todos

## Arguments
`$ARGUMENTS`: Optional requirement ID | Required: no
- If provided: remove TODOs for that specific requirement
- If omitted: remove TODOs for current active requirement

## Prerequisites
- Requirement exists with todos.status = "injected" or "complete"
- 08-todo-manifest.md exists (source of truth for which files to clean)

## Process

### Step 1: Load Requirement
1. Determine requirement ID (from $ARGUMENTS or .current-requirement)
2. Load metadata.json
3. Verify todos.status = "injected" or "complete"
4. If status is neither: exit with "No TODOs to remove for this requirement."

### Step 2: Confirm with User
```
⚠️  Remove TODOs for: [requirement-name]

This will remove [X] TODOs from [Y] files:
  • src/services/AuthService.ts (1 TODO)
  • src/utils/validation.ts (1 TODO)
  • ...

Files created by injection (empty after removal) will be deleted.

Continue? (y/n)
```

Wait for explicit "y" or "yes" before proceeding.

### Step 3: Remove TODOs from Files
1. Parse 08-todo-manifest.md to get file list with actions (Created/Modified)
2. For each file:
   a. Read file content
   b. Find all lines containing BOTH patterns: `[REQ:<this-requirement-id>]` AND `[ID:TODO-`
      (This dual-anchor prevents false matches on unrelated content)
   c. Determine format by checking if next line contains `WHY:`
      - If yes: full format — remove this line and next 3 lines (4 total)
      - If no: compact format — remove only this single line
   d. If file action was "Created", also remove header comments:
      - Lines containing: `Created for requirement: <this-requirement-id>`
      - Lines containing: `Generated:` (immediately after above)
      - Lines containing: `Implementation goes below`
   e. Remove any resulting double-blank-lines (normalize to single blank)
   f. Write updated content
   g. Track if file is now empty

### Step 4: Delete Empty Created Files
For files where action was "Created" and file content matches whitespace-only pattern:

**Whitespace-Only Definition:**
```
Pattern: /^\s*$/  (entire file content)
Matches: Zero or more of: space, tab, newline, carriage return, form feed
Does NOT match: Any printable character, BOM, or non-ASCII bytes
```

**Algorithm:**
1. Read file content as string
2. Test against `/^\s*$/`
3. If match: delete file, track as deleted
4. If no match: preserve file, do not track as deleted

**Examples:**
| Content | Matches | Action |
|---------|---------|--------|
| (empty file, 0 bytes) | Yes | Delete |
| `\n` | Yes | Delete |
| `  \t\n\n` | Yes | Delete |
| `// comment` | No | Preserve |
| `\n// code\n` | No | Preserve |

### Step 5: Update Metadata
```json
{
  "todos": {
    "status": "removed",
    "lastUpdated": "[ISO-8601 timestamp]",
    "total": 0,
    "open": 0,
    "done": 0,
    "files": []
  }
}
```

### Step 6: Update Manifest
Add removal record to 08-todo-manifest.md:
```markdown
## Removal Log

**Removed**: [ISO-8601 timestamp]
**Reason**: User requested removal
**Files cleaned**: [X]
**Files deleted**: [Y]
```

### Step 7: Display Results
```
✅ TODOs Removed: [requirement-name]

Cleaned [X] files:
  • src/services/AuthService.ts ✓
  • src/utils/validation.ts ✓

Deleted [Y] empty files:
  • src/middleware/rateLimit.ts (was TODO-only)

Manifest updated: requirements/[folder]/08-todo-manifest.md
```

## Error Handling
| Condition | Response |
|-----------|----------|
| No requirement specified | "No requirement specified. Use: /remove-todos [requirement-id]" |
| Requirement not found | "Requirement not found: [id]" |
| No TODOs to remove | "No TODOs to remove. Status must be 'injected' or 'complete'." |
| File not found during removal | Warning only, continue with other files |
| User declines confirmation | "Cancelled. No changes made." |

## Rules
- Always require user confirmation before removing
- Only remove TODOs matching the specific requirement ID
- Preserve all non-TODO content in files
- Delete created files only if they're empty after TODO removal
- Update manifest with removal log (audit trail)

## Metadata Updates
- Set `todos.status` to "removed"
- Set `todos.total`, `open`, `done` to 0
- Set `todos.files` to empty array
- Set `todos.lastUpdated` to current timestamp
