# RUNBOOK_FINAL.md
## claude-code-requirements-builder

**Version:** vNEXT19  
**Date:** 2025-01-19  
**Promise:** Follow every numbered step exactly. You will be able to complete the requirements workflow.

> ⚠️ **VERSION CHECK:** If your HANDOFF_PACKET shows a version newer than vNEXT19, STOP. Obtain the matching runbook for that version before continuing.

---

# ⚠️ CRITICAL WARNING

```
┌─────────────────────────────────────────────────────────────────────┐
│  DO NOT paste terminal commands into Claude chat.                   │
│                                                                     │
│  Terminal commands must be typed or pasted into your TERMINAL       │
│  application (Terminal.app, Git Bash, or Linux terminal).           │
│                                                                     │
│  Claude chat is for /requirements-* commands only.                  │
└─────────────────────────────────────────────────────────────────────┘
```

---

# Section 0: Scope

## 0.1 What This Runbook IS
- A step-by-step guide for using the requirements command pack
- Written for users with zero prior experience
- Based on HANDOFF_PACKET vNEXT18 authority

## 0.2 What This Runbook is NOT
- A programming tutorial
- A guide to modifying the tool
- A replacement for error messages

---

# Section 1: Terminology

Read these definitions before proceeding.

| # | Term | Definition |
|---|------|------------|
| 1.1 | **requirement folder** | A folder inside `requirements/` containing all files for one feature |
| 1.2 | **metadata.json** | JSON file tracking state (phase, status, counts) |
| 1.3 | **phase** | Gathering stage: setup → discovery → context → detail → complete |
| 1.4 | **status** | Overall state: active, complete, or incomplete |
| 1.5 | **todos.status** | TODO state: injected, complete, or removed |
| 1.6 | **idempotent** | Safe to run multiple times without causing errors |
| 1.7 | **alias** | Short command name (e.g., `/validate` = `/requirements-validate`) |
| 1.8 | **REC-XX** | Recovery procedure ID (REC-01 through REC-15) in §17 |

---

# Section 2: Open Your Terminal

## 2.1 macOS

**Purpose:** Open the Terminal application.

**Action:**
1. Press `Cmd` + `Space` (hold Command, tap Space)
2. Type exactly: `Terminal`
3. Press `Enter`

**Expected Result:** A window appears with a blinking cursor and text like `username@computer ~ %`

**If Not:**
- If Spotlight does not open → Press `Cmd` + `Space` again, ensure both keys pressed
- If Terminal is not found → Open Finder → Applications → Utilities → Terminal

---

## 2.2 Windows (Command Prompt)

**Purpose:** Open the Command Prompt application.

**Action:**
1. Press `Windows key` + `R` (hold Windows key, tap R)
2. Type exactly: `cmd`
3. Press `Enter`

**Expected Result:** A black window appears with text like `C:\Users\YourName>`

**If Not:**
- If Run dialog does not open → Click Start menu, type `cmd`, click "Command Prompt"
- If access denied → Right-click "Command Prompt" → "Run as administrator"

---

## 2.3 Windows (PowerShell)

**Purpose:** Open PowerShell.

**Action:**
1. Press `Windows key` + `X`
2. Click "Windows PowerShell" or "Terminal"

**Expected Result:** A blue window appears with text like `PS C:\Users\YourName>`

**If Not:**
- If menu does not appear → Right-click Start button → select "Windows PowerShell"

**Note:** For Section 4 bash scripts, Windows users must use Git Bash. See Section 4.0.

---

## 2.4 Linux

**Purpose:** Open a terminal emulator.

**Action:**
1. Press `Ctrl` + `Alt` + `T` simultaneously

**Expected Result:** A terminal window appears with a blinking cursor.

**If Not:**
- If nothing happens → Click Activities (top-left) → type "Terminal" → click the icon
- If still not found → Your distribution may use a different terminal; search "terminal" in applications

---

## ✓ YOU ARE HERE: Terminal Open

You should now have a terminal window open with a blinking cursor. If not, return to Section 2 for your operating system.

---

# Section 3: Navigate to the Repository

## 3.1 macOS / Linux

**Purpose:** Change directory to the tool folder.

**Action:** Type this exact command in your terminal (not Claude chat) and press `Enter`:
```
cd ~/Desktop/claude-code-requirements-builder
```

**Expected Result:** The cursor returns with no error message. The prompt may change to show the folder name.

**If Not:**
- If you see `No such file or directory` → The folder does not exist on your Desktop. Proceed to Section 3.4.
- If you see `Permission denied` → Contact your system administrator.

---

## 3.2 Windows (Command Prompt)

**Purpose:** Change directory to the tool folder.

**Action:** Type this exact command in your terminal (not Claude chat) and press `Enter`:
```
cd %USERPROFILE%\Desktop\claude-code-requirements-builder
```

**Expected Result:** The prompt changes to show `...\claude-code-requirements-builder>`

**If Not:**
- If you see `The system cannot find the path specified` → Proceed to Section 3.4.

---

## 3.3 Windows (PowerShell)

**Purpose:** Change directory to the tool folder.

**Action:** Type this exact command in your terminal (not Claude chat) and press `Enter`:
```
cd $env:USERPROFILE\Desktop\claude-code-requirements-builder
```

**Expected Result:** The prompt changes to show the folder path.

**If Not:**
- If you see a red error message → Proceed to Section 3.4.

---

## 3.4 Finding the Folder (All Operating Systems)

**Purpose:** Locate the folder if it is not on your Desktop.

**Action (macOS):**
1. Open Finder
2. Press `Cmd` + `F`
3. Type: `claude-code-requirements-builder`
4. Look for a folder (not a file)
5. Note the location shown below the folder name

**Action (Windows):**
1. Open File Explorer
2. Click in the search box
3. Type: `claude-code-requirements-builder`
4. Wait for results
5. Note the folder location

**Action (Linux):**
1. Type in terminal: `find ~ -type d -name "claude-code-requirements-builder" 2>/dev/null`
2. Note the path printed

**Expected Result:** You find the folder path.

**If Not:**
- If no folder is found → You do not have the tool. Download it first. STOP here.

---

## 3.5 Verify You Are in the Correct Folder

**Purpose:** Confirm the folder contains expected files.

**Action (macOS / Linux):** Type and press Enter:
```
ls
```

**Action (Windows cmd):** Type and press Enter:
```
dir
```

**Action (Windows PowerShell):** Type and press Enter:
```
ls
```

**Expected Result:** You see these items:
```
LICENSE    README.md    commands    examples    requirements    tests
```

**If Not:**
- If you see different files → You are in the wrong folder. Return to Section 3.1.
- If you see "not recognized" → You typed the wrong command for your OS.

---

## ✓ YOU ARE HERE: Correct Folder

You should see `LICENSE`, `README.md`, `commands`, `examples`, `requirements`, `tests` listed.

---

# Section 4: Verify System Health

You MUST complete this section before using the tool.

---

## 4.0 Windows Users: Git Bash Prerequisite

**Purpose:** Confirm Git Bash is installed (required for bash scripts on Windows).

**Action:**
1. Press `Windows key`, type `Git Bash`
2. If an application appears → Git Bash is installed

**Expected Result:** "Git Bash" appears in search results.

**If Not:**
- If Git Bash is not found → Download and install Git for Windows from https://git-scm.com/download/win
- After installation, restart your computer and repeat this check

**How to open Git Bash:**
1. Press `Windows key`, type `Git Bash`, press `Enter`
2. A terminal window with `MINGW64` in the title bar appears

**Important:** For Sections 4.1–4.3, Windows users MUST use Git Bash (not cmd or PowerShell) to run the bash scripts.

---

## 4.1 Run the Test Suite

**Purpose:** Confirm all 36 automated tests pass.

**Action (macOS / Linux):** Type and press Enter:
```
./tests/run-tests.sh
```

**Action (Windows - Git Bash required):** Type and press Enter:
```
bash ./tests/run-tests.sh
```

**Expected Result:** The final lines show:
```
Passed:  36
Failed:  0
Skipped: 0

✅ All 36 tests passed!
```

**If Not:**
| You See | Meaning | Fix |
|---------|---------|-----|
| `Permission denied` | Script not executable | Run: `chmod +x ./tests/run-tests.sh` |
| `command not found: bash` | Bash not installed | Install Git Bash (Windows) or bash |
| `command not found: jq` | jq not installed | macOS: `brew install jq`; Ubuntu: `sudo apt install jq` |
| `No such file or directory` | Wrong folder | Return to Section 3.5 |
| Any test shows `FAIL` | Tool file corrupted | First confirm you are in the correct folder (Section 3.5). If confirmed, re-download the tool. |
| `not recognized` or `cannot be loaded` | PowerShell cannot run bash scripts | Switch to Git Bash (Section 4.0) |

---

## 4.2 Run the Drift Oracle

**Purpose:** Confirm no files have become inconsistent.

**Action (macOS / Linux):** Type and press Enter:
```
./tests/drift-oracle.sh
```

**Action (Windows - Git Bash required):** Type and press Enter:
```
bash ./tests/drift-oracle.sh
```

**Expected Result:** The final lines show:
```
Passed:  35
Failed:  0

✅ Drift oracle passed - no contract drift detected
```

**If Not:**
| You See | Meaning | Fix |
|---------|---------|-----|
| `Permission denied` | Script not executable | Run: `chmod +x ./tests/drift-oracle.sh` |
| Any check shows `DRIFT-FAIL` | File inconsistency | First confirm you are in the correct folder (Section 3.5). If confirmed, re-download the tool. |
| `not recognized` or `cannot be loaded` | PowerShell cannot run bash scripts | Switch to Git Bash (Section 4.0) |

---

## 4.3 Run P0 Drift Detectors

**Purpose:** Confirm no legacy `context.*` fields exist.

**Action (macOS / Linux with ripgrep):** Type and press Enter:
```
rg -n "context\." commands requirements README.md
```

**Action (if ripgrep not installed):** Type and press Enter:
```
grep -rn "context\." commands requirements README.md
```

**Action (Windows PowerShell):**
```
Select-String -Path "commands\*","requirements\*","README.md" -Pattern "context\."
```

**Expected Result:** No output (empty result).

**If Not:**
- If you see file matches → First confirm you are in the correct folder (Section 3.5). If confirmed, legacy fields exist; re-download the tool.
- If `command not found` → Install ripgrep or use grep version above.

---

## 4.4 STOP Conditions

**If any of these are true, do NOT proceed:**

| Condition | Action |
|-----------|--------|
| Test suite shows any `FAIL` | First confirm folder (Section 3.5). If correct, re-download tool, re-run tests. |
| Drift oracle shows any `DRIFT-FAIL` | First confirm folder (Section 3.5). If correct, re-download tool, re-run oracle. |
| P0 detector shows matches | First confirm folder (Section 3.5). If correct, re-download tool. |
| You cannot make scripts executable | Contact system administrator |

---

## ✓ YOU ARE HERE: System Healthy

You should see:
- Test suite: 36 passed, 0 failed
- Drift oracle: 35 passed, 0 failed
- P0 detectors: no matches

If all three are true, proceed to Section 5.

---

# Section 5: Command Reference

## 5.1 Command Alias Table

| Full Command | Alias | Use Alias? |
|--------------|-------|------------|
| `/requirements-start` | (none) | No |
| `/requirements-status` | (none) | No |
| `/requirements-current` | (none) | No |
| `/requirements-end` | (none) | No |
| `/requirements-list` | (none) | No |
| `/requirements-remind` | `/remind` | Yes |
| `/requirements-validate` | `/validate` | Yes |
| `/requirements-inject-todos` | `/inject-todos` | Yes |
| `/requirements-todo-done` | `/todo-done` | Yes |
| `/requirements-todos` | `/todos` | Yes |
| `/requirements-verify` | `/verify` | Yes |
| `/requirements-remove-todos` | `/remove-todos` | Yes |

**Command Entry Rule:**
- If **Alias** column shows a value → always type the alias (e.g., `/validate`)
- If **Alias** column shows `(none)` → always type the full `/requirements-*` command

**Rule:** This runbook uses aliases where available.

---

## 5.2 Prerequisites Table (from §23.1)

| Command | Prerequisite | Error if Missing |
|---------|--------------|------------------|
| `/requirements-start` | None | — |
| `/requirements-status` | Active requirement | `❌ No active requirement` |
| `/requirements-current` | Any requirement | `ℹ️ No requirements found` |
| `/requirements-end` | `phase == "complete"` | `❌ Gathering not complete` |
| `/requirements-list` | None | — |
| `/remind` | Active requirement | `❌ No active requirement` |
| `/validate` | Spec file exists | `❌ No spec found` |
| `/inject-todos` | Spec with Implementation Map | `❌ No Implementation Map found` |
| `/todo-done` | todos.status = injected or complete | `❌ No TODOs injected` |
| `/todos` | Active requirement | `❌ No active requirement` |
| `/verify` | todos.done > 0 | `❌ No completed TODOs to verify` |
| `/remove-todos` | todos.status = injected or complete | `❌ No TODOs to remove` |

---

## 5.3 Idempotency Table (from §23.4.1)

| Command | Safe to Re-run? | What Happens |
|---------|-----------------|--------------|
| `/requirements-start` | ❌ NO | Creates duplicate folder |
| `/requirements-status` | ✅ YES | Shows status (read-only) |
| `/requirements-current` | ✅ YES | Shows details (read-only) |
| `/requirements-end` | ❌ NO | Option 3 deletes folder |
| `/requirements-list` | ✅ YES | Lists requirements (read-only) |
| `/remind` | ✅ YES | Shows rules (read-only) |
| `/validate` | ✅ YES | Overwrites report |
| `/inject-todos` | ✅ YES | Skips existing TODOs |
| `/todo-done` | ✅ YES | Shows "already done" |
| `/todos` | ✅ YES | Lists TODOs (read-only) |
| `/verify` | ✅ YES | Overwrites report |
| `/remove-todos` | ✅ YES | Does nothing if already removed |

---

## 5.4 "Where Am I?" Decision Table (from §23.5)

| Your State | Available Commands | Next Action |
|------------|-------------------|-------------|
| No requirements exist | `/requirements-start`, `/requirements-list` | `/requirements-start "description"` |
| After `/requirements-start` | `/requirements-status`, `/requirements-current`, `/requirements-list`, `/remind` | Answer questions, `/requirements-status` |
| Gathering complete (phase=complete) | `/requirements-end`, `/requirements-status`, `/requirements-current` | `/requirements-end` (Option 1) |
| After `/requirements-end` | `/validate`, `/inject-todos` | `/validate standard` |
| After `/inject-todos` | `/todo-done`, `/todos`, `/remove-todos` | Implement work, `/todo-done TODO-001` |
| All TODOs marked done | `/verify`, `/remove-todos` | `/verify` |
| After `/verify` | `/remove-todos`, `/requirements-start` | `/remove-todos` |
| After `/remove-todos` | `/requirements-start`, `/requirements-list` | 🎉 Complete |

---

## 5.5 Emergency: I'm Lost

**Purpose:** Single recovery entry point when you don't know what to do.

**Action:** In Claude chat, type:
```
/requirements-status
```

**Expected Result:** Claude displays your current state (phase, status, counts).

**If Not:**
- If `❌ No active requirement` → Either run `/requirements-start "description"` to begin, or run `/requirements-list` to see existing requirements.

**Then:** Match the output to Section 5.4 ("Where Am I?" table) and follow the **Next Action** column.

---

## ✓ YOU ARE HERE: Commands Understood

You understand:
- Which commands have aliases
- What each command requires before running
- Which commands are safe to repeat
- How to determine what command to run next

---

# Section 6: Complete Workflow

> 📌 **Reminder:** Use aliases where available (see Section 5.1). Example: type `/validate` not `/requirements-validate`.

Follow steps 6.1 through 6.12 in exact order.

---

## 6.1 Start a New Requirement

**Purpose:** Create a requirement folder and begin gathering.

**Action:** In Claude chat, type:
```
/requirements-start "your feature description here"
```

Example:
```
/requirements-start "Add user login with email and password"
```

**Expected Result:**
- Folder created: `requirements/YYYY-MM-DD-HHMM-feature-name/`
- Files created: `00-initial-request.md`, `metadata.json`
- Claude responds with complexity assessment and first question

**If Not:**
| Error | Meaning | Fix |
|-------|---------|-----|
| (no error expected) | — | — |

**Artifacts Created:**
- `requirements/[folder]/00-initial-request.md`
- `requirements/[folder]/metadata.json`

**Next:** Answer discovery questions (Step 6.2)

---

## 6.2 Answer Discovery Questions

**Purpose:** Provide high-level information about your feature.

**Action:** Read each question Claude asks. Type your answer in the chat.

**Expected Result:**
- Claude asks 3-8 questions depending on complexity
- Files created: `01-discovery-questions.md`, `02-discovery-answers.md`
- `metadata.json` updated: phase progresses

**If Not:**
| Error | Meaning | Fix | Recovery |
|-------|---------|-----|----------|
| `❌ No active requirement` | No current requirement | Run `/requirements-start` first | See REC-11 |

**Artifacts Created:**
- `requirements/[folder]/01-discovery-questions.md`
- `requirements/[folder]/02-discovery-answers.md`

**Next:** Context gathering (Step 6.3)

---

## 6.3 Context Gathering

**Purpose:** Claude analyzes your codebase.

**Action:** Answer Claude's questions about existing patterns and files.

**Expected Result:**
- File created: `03-context-findings.md`
- `metadata.json` updated: phase advances

**If Not:**
| Error | Meaning | Fix | Recovery |
|-------|---------|-----|----------|
| `❌ No active requirement` | Requirement not active | Check with `/requirements-status` | See REC-11 |

**Artifacts Created:**
- `requirements/[folder]/03-context-findings.md`

**Next:** Detail questions (Step 6.4)

---

## 6.4 Answer Detail Questions

**Purpose:** Provide implementation specifics.

**Action:** Answer detailed questions about edge cases, validation, etc.

**Expected Result:**
- Files created: `04-detail-questions.md`, `05-detail-answers.md`
- `metadata.json` updated: `phase` becomes `"complete"`

**If Not:**
| Error | Meaning | Fix | Recovery |
|-------|---------|-----|----------|
| `❌ No active requirement` | Requirement not active | Check `/requirements-status` | See REC-11 |

**Artifacts Created:**
- `requirements/[folder]/04-detail-questions.md`
- `requirements/[folder]/05-detail-answers.md`

**Next:** Generate spec (Step 6.5)

---

## 6.5 Generate the Specification

**Purpose:** Create the formal requirements document.

**Action:** In Claude chat, type:
```
/requirements-end
```

Then type `1` to choose "Generate spec with current information".

**Expected Result:**
- File created: `06-requirements-spec.md`
- `metadata.json` updated: `status` becomes `"complete"`
- Claude shows:
```
✅ Spec generated

📄 File: requirements/[folder]/06-requirements-spec.md

Next:
  1. Review: /requirements-current
  2. Validate: /validate
  3. Inject TODOs: /inject-todos
```

**If Not:**
| Error | Meaning | Fix | Recovery |
|-------|---------|-----|----------|
| `❌ Gathering not complete` | Phase is not "complete" | Answer remaining questions | — |
| `❌ No active requirement to end` | No `.current-requirement` | Run `/requirements-start` | See REC-11 |
| No option menu appears | Waiting for your choice | Type `1` and press Enter as a separate message | — |

**Artifacts Created:**
- `requirements/[folder]/06-requirements-spec.md`

**Next:** Validate (Step 6.6)

---

## 6.6 Validate the Specification

**Purpose:** Check spec for ambiguity, completeness, feasibility.

**Action:** In Claude chat, type:
```
/validate standard
```

**Expected Result:**
- File created: `07-validation-report.md`
- `metadata.json` updated: `validation.status` set
- If passed:
```
✅ Validation passed (Score: [X]/100)

Next: /inject-todos
```

**If Not:**
| Error | Meaning | Fix | Recovery |
|-------|---------|-----|----------|
| `❌ No spec found` | Spec file missing | Run `/requirements-end` first | See REC-05 |
| `❌ Validation failed` | Blocking issues found | Fix issues in spec, re-run `/validate` | — |

**Artifacts Created:**
- `requirements/[folder]/07-validation-report.md`

**Next:** Inject TODOs (Step 6.7)

---

## 6.7 Inject TODOs into Codebase

**Purpose:** Insert TODO comments into source files.

**Action:** In Claude chat, type:
```
/inject-todos
```

**Expected Result:**
- File created: `08-todo-manifest.md`
- TODO comments inserted into codebase
- `metadata.json` updated: `todos.status` = `"injected"`, counts set
- Claude shows:
```
✅ TODOs injected

Summary:
  • Total: [N] TODOs
  • Files modified: [M]
  • New files created: [K]

📦 Manifest: requirements/[folder]/08-todo-manifest.md

Next:
  1. Review: /todos
  2. Implement each TODO
  3. Mark done: /todo-done TODO-001
  4. Verify: /verify
```

**If Not:**
| Error | Meaning | Fix | Recovery |
|-------|---------|-----|----------|
| `❌ No Implementation Map found` | Spec missing map | Add Implementation Map to spec | — |
| `❌ No spec found` | Spec file missing | Run `/requirements-end` | See REC-05 |

**Artifacts Created:**
- `requirements/[folder]/08-todo-manifest.md`
- TODO comments in codebase files

**Next:** Implement work (Step 6.8)

---

## 6.8 Implement Your Code

**Purpose:** Write the code described in each TODO.

**Action:** This is MANUAL work outside the command pack.
1. Open your code editor
2. Find files with TODO comments
3. Implement the functionality described
4. Do NOT delete the TODO comments yet

**Expected Result:** Your code implements the features.

**If Not:** This is coding work. Consult programming resources.

**Artifacts Created:** Your code changes.

**Next:** Mark TODOs done (Step 6.9)

---

## 6.9 Mark TODOs as Done

**Purpose:** Record completion of each TODO.

**Action:** For each TODO, in Claude chat type:
```
/todo-done TODO-001
```

Repeat with TODO-002, TODO-003, etc.

**Expected Result:**
- Manifest updated: `⬜` becomes `✅`
- `metadata.json` updated: counts change
- Claude shows:
```
✅ TODO-001 marked done

Progress: [X/Z] done · [Y] remaining
```

When last TODO done:
```
🎉 All TODOs complete

Next: /verify
```

**If Not:**
| Error | Meaning | Fix | Recovery |
|-------|---------|-----|----------|
| `❌ No TODOs injected` | TODOs not injected | Run `/inject-todos` first | — |
| `TODO-001 not found` | Invalid ID | Run `/todos` to see valid IDs | — |
| `TODO-001 is already done` | Already marked | Safe to ignore (idempotent) | — |

**Artifacts Updated:**
- `requirements/[folder]/08-todo-manifest.md`
- `requirements/[folder]/metadata.json`

**Next:** Verify (Step 6.10)

---

## 6.10 Verify Implementation

**Purpose:** Check that implementation matches plan.

**Action:** In Claude chat, type:
```
/verify
```

**Expected Result:**
- File created: `09-verification-report.md`
- `metadata.json` updated: `verification.status` set
- Claude shows:
```
✅ Verification passed

All [N] TODOs verified successfully.

📋 Report: requirements/[folder]/09-verification-report.md

Next steps:
  • Review flagged items in report
  • Remove TODO comments: /remove-todos
  • Start new requirement: /start
```

**If Not:**
| Error | Meaning | Fix | Recovery |
|-------|---------|-----|----------|
| `❌ No completed TODOs to verify` | No TODOs marked done | Run `/todo-done` first | — |
| `⚠️ Verification partial` | Some items need review | Open report, review items, re-verify | — |
| `❌ Verification failed` | Most items need review | Open report, address issues | — |

**Artifacts Created:**
- `requirements/[folder]/09-verification-report.md`

**Next:** Remove TODOs (Step 6.11)

---

## 6.11 Remove TODOs from Codebase

**Purpose:** Clean up TODO comments.

**Action:** In Claude chat, type:
```
/remove-todos
```

When prompted, type exactly: `delete`

**Expected Result:**
- TODO comments removed from files
- `metadata.json` updated: `todos.status` = `"removed"`
- Claude shows:
```
✅ TODOs removed

Summary:
  • TODOs removed: [N]
  • Files modified: [M]
  • Empty files deleted: [K]

Requirement folder preserved. Manifest updated with removal log.

🎉 Lifecycle complete.

Next: /start to begin new requirement, or /list to view all.
```

**If Not:**
| Error | Meaning | Fix | Recovery |
|-------|---------|-----|----------|
| `❌ No TODOs to remove` | Already removed or never injected | Check with `/requirements-status` | — |
| `ℹ️ Cancelled` | Did not type "delete" | Re-run, type `delete` | — |

**Artifacts Updated:**
- Codebase files (TODOs removed)
- `requirements/[folder]/metadata.json`

**Next:** Complete (Step 6.12)

---

## 6.12 Lifecycle Complete

**Purpose:** The requirement is finished.

**Action:** Choose next steps:
- Start new requirement: `/requirements-start "new feature"`
- View all requirements: `/requirements-list`
- Commit changes to version control

**Expected Result:** 🎉 Workflow complete.

**If Not:** Run `/requirements-status` to confirm `todos.status` = `"removed"`.

---

## ✓ YOU ARE HERE: Workflow Complete

You have completed:
- ✅ Started requirement
- ✅ Answered all questions
- ✅ Generated specification
- ✅ Validated specification
- ✅ Injected TODOs
- ✅ Implemented code
- ✅ Marked TODOs done
- ✅ Verified implementation
- ✅ Removed TODOs

---

# Section 7: Recovery Procedures

Use this section when you encounter errors.

---

## 7.1 "No active requirement" Error

**Is the error:** `❌ No active requirement`?

**Decision Tree:**
1. Did you run `/requirements-start`?
   - **No** → Run `/requirements-start "description"`
   - **Yes** → Continue to step 2
2. Does `.current-requirement` file exist in repo root?
   - **macOS/Linux check:** `ls -la | grep current`
   - **Windows check:** `dir /a | findstr current`
   - **No** → Run `/requirements-start` again
   - **Yes, but stale** → See **REC-11** in §17.2

---

## 7.2 "Gathering not complete" Error

**Is the error:** `❌ Gathering not complete`?

**Decision Tree:**
1. Run `/requirements-status`
2. Check the `phase` value shown
3. If phase is NOT `complete`:
   - Continue answering questions until phase reaches `complete`
4. If phase shows `complete` but error persists:
   - See **REC-05** for corrupt metadata.json

---

## 7.3 "No spec found" Error

**Is the error:** `❌ No spec found`?

**Decision Tree:**
1. Does `06-requirements-spec.md` exist in requirement folder?
   - **macOS/Linux check:** `ls requirements/*/06-requirements-spec.md`
   - **Windows check:** `dir requirements\*\06-requirements-spec.md`
   - **No** → Run `/requirements-end` and choose Option 1
   - **Yes** → See **REC-05** for corrupt metadata.json

---

## 7.4 Corrupt metadata.json

**Symptom:** JSON parse error, unexpected command failures

**Fix:**

**Purpose:** Restore a corrupt metadata.json file safely.

**Action:** Open HANDOFF_PACKET §17 **REC-05** and follow it exactly. Do not attempt reconstruction from memory.

**Expected Result:** metadata.json is restored and commands work again.

**If Not:** Contact the tool maintainer with the error message you see.

---

## 7.5 Count Desync

**Symptom:** `/requirements-status` shows wrong counts

**Purpose:** Correct TODO counts in metadata.json when they don't match the manifest.

**Action:** Open HANDOFF_PACKET §17 **REC-06** and follow it exactly. Do not edit metadata.json without following REC-06.

**Expected Result:** `todos.total`, `todos.done`, and `todos.remaining` match the actual checkboxes in `08-todo-manifest.md`.

**If Not:** See **REC-05** if metadata.json becomes corrupt during the fix.

---

## 7.6 Interrupted Mid-Workflow

**Symptom:** You closed the chat, don't remember where you were

**Purpose:** Resume from the correct workflow step after an interruption.

**Action:** In Claude chat, type `/requirements-status` and read the phase and status shown.

**Expected Result:** Claude displays your current state. Match it to Section 5.4 ("Where Am I?" table) and follow the **Next Action** column.

**If Not:** If `❌ No active requirement`, run `/requirements-list` to see existing requirements.

---

## 7.7 Verification Failed

**Symptom:** `⚠️ Verification partial` or `❌ Verification failed`

**Purpose:** Address items flagged in the verification report.

**Action:** Open `requirements/[folder]/09-verification-report.md`, review items marked "needs review", and complete any unfinished implementation.

**Expected Result:** After finishing implementation, re-run `/verify` and see `✅ Verification passed`.

**If Not:** If verification still fails after implementation is complete, see **REC-06, REC-07** for count/status desync.

---

## ✓ YOU ARE HERE: Recovery Understood

You know how to:
- Diagnose "no active requirement"
- Diagnose "gathering not complete"
- Handle corrupt metadata.json
- Resume after interruption
- Address verification failures

---

# Section 8: Gate Commands

## 8.1 Test Suite Command

**Purpose:** Verify 36 tests pass.

**Action (Terminal, NOT Claude chat):**

**macOS / Linux:**
```
./tests/run-tests.sh
```

**Windows (Git Bash):**
```
bash ./tests/run-tests.sh
```

**Interpretation:**
| Output | Meaning |
|--------|---------|
| `Passed: 36, Failed: 0` | ✅ Healthy |
| `Failed: [any number > 0]` | ❌ Problem exists |

**If Not:** See Section 4.4 STOP Conditions for troubleshooting.

---

## 8.2 Drift Oracle Command

**Purpose:** Verify 35 consistency checks pass.

**Action (Terminal, NOT Claude chat):**

**macOS / Linux:**
```
./tests/drift-oracle.sh
```

**Windows (Git Bash):**
```
bash ./tests/drift-oracle.sh
```

**Interpretation:**
| Output | Meaning |
|--------|---------|
| `Passed: 35, Failed: 0` | ✅ No drift |
| `Failed: [any number > 0]` | ❌ Files inconsistent |

**If Not:** See Section 4.4 STOP Conditions for troubleshooting.

---

## 8.3 P0 Drift Detector Commands

**Purpose:** Verify no legacy `context.*` fields.

**Action (Terminal, NOT Claude chat):**

**macOS / Linux (ripgrep):**
```
rg -n "context\." commands requirements README.md
```

**macOS / Linux (grep):**
```
grep -rn "context\." commands requirements README.md
```

**Windows PowerShell:**
```
Select-String -Path "commands\*","requirements\*","README.md" -Pattern "context\."
```

**Interpretation:**
| Output | Meaning |
|--------|---------|
| No output (empty) | ✅ Clear |
| Any file:line matches | ❌ Legacy fields exist |

**If Not:** See Section 4.4 STOP Conditions for troubleshooting.

---

## ✓ YOU ARE HERE: Gates Understood

You can run and interpret:
- Test suite (expect 36/36)
- Drift oracle (expect 35/35)
- P0 detectors (expect no matches)

---

# Section 9: Appendix A - Verified Outputs

Captured during runbook generation:

## 9.1 pwd
```
/Users/aligomaa/Desktop/claude-code-requirements-builder
```

## 9.2 ls
```
LICENSE    README.md    commands    examples    requirements    tests
```

## 9.3 Test Suite
```
Passed:  36
Failed:  0
Skipped: 0

✅ All 36 tests passed!
```

## 9.4 Drift Oracle
```
Passed:  35
Failed:  0

✅ Drift oracle passed - no contract drift detected
```

## 9.5 P0 Detectors
```
=== P0 Check 1: context. ===
(no matches - CLEAR)

=== P0 Check 2: contextFiles ===
(no matches - CLEAR)
```

---

# Section 10: Appendix B - Five Rules

If you remember nothing else:

1. **Run commands in the correct place.** Terminal commands go in Terminal. `/requirements-*` commands go in Claude chat.

2. **Check status when lost.** Run `/requirements-status` to see exactly where you are.

3. **Follow the "Next:" prompt.** Each successful command tells you what to do next.

4. **Most commands are safe to re-run.** Check Section 5.3 (Idempotency) if unsure.

5. **Errors point to recovery.** Each error message maps to a REC-XX procedure in Section 7.

---

# Section 11: Appendix C - Authority References

This runbook derives all command behavior from HANDOFF_PACKET vNEXT18:
This runbook's version may advance for doc-only UX improvements while authority remains pinned to HANDOFF vNEXT18 unless the HANDOFF version itself changes.

| Topic | Authority Section |
|-------|------------------|
| Command contracts (PRE/POST) | §13.2 |
| Prerequisites | §23.1 |
| Error messages | §14.1 |
| Recovery procedures | §17 |
| State machines | §12 |
| Idempotency | §23.4.1 |
| Quick reference | §23.5 |

---

*End of RUNBOOK_FINAL.md*
