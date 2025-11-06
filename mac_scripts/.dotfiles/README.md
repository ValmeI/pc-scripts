# Dotfiles Setup with GNU Stow

These configs are managed with **GNU Stow** to create symlinks in `$HOME`.

## Initial Setup

Install stow (macOS):
```bash
brew install stow
```

## Structure

Each folder here (e.g. `zsh`, `hammerspoon`, `ghostty`, `starship`, `pylintrc-personal`, `pylintrc-work`) is a **stow package** containing files laid out exactly as they should appear in `$HOME`.

Example structure:
```
zsh/.zshrc                                → ~/.zshrc
ghostty/.config/ghostty/config            → ~/.config/ghostty/config
hammerspoon/.hammerspoon/init.lua         → ~/.hammerspoon/init.lua
starship/.config/starship.toml            → ~/.config/starship.toml
pylintrc-personal/.pylintrc               → ~/.pylintrc (personal machine)
pylintrc-work/.pylintrc                   → ~/.pylintrc (work machine)
```

## Apply Symlinks

From inside the `.dotfiles` directory:

```bash
cd ~/pc-scripts/mac_scripts/.dotfiles

# Personal machine
stow -t ~ zsh hammerspoon ghostty starship pylintrc-personal

# Work machine
stow -t ~ zsh hammerspoon ghostty starship pylintrc-work
```

This creates symlinks in your home directory pointing back to these files.

## Update After Changes

1. Edit files **inside this repo** (never directly in `~`)
2. Changes are automatically reflected (symlinks!)
3. Re-run `stow -t ~ ...` only if you add new packages or files

## Migrating Existing Configs

If you have existing dotfiles in `~` and want to move them into this stow structure:

```bash
cd ~/pc-scripts/mac_scripts/.dotfiles

# 1) Create package directories
mkdir -p zsh hammerspoon ghostty/.config/ghostty starship/.config pylintrc-personal

# 2) Move files into packages (use git mv if tracked in repo)
mv ~/.zshrc zsh/
mv ~/.hammerspoon hammerspoon/
mv ~/.config/ghostty/config ghostty/.config/ghostty/
mv ~/.config/starship.toml starship/.config/
mv ~/.pylintrc pylintrc-personal/  # or pylintrc-work depending on machine

# 3) Clean up empty dirs (optional)
rmdir ~/.config/ghostty 2>/dev/null || true
rmdir ~/.hammerspoon 2>/dev/null || true

# 4) Apply stow to create symlinks
stow -t ~ zsh hammerspoon ghostty starship pylintrc-personal
```

## Troubleshooting

### Conflict: file already exists

If a real file already exists at the target location:

```bash
# Remove the existing file first
rm ~/path/to/file

# Then stow again
stow -t ~ package-name
```

### Adopt existing files into repo

Alternatively, use `--adopt` to move existing files from `~` into the repo:

```bash
stow --adopt -t ~ package-name
```

This will move the files from `~` into the stow package directory.

## Quick Reference

```bash
# Apply all packages (personal)
stow -t ~ zsh hammerspoon ghostty starship pylintrc-personal

# Apply all packages (work)
stow -t ~ zsh hammerspoon ghostty starship pylintrc-work

# Remove symlinks (if needed)
stow -D -t ~ zsh hammerspoon ghostty starship pylintrc-personal

# Re-stow (useful after conflicts)
stow -R -t ~ zsh hammerspoon ghostty starship pylintrc-personal
```
