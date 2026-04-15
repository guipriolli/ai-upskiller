# Special Flow: Quick Task

**Trigger:** "quick task [DESCRIPTION]" or "quick fix [DESCRIPTION]"

**For tasks:**
- ≤3 files touched
- Fits in one sentence
- No separate spec/design needed

**Flow:**
1. Describe task and acceptance criteria
2. **Pre-check:** "Does this approach look right?" (user confirms)
3. Implement minimum code
4. Verify with test / manual check
5. Commit
6. Log to `.specs/quick/NNN-slug.md`:
   ```markdown
   ---
   id: NNN
   slug: [slug-from-title]
   status: completed
   date: YYYY-MM-DD
   ---

   # Quick Task: [Title]

   ## Description
   [What was done]

   ## Files Changed
   - `path/to/file.ts`

   ## Result
   [Summary of outcome]

   ## Commit
   [Commit hash]
   ```
