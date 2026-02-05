# Mark TODO Done

Mark a specific TODO as completed and update tracking.

## Aliases
- /requirements-todo-done
- /todo-done

## Arguments
`$ARGUMENTS`: TODO ID | Required: yes
- Format: `TODO-001` or `requirement-id:TODO-001`
- If no requirement prefix, uses current active requirement

## Process

### Step 1: Parse Arguments
1. If format is `TODO-NNN`: use current requirement from .current-requirement
2. If format is `req-id:TODO-NNN`: use specified requirement
3. If no active requirement and no prefix: error

### Step 2: Load and Validate
1. Load metadata.json for the requirement
2. Verify todos.status = "injected"
3. Load 08-todo-manifest.md
4. Find the specified TODO
5. If not found: error with available TODO IDs

### Step 3: Update Manifest
Change TODO status in 08-todo-manifest.md:
```
Before: ### TODO-001 ⬜
After:  ### TODO-001 ✅
```

Add completion timestamp:
```
**Completed**: [ISO-8601 timestamp]
```

### Step 4: Update Metadata
```json
{
  "todos": {
    "open": [decrement by 1],
    "done": [increment by 1],
    "lastUpdated": "[ISO-8601 timestamp]"
  }
}
```

### Step 5: Check Completion
If todos.open = 0:
- Update todos.status to "complete"
- Display celebration message

### Step 6: Display Result
```
✅ TODO-001 marked done: [task description]

Progress: [X] open, [Y] done of [Z] total
[████████░░] 80%

Remaining:
  ⬜ TODO-002 [P1] Create auth routes
  ⬜ TODO-003 [P2] Add rate limiting
```

If all complete:
```
🎉 All TODOs complete for [requirement-name]!

All [X] tasks finished. Consider:
  • Run verification: /verify
  • Start next requirement: /requirements-start
```

## Error Handling
| Condition | Response |
|-----------|----------|
| No TODO ID provided | "Usage: /todo-done TODO-001" |
| No active requirement | "No active requirement. Use: /todo-done req-id:TODO-001" |
| TODO not found | "TODO-001 not found. Available: TODO-001, TODO-002, ..." |
| TODO already done | "TODO-001 is already marked done." |
| No TODOs injected | "No TODOs exist for this requirement." |

## Rules
- Only marks manifest and metadata (doesn't modify codebase files)
- User responsible for actually removing TODO comment from code
- Progress percentage shown to motivate completion
