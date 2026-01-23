# Jesse's dotfiles

Dotfiles managed with [chezmoi](https://chezmoi.io/).

## New Laptop Setup

Run this one-liner to set up a new machine:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply jenglert
```

Or if using SSH:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:jenglert/dotfiles.git
```

This will:
1. Install chezmoi
2. Clone this repository
3. Prompt for configuration values (git name, email, postal config path)
4. Install Homebrew (if not present)
5. Install all Homebrew packages
6. Install oh-my-zsh and powerlevel10k
7. Apply all dotfiles
8. Configure macOS system preferences

## What's Included

### Shell Configuration
- **zsh** with oh-my-zsh and powerlevel10k theme
- Custom aliases, functions, and exports
- PATH configuration for Homebrew GNU utilities

### Development Tools
Installed via Homebrew:
- Git, GitHub CLI (gh), GitLab CLI (glab), Graphite
- Node.js, Yarn, pnpm
- Java (Temurin 21), Maven
- Kubernetes CLI, kubectx
- jq, vim, and more

### macOS Configuration
System preferences for:
- Finder (show hidden files, path bar, etc.)
- Dock and hot corners
- Keyboard (fast repeat rate, disable auto-correct)
- Trackpad (tap to click, three-finger drag)
- Screenshots (save to ~/Screenshots)
- And more...

### Applications
Installed via Homebrew Cask:
- iTerm2
- Rectangle (window management)
- Scroll Reverser
- 1Password CLI

## Updating

To pull the latest changes and apply them:

```bash
chezmoi update
```

To see what would change before applying:

```bash
chezmoi diff
```

## Customization

### Adding Custom Commands

If `~/.extra` exists, it will be sourced by `.zshrc`. Use this for machine-specific configuration you don't want in the repo.

### Modifying Dotfiles

Edit the source files and apply:

```bash
chezmoi edit ~/.zshrc
chezmoi apply
```

Or edit directly in the source directory:

```bash
cd $(chezmoi source-path)
# make changes
chezmoi apply
```

## Structure

```
.chezmoi.toml.tmpl          # Config prompts (git identity, etc.)
.chezmoiignore              # Files to ignore
run_once_before_*           # Scripts that run once before applying
run_onchange_before_*       # Scripts that run when content changes
run_once_after_*            # Scripts that run once after applying
dot_*                       # Dotfiles (become ~/.*)
dot_*.tmpl                  # Templated dotfiles
private_dot_vim/            # ~/.vim directory
init/                       # App config files (iTerm2, Rectangle)
```

## Based On

Originally forked from [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles).
