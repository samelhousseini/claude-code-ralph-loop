# Ralph Loop

Fresh-context autonomous development for Claude Code. Agent teams coordinate parallel workers while persisting state via files and git, solving context rot through independent context windows.

Named after Ralph Wiggum from The Simpsons — "persistent iteration despite setbacks."

## Two Modes of Operation

Ralph Loop supports two approaches. **Interactive Teams is the recommended method** — it gives you direct control and parallel execution in a single session. The Process Loop is available as an alternative for unattended, hands-off builds.

| | Interactive Teams (`loop/`) | Process Loop (`loop_process/`) |
|---|---|---|
| **Recommended** | Yes | Alternative |
| **How it runs** | Single session with agent team of teammates | External shell script restarts Claude each iteration |
| **Context** | Teammates have independent context windows | Fresh context every iteration (solves context rot) |
| **Parallelism** | Parallel — multiple workers run simultaneously | Parallel — workers run per batch, loop restarts between batches |
| **User interaction** | Interactive; user can steer between phases | Hands-off; runs unattended |
| **Communication** | Teammates message each other directly | State passed via files (progress.txt, plan) |
| **Best for** | Most projects — coordination, steering, and parallel execution | Long-running unattended builds |

---

## Interactive Teams (`loop/`) — Recommended

Agent teams mode. You start a single Claude Code session, give it the prompt, and it creates a **team of Claude Code instances** that work in parallel with shared task lists and direct messaging.

> **Requires** the experimental agent teams feature:
> ```json
> // settings.json
> { "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
> ```

```
┌──────────────────────────────────────────────────────────┐
│                      Team Lead (you)                      │
│           Coordinates work, presents to user              │
│                                                          │
│   ┌──────────┐   ┌──────────┐   ┌──────────┐           │
│   │ Worker 1 │   │ Worker 2 │   │ Worker 3 │  Build    │
│   │          │◄─►│          │◄─►│          │  mode     │
│   └──────────┘   └──────────┘   └──────────┘           │
│                                                          │
│   ┌──────────┐   ┌───────────┐   ┌────────┐            │
│   │ Analyst  │──►│ Architect │◄─►│ Critic │  Plan      │
│   │          │   │           │   │        │  mode      │
│   └──────────┘   └───────────┘   └────────┘            │
│                                                          │
│              Shared Task List + Messaging                 │
└──────────────────────────────────────────────────────────┘
```

### Usage

Open Claude Code interactively and paste one of these commands:

**Planning mode** — team of analyst, architect, and critic:

```
Read loop/PROMPT_plan_interactive.md and execute it. Iterate until the plan is comprehensive and high quality.
```

**Build mode** — team of parallel workers:

```
Read loop/PROMPT_build_interactive.md and execute it. DO NOT QUIT BEFORE YOU FINISH ALL THE TASKS.
```

### How It Works — Planning

1. **Team lead** creates a `planning-team` and spawns three specialists
2. **Analyst** reads all specs and catalogs requirements
3. **Architect** designs `IMPLEMENTATION_PLAN.md` (4-level checkbox tracking) and `IMPLEMENTATION_PLAN_INSTRUCTIONS.md` (build-phase guide covering environment, testing, quality gates)
4. **Critic** reviews the plan against specs, finds gaps
5. Architect and critic **debate and refine** until no gaps remain
6. Team lead **presents findings** to you between phases for feedback

### How It Works — Building

1. **Team lead** reads `IMPLEMENTATION_PLAN.md` and analyzes task dependencies
2. **Independent tasks** are batched together and workers are spawned in parallel (one worker per task)
3. Each worker has **file ownership** — specific files only they may modify, preventing conflicts
4. Workers follow `IMPLEMENTATION_PLAN_INSTRUCTIONS.md` for environment setup, testing protocols, and quality gates
5. When a batch completes, the team is torn down and a new batch begins (fresh context)
6. **Dependent tasks** wait for their dependencies to complete before starting
7. Team lead **monitors progress**, resolves blockers, and updates plan checkboxes
8. When all tasks complete, team lead shuts down and cleans up

### Files

```
loop/
├── PROMPT_plan_interactive.md          # Planning mode prompt (agent team)
├── PROMPT_build_interactive.md         # Build mode prompt (agent team)
├── specs/                              # Your requirements go here
├── IMPLEMENTATION_PLAN.md              # Generated task list (created at runtime)
├── IMPLEMENTATION_PLAN_INSTRUCTIONS.md # Build-phase instructions (created at runtime)
├── progress.txt                        # Phase/task log (created at runtime)
├── plan-critique.md                    # Plan gaps tracker (created at runtime)
└── requirements-analysis.md            # Analyst output (created at runtime)
```

### Interacting with the Team

- **Message the lead** — type normally in the main terminal
- **Message a teammate** — use `Shift+Up/Down` to select, then type
- **View task list** — press `Ctrl+T`
- **Split panes** — set `"teammateMode": "tmux"` in settings for side-by-side view

---

## Process Loop (`loop_process/`) — Alternative

The original Ralph Loop. An external shell script runs Claude Code in a loop, giving each iteration a fresh context window. Each iteration uses the same agent team pattern (team lead + parallel workers), but the loop script manages iteration boundaries and git syncing.

```
┌─────────────────────────────────────────────────────────┐
│                    External Bash Loop                    │
│                                                         │
│   while true; do                                        │
│       cat PROMPT.md | claude -p  ──► Fresh Claude       │
│       git push                       instance each      │
│   done                               iteration          │
│                                                         │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                   Persistent State                       │
│                                                         │
│   • loop_process/specs/             Requirements        │
│   • loop_process/IMPLEMENTATION_PLAN.md   Task list     │
│   • loop_process/progress.txt       Learnings log       │
│   • Git history                     Memory              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Usage

**Planning mode** — generates `loop_process/IMPLEMENTATION_PLAN.md`:

```bash
# Bash / macOS / Linux / devcontainer
./loop_process/loop.sh plan 10

# PowerShell / Windows
.\loop_process\loop.ps1 -Mode plan -MaxIterations 10
```

**Build mode** — implements tasks from the plan:

```bash
# Bash
./loop_process/loop.sh build 50

# PowerShell
.\loop_process\loop.ps1 -Mode build -MaxIterations 50
```

The number is the max iterations (safety limit). The loop stops when Claude outputs `<promise>COMPLETE</promise>` or hits the limit.

### How Each Iteration Works

1. **Read** — Claude reads specs, plan, and progress
2. **Analyze** — Identifies independent tasks and creates a parallel worker batch
3. **Spawn** — Workers implement tasks in parallel with file ownership isolation
4. **Monitor** — Team lead coordinates, resolves blockers
5. **Update** — Plan checkboxes and progress.txt are updated
6. **Exit** — Team is torn down; loop restarts with fresh context

### Files

```
loop_process/
├── loop.sh                             # Bash loop runner
├── loop.ps1                            # PowerShell loop runner
├── PROMPT_plan.md                      # Planning mode prompt
├── PROMPT_build.md                     # Build mode prompt
├── specs/                              # Your requirements go here
├── IMPLEMENTATION_PLAN.md              # Generated task list (created at runtime)
├── IMPLEMENTATION_PLAN_INSTRUCTIONS.md # Build-phase instructions (created at runtime)
├── progress.txt                        # Iteration log (created at runtime)
└── plan-critique.md                    # Plan gaps tracker (created at runtime)
```

---

## Shared Setup

### Prerequisites

- **Docker Desktop** (must be running)
- **VS Code** with [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- **Claude Max/Pro subscription** (or Anthropic API key)

### 1. Start Docker Desktop

The devcontainer requires Docker to be running.

### 2. Open in VS Code

```bash
cd ralph-loop
code .
```

### 3. Reopen in Container

Press `F1` → Select **"Dev Containers: Reopen in Container"**

Wait for the container to build (first time takes a few minutes).

### 4. Authenticate Claude

Inside the container terminal:

```bash
claude login
```

This opens a browser to authenticate with your Claude account. Your Max/Pro subscription will be used (no separate API billing).

> **Note:** Do NOT set `ANTHROPIC_API_KEY` environment variable if using Max/Pro — it would override subscription auth and bill separately.

### 5. Enable Agent Teams

Both modes require agent teams. Add this to your Claude Code settings:

```json
// settings.json
{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
```

### 6. Add Your Specifications

Put your project requirements in the specs folder for your chosen mode:

```
# For interactive teams (recommended):
loop/specs/
├── requirements.md     # What you want to build
├── features/           # Feature specifications
└── technical/          # Technical specs

# For process loop:
loop_process/specs/
├── requirements.md     # What you want to build
├── features/           # Feature specifications
└── technical/          # Technical specs
```

Each mode reads specs from its own folder. If the specs folder is missing or empty when planning starts, the planner will auto-generate specs from the codebase and pause for your approval before proceeding.

### 7. Run It

```bash
# Interactive teams (recommended) — open Claude Code and paste:
# Plan:  Read loop/PROMPT_plan_interactive.md and execute it.
# Build: Read loop/PROMPT_build_interactive.md and execute it.

# Process loop (alternative) — run from terminal:
./loop_process/loop.sh plan 10
./loop_process/loop.sh build 50
```

## File Structure

```
ralph-loop/
├── .devcontainer/
│   ├── devcontainer.json       # Container config
│   ├── Dockerfile              # Claude Code CLI setup
│   └── setup.sh                # Post-create setup
├── loop/                       # Interactive teams (recommended)
│   ├── PROMPT_plan_interactive.md   # Planning prompt (team)
│   ├── PROMPT_build_interactive.md  # Build prompt (team)
│   └── specs/                  # Requirements for interactive mode
├── loop_process/               # Process loop (alternative)
│   ├── loop.sh                 # Bash loop runner
│   ├── loop.ps1                # PowerShell loop runner
│   ├── PROMPT_plan.md          # Planning prompt
│   ├── PROMPT_build.md         # Build prompt
│   └── specs/                  # Requirements for process mode
├── AGENTS.md                   # Operational guide for Claude
└── src/                        # Your source code
```

## Customization

### Modify Prompts

- **Interactive teams**: edit `loop/PROMPT_build_interactive.md` and `loop/PROMPT_plan_interactive.md`
- **Process loop**: edit `loop_process/PROMPT_build.md` and `loop_process/PROMPT_plan.md`

### Add Quality Gates

Both modes' build prompts reference `IMPLEMENTATION_PLAN_INSTRUCTIONS.md` for testing protocols (unit tests, IaC lifecycle testing, skill YAML stress testing, linting). Customize the plan prompt's architect section to change what gets generated in that document.

### Adjust Allowed Tools (Process Loop)

In `loop_process/loop.sh`, the `--allowedTools` flag controls what Claude can use. See Claude Code docs for the full tool reference.

## Safety

The devcontainer provides isolation:

- `--cap-drop=ALL` — Drops all Linux capabilities
- `--security-opt=no-new-privileges:true` — Prevents privilege escalation
- Runs as non-root `node` user
- `--dangerously-skip-permissions` is safe inside the sandbox

**Always set `--max-iterations`** (process loop) to prevent runaway loops.

## Troubleshooting

### OAuth/Permission Errors

If you see permission errors with `.claude` directory:

```bash
# In PowerShell on Windows host
docker volume rm claude-config

# Then rebuild container in VS Code
F1 → "Dev Containers: Rebuild Container"
```

### Authentication Issues

```bash
# Check auth status
claude auth status

# Re-login if needed
claude logout
claude login
```

### Loop Not Stopping (Process Loop)

The loop exits when Claude outputs `<promise>COMPLETE</promise>` or hits max iterations. If stuck:

- Press `Ctrl+C` to stop
- Check `loop_process/progress.txt` for what's happening
- Reduce max iterations for debugging

### Agent Team Issues

- **Teammates not appearing**: ensure `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is set to `1`
- **Lead doing work instead of delegating**: tell it to "wait for teammates" or use delegate mode (`Shift+Tab`)
- **Stuck tasks**: check `TaskList` and nudge teammates via `SendMessage`
- **File conflicts**: ensure each worker's task description includes file ownership

## Cost Considerations

With Max/Pro subscription, usage is included in your plan. Without subscription:

- Agent teams use more tokens (each teammate is a separate session)
- A 50-iteration process loop on a medium codebase can cost $50-100+ in API usage
- Parallel workers complete faster but use tokens concurrently
- Always set iteration limits for process loops
- Break large tasks into smaller specs

## Credits

Based on Geoffrey Huntley's Ralph Loop methodology. See [ghuntley.com/ralph](https://ghuntley.com/ralph/) for the original concept.

## License

MIT
