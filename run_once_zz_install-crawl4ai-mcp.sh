#!/bin/bash
set -euo pipefail

CRAWL4AI_MCP_DIR="$HOME/projects/crawl4ai-mcp"

if ! command -v uv &>/dev/null; then
    echo "==> Skipping crawl4ai-mcp setup: uv is not installed."
    exit 0
fi

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

echo "==> crawl4ai-mcp setup complete."
