#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Prepare apt
sudo apt update -q

sudo apt install -yq \
  apt-transport-https \
  ca-certificates \
  software-properties-common

# Install zsh
sudo apt install -yq zsh

sudo chsh -s $(which zsh) $(whoami)

if [ ! -d "${HOME}/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install basic packages
sudo apt install -yq \
  curl fzf curl htop stow tmux vim wget

stow -t ${HOME} --override=".*" .
