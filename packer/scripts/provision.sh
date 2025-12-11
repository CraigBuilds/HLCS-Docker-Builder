#!/bin/bash
# Provisioning script for Ubuntu 24.04 VM
#
# This script is executed by Packer after the Ubuntu installation completes.
# It installs and configures:
# 1. Docker Engine (from official Docker repository)
# 2. Visual Studio Code (from official Microsoft repository)
# 3. Adds the provisioning user to the docker group
#
# The script is run with root privileges via sudo by Packer.

# Exit immediately if any command fails
# This ensures we catch errors early and don't continue with a broken setup
set -e

# Exit if any command in a pipeline fails (not just the last one)
set -o pipefail

# Print each command before executing it (useful for debugging)
set -x

echo "==================================="
echo "Starting provisioning script..."
echo "==================================="

# Update package lists to get latest package information from all repositories
# This ensures we install the most recent versions available
echo "Updating package lists..."
apt-get update

# Install prerequisite packages needed for adding new repositories
# - ca-certificates: SSL certificates for HTTPS connections
# - curl: Command-line tool for downloading files
# - gnupg: GNU Privacy Guard for verifying package signatures
# - lsb-release: Provides information about the Linux distribution
echo "Installing prerequisites..."
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "==================================="
echo "Installing Docker Engine..."
echo "==================================="

# Create directory for Docker's GPG key if it doesn't exist
# The -m 0755 sets permissions: owner can read/write/execute, others can read/execute
echo "Creating Docker GPG key directory..."
install -m 0755 -d /etc/apt/keyrings

# Download Docker's official GPG key and save it to the keyrings directory
# This key is used to verify that packages from Docker's repository are authentic
echo "Downloading Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# Set read permissions for all users on the GPG key file
# This allows apt to read the key when verifying packages
echo "Setting permissions on Docker GPG key..."
chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker's official repository to apt sources
# This tells apt where to download Docker packages from
# The repository URL is specific to:
# - Ubuntu distribution (from lsb_release)
# - The correct architecture (dpkg --print-architecture)
# - Signed with Docker's GPG key for security
echo "Adding Docker repository to apt sources..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists again to include packages from the new Docker repository
echo "Updating package lists with Docker repository..."
apt-get update

# Install Docker Engine and related components
# - docker-ce: Docker Community Edition engine
# - docker-ce-cli: Command-line interface for Docker
# - containerd.io: Container runtime used by Docker
# - docker-buildx-plugin: Docker plugin for extended build capabilities
# - docker-compose-plugin: Docker plugin for defining multi-container applications
echo "Installing Docker packages..."
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Start the Docker service
# This ensures Docker is running after installation
echo "Starting Docker service..."
systemctl start docker

# Enable Docker to start automatically on system boot
# This ensures Docker is available every time the VM starts
echo "Enabling Docker service to start on boot..."
systemctl enable docker

# Verify Docker installation by running the hello-world container
# This is a simple test to confirm Docker is working correctly
echo "Verifying Docker installation..."
docker run --rm hello-world

# Add the packer user to the docker group
# This allows the user to run Docker commands without sudo
# The user will need to log out and back in (or restart) for this to take effect
echo "Adding user 'packer' to docker group..."
usermod -aG docker packer

echo "==================================="
echo "Installing Visual Studio Code..."
echo "==================================="

# Download Microsoft's GPG key for their package repository
# This key verifies that VS Code packages are authentic
echo "Downloading Microsoft GPG key..."
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg

# Add Microsoft's VS Code repository to apt sources
# This tells apt where to download VS Code packages from
echo "Adding VS Code repository to apt sources..."
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
    tee /etc/apt/sources.list.d/vscode.list > /dev/null

# Update package lists to include packages from the Microsoft repository
echo "Updating package lists with VS Code repository..."
apt-get update

# Install Visual Studio Code
# 'code' is the package name for VS Code from the Microsoft repository
echo "Installing Visual Studio Code..."
apt-get install -y code

# Verify VS Code installation by checking its version
echo "Verifying VS Code installation..."
code --version

echo "==================================="
echo "Cleaning up..."
echo "==================================="

# Remove downloaded package files to save disk space
# These files are cached by apt but are no longer needed after installation
echo "Removing cached package files..."
apt-get clean

# Remove unnecessary packages that were installed as dependencies
# but are no longer needed
echo "Removing unnecessary packages..."
apt-get autoremove -y

echo "==================================="
echo "Provisioning complete!"
echo "==================================="

# Print summary of what was installed
echo ""
echo "Installed software:"
echo "- Docker Engine: $(docker --version)"
echo "- Docker Compose: $(docker compose version)"
echo "- Visual Studio Code: $(code --version | head -n 1)"
echo ""
echo "The 'packer' user has been added to the docker group."
echo "Docker can be used without sudo after the next login."
