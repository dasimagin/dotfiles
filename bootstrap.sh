#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Install zsh
apt udpate -q && apt install -yq zsh

chsh -s $(which zsh)

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install basic packages
apt update -q && apt install -yq \
    fzf \
    git \
    htop \
    stow \
    tmux \
    vim \
    wget
