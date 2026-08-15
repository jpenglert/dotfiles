# Repository Guide

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
- `executable_` prefix → sets executable permissions
- `private_` prefix → sets restrictive permissions
- `.tmpl` suffix → processed as Go template with chezmoi data
- `run_onchange_before_` → scripts that run before applying, re-run when content hash changes
- `run_onchange_after_` → scripts that run after applying

### Source vs Target Paths

Chezmoi has two path contexts:

- **Source paths** - Files in this repo (e.g., `dot_claude/executable_statusline.sh`)
- **Target paths** - Files in the home directory (e.g., `~/.claude/statusline.sh`)

When adding files:

1. Copy to the appropriate `dot_` directory (use `executable_` prefix if needed).
2. Update `.chezmoiignore` if the directory is ignored; its patterns use **target paths**, not source paths.

### dot_claude/ vs .claude/ directories

This repo contains two similarly named directories with different purposes:

- **`dot_claude/`** - Chezmoi source directory for `~/.claude/`. Files here get deployed to the home directory. Put managed dotfiles here.
- **`.claude/`** - Claude Code's local settings for this repo (e.g., `settings.local.json`). This is not deployed anywhere; it is chezmoi's own Claude Code configuration.

### Configuration Flow

1. `.chezmoi.toml.tmpl` prompts for user-specific data (git name/email and paths).
2. `.chezmoiexternal.toml` downloads external dependencies (oh-my-zsh, powerlevel10k, and zsh plugins).
3. `run_onchange_before_*` scripts install Homebrew and packages.
4. Dotfiles are applied to the home directory.
5. `run_onchange_after_*` scripts configure macOS system preferences.

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

- `dot_path.tmpl` → `~/.path` - All PATH modifications go here
- `dot_exports.tmpl` → `~/.exports` - Environment variables and secrets (via 1Password)
- `dot_aliases` → `~/.aliases` - Shell aliases
- `dot_functions` → `~/.functions` - Shell functions

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

Secrets are retrieved via chezmoi's 1Password integration using `onepasswordRead` in templates. It is used for API tokens (GitLab, GitHub, Apollo, Bugsnag, and DataDog).

## Installation Scripts

Scripts in the root with a `run_onchange_` prefix execute in alphabetical order:

1. `00-sudo-keepalive` - Maintains the sudo session during installation
2. `01-install-homebrew` - Installs Homebrew if missing
3. `02-install-packages` - Installs ~50 packages via brew/cask
4. `configure-macos` - Applies 100+ macOS system preferences via `defaults write`
5. `zzz-cleanup` - Cleans up the sudo keepalive process

### Ignore File (.chezmoiignore)

The `.chezmoiignore` file controls which files chezmoi manages. **Its syntax differs from `.gitignore`.**

Key rules:

- Use `.dir/*` (single asterisk) to ignore contents of a directory.
- Use `!.dir/filename` to exclude specific files from being ignored.
- All `!` exclusions take priority over includes.
- Patterns match against **target paths** (e.g., `.claude/`), not source paths (e.g., `dot_claude/`).

Example: ignore a directory but manage specific files:

```
.claude/*
!.claude/CLAUDE.md
!.claude/statusline.sh
```

**Do not use `**` for this pattern**; it will not work with negations as expected.

## Directory Structure

- `init/` - Application preference files (iTerm2, Rectangle, Terminal themes)
- `private_dot_vim/` - Vim configuration (colors, syntax, backup directories)
- `.chezmoitemplates/` - Reusable template partials
