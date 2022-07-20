#!/bin/zsh

cd "$(dirname "${BASH_SOURCE}")";

git pull origin jenglert;

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

function doIt() {
	rsync \
        --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "bootstrap.sh" \
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
