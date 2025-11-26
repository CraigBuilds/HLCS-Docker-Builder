# HLCS-Docker-Builder

This repository contains Docker containers for ROS2 development, built and deployed automatically via GitHub Actions.

## ROS2 Humble Container

A Docker container based on ROS2 Humble Desktop with common development tools.

### Usage

#### Pulling the Image

The container is automatically built and pushed to GitHub Container Registry. You can pull it using:

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

### CI/CD

The container is automatically built and deployed when:
- Code is pushed to the main/master branch
- Pull requests are created
- Manual workflow dispatch is triggered

### What's Included

- ROS2 Humble Desktop
- Python3 and pip
- Colcon build tools
- Git and vim
- Pre-configured ROS2 environment

### Building Locally

To build the container locally:

```bash
docker build -t hlcs-ros2-humble .
```