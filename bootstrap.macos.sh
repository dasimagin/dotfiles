#!/bin/bash

# Install brew
if ! command -v brew &> /dev/null; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi


# Install zsh

# zsh is already default shell on macOS, so we need only to install oh-my-zsh
if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install basic packages
brew install \
  curl fzf curl git htop stow tmux vim wget

# Install jetbrains mono font
brew install --cask font-jetbrains-mono

# Make backup of dotfiles
for file in $(ls -a | grep -E '^\..*'); do
  if [ -f "${HOME}/${file}" ]; then
    if [ -L "${HOME}/${file}" ]; then
      echo "Removing symlink ${file}..."
      rm "${HOME}/${file}"
    else
      echo "Backing up ${file}..."
      mv "${HOME}/${file}" "${HOME}/${file}.backup"
    fi
  fi
done

# Stow dotfiles
stow -t ${HOME} --override=".*" .
