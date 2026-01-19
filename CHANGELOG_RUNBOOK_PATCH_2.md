# CHANGELOG — Runbook Patch 2

**Date:** 2025-01-19  
**Base:** RUNBOOK_FINAL_vNEXT18_SHIP.md (1185 lines)  
**Output:** RUNBOOK_FINAL_vNEXT19_SHIP.md (1192 lines, +7)  
**Authority:** Doc-only UX patch; HANDOFF authority unchanged (vNEXT18)  
**Lock Stamp:** Doc-only UX patch; authority pinned to HANDOFF vNEXT18 (policy option b).

---

## Patches Applied

| Patch | Finding | Location | Change |
|-------|---------|----------|--------|
| P-01 | F-01 | §4.1 If Not table | Added row for PowerShell error → Git Bash redirect |
| P-02 | F-02 | §2.3 | Added forward reference: "For Section 4 bash scripts, use Git Bash" |
| P-03 | F-05 | §4.2 If Not table | Added row for PowerShell error → Git Bash redirect |
| P-04 | F-03 | §6.5 If Not table | Added row for "No option menu appears" |
| P-05 | F-04 | §3.1, §3.2, §3.3 | Added "(in your terminal, not Claude chat)" to Action lines |

---

## Rationale

### P-01: PowerShell Error Recovery (P0 Fix)
- **Before:** §4.1 If Not table had no row for PowerShell's "not recognized" error
- **After:** Added `| \`not recognized\` or \`cannot be loaded\` | PowerShell cannot run bash scripts | Switch to Git Bash (Section 4.0) |`
- **Why:** Windows users following §2.3→§3.3→§4.1 would hit bash script failure with no recovery path

### P-02: Forward Reference to Git Bash
- **Before:** §2.3 ended with If Not clause, no mention of bash script limitation
- **After:** Added note: "For Section 4 bash scripts, Windows users must use Git Bash. See Section 4.0."
- **Why:** Prevents users from progressing through §3/§4 in PowerShell before learning they need Git Bash

### P-03: §4.2 PowerShell Error (Symmetry with P-01)
- **Before:** §4.2 If Not table only had Permission denied and DRIFT-FAIL rows
- **After:** Added same PowerShell error row as §4.1
- **Why:** Same failure mode applies to drift-oracle.sh

### P-04: Option Menu Guidance
- **Before:** §6.5 had no guidance if user didn't see option menu or didn't know to type "1"
- **After:** Added `| No option menu appears | Waiting for your choice | Type \`1\` and press Enter as a separate message | — |`
- **Why:** Beginners may not understand that typing "1" is a separate chat interaction

### P-05: Inline Terminal Reminder
- **Before:** §3.1/3.2/3.3 said "Type this exact command and press Enter"
- **After:** Changed to "Type this exact command in your terminal (not Claude chat) and press Enter"
- **Why:** Reinforces Critical Warning at the point where terminal commands first appear

---

## Gates

| Gate | Result |
|------|--------|
| Test suite | Unaffected (doc-only) |
| Drift oracle | Unaffected (doc-only) |
| P0 detector | Unaffected (doc-only) |

---

## Version Updates

- Header version: vNEXT18 → vNEXT19
- VERSION CHECK reference: vNEXT18 → vNEXT19
- Authority reference: unchanged (vNEXT18)

---

*End of CHANGELOG_RUNBOOK_PATCH_2.md*
