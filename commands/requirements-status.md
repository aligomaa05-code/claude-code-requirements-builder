# Check Requirements Status

Show current requirement gathering progress and continue.

## Instructions:

1. Read requirements/.current-requirement
2. If no active requirement:
   - Show message: "No active requirement gathering"
   - Suggest /requirements-start or /requirements-list
   - Exit

3. If active requirement exists:
   - Read metadata.json for current phase and progress
   - Show formatted status
   - Load appropriate question/answer files
   - Continue from last unanswered question

## Status Display Format:

### During Gathering (phase != complete):
```
📋 Active Requirement: [name]
Started: [time ago]
Phase: [Initial Setup/Context Discovery/Targeted Context/Expert Requirements]
Progress: [X/Y] questions answered

[Show last 3 answered questions with responses]

Next Question:
[Show next unanswered question with default]
```

### After Completion (phase = complete):
```
📋 Requirement: [name]
Status: Complete
Duration: [time from start to completion]
Complexity: [simple/standard/complex]

Spec: requirements/[folder]/06-requirements-spec.md

Validation: [status based on validation section in metadata]
  - If no validation section: "Not validated. Run /validate to check spec quality."
  - If validation.status = "passed": "✅ Passed (score: [X], [Y] warnings)"
  - If validation.status = "failed": "❌ Failed ([X] blocking issues). Run /validate to see details."

TODOs: [status based on todos.status]
  - If no todos section: "Not injected. Run /inject-todos to add TODOs to codebase."
  - If todos.status = "injected": "[X] open, [Y] done of [Z] total"
  - If todos.status = "removed": "Removed from codebase."
  - If todos.status = "complete": "✅ All [Z] TODOs complete"

Verification: [status based on verification section in metadata]
  - If no verification section: "Not verified. Run /verify after completing TODOs."
  - If verification.status = "no_data": "⚠️ No data (no completed TODOs to verify)"
  - If verification.status = "passed": "✅ Passed ([X] verified)"
  - If verification.status = "partial": "⚠️ Partial ([X] verified, [Y] need review)"
  - If verification.status = "failed": "❌ Failed (most items need review)"

Next actions:
  • Validate spec: /validate (if not validated)
  • Inject TODOs: /inject-todos (if validated or skipping validation)
  • View details: /requirements-current
  • Start new: /requirements-start [description]
```

## Continuation Flow:
1. Read next unanswered question from file
2. Present to user with default
3. Accept yes/no/idk response
4. Update answer file
5. Update metadata progress
6. Move to next question or phase

## Phase Transitions:
- Discovery complete → Run context gathering → Generate detail questions
- Detail complete → Generate final requirements spec

## Error Handling
| Condition | Response |
|-----------|----------|
| No .current-requirement file | "No active requirement gathering. Use /requirements-start or /requirements-list" |
| .current-requirement points to missing folder | "Requirement folder not found: [name]. Use /requirements-list to see available." |
| metadata.json missing or corrupt | "Cannot read requirement status. metadata.json may be corrupt." |
| Question file missing during resume | "Question file not found. Requirement may be incomplete." |