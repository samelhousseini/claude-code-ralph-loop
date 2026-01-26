# Ralph Loop Agent Guide

## Philosophy

"Disk is state, git is memory" - Progress persists in files, not context windows.

## Operational Modes

### Plan Mode (`./loop.sh plan`)
- Analyze requirements in `specs/`
- Generate `IMPLEMENTATION_PLAN.md`
- Break work into context-window-sized tasks

### Build Mode (`./loop.sh build`)
- Pick highest priority incomplete task
- Implement, test, commit
- One task per iteration

## Key Files

| File | Purpose |
|------|---------|
| `IMPLEMENTATION_PLAN.md` | Task list with priorities and status |
| `progress.txt` | Iteration log and learnings |
| `specs/` | Requirements and specifications |
| `PROMPT_plan.md` | Planning mode instructions |
| `PROMPT_build.md` | Build mode instructions |

## Context Management

- Target 40-60% context utilization
- Use subagents for large searches/refactors
- Exit after completing ONE task
- Fresh context = fresh start

## Completion Protocol

1. Task complete → Update plan → Log progress → Exit
2. All tasks complete → Output `<promise>COMPLETE</promise>`
3. Blocked → Log blocker → Output `<promise>EXIT</promise>`
