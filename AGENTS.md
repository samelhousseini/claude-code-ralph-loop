# Ralph Loop Agent Guide

## Philosophy

"Disk is state, git is memory" — Progress persists in files, not context windows.

## Operational Modes

### Recommended: Interactive Teams (`loop/`)

Agent team orchestration inside a single Claude Code session. A team lead coordinates specialist teammates who work in parallel.

**Planning mode** — Analyst + Architect + Critic collaborate on the plan:
```
Read loop/PROMPT_plan_interactive.md and execute it.
```

**Build mode** — Parallel worker teams implement the plan:
```
Read loop/PROMPT_build_interactive.md and execute it.
```

### Alternative: Process Loop (`loop_process/`)

External shell script restarts Claude each iteration for fresh context. Same agent team pattern, but the loop script manages iteration boundaries.

```bash
./loop_process/loop.sh plan 10    # Planning
./loop_process/loop.sh build 50   # Building
```

## Architecture

Both modes use the same team-based pattern:

- **Team lead** (orchestrator only) — coordinates, never implements
- **Planning specialists** — analyst, architect, critic (plan mode)
- **Parallel workers** — independent tasks run simultaneously (build mode)
- **Dependency analysis** — workers are batched by dependencies; independent tasks run in parallel
- **File ownership isolation** — each worker owns specific files to prevent conflicts

## Key Files

| File | Purpose |
|------|---------|
| `IMPLEMENTATION_PLAN.md` | Task list with 4-level checkbox tracking |
| `IMPLEMENTATION_PLAN_INSTRUCTIONS.md` | Build-phase guide (environment, testing, quality gates) |
| `progress.txt` | Iteration log and learnings |
| `specs/` | Requirements and specifications |
| `requirements-analysis.md` | Analyst output (plan mode) |
| `plan-critique.md` | Critic's gap tracker (plan mode) |

## Context Management

- Team lead stays in the main conversation; workers get independent context windows
- Workers are torn down and recreated between batches (fresh context per batch)
- State persists via files and git, not context windows
- Process loop mode additionally restarts Claude itself each iteration

## Completion Protocol

1. Task complete → Update plan checkboxes → Log progress
2. All tasks complete → Output `<promise>COMPLETE</promise>`
3. Blocked → Log blocker → Output `<promise>EXIT</promise>`
