# Special Flow: Initialize Project

**Trigger:** "initialize project" or "set up project"

**Flow:**
1. Ask 5 questions (conversational, not a form):
   - Vision: "What are we building and for whom?"
   - Audience: "Who will use this?"
   - Stack: "What tech stack are we using?" (optional if unclear)
   - V1 scope: "What's the minimum viable feature?"
   - Constraints: "Any non-negotiables?" (time, performance, compliance, etc.)

2. Create `.specs/project/PROJECT.md`:
   ```markdown
   ---
   project: [name]
   version: 1.0 (vision)
   created: YYYY-MM-DD
   last-updated: YYYY-MM-DD
   ---

   # Project: [Name]

   ## Vision
   [What we're building]

   ## Audience
   [Who uses it]

   ## Tech Stack
   - [Language/runtime]
   - [Framework]
   - [Database]
   - [Key libraries]

   ## V1 Scope
   - [Feature 1]
   - [Feature 2]

   ## Constraints
   - [Time: ship by X]
   - [Performance: must do Y in <Z ms]
   - [Compliance: GDPR, etc.]
   ```

3. Offer to create `.specs/project/ROADMAP.md` (milestones and phasing)

4. Offer to create `.specs/project/STATE.md` (decisions, blockers, deferred ideas)

---

## Optional: STATE.md

Create `.specs/project/STATE.md` to track decisions, blockers, and deferred ideas across sessions.

Template:

```markdown
---
project: [project-name]
last-updated: YYYY-MM-DD
---

# Project State

## Recent Decisions
| ID | Decision | Rationale | Date |
|----|----------|-----------|------|
| AD-01 | [What was decided] | [Why] | YYYY-MM-DD |

## Active Blockers
| ID | Blocker | Severity | Resolution Path |
|----|---------|----------|-----------------|
| B-01 | [What's blocked] | High/Med/Low | [How to unblock] |

## Deferred Ideas
- [Idea that came up but is out of scope for now]

## Lessons Learned
- [What we learned that affects future work]
```
