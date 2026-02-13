# Ralph Loop

Fresh-context autonomous development for Claude Code. Each iteration spawns a new Claude Code process, solving context rot through fresh context windows while persisting state via files and git.

Named after Ralph Wiggum from The Simpsons - "persistent iteration despite setbacks."

## Two Modes of Operation

Ralph Loop supports two approaches to autonomous development:

| | Process Loop (`loop_process/`) | Interactive Teams (`loop/`) |
|---|---|---|
| **How it runs** | External shell script restarts Claude each iteration | Single session with agent team of teammates |
| **Context** | Fresh context every iteration (solves context rot) | Teammates have independent context windows |
| **Parallelism** | Sequential — one task at a time | Parallel — multiple teammates work simultaneously |
| **User interaction** | Hands-off; runs unattended | Interactive; user can steer between phases |
| **Communication** | State passed via files (progress.txt, plan) | Teammates message each other directly |
| **Best for** | Long-running unattended builds | Complex work needing coordination and discussion |
| **Token cost** | Lower — one session at a time | Higher — each teammate is a separate Claude instance |

---

## Process Loop (`loop_process/`)

The original Ralph Loop. An external shell script runs Claude Code in a loop, giving each iteration a fresh context window. State persists through files and git.

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
2. **Pick** — Selects highest priority incomplete task
3. **Implement** — Makes changes, runs tests
4. **Validate** — Checks pass (tests, lint, typecheck)
5. **Commit** — If checks pass, commits changes
6. **Log** — Updates `loop_process/progress.txt` with learnings
7. **Exit** — Process ends; loop restarts with fresh context

### Files

```
loop_process/
├── loop.sh              # Bash loop runner
├── loop.ps1             # PowerShell loop runner
├── PROMPT_plan.md       # Planning mode prompt
├── PROMPT_build.md      # Build mode prompt
├── specs/               # Your requirements go here
├── IMPLEMENTATION_PLAN.md   # Generated task list (created at runtime)
├── progress.txt         # Iteration log (created at runtime)
└── plan-critique.md     # Plan gaps tracker (created at runtime)
```

---

## Interactive Teams (`loop/`)

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
3. **Architect** designs the implementation plan from the analysis
4. **Critic** reviews the plan against specs, finds gaps
5. Architect and critic **debate and refine** until no gaps remain
6. Team lead **presents findings** to you between phases for feedback

### How It Works — Building

1. **Team lead** creates a `build-team` and populates the shared task list from `loop/IMPLEMENTATION_PLAN.md`
2. **Workers** (2-3) self-claim tasks and implement them in parallel
3. Workers **message each other** when they need context from completed work
4. Team lead **monitors progress**, resolves blockers, and updates the plan
5. When all tasks complete, team lead shuts down workers and cleans up

### Files

```
loop/
├── PROMPT_plan_interactive.md   # Planning mode prompt (agent team)
├── PROMPT_build_interactive.md  # Build mode prompt (agent team)
├── specs/                       # Your requirements go here
├── IMPLEMENTATION_PLAN.md       # Generated task list (created at runtime)
├── progress.txt                 # Phase/task log (created at runtime)
├── plan-critique.md             # Plan gaps tracker (created at runtime)
└── requirements-analysis.md     # Analyst output (created at runtime)
```

### Interacting with the Team

- **Message the lead** — type normally in the main terminal
- **Message a teammate** — use `Shift+Up/Down` to select, then type
- **View task list** — press `Ctrl+T`
- **Split panes** — set `"teammateMode": "tmux"` in settings for side-by-side view

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

> **Note:** Do NOT set `ANTHROPIC_API_KEY` environment variable if using Max/Pro - it would override subscription auth and bill separately.

### 5. Add Your Specifications

Put your project requirements in the specs folder for your chosen mode:

```
# For process loop:
loop_process/specs/
├── requirements.md     # What you want to build
├── features/           # Feature specifications
└── technical/          # Technical specs

# For interactive teams:
loop/specs/
├── requirements.md     # What you want to build
├── features/           # Feature specifications
└── technical/          # Technical specs
```

Each mode reads specs from its own folder. If the specs folder is missing or empty when planning starts, the planner will auto-generate specs from the codebase and pause for your approval before proceeding.

### 6. Run It

Choose your mode:

```bash
# Process loop (unattended)
./loop_process/loop.sh plan 10
./loop_process/loop.sh build 50

# Interactive teams (in Claude Code)
# Paste: Read loop/PROMPT_plan_interactive.md and execute it.
# Paste: Read loop/PROMPT_build_interactive.md and execute it.
```

## File Structure

```
ralph-loop/
├── .devcontainer/
│   ├── devcontainer.json       # Container config
│   ├── Dockerfile              # Claude Code CLI setup
│   └── setup.sh                # Post-create setup
├── loop_process/               # Process loop (fresh context per iteration)
│   ├── loop.sh                 # Bash loop runner
│   ├── loop.ps1                # PowerShell loop runner
│   ├── PROMPT_plan.md          # Planning prompt
│   ├── PROMPT_build.md         # Build prompt
│   └── specs/                  # Requirements for process mode
├── loop/                       # Interactive teams (agent team coordination)
│   ├── PROMPT_plan_interactive.md   # Planning prompt (team)
│   ├── PROMPT_build_interactive.md  # Build prompt (team)
│   └── specs/                  # Requirements for interactive mode
├── AGENTS.md                   # Operational guide for Claude
└── src/                        # Your source code
```

## Customization

### Modify Prompts

- **Process loop**: edit `loop_process/PROMPT_build.md` and `loop_process/PROMPT_plan.md`
- **Interactive teams**: edit `loop/PROMPT_build_interactive.md` and `loop/PROMPT_plan_interactive.md`

### Add Quality Gates

The default `loop_process/PROMPT_build.md` expects tests, linting, and type-checking. Modify for your project's tooling.

### Adjust Allowed Tools (Process Loop)

In `loop_process/loop.sh`, the `--allowedTools` flag controls what Claude can use. See Claude Code docs for the full tool reference.

## Safety

The devcontainer provides isolation:

- `--cap-drop=ALL` - Drops all Linux capabilities
- `--security-opt=no-new-privileges:true` - Prevents privilege escalation
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

### Agent Team Issues (Interactive)

- **Teammates not appearing**: ensure `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is set to `1`
- **Lead doing work instead of delegating**: tell it to "wait for teammates" or use delegate mode (`Shift+Tab`)
- **Stuck tasks**: check `TaskList` and nudge teammates via `SendMessage`

## Cost Considerations

With Max/Pro subscription, usage is included in your plan. Without subscription:

- A 50-iteration process loop on a medium codebase can cost $50-100+ in API usage
- Agent teams use more tokens (each teammate is a separate session)
- Always set iteration limits for process loops
- Break large tasks into smaller specs

## Credits

Based on Geoffrey Huntley's Ralph Loop methodology. See [ghuntley.com/ralph](https://ghuntley.com/ralph/) for the original concept.

## License

MIT
