# Dotfiles Setup with GNU Stow

These configs are managed with **GNU Stow** to create symlinks in `$HOME`.

## Initial Setup

Install stow (macOS):
```bash
brew install stow
```

## Structure

Each folder here (e.g. `zsh`, `hammerspoon`, `ghostty`, `starship`, `pylintrc`) is a **stow package** containing files laid out exactly as they should appear in `$HOME`.

Example structure:
```
zsh/.zshrc                          → ~/.zshrc
ghostty/.config/ghostty/config      → ~/.config/ghostty/config
hammerspoon/.hammerspoon/init.lua   → ~/.hammerspoon/init.lua
starship/.config/starship.toml      → ~/.config/starship.toml
pylintrc/.pylintrc                  → ~/.pylintrc
```

## Apply Symlinks

From inside the `.dotfiles` directory:

```bash
cd ~/pc-scripts/mac_scripts/.dotfiles
stow -t ~ zsh hammerspoon ghostty starship pylintrc
```

This creates symlinks in your home directory pointing back to these files.

## Update After Changes

1. Edit files **inside this repo** (never directly in `~`)
2. Changes are automatically reflected (symlinks!)
3. Re-run `stow -t ~ ...` only if you add new packages or files

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

To move existing config files from `~` into this repo:

```bash
stow --adopt -t ~ package-name
```

This will move the files from `~` into the stow package directory.

## Quick Reference

```bash
# Apply all packages
stow -t ~ zsh hammerspoon ghostty starship pylintrc

# Remove symlinks (if needed)
stow -D -t ~ zsh hammerspoon ghostty starship pylintrc

# Re-stow (useful after conflicts)
stow -R -t ~ zsh hammerspoon ghostty starship pylintrc
```
