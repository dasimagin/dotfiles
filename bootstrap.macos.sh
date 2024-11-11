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
  curl fzf curl htop stow tmux vim wget

stow -t ${HOME} --override=".*" .
