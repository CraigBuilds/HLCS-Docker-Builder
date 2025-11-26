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

To use this container as a persistent development environment on VMs:

```bash
# Start the container in the background
docker run -d --name ros2-dev \
  --restart unless-stopped \
  -v /path/to/workspace:/workspace \
  ghcr.io/craigbuilds/hlcs-docker-builder:latest \
  sleep infinity

# Access the container
docker exec -it ros2-dev /bin/bash

# Run commands from the host
docker exec ros2-dev colcon build
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

### Building Locally

To build the container locally:

```bash
docker build -t hlcs-ros2-humble .
```