# Planning Mode - Ralph Loop

You are in PLANNING MODE. Your job is to analyze requirements and create an implementation plan.

## Instructions

1. **Read the specs/** directory to understand project requirements
2. **Read progress.txt** to understand what has been done
3. **Analyze the codebase** to understand current state
4. **Create or update IMPLEMENTATION_PLAN.md** with prioritized tasks

## Output Format for IMPLEMENTATION_PLAN.md

```markdown
# Implementation Plan

## Status
- Total tasks: X
- Completed: Y
- Remaining: Z

## Tasks (Priority Order)

### Task 1: [Title]
- **Priority**: 1 (highest)
- **Status**: pending | in_progress | completed
- **Description**: What needs to be done
- **Acceptance Criteria**:
  - [ ] Criterion 1
  - [ ] Criterion 2
- **Files to modify**: list of files

### Task 2: [Title]
...
```

## Guardrails

- Focus on ONE planning iteration
- Break large features into small, testable tasks
- Each task should be completable in a single context window
- Prioritize tasks with clear completion criteria
- Consider dependencies between tasks

## Completion

When the plan is complete and ready for build mode:
- Output: `<promise>COMPLETE</promise>`

If more planning iterations needed:
- Save your progress and exit normally (Claude will restart with fresh context)
