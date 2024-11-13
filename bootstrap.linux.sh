#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# define arch to download packages
ARCH=$(dpkg --print-architecture)

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

# instatll fzf (ubuntu 22.04 compatible)
FZF_VERSION=0.56.0
wget -qO - "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_${ARCH}.tar.gz" | sudo tar -xz -C /usr/local/bin

# Install basic packages
sudo apt install -yq \
  curl curl htop stow tmux vim wget

# Make backup of dotfiles
for file in $(ls -a | grep -E '^\..*'); do
  if [ -f "${HOME}/${file}" ]; then
    if [ -L "${HOME}/${file}" ]; then
      echo "Removing symlink ${file}"
      rm "${HOME}/${file}"
    else
      echo "Backing up ${file}"
      mv "${HOME}/${file}" "${HOME}/${file}.backup"
    fi
  fi
done

# Stow dotfiles
stow -t ${HOME} --override=".*" .
