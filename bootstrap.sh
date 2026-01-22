#!/bin/zsh

cd "$(dirname "$0")";

git pull origin jenglert-zsh;

# Install oh-my-zsh (skip if already installed)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

function doIt() {
	rsync \
		--exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude "bootstrap.sh" \
		--exclude "brew.sh" \
		--exclude ".macos" \
		--exclude "README.md" \
		--exclude "LICENSE-MIT.txt" \
		-avh --no-perms . ~;

    echo "Source ~/.zshrc"
	source ~/.zshrc;
}

if [ "$1" = "--force" ] || [ "$1" = "-f" ]; then
	doIt;
else
    echo "This may overwrite existing files in your home directory. Are you sure? (y/n) ";
    read answer

	if [[ $answer =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
unset doIt;
