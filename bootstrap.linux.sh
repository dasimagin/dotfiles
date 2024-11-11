#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Prepare apt
apt update -q && apt install -yq \
  apt-transport-https \
  ca-certificates \
  software-properties-common

# Install zsh
apt install -yq zsh

sudo chsh -s $(which zsh) $(whoami)

if [ ! -d "${HOME}/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install basic packages
apt install -yq \
  curl fzf curl htop stow tmux vim wget

