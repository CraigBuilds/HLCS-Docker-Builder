# HLCS-Docker-Builder

This repository contains Docker containers for ROS2 development, built and deployed on-demand via GitHub Actions.

## ROS2 Humble Development Environment Container

A comprehensive Docker container based on ROS2 Humble Desktop, designed to be used as a complete development environment with VSCode and essential development tools.

### Usage

#### Pulling the Image

The container is built and pushed to GitHub Container Registry on-demand. You can pull it using:

```bash
docker pull ghcr.io/craigbuilds/hlcs-docker-builder:latest
```

Or use a specific tag:

```bash
docker pull ghcr.io/craigbuilds/hlcs-docker-builder:humble
```

#### Running the Container

Run the container interactively:

```bash
docker run -it --rm ghcr.io/craigbuilds/hlcs-docker-builder:latest
```

Run with a mounted workspace (recommended for development):

```bash
docker run -it --rm -v $(pwd):/workspace ghcr.io/craigbuilds/hlcs-docker-builder:latest
```

#### Using as a Development Environment

For long-running development sessions, you can run the container in detached mode and then exec into it:

```bash
# Start the container in the background
docker run -d --name ros2-dev \
  -v $(pwd):/workspace \
  --network host \
  ghcr.io/craigbuilds/hlcs-docker-builder:latest \
  sleep infinity

# Enter the container
docker exec -it ros2-dev /bin/bash
```

#### Installing VSCode in the Container

VSCode is not pre-installed to avoid build-time network restrictions, but can be easily installed after starting the container:

```bash
# Enter the running container
docker exec -it ros2-dev /bin/bash

# Install VSCode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm packages.microsoft.gpg
sudo apt update && sudo apt install -y code

# Run VSCode (requires X11 forwarding or similar display configuration)
code --user-data-dir /workspace/.vscode-data
```

#### Using VSCode Dev Containers Extension

The recommended way to use VSCode with this container is via the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers):

1. Install the Dev Containers extension in VSCode on your host machine
2. Start the container: `docker run -d --name ros2-dev -v $(pwd):/workspace ghcr.io/craigbuilds/hlcs-docker-builder:latest sleep infinity`
3. In VSCode, press F1 and select "Dev Containers: Attach to Running Container..."
4. Select the `ros2-dev` container
5. VSCode will connect to the container, giving you full IDE functionality

#### Using on VMs (Auto-start on Boot)

To have the container automatically start when a VM boots, add this to your VM's startup script or systemd service:

```bash
# Start the ROS2 development container
docker run -d --name ros2-dev \
  --restart unless-stopped \
  -v /path/to/workspace:/workspace \
  --network host \
  ghcr.io/craigbuilds/hlcs-docker-builder:latest \
  sleep infinity
```

To execute commands using the tools in the container:

```bash
# Run a command in the container
docker exec ros2-dev colcon build

# Open an interactive shell
docker exec -it ros2-dev /bin/bash
```

### CI/CD

The container is built and deployed on-demand via manual workflow dispatch. To trigger a build:

1. Go to the [Actions tab](../../actions/workflows/build-and-deploy.yml)
2. Click "Run workflow"
3. Select the branch and run

The workflow uses GitHub Actions cache for Docker layers, registry fallback for image pulls, and builds images for a single platform to maximize speed.

### What's Included

#### Core Tools
- ROS2 Humble Desktop
- Python3 and pip
- Colcon build tools
- Non-root user (developer) with sudo access

#### Development Tools
- Build tools: gcc, g++, make, cmake, clang
- Debuggers: gdb, valgrind
- Code formatters: clang-format, clang-tidy
- Version control: git
- Editors: vim, nano
- Shell tools: bash-completion, tmux, htop, tree

#### Python Development
- pytest - Testing framework (pre-installed)
- Additional packages can be installed: pylint, black, flake8, mypy, ipython, jupyter

#### Network and System Tools
- ssh client
- ping, net-tools
- wget, curl
- sudo access for the developer user

#### VSCode Support
- VSCode can be installed after container startup (see usage instructions)
- Fully compatible with VSCode Dev Containers extension
- Pre-configured development environment ready for use

#### Container Features
- Non-root user (developer, UID 1000) for better security
- Pre-configured ROS2 environment that auto-sources on shell startup
- Workspace directory at `/workspace` with proper permissions
- Automatic sourcing of workspace overlays when available

### Building Locally

To build the container locally:

```bash
docker build -t hlcs-ros2-humble .
```