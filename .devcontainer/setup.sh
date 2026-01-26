#!/bin/bash
# Post-create setup script

echo "Setting up Ralph Loop environment..."

# Ensure .claude directory exists with correct permissions
# (Docker volume may override Dockerfile-created directory)
mkdir -p /home/node/.claude
chmod -R 755 /home/node/.claude 2>/dev/null || true

# Make loop scripts executable
chmod +x /workspace/loop.sh 2>/dev/null || true

# Initialize git if not already
if [ ! -d "/workspace/.git" ]; then
    git init /workspace
fi

# Configure git (run from workspace)
cd /workspace
git config user.email "ralph@loop.local"
git config user.name "Ralph Loop"

# Create progress.txt if it doesn't exist
if [ ! -f "/workspace/progress.txt" ]; then
    echo "# Progress Log" > /workspace/progress.txt
    echo "## $(date '+%Y-%m-%d %H:%M:%S') - Initialized" >> /workspace/progress.txt
fi

# Verify Claude Code installation
if command -v claude &> /dev/null; then
    echo "Claude Code CLI installed successfully"
    claude --version
else
    echo "Warning: Claude Code CLI not found, installing..."
    npm install -g @anthropic-ai/claude-code
fi

# Print auth instructions (don't run claude auth status - it can hang)
echo ""
echo "========================================"
echo "  AUTHENTICATION SETUP"
echo "========================================"
echo "To use your Max/Pro subscription:"
echo "  1. Run: claude login"
echo "  2. Authenticate in browser with your Claude account"
echo ""
echo "To check auth status later: claude auth status"
echo ""
echo "NOTE: Do NOT set ANTHROPIC_API_KEY if you want to use"
echo "your subscription - it will override subscription auth"
echo "========================================"
echo ""
echo "Ralph Loop environment ready!"
