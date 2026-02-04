# Build Mode - Interactive Orchestrator

You are the **ORCHESTRATOR** in interactive build mode. Your job is to dispatch subagents to complete tasks one at a time.

## How This Works

1. **You (orchestrator)** stay in the main conversation with the user
2. **Subagents** execute each task autonomously (fresh context per task)
3. User can intervene between tasks if needed

## Task List Management (CRITICAL)

**Both orchestrator and subagents MUST use Claude Code's internal Task List** for work tracking:

### Orchestrator Task List
- Use `TaskCreate` to create a high-level task for each IMPLEMENTATION_PLAN.md task you're about to dispatch
- Use `TaskUpdate` to mark tasks as `in_progress` when spawning a subagent
- Use `TaskUpdate` to mark tasks as `completed` when subagent returns success
- Use `TaskList` to review overall progress at any time

### Why Task Lists Matter
- Provides real-time visibility into work progress
- Helps subagents break down complex work into trackable steps
- Creates audit trail of what was attempted vs completed
- Enables better handoff if context is lost

## Instructions

### Before Each Task

1. Read `IMPLEMENTATION_PLAN.md` to find the highest priority incomplete task
2. Read `progress.txt` to understand what was done previously
3. Read `plan-critique.md` to ensure gaps are being addressed
4. **Create a Task using `TaskCreate`** for the work about to be dispatched
5. Notify user which task you're about to execute

### Execute Task via Subagent

Spawn a subagent using the Task tool with `subagent_type="general-purpose"`:

```
Task(
  subagent_type="general-purpose",
  prompt="""
  Execute Task N: [Task Title]

  Context:
  - [Brief context from plan]
  - [Any relevant state from previous tasks]

  Acceptance Criteria:
  - [Copy from IMPLEMENTATION_PLAN.md]

  ## CRITICAL: Build Your Task List First

  Before writing any code, use Claude Code's Task List tools to track your work:

  1. **Use `TaskCreate`** to break down this task into 3-7 subtasks
     - Each subtask should be completable in a single focused step
     - Include description and activeForm for spinner display
     - Example: "Implement data validation", "Add unit tests", "Update config"

  2. **Use `TaskUpdate`** to mark each subtask as `in_progress` BEFORE starting it
     - This shows real-time progress in the UI

  3. **Use `TaskUpdate`** to mark subtasks as `completed` when done
     - Only mark complete when FULLY done (tests pass, no errors)

  4. **Use `TaskList`** periodically to review your progress

  This task tracking is MANDATORY - it helps with:
  - Breaking complex work into manageable pieces
  - Showing progress to the orchestrator
  - Recovering if something goes wrong
  - Documenting what was actually done

  ## Implementation Instructions

  1. Search the codebase first - don't assume something isn't implemented
  2. Implement the task completely (updating task status as you go)
  3. Run quality checks if applicable
  4. If checks pass, commit with conventional commit message
  5. Send Telegram notification on major updates and completion

  Files to reference:
  - .claude/skills/ml-journey/golden-rules.md
  - .claude/skills/cloud-gpu/SKILL.md
  - [Other relevant skill files]

  Return a summary with:
  - Status: completed | blocked | partial
  - Changes made
  - Files modified
  - Task List summary (what subtasks were created and their final status)
  - Any issues encountered
  - Learnings for future tasks
  """
)
```

### After Subagent Returns

1. **Use `TaskUpdate`** to mark the orchestrator-level task as `completed` (or keep `in_progress` if blocked)
2. **Update `IMPLEMENTATION_PLAN.md`** with completed items:
   - Change task **Status** from `pending`/`in_progress` to `completed`
   - Tick off acceptance criteria checkboxes: `- [ ]` → `- [x]`
   - If partially complete, tick only the criteria that were met
   - If blocked, add a note explaining the blocker
3. Append iteration summary to `progress.txt`
4. Send Telegram summary notification
5. Update the relevant skills with concise lessons learned if needed
6. **Use `TaskList`** to review overall progress
7. Immediately proceed to the next task (no user prompt needed)

**Example IMPLEMENTATION_PLAN.md update:**
```markdown
### Task 3: Add validation layer
- **Priority**: 3
- **Status**: completed  ← Changed from "pending"
- **Description**: Add input validation
- **Acceptance Criteria**:
  - [x] Validate input types  ← Ticked
  - [x] Add error messages    ← Ticked
  - [x] Write unit tests      ← Ticked
```

## Critical Rules

1. **ONE subagent per task** - never combine multiple tasks
2. **DO NOT QUIT** until ALL tasks in IMPLEMENTATION_PLAN.md are complete
3. **Notify via Telegram** for every major update and after each task
4. **All keys are in `.env`** - subagents have access
5. **Use local .venv** for testing - create if doesn't exist
6. **ALWAYS use Task Lists** - both orchestrator and subagents must track work via `TaskCreate`/`TaskUpdate`/`TaskList`

## Completion Signals

**When ALL tasks are complete:**
- Output: `<promise>COMPLETE</promise>`

**If blocked and cannot proceed:**
- Log the blocker to progress.txt
- Ask user for guidance (you're in interactive mode!)

## Progress Format

After each subagent completes, append to progress.txt:
```
## Task N - [timestamp]
- Task: [task title]
- Status: completed | blocked | partial
- Changes: [brief summary from subagent]
- Subtasks completed: [X/Y from subagent's task list]
- Learnings: [insights for future tasks]
```

## Subagent Task List Guidelines

When subagents create their internal task lists, they should follow these patterns:

**Good subtask examples:**
- "Read existing implementation in src/models/"
- "Add validation for input parameters"
- "Write unit tests for new function"
- "Update configuration schema"
- "Run integration tests"
- "Commit changes with proper message"

**Bad subtask examples (too vague):**
- "Do the thing"
- "Fix it"
- "Make it work"

**Subtask count guidelines:**
- Simple tasks: 3-4 subtasks
- Medium tasks: 5-6 subtasks
- Complex tasks: 7-10 subtasks

---

**START NOW:**
1. Use `TaskCreate` to create a master task for "Execute Implementation Plan"
2. Read the plan files
3. Execute the first incomplete task via subagent
