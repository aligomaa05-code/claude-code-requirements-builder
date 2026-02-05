# Inject TODOs

Insert scoped TODO comments into codebase files based on the requirements specification.

## Aliases
- /requirements-inject-todos
- /inject-todos

## Arguments
`$ARGUMENTS`: Optional requirement ID | Required: no
- If provided: inject TODOs for that specific requirement
- If omitted: inject TODOs for current active requirement

## Prerequisites
- 06-requirements-spec.md exists with Implementation Map section
- 03-context-findings.md exists (for file context verification)
- Requirement status is "complete" (spec generation finished)

## Process

### Step 1: Load Requirement Data
1. If $ARGUMENTS provided, use as requirement ID (folder name)
2. Else read `requirements/.current-requirement` for active requirement
3. If neither exists: error with guidance
4. Load metadata.json from requirement folder
5. Verify status allows injection (not "cancelled" or "abandoned")
6. Check validation status:
   - If no validation section: warn "Spec not validated. Consider running /validate first. Continue anyway? (y/n)"
   - If validation.status = "failed": warn "Validation failed (score: [X]). Fix issues before injecting. Continue anyway? (y/n)"
   - If validation.status = "passed": proceed without warning

### Step 2: Parse Implementation Map
1. Read 06-requirements-spec.md
2. Locate "## Implementation Map" section
3. Parse markdown table into structured list:
   - Expected column order: #, Requirement, Target File, Priority, Notes
   - Extract for each row:
     - num: Value from # column (used for TODO ID)
     - requirement: Value from Requirement column
     - targetFile: Value from Target File column (may have [NEW] prefix)
     - priority: Value from Priority column (P1, P2, or P3)
       
       **Priority Conversion Rule:**
       ```
       Input (table):  "P1" | "P2" | "P3"  (case-insensitive)
       Validation:     Must match /^P[123]$/i — else ERROR (wrong format)
       Internal:       Strip "P" → numeric 1, 2, or 3
       Output (code):  [P:1], [P:2], or [P:3]
       Output (display): P1, P2, P3
       ```
       
     - notes: Value from Notes column (may be empty)
4. If Implementation Map section missing or empty: exit with error
5. If table has wrong format or missing columns: exit with error listing expected format

### Step 3: Validate Target Files
For each item in parsed Implementation Map:
1. If targetFile starts with `[NEW]`:
   - Strip prefix, mark for creation
   - Infer language from extension
2. Else verify file exists in codebase:
   - If exists: continue
   - If not found: prompt user with options:
     ```
     File not found: [path]
     Options:
     1. Create it (empty with TODO)
     2. Skip this TODO
     3. Specify different path: _____
     ```
3. Build final validated file list with actions (modify/create/skip)

### Step 4: Generate TODO Content
For each non-skipped Implementation Map item:

Determine TODO format based on priority:
- P1/P2: Full format (4 lines)
- P3: Compact format (1 line)

Full format:
```
// TODO [REQ:<folder-name>] [ID:TODO-<NNN>] [P:<1|2|3>] <requirement>
// WHY: <derived from spec Overview or section context>
// DONE WHEN: <derived from Acceptance Criteria if available, else from requirement>
// SPEC: requirements/<folder-name>/06-requirements-spec.md
```

Compact format (P:3 only):
```
// TODO [REQ:<folder-name>] [ID:TODO-<NNN>] [P:3] <requirement>
```

Priority format: `[P:1]`, `[P:2]`, or `[P:3]` (numeric, not P1/P2/P3)

TODO ID format: TODO-001, TODO-002, etc. (sequential, zero-padded to 3 digits)

### Step 5: Determine Comment Syntax
Based on target file extension:

| Extension | Syntax |
|-----------|--------|
| .js, .ts, .tsx, .jsx, .go, .java, .c, .cpp, .swift | `// comment` |
| .py, .rb, .sh, .yaml, .yml | `# comment` |
| .css, .scss | `/* comment */` |
| .html, .xml, .vue, .svelte | `<!-- comment -->` |
| .sql | `-- comment` |
| .md | `<!-- comment -->` |
| Unknown | `# comment` (fallback) |

### Step 6: Insert TODOs into Files
For each target file:

**For existing files:**
1. Read current content
2. Find insertion point: after imports/headers, before first code block
   - JS/TS: after last `import` line
   - Python: after last `import` or `from` line
   - Other: line 1 (top of file)
3. Insert blank line, then all TODOs for this file, then blank line
4. Write updated content
5. Record line numbers where TODOs were inserted

**For new files ([NEW] prefix):**
1. Create file with language-appropriate header comment:
   ```
   // [filename] - Created for requirement: [requirement-name]
   // Generated: [ISO-8601 timestamp]
   
   [TODOs here]
   
   // Implementation goes below
   ```
2. Do NOT add imports - user will add appropriate imports during implementation
3. Record as newly created

### Step 7: Create TODO Manifest
Create 08-todo-manifest.md in requirement folder:

```markdown
# TODO Manifest: [Requirement Name]

**Requirement**: [folder-name]
**Generated**: [ISO-8601 timestamp]
**Status**: [X] open, 0 done of [X] total

## TODOs

### TODO-001 ⬜
**File**: `[path]:[line-number]`
**Priority**: P1
**Task**: [requirement text]
**Done when**: [acceptance criteria]

### TODO-002 ⬜
**File**: `[path]:[line-number]`
**Priority**: P1
**Task**: [requirement text]
**Done when**: [acceptance criteria]

[Continue for all TODOs...]

## Files Modified

| File | TODOs | Action |
|------|-------|--------|
| [path] | TODO-001, TODO-002 | Modified |
| [path] | TODO-003 | Created |
```

### Step 8: Update Metadata
Update metadata.json with todos section:
```json
{
  "todos": {
    "status": "injected",
    "lastUpdated": "[ISO-8601 timestamp]",
    "total": [number of TODOs],
    "open": [same as total],
    "done": 0,
    "files": ["path1", "path2", "..."]
  }
}
```

### Step 9: Display Results
```
✅ TODOs Injected: [requirement-name]

Created [X] TODOs across [Y] files:

  📄 src/services/ReportService.ts
     └─ TODO-001 [P1] Add PDF generation method
     └─ TODO-002 [P1] Implement page formatting
  
  📄 src/api/reports.ts
     └─ TODO-003 [P1] Add POST /reports/:id/pdf endpoint
  
  📄 [NEW] src/utils/pdfHelpers.ts
     └─ TODO-004 [P2] Create PDF utility functions

Manifest: requirements/[folder]/08-todo-manifest.md

Next steps:
  • View full manifest: cat requirements/[folder]/08-todo-manifest.md
  • Find all TODOs: grep -rn "TODO \[REQ:[folder]" src/
  • Start implementing: open any file and find TODO-001

⚠️  TODOs are now in your codebase. Consider committing this state.
```

## Output Files
| File | Action |
|------|--------|
| 08-todo-manifest.md | Create |
| metadata.json | Update (todos section) |
| [target files from Implementation Map] | Modify or Create |

## Error Handling
| Condition | Response |
|-----------|----------|
| No requirement specified or active | "No requirement specified. Use: /inject-todos [requirement-id]" |
| Requirement folder not found | "Requirement not found: [id]. Use /requirements-list to see available." |
| 06-requirements-spec.md missing | "Spec not found. Run /requirements-end first to generate." |
| Implementation Map section missing | "Spec missing Implementation Map. Add manually or regenerate with /requirements-end" |
| Implementation Map wrong format | "Implementation Map table has wrong format. Expected columns: #, Requirement, Target File, Priority, Notes" |
| Implementation Map empty (no rows) | "Implementation Map has no items. Nothing to inject." |
| File write permission denied | "Cannot write to [path]. Check permissions." |
| TODOs already injected (todos.status = "injected") | "TODOs already injected for this requirement. Re-running is safe (existing TODOs will be skipped). Continue? (y/n)" |

## Rules
- Never modify files outside project directory
- Preserve all existing file content (insert only, never delete)
- TODOs grouped by file, inserted once per file (one write pass; multiple TODO blocks if multiple map rows target same file)
- Sequential TODO IDs within requirement (TODO-001, TODO-002, ...)
- Full format for P1/P2, compact format for P3
- Always create manifest even if only one TODO

### Idempotency Rule

**Key:** Combination of REQ (folder name) + ID (TODO-NNN)

**Detection Pattern:**
```
TODO [REQ:<folder-name>] [ID:<todo-id>]
```

**Regex:**
```
/TODO \[REQ:FOLDER\] \[ID:TODO-NNN\]/
```
Where `FOLDER` is the exact requirement folder name and `TODO-NNN` is the exact TODO ID.

**Algorithm:**
```
FOR each TODO to inject:
  1. Build detection pattern:
     pattern = "TODO [REQ:" + folder + "] [ID:" + todoId + "]"
  
  2. Read target file content
  
  3. Search for pattern (case-sensitive, exact substring match)
  
  4. IF pattern found in file:
       Log: "Skipping {todoId} - already exists in {file}"
       SKIP this TODO
     ELSE:
       INSERT TODO at appropriate location
       Log: "Inserted {todoId} into {file}"
```

**Idempotency Guarantee:**
Running `/inject-todos` N times produces identical result to running once.

**Edge Cases:**

| Situation | Detection | Action |
|-----------|-----------|--------|
| TODO exists in code, manifest exists | Pattern found | Skip (normal) |
| TODO missing from code, manifest exists | Pattern not found | Warn, offer re-inject |
| TODO exists in code, manifest missing | Pattern found | Skip, warn orphan |
| Different requirement has same TODO-001 | Different REQ prefix | No collision |

## Metadata Updates
After successful injection:
- Set `todos.status` to "injected"
- Set `todos.lastUpdated` to current ISO timestamp
- Set `todos.total` to count of TODOs created
- Set `todos.open` to same as total (all start open)
- Set `todos.done` to 0
- Set `todos.files` to array of modified/created file paths

## Phase Transition
- **On success**: Remain in "complete" status, TODOs now in codebase
- **On partial success**: Inject what's possible, report failures, still update metadata
- **On failure**: No state change, no files modified, clear error message
