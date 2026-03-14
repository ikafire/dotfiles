#!/bin/bash
set -euo pipefail

KEY="$HOME/.ssh/id_ed25519"

if [ ! -f "$KEY" ]; then
    echo "==> Generating ed25519 SSH key..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$USER@$(hostname)" -f "$KEY" -N ""

    echo ""
    echo "==> Public key (add to GitHub/GitLab/etc.):"
    cat "${KEY}.pub"
else
    echo "==> SSH key already exists, skipping."
fi

# Switch chezmoi repo remote from HTTPS to SSH
CHEZMOI_DIR="$(chezmoi source-path 2>/dev/null || echo "$HOME/.local/share/chezmoi")"
CURRENT_URL="$(git -C "$CHEZMOI_DIR" remote get-url origin 2>/dev/null || true)"
if [[ "$CURRENT_URL" == https://github.com/* ]]; then
    SSH_URL="${CURRENT_URL/https:\/\/github.com\//git@github.com:}"
    echo ""
    echo "==> Switching chezmoi remote to SSH: $SSH_URL"
    git -C "$CHEZMOI_DIR" remote set-url origin "$SSH_URL"
fi
