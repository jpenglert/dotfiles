#!/bin/zsh

# Change to the directory where this script is located
cd "$(dirname "$0")";

# Pull the latest changes from the remote repository
git pull origin jenglert-zsh;

# Install and configure oh-my-zsh and powerlevel10k
./zsh.sh

function doIt() {
	# Sync dotfiles to home directory, excluding scripts and repo files
	rsync \
		--exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude "bootstrap.sh" \
		--exclude "brew.sh" \
		--exclude ".macos" \
		--exclude "README.md" \
		--exclude "LICENSE-MIT.txt" \
		-avh --no-perms . ~;

	# Reload zsh configuration
	echo "Source ~/.zshrc"
	source ~/.zshrc;
}

# Run without prompting if --force or -f flag is passed
if [ "$1" = "--force" ] || [ "$1" = "-f" ]; then
	doIt;
else
	# Prompt for confirmation before overwriting files
	echo "This may overwrite existing files in your home directory. Are you sure? (y/n) ";
	read answer

	if [[ $answer =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
unset doIt;
