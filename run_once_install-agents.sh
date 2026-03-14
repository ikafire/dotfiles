#!/bin/bash
set -euo pipefail

# nvm + Node.js (required for claude and codex)
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    echo "==> Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash
fi
# Load nvm so subsequent commands can use it
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
if ! command -v node &>/dev/null; then
    echo "==> Installing Node.js LTS..."
    nvm install --lts
fi

# Claude Code
if ! command -v claude &>/dev/null; then
    echo "==> Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
fi

# Codex
if ! command -v codex &>/dev/null; then
    echo "==> Installing Codex..."
    npm install -g @openai/codex
fi

# Crawl4AI MCP server
CRAWL4AI_MCP_DIR="$HOME/projects/crawl4ai-mcp"

if ! command -v uv &>/dev/null; then
    echo "==> Skipping crawl4ai-mcp setup: uv is not installed."
else
    if [ ! -d "$CRAWL4AI_MCP_DIR/.git" ]; then
        echo "==> Cloning crawl4ai-mcp..."
        mkdir -p "$(dirname "$CRAWL4AI_MCP_DIR")"
        git clone https://github.com/potterdigital/crawl4ai-mcp.git "$CRAWL4AI_MCP_DIR"
    else
        echo "==> Using existing crawl4ai-mcp checkout at $CRAWL4AI_MCP_DIR"
    fi

    echo "==> Installing crawl4ai-mcp dependencies..."
    uv sync --directory "$CRAWL4AI_MCP_DIR"

    echo "==> Installing crawl4ai browser dependencies..."
    if ! uv run --directory "$CRAWL4AI_MCP_DIR" crawl4ai-setup; then
        echo "==> crawl4ai-setup could not complete fully; installing Chromium browser directly..."
        uv run --directory "$CRAWL4AI_MCP_DIR" python -m playwright install chromium
    fi

    echo "==> Verifying crawl4ai installation..."
    uv run --directory "$CRAWL4AI_MCP_DIR" crawl4ai-doctor

    if command -v claude &>/dev/null; then
        if claude mcp get crawl4ai >/dev/null 2>&1; then
            echo "==> Claude Code MCP server 'crawl4ai' already configured."
        else
            echo "==> Registering crawl4ai MCP server in Claude Code (user scope)..."
            CLAUDE_MCP_JSON=$(cat <<JSON
{"type":"stdio","command":"uv","args":["run","--directory","$CRAWL4AI_MCP_DIR","python","-m","crawl4ai_mcp.server"]}
JSON
)
            claude mcp add-json --scope user crawl4ai "$CLAUDE_MCP_JSON"
        fi
    else
        echo "==> Skipping Claude Code MCP registration: claude CLI not found."
    fi

    if command -v codex &>/dev/null; then
        if codex mcp get crawl4ai >/dev/null 2>&1; then
            echo "==> Codex MCP server 'crawl4ai' already configured."
        else
            echo "==> Registering crawl4ai MCP server in Codex..."
            codex mcp add crawl4ai -- uv run --directory "$CRAWL4AI_MCP_DIR" python -m crawl4ai_mcp.server
        fi
    else
        echo "==> Skipping Codex MCP registration: codex CLI not found."
    fi
fi

echo "==> Agent setup done!"
