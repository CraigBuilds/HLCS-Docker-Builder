#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -eq 0 ]]; then
  echo "Please run this script as a normal user with sudo privileges, not as root."
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "This script requires sudo to install packages."
  exit 1
fi

TARGET_USER="${SUDO_USER:-$USER}"

echo "Installing VS Code and prerequisites on the host for user: ${TARGET_USER}"

sudo apt-get update
sudo apt-get install -y \
  wget \
  gpg \
  apt-transport-https \
  software-properties-common

# Add Microsoft repo for VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor \
  | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg >/dev/null

echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" \
  | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null

sudo apt-get update
sudo apt-get install -y code

# Install VS Code extensions for the target user (not root)
sudo -u "${TARGET_USER}" code --install-extension ms-vscode-remote.remote-containers || true
sudo -u "${TARGET_USER}" code --install-extension ms-python.python || true
sudo -u "${TARGET_USER}" code --install-extension ms-python.vscode-pylance || true
sudo -u "${TARGET_USER}" code --install-extension ms-iot.vscode-ros || true
sudo -u "${TARGET_USER}" code --install-extension ms-azuretools.vscode-docker || true

echo "VS Code and extensions installed. You can now open the repo and 'Reopen in Container'."
