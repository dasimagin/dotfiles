#!/bin/bash
set -euo pipefail

bootstrap_macos() {
  # Install zsh
  # zsh is already default shell on macOS, so we need only to install oh-my-zsh
  if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    RUNZSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  # Install brew
  if ! command -v brew &>/dev/null; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Add brew to PATH during bootstrap
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # Install python
  brew install python3

  # Install basic packages
  brew install bat curl fzf git htop kitty less make stow tmux vim wget

  # Install C++ toolchain
  if ! xcode-select -p &>/dev/null; then
    xcode-select --install
  fi

  # Install jetbrains mono font
  brew install --cask font-jetbrains-mono

  # dev tools
  brew install clang-format bazelisk buildifier coder

  # Install AI coding agents
  brew install --cask codex claude-code

  # Clean up all
  brew cleanup
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
    RUNZSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  # Setup locales
  sudo apt install -yq locales
  sudo locale-gen en_US.UTF-8 ru_RU.UTF-8
  sudo update-locale

  sudo apt install -yq bat curl fzf git htop kitty less stow tmux vim wget

  # Install dev tools
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null

  sudo add-apt-repository -y "deb [arch=$(dpkg --print-architecture)] https://packages.microsoft.com/repos/vscode stable main"

  sudo apt update -q

  sudo apt install -yq \
    clang \
    lldb \
    clang-format \
    make \
    python3-dev \
    python3-pip

  # Install jetbrains mono font
  sudo apt install -yq fonts-jetbrains-mono

  # Install texlive
  sudo apt install -yq texlive-full

  # Cleanup all
  sudo apt autoremove --purge
}

bootstrap_linux_coder() {
  nix profile install \
    nixpkgs#bat \
    nixpkgs#glibcLocales \
    nixpkgs#htop \
    nixpkgs#stow

  export PATH="$HOME/.nix-profile/bin:$PATH"
  export LOCALE_ARCHIVE="$HOME/.nix-profile/lib/locale/locale-archive"

  # what about use nix for all packages?
  if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    RUNZSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  curl -fsSL https://claude.ai/install.sh | bash
}

prepare_dotfiles() {
  # Make backup of dotfiles
  (
    cd dot
    for file in $(find . -type f); do
      if [ -L "${HOME}/${file}" ]; then
        echo "Removing symlink ${file}"
        rm "${HOME}/${file}"
      elif [ -f "${HOME}/${file}" ]; then
        echo "Backing up ${file}..."
        mv "${HOME}/${file}" "${HOME}/${file}.backup"
      fi
    done

    # Stow dotfiles
    stow -t ${HOME} --override=".*" .
  )
}

setup_vscode() {

  if [ -n "${CODER:-}" ]; then
    echo "Skip VSCode setup!"
    return
  fi

  echo "VSCode setup..."

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    VSCODE_CONFIG_DIR="${HOME}/.config/Code/User"
    sudo apt install -yq code
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install --cask visual-studio-code
    VSCODE_CONFIG_DIR="${HOME}/Library/Application Support/Code/User"
  fi

  DOT_VSCODE_DIR="${PWD}/vscode"
  CONFIGS="settings.json"

  for file in ${CONFIGS}; do
    if [ -L "${VSCODE_CONFIG_DIR}/${file}" ]; then
      echo "Removing symlink ${file}"
      rm "${VSCODE_CONFIG_DIR}/${file}"
    elif [ -f "${VSCODE_CONFIG_DIR}/${file}" ]; then
      echo "Backing up ${file}..."
      mv "${VSCODE_CONFIG_DIR}/${file}" "${VSCODE_CONFIG_DIR}/${file}.backup"
    fi

    ln -sf "${DOT_VSCODE_DIR}/${file}" "${VSCODE_CONFIG_DIR}/${file}"
  done

  echo "Install extensions..."
  comm -23 <(code --list-extensions | sort) <(sort "${DOT_VSCODE_DIR}/extensions.txt") | xargs -L 1 code --uninstall-extension
  cat "${DOT_VSCODE_DIR}/extensions.txt" | xargs -L 1 code --force --install-extension
}

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export DEBIAN_FRONTEND=noninteractive
  export DOT_VSCODE_DIR="${PWD}/vscode"

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
setup_vscode

