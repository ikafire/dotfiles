#!/bin/bash
set -euo pipefail

# System packages (apt) — apt-get install is idempotent
echo "==> Installing system packages..."
sudo apt-get update
sudo apt-get install -y \
    git \
    zsh \
    fzf \
    tig \
    jq \
    ca-certificates \
    curl \
    python3

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "==> Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# zsh-autosuggestions (oh-my-zsh custom plugin)
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "==> Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting (oh-my-zsh custom plugin)
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    echo "==> Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
fi

# Set zsh as default login shell
ZSH_PATH="$(which zsh)"
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_PATH" ]; then
    echo "==> Setting zsh as default shell..."
    # Ensure zsh is in /etc/shells
    grep -qxF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells
    sudo chsh -s "$ZSH_PATH" "$USER"
fi

# Starship prompt
if ! command -v starship &>/dev/null; then
    echo "==> Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# Zoxide
if ! command -v zoxide &>/dev/null; then
    echo "==> Installing Zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

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

# uv (Python package manager)
if ! command -v uv &>/dev/null; then
    echo "==> Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# .NET SDK 8.0 and 10.0
if ! dpkg -s dotnet-sdk-8.0 &>/dev/null || ! dpkg -s dotnet-sdk-10.0 &>/dev/null; then
    echo "==> Installing .NET SDK..."
    sudo apt update
    sudo apt install -y dotnet-sdk-8.0 dotnet-sdk-10.0
fi

# Docker
if ! command -v docker &>/dev/null; then
    echo "==> Installing Docker..."

    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo groupadd docker 2>/dev/null || true
    sudo usermod -aG docker "$USER"

    echo "==> Docker installed! Log out and back in for group changes to take effect."
fi

echo "==> Done!"
