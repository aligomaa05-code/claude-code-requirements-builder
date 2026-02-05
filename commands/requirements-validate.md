# Validate Requirements

Check requirements specification for ambiguity, gaps, and issues before implementation.

## Aliases
- /requirements-validate
- /validate

## Arguments
`$ARGUMENTS`: Optional mode or requirement ID | Required: no
- `quick` — Pattern-based checks only (~30 seconds)
- `standard` — AI analysis of each requirement (default, ~2 minutes)
- `adversarial` — Multi-persona attack on spec (~5 minutes)
- `[requirement-id]` — Validate specific requirement instead of current

## Prerequisites
- 06-requirements-spec.md exists
- Requirement status is "complete"

## Process

### Step 1: Load Requirement
1. Parse $ARGUMENTS for mode (quick/standard/adversarial) and/or requirement ID
2. If no requirement ID: use .current-requirement
3. Load 06-requirements-spec.md
4. Load 03-context-findings.md (for feasibility checks)
5. If spec missing: exit with error

### Step 2: Run Validation Lenses

#### Lens Reference

| # | Lens Name | Purpose | Modes |
|---|-----------|---------|-------|
| 1 | Ambiguity Detection | Flag vague/subjective terms | quick, standard, adversarial |
| 2 | Completeness Check | Verify required sections exist | quick, standard, adversarial |
| 3 | Testability Assessment | Check acceptance criteria are testable | standard, adversarial |
| 4 | Feasibility Review | Cross-reference with codebase | standard, adversarial |
| 5 | Consistency Check | Find internal contradictions | standard, adversarial |

#### Mode Behavior

| Mode | Lenses Run | Time | Use When |
|------|------------|------|----------|
| quick | 1-2 only | ~30 sec | Fast sanity check |
| standard | 1-5 | ~2 min | Normal validation (default) |
| adversarial | 1-5 + personas | ~5 min | High-stakes requirements |

#### Lens 1: Ambiguity Detection
Flag vague or subjective terms:
- "appropriate", "adequate", "reasonable"
- "fast", "slow", "quickly", "efficiently"
- "user-friendly", "intuitive", "simple"
- "etc", "and so on", "as needed"
- "should" without clear condition
- "may" or "might" (uncertain commitment)

For each found: note location and suggest specific alternative.

#### Lens 2: Completeness Check
Verify required sections exist and have content:
- [ ] Overview present and describes the problem
- [ ] Functional Requirements has specific items
- [ ] Technical Requirements references actual files
- [ ] Acceptance Criteria has testable items
- [ ] Implementation Map has entries

Check for gaps:
- Error handling: Are failure cases specified?
- Edge cases: Empty states, boundaries, limits?
- Permissions: Who can do what?

#### Lens 3: Testability Assessment (standard+ only)
For each acceptance criterion:
- Can it be verified with a specific test?
- Is there a measurable outcome?
- Is the expected behavior clear?

Flag criteria that are:
- Subjective ("user finds it easy")
- Unmeasurable ("performs well")
- Missing success definition

#### Lens 4: Feasibility Review (standard+ only)
Cross-reference with 03-context-findings.md:
- Do referenced files exist?
- Are suggested patterns actually in codebase?
- Any technical constraints violated?
- Dependencies available?

#### Lens 5: Consistency Check (standard+ only)
Internal consistency:
- Do functional requirements align with acceptance criteria?
- Does Implementation Map cover all requirements?
- Any contradictions between sections?

### Step 2b: Adversarial Attack (adversarial mode only)

Three personas challenge the spec:

**Malicious User Persona:**
"How could someone exploit gaps in this spec?"
- Security holes not addressed
- Input validation missing
- Authorization edge cases

**Lazy Developer Persona:**
"How could someone misinterpret this to do minimal work?"
- Ambiguous requirements that allow shortcuts
- Missing detail that could justify skipping features
- Unclear priorities

**Skeptical QA Persona:**
"What would I flag as untestable or incomplete?"
- Missing test scenarios
- Undefined expected behaviors
- Acceptance criteria without clear pass/fail

For each persona: generate 2-3 specific attack scenarios with suggested fixes.

### Step 3: Calculate Score
```
Base score: 100

Deductions:
- Blocking issue: -15 points each
- Warning: -5 points each

Minimum score: 0
```

### Step 4: Determine Status
- Score >= 70 AND no blocking issues → `passed`
- Score < 70 OR any blocking issues → `failed`

### Step 5: Generate Report
Create 07-validation-report.md:

```markdown
# Validation Report: [Requirement Name]

**Validated**: [ISO-8601 timestamp]
**Mode**: [quick/standard/adversarial]
**Status**: [PASSED/FAILED]
**Score**: [X]/100

## Summary

| Lens | Status | Issues |
|------|--------|--------|
| Ambiguity | [✅/⚠️/❌] | [count] |
| Completeness | [✅/⚠️/❌] | [count] |
| Testability | [✅/⚠️/❌] | [count] |
| Feasibility | [✅/⚠️/❌] | [count] |
| Consistency | [✅/⚠️/❌] | [count] |

## Blocking Issues

### [BLOCK-1] [Issue title]
**Lens**: [lens name]
**Location**: [Section > Subsection or line reference]
**Issue**: [Description of the problem]
**Suggestion**: [Specific fix]

## Warnings

### [WARN-1] [Issue title]
**Lens**: [lens name]
**Location**: [reference]
**Issue**: [Description]
**Suggestion**: [Specific fix]

## Adversarial Findings (adversarial mode only)

### Malicious User Attacks
1. **[ATTACK-1]**: [Attack description]
   **Risk**: [What could go wrong]
   **Fix**: [Suggested spec amendment]

### Lazy Developer Shortcuts
1. **[SHORTCUT-1]**: [How spec could be misinterpreted]
   **Risk**: [Resulting poor implementation]
   **Fix**: [How to make spec more explicit]

### QA Gaps
1. **[QA-1]**: [What can't be tested]
   **Risk**: [Quality impact]
   **Fix**: [How to make testable]

## Passed Checks

- ✅ [Check that passed]
- ✅ [Check that passed]
```

### Step 6: Update Metadata
```json
{
  "validation": {
    "status": "passed|failed",
    "lastRun": "[ISO-8601 timestamp]",
    "mode": "quick|standard|adversarial",
    "score": [0-100],
    "blocking": [count],
    "warnings": [count]
  }
}
```

### Step 7: Display Results
```
🔍 Validation Complete: [requirement-name]

Status: [✅ PASSED / ❌ FAILED]
Score: [X]/100
Mode: [quick/standard/adversarial]

Issues found:
  ❌ [N] blocking (must fix)
  ⚠️ [N] warnings (should review)

Report: requirements/[folder]/07-validation-report.md

Next steps:
  • If passed: /inject-todos
  • If failed: Fix issues in spec, then /validate again
```

## Error Handling
| Condition | Response |
|-----------|----------|
| No requirement specified | "No requirement specified. Use: /validate [requirement-id]" |
| Spec not found | "Spec not found. Run /requirements-end first." |
| Invalid mode | "Unknown mode: [X]. Use: quick, standard, or adversarial" |

## Rules
- Read-only on spec (suggests changes, doesn't apply them)
- Always generate report even if all checks pass
- Blocking issues should be fixed before TODO injection (recommended)
- Re-running overwrites previous validation report

## Metadata Updates
- Set `validation.status` to "passed" or "failed"
- Set `validation.lastRun` to current timestamp
- Set `validation.mode` to mode used
- Set `validation.score` to calculated score
- Set `validation.blocking` to count of blocking issues
- Set `validation.warnings` to count of warnings
