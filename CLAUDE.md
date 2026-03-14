# Dotfiles (chezmoi)

Personal dotfiles managed with chezmoi. Maps source files to `$HOME` using naming conventions: `dot_*` → `.` prefix, `run_once_*.sh` → one-time scripts, `.tmpl` → Go templates.

## Workflow

**Always commit and push after making changes.** After any file edits, stage the changes, commit with a descriptive message, and push to the remote. Do not wait for the user to ask.

## Commands

| Command | Description |
|---------|-------------|
| `chezmoi apply` | Apply all dotfiles to home directory |
| `chezmoi diff` | Preview changes before applying |
| `chezmoi managed` | List all managed files |
| `chezmoi add ~/.some_file` | Add a new file to be managed |
| `chezmoi update` | Pull from remote and apply |

## Managed Files

| Source | Target | Purpose |
|--------|--------|---------|
| `dot_zshrc` | `~/.zshrc` | Zsh + Oh My Zsh, Starship, fzf, zoxide |
| `dot_gitconfig` | `~/.gitconfig` | Global git config with conditional work/bridgewell includes |
| `dot_config/git/ignore` | `~/.config/git/ignore` | Global gitignore |
| `dot_config/bridgewell/dot_gitconfig` | `~/.config/bridgewell/.gitconfig` | Work identity for `~/.config/bridgewell/` repos |
| `dot_oh-my-zsh/custom/alias.zsh` | `~/.oh-my-zsh/custom/alias.zsh` | Custom shell aliases |
| `work/dot_gitconfig` | `~/work/.gitconfig` | Work identity for `~/work/` repos |
| `dot_claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | Claude Code global instructions |
| `dot_claude/settings.json` | `~/.claude/settings.json` | Claude Code settings (permissions, model, plugins) |
| `dot_config/ccstatusline/settings.json` | `~/.config/ccstatusline/settings.json` | Claude Code statusline layout |
| `.chezmoi.toml.tmpl` | `~/.config/chezmoi/chezmoi.toml` | Chezmoi config (`autoCommit = true`) |

**Installation scripts (run once):**
- `run_once_install.sh` — zsh, Oh My Zsh, Starship, fzf, zoxide, uv, .NET SDK, Docker CE
- `run_once_install-agents.sh` — nvm, Node.js, Claude Code, Codex, Crawl4AI MCP
- `run_once_generate-ssh-key.sh` — ed25519 SSH key, switches chezmoi remote to SSH

## Gotchas

- **Git identity switching:** `dot_gitconfig` uses `includeIf "gitdir:~/work/"` and `includeIf "gitdir:~/.config/bridgewell/"` to auto-switch to work email. No chezmoi templating needed.
- **Script idempotency:** Each step in `run_once_*.sh` must guard itself with its own condition — never use an early `exit 0` to skip the entire script.
- **`.chezmoiignore`:** Repo-level `CLAUDE.md` and `README.md` are ignored — they won't be applied to home.
- **Templates:** Only `.chezmoi.toml.tmpl` uses templates currently. To add machine-specific config, convert a file to `.tmpl` and use `{{- if eq .chezmoi.os "darwin" }}`.
