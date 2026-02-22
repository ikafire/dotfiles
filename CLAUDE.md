# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Chezmoi Commands

```bash
# Apply all dotfiles to the home directory
chezmoi apply

# Preview changes before applying
chezmoi diff

# Add a new file to be managed
chezmoi add ~/.some_config_file

# Edit a managed file (opens in $EDITOR, applies on save)
chezmoi edit ~/.zshrc

# Re-run a run_once script (after modifying it, rename to force re-run)
chezmoi apply --force

# Update from remote and apply
chezmoi update
```

## Repository Structure

Chezmoi maps files in this repo to `$HOME` using naming conventions:
- `dot_*` → `.` prefix (e.g., `dot_zshrc` → `~/.zshrc`)
- `run_once_*.sh` → scripts executed once on first `chezmoi apply`
- `.tmpl` suffix → processed as Go templates before applying

**Managed files:**
- `dot_zshrc` → `~/.zshrc` — Zsh + Oh My Zsh config with Starship prompt, fzf, zoxide
- `dot_gitconfig` → `~/.gitconfig` — Global git config with conditional work include
- `dot_config/git/ignore` → `~/.config/git/ignore` — Global gitignore
- `work/dot_gitconfig` → `~/work/.gitconfig` — Work identity (included via `gitdir:~/work/`)
- `.chezmoi.toml.tmpl` → chezmoi config (git `autoCommit = true`)

**Installation scripts (run once):**
- `run_once_install.sh` — Installs zsh (set as default shell), Oh My Zsh, Starship, fzf, zoxide, nvm, Node.js, Claude Code, Codex, Docker CE
- `run_once_generate-ssh-key.sh` — Generates ed25519 SSH key, switches chezmoi remote to SSH

## Key Architecture Decisions

**Work vs personal git identity:** Uses git's native `includeIf "gitdir:~/work/"` directive in `dot_gitconfig` to automatically switch to a work email (`clin@bridgewell.com`) for repos under `~/work/`. No chezmoi templating is needed for this.

**Templating:** Currently only `.chezmoi.toml.tmpl` uses templates. The `SKILL.md` in `.claude/skills/chezmoi/` documents patterns for adding machine-specific or OS-specific configuration when needed.

**Idempotency in scripts:** Each step must guard itself with its own condition — never use an early `exit 0` to skip an entire script. Other steps in the script must still run.

**Adding machine-specific config:** When a file needs to vary by machine, convert it to a `.tmpl` file and use Go template syntax with chezmoi data:
```
{{- if eq .chezmoi.os "darwin" }}
# macOS-specific config
{{- end }}
```
