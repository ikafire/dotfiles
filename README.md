# dotfiles

Personal dotfiles managed by [chezmoi](https://chezmoi.io).

## Bootstrap a new machine

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ikafire
```

Log out and back in after for the shell change and Docker group to take effect.

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

**Re-run the install script:**
```bash
bash ~/.local/share/chezmoi/run_once_install.sh
```
