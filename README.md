# HLCS-Docker-Builder

This repository contains Docker containers for ROS2 development, built and deployed on-demand via GitHub Actions.

## ROS2 Humble Container

A Docker container based on ROS2 Humble Desktop with VSCode and development tools for writing ROS2 Python nodes.

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

Run with a mounted workspace:

```bash
docker run -it --rm -v $(pwd):/workspace ghcr.io/craigbuilds/hlcs-docker-builder:latest
```

#### Using as Development Environment on VMs

**Easy Setup with Helper Script:**

Download the helper script and start the container:

```bash
# Download the helper script
curl -O https://raw.githubusercontent.com/CraigBuilds/HLCS-Docker-Builder/main/start-dev-container.sh
chmod +x start-dev-container.sh

# Start the container (uses current directory as workspace)
./start-dev-container.sh

# Or specify a workspace path
./start-dev-container.sh /path/to/your/workspace
```

The script automatically:
- Pulls the latest container image
- Creates and starts the container with the correct configuration
- Sets up auto-restart on VM reboot
- Mounts your workspace directory

**Enter the development environment:**

```bash
docker exec -it ros2-dev bash
```

**Run commands from the host:**

```bash
docker exec ros2-dev colcon build
```

**Manual Setup (if preferred):**

```bash
# Start the container
docker run -d --name ros2-dev \
  --restart unless-stopped \
  -v /path/to/workspace:/workspace \
  ghcr.io/craigbuilds/hlcs-docker-builder:latest \
  sleep infinity

# Access the container
docker exec -it ros2-dev bash
```
```

### CI/CD

The container is built and deployed on-demand via manual workflow dispatch. To trigger a build:

1. Go to the [Actions tab](../../actions/workflows/build-and-deploy.yml)
2. Click "Run workflow"
3. Select the branch and run

The workflow uses GitHub Actions cache for Docker layers, registry fallback for image pulls, and builds images for a single platform to maximize speed.

### What's Included

- ROS2 Humble Desktop
- VSCode
- Python3 and pip
- Colcon build tools
- Git and vim
- Pre-configured ROS2 environment

### Running VSCode as a GUI Application

VSCode can be run as a graphical application in several ways:

#### Option 1: Using VSCode Remote (Recommended)

The easiest approach is to use VSCode's Remote - Containers extension from your host machine:

1. Install [VSCode](https://code.visualstudio.com/) on your host machine
2. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
3. Start the container using the helper script or Docker Compose
4. In VSCode, press `F1` and select "Dev Containers: Attach to Running Container..."
5. Select the `ros2-dev` container

This gives you full VSCode functionality without needing X11 or GUI forwarding.

#### Option 2: X11 Forwarding (Linux Hosts)

To run VSCode's GUI directly from the container on Linux:

**Using Docker Compose:**

```bash
# Allow X11 connections (one-time setup)
xhost +local:docker

# Start with Docker Compose
docker compose up -d

# Enter container and run VSCode
docker exec -it ros2-dev bash
code --user-data-dir=/workspace/.vscode-data --no-sandbox
```

**Using Docker Run:**

```bash
# Allow X11 connections (one-time setup)
xhost +local:docker

# Start container with X11 support
docker run -d --name ros2-dev \
  --restart unless-stopped \
  -v $(pwd):/workspace \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -e DISPLAY=$DISPLAY \
  --network host \
  ghcr.io/craigbuilds/hlcs-docker-builder:latest \
  sleep infinity

# Enter container and run VSCode
docker exec -it ros2-dev bash
code --user-data-dir=/workspace/.vscode-data --no-sandbox
```

#### Option 3: VNC/Remote Desktop (Advanced)

For remote access or Windows/Mac hosts, you can set up VNC by adding a desktop environment. This requires additional configuration not included by default.

### Using Docker Compose

Docker Compose simplifies container management with a configuration file:

```bash
# Start the container
docker compose up -d

# Enter the container
docker compose exec ros2-dev bash

# Stop the container
docker compose down

# View logs
docker compose logs -f
```

The `docker-compose.yml` file includes:
- Automatic workspace mounting
- X11 socket mounting for GUI support (Linux)
- Host network access
- Auto-restart configuration

### Building Locally

To build the container locally:

```bash
docker build -t hlcs-ros2-humble .
```