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
    unzip \
    python3 \
    libc6 \
    libgcc1 \
    libgssapi-krb5-2 \
    libicu-dev \
    libssl-dev \
    libstdc++6 \
    zlib1g

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

# uv (Python package manager)
if ! command -v uv &>/dev/null; then
    echo "==> Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# .NET SDK (via Microsoft install script — avoids apt mirror lag)
DOTNET_INSTALL_DIR="$HOME/.dotnet"
if ! "$DOTNET_INSTALL_DIR/dotnet" --list-sdks 2>/dev/null | grep -q "^8\."; then
    echo "==> Installing .NET SDK 8.0..."
    curl -fsSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel 8.0 --install-dir "$DOTNET_INSTALL_DIR"
fi
if ! "$DOTNET_INSTALL_DIR/dotnet" --list-sdks 2>/dev/null | grep -q "^10\."; then
    echo "==> Installing .NET SDK 10.0..."
    curl -fsSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel 10.0 --install-dir "$DOTNET_INSTALL_DIR"
fi
if ! "$DOTNET_INSTALL_DIR/dotnet" tool list -g 2>/dev/null | grep -q "csharp-ls"; then
    echo "==> Installing csharp-ls (C# LSP)..."
    "$DOTNET_INSTALL_DIR/dotnet" tool install -g csharp-ls
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
