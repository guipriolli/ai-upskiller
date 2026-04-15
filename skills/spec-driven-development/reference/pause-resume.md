# Special Flows: Pause & Resume Work

## Pause Work

**Trigger:** "pause work" or "exit session"

**Flow:**
1. Write `.specs/HANDOFF.md`:
   ```markdown
   ---
   paused: YYYY-MM-DD HH:MM
   session-id: [UUID from Claude Code]
   ---

   # Handoff: [Feature / Task Name]

   ## Current Position
   [Which phase? Which task? What just got done?]

   ## Pending Steps
   - [ ] [Step 1]
   - [ ] [Step 2]

   ## Blockers
   - [Blocker 1 and how to unblock]

   ## Uncommitted Files
   - [File 1: status]
   - [File 2: status]

   ## Notes for Next Session
   [Anything important to know when resuming?]
   ```

2. List uncommitted files (if any) and ask: "Should I commit before I exit?"

## Resume Work

**Trigger:** "resume work" or "pick up where I left off"

**Flow:**
1. Read `.specs/HANDOFF.md` (if exists)
2. Read `.specs/project/STATE.md` (decisions, recent blockers)
3. Read relevant feature files (spec.md / design.md / tasks.md)
4. **Summarize:** "Last session you were [here]. Pending steps are [X]. Blockers are [Y]. Should we continue with [Z]?"
5. Ask: "Ready to continue, or do you need to catch up first?"
