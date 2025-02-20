#!/bin/bash

BASIC_PKGS="bat curl fzf git htop less stow tmux vim wget"
DEV_PKGS="clang clang-format clang-tidy cmake lldb make python3-dev python3-pip"

bootstrap_macos() {
  # Install zsh
  # zsh is already default shell on macOS, so we need only to install oh-my-zsh
  if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  # Install brew
  if ! command -v brew &>/dev/null; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Add brew to PATH during bootstrap
  eval "$(/opt/homebrew/bin/brew shellenv)"

    # Install basic packages
  brew install ${BASIC_PKGS}

  # Install dev tools
  brew install ${DEV_PKGS}

  # Install jetbrains mono font
  brew install --cask font-jetbrains-mono

  # Install nnn plugins
  sh -c "$(curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs)"
}

bootstrap_linux() {
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

  sudo apt install -yq ${BASIC_PKGS}

  # Install dev tools
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
  sudo add-apt-repository -y "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
  sudo apt update -q

  sudo apt install -yq ${DEV_PKGS} code

  # Install jetbrains mono font
  sudo apt install -yq fonts-jetbrains-mono

  # Install texlive
  sudo apt install -yq texlive-full

  # Install nnn plugins
  sh -c "$(curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs)"
}

bootstrap_linux_coder() {
  nix profile install \
    nixpkgs#bat \
    nixpkgs#fzf \
    nixpkgs#htop \
    nixpkgs#stow

  export PATH="$HOME/.nix-profile/bin:$PATH"

  # what about use nix for all packages?
  if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

}

prepare_dotfiles() {
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
}

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export DEBIAN_FRONTEND=noninteractive

  if [ -v CODER ]; then
    echo "Coder devcontainer detected"
    bootstrap_linux_coder
  else
    echo "Linux detected"
    bootstrap_linux
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  echo "MacOS detected..."
  bootstrap_macos
else
  echo "Unsupported OS!"
  exit 1
fi

prepare_dotfiles
