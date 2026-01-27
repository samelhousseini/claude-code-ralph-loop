#!/bin/bash
# loop.sh - External Ralph Loop with fresh context each iteration
# Usage: ./loop.sh [mode] [max_iterations]
# Examples:
#   ./loop.sh plan 10      # Run planning mode for max 10 iterations
#   ./loop.sh build 50     # Run build mode for max 50 iterations
#   ./loop.sh build 0      # Run build mode indefinitely (until COMPLETE)
#
# REQUIRES: jq for JSON parsing (real-time streaming output)
# Install jq:
#   Windows (choco):    choco install jq
#   Windows (scoop):    scoop install jq
#   macOS:              brew install jq
#   Ubuntu/Debian:      sudo apt install jq
#   Download:           https://jqlang.github.io/jq/download/

set -e

MODE="${1:-build}"
PROMPT_FILE="PROMPT_${MODE}.md"
MAX_ITERATIONS=${2:-50}  # Default safety limit
ITERATION=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  Ralph Loop - Fresh Context    ${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "Mode: ${GREEN}$MODE${NC}"
echo -e "Prompt file: ${GREEN}$PROMPT_FILE${NC}"
echo -e "Max iterations: ${GREEN}$MAX_ITERATIONS${NC}"
echo ""

# Verify prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo -e "${RED}Error: $PROMPT_FILE not found${NC}"
    echo "Create $PROMPT_FILE first, or use 'plan' or 'build' mode"
    exit 1
fi

# Verify Claude authentication (Max/Pro subscription OR API key)
if ! claude auth status &>/dev/null; then
    if [ -z "$ANTHROPIC_API_KEY" ]; then
        echo -e "${RED}Error: Not authenticated${NC}"
        echo "Run 'claude login' to authenticate with your Max/Pro subscription"
        echo "Or set ANTHROPIC_API_KEY for API billing"
        exit 1
    fi
fi
echo -e "Auth: ${GREEN}OK${NC}"

while true; do
    ITERATION=$((ITERATION + 1))

    echo -e "\n${YELLOW}========== Iteration $ITERATION ==========${NC}"
    echo -e "$(date '+%Y-%m-%d %H:%M:%S')"

    # Check max iterations
    if [ $MAX_ITERATIONS -gt 0 ] && [ $ITERATION -gt $MAX_ITERATIONS ]; then
        echo -e "${RED}Reached max iterations: $MAX_ITERATIONS${NC}"
        break
    fi

    # FRESH Claude Code process each iteration - the key insight
    # Use --output-format stream-json for real-time streaming
    TEMP_OUTPUT="loop_output_$$.txt"

    cat "$PROMPT_FILE" | claude -p \
        --dangerously-skip-permissions \
        --verbose \
        --output-format stream-json \
        --allowedTools "Read,Write,Edit,MultiEdit,Glob,Grep,Bash,WebFetch,WebSearch,Task,NotebookEdit,TodoWrite" \
        2>&1 | tee "$TEMP_OUTPUT" | while IFS= read -r line; do
            # Try to extract text from JSON (use printf to avoid echo issues with special chars)
            text=$(printf '%s' "$line" | jq -r '.delta.text // .message.content[]?.text // empty' 2>/dev/null)
            if [ -n "$text" ]; then
                # printf %b interprets backslash escapes, preserving newlines
                printf '%b' "$text"
            fi
        done || true

    echo ""
    OUTPUT=$(cat "$TEMP_OUTPUT")
    rm -f "$TEMP_OUTPUT"

    # Log iteration to progress.txt
    echo "" >> progress.txt
    echo "## Iteration $ITERATION - $(date '+%Y-%m-%d %H:%M:%S')" >> progress.txt

    # Check for completion signal
    if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
        echo -e "\n${GREEN}========================================${NC}"
        echo -e "${GREEN}  All tasks complete!${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo "## COMPLETED - $(date '+%Y-%m-%d %H:%M:%S')" >> progress.txt
        exit 0
    fi

    # Check for explicit EXIT signal
    if echo "$OUTPUT" | grep -q "<promise>EXIT</promise>"; then
        echo -e "\n${YELLOW}Exit signal received${NC}"
        exit 0
    fi

    # Push to git if there are commits
    if git rev-parse HEAD &>/dev/null; then
        git push origin "$(git branch --show-current)" 2>/dev/null || \
        git push -u origin "$(git branch --show-current)" 2>/dev/null || true
    fi

    # Small delay between iterations to avoid rate limiting
    sleep 2
done

echo -e "\n${BLUE}Ralph Loop finished after $ITERATION iterations${NC}"
