# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a chezmoi-based dotfiles repository for macOS development environment management. It manages shell configuration, development tools, and system preferences through chezmoi's templating system.

## Key Commands

```bash
# Apply all dotfiles to the system
chezmoi apply

# Preview changes before applying
chezmoi diff

# Edit a managed file (opens editor, applies on save)
chezmoi edit ~/.zshrc

# Pull latest changes and apply
chezmoi update

# Add a new file to be managed
chezmoi add ~/.newconfig
```

## Architecture

### Chezmoi File Naming Conventions

- `dot_` prefix → becomes `.` (e.g., `dot_zshrc` → `~/.zshrc`)
- `private_` prefix → sets restrictive permissions
- `.tmpl` suffix → processed as Go template with chezmoi data
- `run_onchange_before_` → scripts that run before applying, re-run when content hash changes
- `run_onchange_after_` → scripts that run after applying

### Configuration Flow

1. `.chezmoi.toml.tmpl` → prompts for user-specific data (git name/email, paths)
2. `.chezmoiexternal.toml` → downloads external dependencies (oh-my-zsh, powerlevel10k, zsh plugins)
3. `run_onchange_before_*` scripts → install Homebrew and packages
4. Dotfiles are applied to home directory
5. `run_onchange_after_*` scripts → configure macOS system preferences

### Key Files

- **`.chezmoi.toml.tmpl`** - Chezmoi configuration with user prompts and 1Password integration
- **`.chezmoiexternal.toml`** - External dependencies (oh-my-zsh framework, powerlevel10k theme, zsh-syntax-highlighting)
- **`.chezmoitemplates/brew-prefix`** - Template partial for detecting Homebrew path (ARM64 vs Intel)

### Shell Stack

- zsh with oh-my-zsh framework
- powerlevel10k theme (configured in `dot_p10k.zsh`)
- Plugins: git, alias-finder, docker, docker-compose, gcloud, mvn, zsh-syntax-highlighting

### Shell Dotfiles

The `.zshrc` sources several dotfiles for organization. Each has a specific purpose:

- **`dot_path.tmpl`** → `~/.path` - All PATH modifications go here
- **`dot_exports.tmpl`** → `~/.exports` - Environment variables and secrets (via 1Password)
- **`dot_aliases`** → `~/.aliases` - Shell aliases
- **`dot_functions`** → `~/.functions` - Shell functions

When making changes:
- Adding to PATH → edit `dot_path.tmpl`
- Adding environment variables → edit `dot_exports.tmpl`
- Adding aliases → edit `dot_aliases`
- Adding shell functions → edit `dot_functions`
- Changing zsh/oh-my-zsh config (plugins, theme, options) → edit `dot_zshrc.tmpl`

### Template Variables

Templates use chezmoi's data system. Access values with `{{ .variableName }}`:
- `.name`, `.email` - Git identity from prompts
- `.postalPath` - Optional Postal.io development path
- `.opPath` - 1Password CLI path (architecture-dependent)

### 1Password Integration

Secrets are retrieved via chezmoi's 1Password integration using `onepasswordRead` function in templates. Used for API tokens (GitLab, GitHub, Apollo, Bugsnag, DataDog).

## Installation Scripts

Scripts in root with `run_onchange_` prefix execute in alphabetical order:

1. `00-sudo-keepalive` - Maintains sudo session during installation
2. `01-install-homebrew` - Installs Homebrew if missing
3. `02-install-packages` - Installs ~50 packages via brew/cask
4. `configure-macos` - Applies 100+ macOS system preferences via `defaults write`
5. `zzz-cleanup` - Cleans up sudo keepalive process

## Directory Structure

- `init/` - Application preference files (iTerm2, Rectangle, Terminal themes)
- `private_dot_vim/` - Vim configuration (colors, syntax, backup directories)
- `.chezmoitemplates/` - Reusable template partials
