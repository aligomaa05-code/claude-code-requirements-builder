# List TODOs

List all TODOs across all requirements in the project.

## Aliases
- /requirements-todos
- /todos

## Arguments
`$ARGUMENTS`: Optional filter | Required: no
- `open` — Show only open TODOs (default)
- `done` — Show only completed TODOs
- `all` — Show all TODOs regardless of status

## Process

### Step 1: Find All Requirements
1. List all folders in `requirements/` directory
2. Filter to valid requirement folders (match YYYY-MM-DD-HHMM-* pattern)
3. For each folder, check if 08-todo-manifest.md exists

### Step 2: Collect TODOs
For each requirement with a manifest:
1. Parse 08-todo-manifest.md
2. Extract TODO entries with their status (⬜/✅)
3. Apply filter from $ARGUMENTS

### Step 3: Display Results
```
📋 Project TODOs

┌─ 2025-01-27-1430-user-authentication (8 open, 7 done)
│  ⬜ TODO-001 [P1] Add User model to schema
│  ⬜ TODO-002 [P1] Create AuthService
│  ✅ TODO-003 [P1] Add password validation
│  ...
│
├─ 2025-01-28-0900-pdf-export (5 open, 0 done)
│  ⬜ TODO-001 [P1] Add PDF generation method
│  ⬜ TODO-002 [P1] Create PDF endpoint
│  ...

Summary: 13 open, 7 done across 2 requirements
```

If no TODOs found:
```
📋 Project TODOs

No TODOs found. 

To inject TODOs:
1. Complete a requirement: /requirements-end
2. Inject TODOs: /inject-todos
```

## Error Handling
| Condition | Response |
|-----------|----------|
| No requirements folder | "No requirements/ folder found." |
| No manifests exist | "No TODOs found" message with guidance |
| Invalid filter argument | "Unknown filter: [X]. Use: open, done, or all" |

## Rules
- Read-only command (no modifications)
- Always show requirement context (which requirement each TODO belongs to)
- Sort by: requirements (newest first), then TODO ID within requirement
- Show priority in output [P1], [P2], [P3]
