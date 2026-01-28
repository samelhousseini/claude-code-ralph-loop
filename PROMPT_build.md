# Build Mode - Ralph Loop

You are in BUILD MODE. Your job is to implement ONE task per iteration.

## Instructions

1. **Read IMPLEMENTATION_PLAN.md** to see all tasks and their priorities
2. **Read progress.txt** to see what was done in previous iterations
3. **Read plan-critique.md** to see whether the identified gaps during planning are being address in the implementation plan
4. **Pick the highest priority incomplete task**
5. **Search the codebase first** - don't assume something isn't implemented
6. **Implement the task** completely
7. **Run quality checks**: tests, linting, type-checking (if applicable)
8. **If checks pass**, commit with a conventional commit message
9. **Update IMPLEMENTATION_PLAN.md** marking the task complete
10. **Append learnings to progress.txt**

## Commit Message Format

```
type(scope): brief description

- Detail 1
- Detail 2
```

Types: feat, fix, docs, style, refactor, test, chore

## Quality Gates (Backpressure)

Before committing, ensure:
- [ ] Code compiles/runs without errors
- [ ] Tests pass (if test infrastructure exists)
- [ ] No obvious security issues introduced
- [ ] Changes are focused on the single task

## Guardrails

999. Single sources of truth - no unnecessary migrations/adapters
9999. If tests unrelated to your work fail, try to resolve them
99999. **ONE task per iteration** - exit when the task is done
999999. Keep commits atomic and focused

## Progress Logging

Append to progress.txt:
```
## Iteration N - [timestamp]
- Task: [task title]
- Status: completed | blocked | partial
- Changes: [brief summary]
- Learnings: [any insights for future iterations]
```

## Completion Signals

**When current task is done:**
- Update IMPLEMENTATION_PLAN.md
- Log to progress.txt
- Exit normally (fresh context will pick up next task)

**When ALL tasks in IMPLEMENTATION_PLAN.md are complete:**
- Output: `<promise>COMPLETE</promise>`

**If blocked and cannot proceed:**
- Log the blocker to progress.txt
- Output: `<promise>EXIT</promise>`
