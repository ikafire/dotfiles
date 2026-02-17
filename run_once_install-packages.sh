#!/bin/bash
set -euo pipefail

echo "==> Installing essential packages..."

# System packages (apt)
sudo apt-get update
sudo apt-get install -y \
    git \
    zsh \
    fzf \
    tig

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

echo "==> All packages installed!"
