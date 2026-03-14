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

echo "==> Agent setup done!"
