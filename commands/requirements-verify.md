# Verify Implementation

Check that completed TODOs were actually implemented correctly.

## Aliases
- /requirements-verify
- /verify

## Arguments
`$ARGUMENTS`: Optional requirement ID | Required: no
- If provided: verify that specific requirement
- If omitted: verify current active requirement

## Prerequisites
- Requirement has TODOs (todos.status = "injected" or "complete")
- At least one TODO marked done (todos.done > 0)

## Process

### Step 1: Load Requirement
1. Determine requirement ID
2. Load metadata.json
3. Load 06-requirements-spec.md (for acceptance criteria)
4. Load 08-todo-manifest.md (for TODO details)

### Step 2: Identify Completed TODOs
1. Parse manifest for TODOs marked ✅
2. Get file path and "Done when" criteria for each

### Step 3: Verify Each Completed TODO
For each completed TODO:

1. **Check TODO removed from code:**
   - Read the file at recorded path
   - Search for `TODO [REQ:<req-id>] [ID:<todo-id>]`
   - If found: flag as "TODO comment still in code"

2. **Check implementation exists:**
   - Analyze file for code matching the task description
   - Look for functions, classes, or logic that fulfill the requirement
   - If file is empty or minimal: flag as "No implementation found"

3. **Check acceptance criteria:**
   - Match TODO to related acceptance criteria in spec
   - Verify criteria appears satisfiable by the code
   - If unclear: flag as "Needs manual verification"

### Step 4: Calculate Verification Status
```
For each verified TODO:
- TODO removed + implementation exists + criteria met = VERIFIED
- Any flag = NEEDS REVIEW

Overall status determination (using verified and needsReview counts):
- NO_DATA: verified = 0 AND needsReview = 0
           No completed TODOs were checked. Run /todo-done first.
           
- PASSED:  verified > 0 AND needsReview = 0
           All completed TODOs verified successfully.
           
- PARTIAL: needsReview > 0 AND needsReview < verified
           Minority of TODOs need review; most are verified.
           
- FAILED:  needsReview >= verified AND (verified > 0 OR needsReview > 0)
           Majority (or all) TODOs need review.

Examples:
| verified | needsReview | Status  | Reason                    |
|----------|-------------|---------|---------------------------|
| 0        | 0           | NO_DATA | Nothing to verify         |
| 5        | 0           | PASSED  | All verified              |
| 4        | 1           | PARTIAL | 1 < 4, minority bad       |
| 2        | 2           | FAILED  | 2 >= 2, half or more bad  |
| 1        | 3           | FAILED  | 3 >= 1, majority bad      |
| 0        | 2           | FAILED  | 2 >= 0, all bad           |
```

### Step 5: Generate Report
Create 09-verification-report.md:

```markdown
# Verification Report: [Requirement Name]

**Verified**: [ISO-8601 timestamp]
**Status**: [PASSED/PARTIAL/FAILED]
**Checked**: [X] of [Y] completed TODOs

## Summary

| TODO | Task | Status | Issues |
|------|------|--------|--------|
| TODO-001 | Add User model | ✅ VERIFIED | - |
| TODO-002 | Create AuthService | ⚠️ REVIEW | TODO still in code |
| TODO-003 | Add validation | ✅ VERIFIED | - |

## Verified

### TODO-001: Add User model
**File**: src/db/prisma/schema.prisma
**Criteria**: "Models exist with all required fields"
**Finding**: User, Session, PasswordReset models found with correct fields

## Needs Review

### TODO-002: Create AuthService
**File**: src/services/AuthService.ts
**Issues**:
- ⚠️ TODO comment still present at line 4
**Action**: Remove TODO comment after confirming implementation

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| User can register | ✅ | register() method in AuthService |
| Registration fails with existing email | ⚠️ | No duplicate check found |
| User receives verification email | ✅ | EmailService.sendVerification() called |
```

### Step 6: Update Metadata
```json
{
  "verification": {
    "status": "passed|partial|failed",
    "lastRun": "[ISO-8601 timestamp]",
    "verified": [count],
    "needsReview": [count]
  }
}
```

### Step 7: Display Results
```
🔍 Verification Complete: [requirement-name]

Status: [✅ PASSED / ⚠️ PARTIAL / ❌ FAILED]
Verified: [X] of [Y] completed TODOs

Issues found:
  ⚠️ 2 TODOs still have comments in code
  ⚠️ 1 acceptance criterion needs manual check

Report: requirements/[folder]/09-verification-report.md

Next steps:
  • Review flagged items in report
  • Remove leftover TODO comments
  • Mark requirement complete when satisfied
```

## Error Handling
| Condition | Response |
|-----------|----------|
| No requirement specified | "No requirement specified. Use: /verify [requirement-id]" |
| No TODOs injected | "No TODOs to verify. Run /inject-todos first." |
| No TODOs completed | "No completed TODOs to verify. Mark some done with /todo-done TODO-NNN" |
| File not found | Warning in report, continue checking others |

## Rules
- Read-only (doesn't modify code or remove TODOs)
- Only checks TODOs marked as done
- Flags issues for human review rather than auto-fixing
- Can be run multiple times as implementation progresses
