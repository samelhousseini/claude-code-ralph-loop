FROM mcr.microsoft.com/devcontainers/javascript-node:20

# Install Claude Code CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Create .claude directory with correct permissions BEFORE switching to node user
RUN mkdir -p /home/node/.claude && \
    chown -R node:node /home/node/.claude && \
    chmod -R 755 /home/node/.claude

# Create workspace directory
WORKDIR /workspace

# Set up non-root user permissions
USER node
