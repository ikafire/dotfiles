# dotfiles

Personal dotfiles managed by [chezmoi](https://chezmoi.io).

## Bootstrap a new machine

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ikafire
```

Log out and back in after for the shell change and Docker group to take effect.

## Run-once scripts

These run in numeric order on the first `chezmoi apply`, and again whenever their contents change.

| Script | Installs |
|---|---|
| `run_once_01-install-system-tools.sh` | apt packages, zsh + Oh My Zsh (+ autosuggestions, syntax-highlighting), Starship, zoxide, uv, .NET SDK, kubectl, gcloud CLI, Docker CE |
| `run_once_02-install-agents.sh` | nvm + Node.js LTS, Claude Code, OpenSpec, herdr (+ its Claude Code integration), Crawl4AI MCP |
| `run_once_03-generate-ssh-key.sh` | ed25519 SSH key, then switches the chezmoi remote from HTTPS to SSH |
| `run_once_04-install-android-sdk.sh` | JDK 17, adb, Android SDK command-line tools |

Each step guards itself, so re-running any script is safe.

**Crawl4AI MCP** (part of script 02) clones to `~/projects/crawl4ai-mcp` and registers a `crawl4ai` MCP server for Claude Code at user scope.

Manual run:

```bash
bash ~/.local/share/chezmoi/run_once_02-install-agents.sh
```

## How-tos

**Add a new dotfile:**
```bash
chezmoi add ~/.config/foo/config
```

**Edit a managed file:**
```bash
chezmoi edit ~/.zshrc        # opens in $EDITOR, applies on save
```

**Preview changes before applying:**
```bash
chezmoi diff
```

**Pull latest and apply:**
```bash
chezmoi update
```

**Make a file machine-specific (templating):**
```bash
chezmoi add --template ~/.config/foo/config
chezmoi edit ~/.config/foo/config   # use {{ .chezmoi.os }}, {{ .chezmoi.hostname }}, etc.
```

**Pull local edits back into the repo:**
```bash
chezmoi re-add            # all managed files
chezmoi re-add ~/.zshrc   # just one
```

**Re-run a run-once script:**
```bash
bash ~/.local/share/chezmoi/run_once_01-install-system-tools.sh
```
