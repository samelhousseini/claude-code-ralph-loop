# Ralph Loop

Fresh-context autonomous development for Claude Code. Each iteration spawns a new Claude Code process, solving context rot through fresh context windows while persisting state via files and git.

Named after Ralph Wiggum from The Simpsons - "persistent iteration despite setbacks."

## How It Works

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
│   • specs/              Requirements                    │
│   • IMPLEMENTATION_PLAN.md   Task list                  │
│   • progress.txt        Learnings log                   │
│   • Git history         Memory across iterations        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Prerequisites

- **Docker Desktop** (must be running)
- **VS Code** with [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- **Claude Max/Pro subscription** (or Anthropic API key)

## Quick Start

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

Put your project requirements in `specs/`:

```
specs/
├── requirements.md     # What you want to build
├── features/           # Feature specifications
└── technical/          # Technical specs
```

### 6. Run the Loop

**Planning mode** - generates `IMPLEMENTATION_PLAN.md`:

```bash
./loop.sh plan 10
```

**Build mode** - implements tasks from the plan:

```bash
./loop.sh build 50
```

The number is max iterations (safety limit).

## File Structure

```
ralph-loop/
├── .devcontainer/
│   ├── devcontainer.json   # Container config
│   ├── Dockerfile          # Claude Code CLI setup
│   └── setup.sh            # Post-create setup
├── loop.sh                 # Main Ralph Loop script
├── PROMPT_plan.md          # Planning mode instructions
├── PROMPT_build.md         # Build mode instructions
├── AGENTS.md               # Operational guide for Claude
├── progress.txt            # Iteration log
├── specs/                  # Your requirements go here
├── IMPLEMENTATION_PLAN.md  # Generated task list
└── src/                    # Your source code
```

## How the Loop Works

Each iteration:

1. **Read** - Claude reads specs, plan, and progress
2. **Pick** - Selects highest priority incomplete task
3. **Implement** - Makes changes, runs tests
4. **Validate** - Checks pass (tests, lint, typecheck)
5. **Commit** - If checks pass, commits changes
6. **Log** - Updates progress.txt with learnings
7. **Exit** - Fresh context for next iteration

The loop continues until:
- All tasks complete (`<promise>COMPLETE</promise>` output)
- Max iterations reached
- Manual stop (Ctrl+C)

## Customization

### Modify Prompts

Edit `PROMPT_build.md` and `PROMPT_plan.md` to customize Claude's behavior.

### Add Quality Gates

The default `PROMPT_build.md` runs:
```bash
npm test && npm run lint && npm run typecheck
```

Modify these for your project's tooling.

### Adjust Allowed Tools

In `loop.sh`, the `--allowedTools` flag controls what Claude can use. By default, all tools are enabled:

```bash
--allowedTools "Read,Write,Edit,MultiEdit,Glob,Grep,Bash,WebFetch,WebSearch,Task,NotebookEdit,TodoWrite"
```

#### Full Tool Reference

| Tool | Description |
|------|-------------|
| `Read` | Read file contents |
| `Write` | Create new files |
| `Edit` | Edit existing files |
| `MultiEdit` | Make multiple edits in one operation |
| `Glob` | File pattern matching (find files) |
| `Grep` | Search file contents |
| `Bash` | Execute shell commands |
| `WebFetch` | Fetch content from URLs |
| `WebSearch` | Search the web |
| `Task` | Spawn subagents for parallel work |
| `NotebookEdit` | Edit Jupyter notebooks |
| `TodoWrite` | Manage todo/task items |

#### Tool Patterns

You can use patterns for granular control:

```bash
# Allow only specific bash commands
--allowedTools "Bash(git:*),Bash(npm:*),Bash(pnpm:*)"

# Allow writes only to specific directories
--allowedTools "Write(src/**),Write(tests/**)"
```

#### Deny Dangerous Operations

Use `--disallowedTools` to block specific patterns:

```bash
--disallowedTools "Bash(rm -rf *),Bash(sudo *)"
```

## Safety

The devcontainer provides isolation:

- `--cap-drop=ALL` - Drops all Linux capabilities
- `--security-opt=no-new-privileges:true` - Prevents privilege escalation
- Runs as non-root `node` user
- `--dangerously-skip-permissions` is safe inside the sandbox

**Always set `--max-iterations`** to prevent runaway loops.

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

### Loop Not Stopping

The loop exits when Claude outputs `<promise>COMPLETE</promise>` or hits max iterations. If stuck:

- Press `Ctrl+C` to stop
- Check `progress.txt` for what's happening
- Reduce max iterations for debugging

## Cost Considerations

With Max/Pro subscription, usage is included in your plan. Without subscription:

- A 50-iteration loop on a medium codebase can cost $50-100+ in API usage
- Always set iteration limits
- Break large tasks into smaller specs

## Credits

Based on Geoffrey Huntley's Ralph Loop methodology. See [ghuntley.com/ralph](https://ghuntley.com/ralph/) for the original concept.

## License

MIT
