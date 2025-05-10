#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed

# Install `wget`
brew install wget

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

# Install more recent versions of some macOS tools.
brew install vim
brew install grep
brew install screen
brew install gmp

# Install other useful binaries.
brew install ack

# Git
brew install git
brew install git-lfs

# Meslo LG Nerd Fond
brew install --cask font-meslo-lg-nerd-font

# Java
brew tap homebrew/cask-versions
brew install --cask temurin@21

# Maven
brew install maven
brew install maven-completion

# GHPR (GitHub PR Tool)
brew install gh

# Graphite (GitHub PR Tool)
brew install withgraphite/tap/graphite

# JSON
brew install jq
brew install jql

# Kubernetes
brew install kubernetes-cli
brew install kubectx

# node
brew install node
brew install yarn

# rectangle
# https://github.com/rxhanson/Rectangle
brew install --cask rectangle

# Remove outdated versions from the cellar.
brew cleanup

# Ruby
brew instal rbenv
