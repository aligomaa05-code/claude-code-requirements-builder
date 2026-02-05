# End Requirements Gathering

Finalize the current requirement gathering session.

## Instructions:

1. Read requirements/.current-requirement
2. If no active requirement:
   - Show "No active requirement to end"
   - Exit

3. Show current status and ask user intent:
   
   **If phase == "complete":**
   ```
   ⚠️ Ending requirement: [name]
   Current phase: Complete ✓
   
   What would you like to do?
   1. Generate spec with current information
   2. Mark as incomplete for later
   3. Cancel and delete
   ```
   
   **If phase != "complete":**
   ```
   ⚠️ Ending requirement: [name]
   Current phase: [phase] ([X/Y] complete)
   
   ❌ Gathering not complete. Option 1 unavailable.
   
   What would you like to do?
   2. Mark as incomplete for later
   3. Cancel and delete
   ```

4. Based on choice:

### Option 1: Generate Spec
- Create 06-requirements-spec.md
- Include all answered questions
- Add defaults for unanswered with "ASSUMED:" prefix
- Generate implementation hints
- Generate Implementation Map (REQUIRED for TODO injection)
- Update metadata to v2 schema:
  - Add `"_schema": "2.0"` if not present
- Update metadata status to "complete"

### Option 2: Mark Incomplete
- Update metadata status to "incomplete"
- Add "lastUpdated" timestamp
- Create summary of progress
- Note what's still needed

### Option 3: Cancel
- Confirm deletion
- Remove requirement folder
- Clear .current-requirement

## Final Spec Format:
```markdown
# Requirements Specification: [Name]

Generated: [timestamp]
Status: [Complete with X assumptions / Partial]

## Overview
[Problem statement and solution summary]

## Detailed Requirements

### Functional Requirements
[Based on answered questions]

### Technical Requirements
- Affected files: [list with paths]
- New components: [if any]
- Database changes: [if any]

### Assumptions
[List any defaults used for unanswered questions]

### Implementation Notes
[Specific guidance for implementation]

### Acceptance Criteria
[Testable criteria for completion]

## Implementation Map

[REQUIRED: Maps each requirement to target files for TODO injection]

| # | Requirement | Target File | Priority | Notes |
|---|-------------|-------------|----------|-------|
| 1 | [Requirement summary] | [path/to/file.ts] | P1 | [Dependencies] |
| 2 | [Requirement summary] | [path/to/file.ts] | P1 | |
| 3 | [Requirement summary] | [NEW] path/to/new-file.ts | P2 | Depends on #1 |

### Priority Definitions
- **P1 (Must)**: Core functionality, blocking, implement first
- **P2 (Should)**: Important but not blocking
- **P3 (Could)**: Nice-to-have, defer if time-constrained

### Mapping Rules
1. Every actionable item from Functional/Technical Requirements gets a row
2. Small related items can share a row (combine in Requirement column)
3. Target File from 03-context-findings.md or best inference from codebase
4. If file doesn't exist yet, prefix with: `[NEW]`
5. Note dependencies: "Depends on #N" or "Blocked by [condition]"
6. Keep Requirement column under 80 characters (full detail is in spec above)
```

5. Clear .current-requirement
6. Update requirements/index.md
7. Display next steps:
   ```
   ✅ Spec generated: requirements/[folder]/06-requirements-spec.md
   
   Recommended next steps:
     1. Validate spec: /validate (catches issues before implementation)
     2. Inject TODOs: /inject-todos (adds work items to codebase)
   ```

## Error Handling
| Condition | Response |
|-----------|----------|
| No active requirement | "No active requirement to end. Use /requirements-start to begin." |
| metadata.json missing | "Cannot end: metadata.json not found." |
| User cancels at confirmation | "Cancelled. Requirement unchanged." |
| File write fails during spec generation | "Failed to write spec file. Check permissions." |
| Option 3 deletion fails | "Could not delete folder. Check permissions. Folder may need manual removal." |
