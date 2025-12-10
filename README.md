# HLCS-Docker-Builder

This repository contains Docker containers for ROS2 development, built and deployed on-demand via GitHub Actions.

## ROS2 Humble Container

A Docker container based on ROS2 Humble Desktop with development tools and HLCS dependencies. 

### Usage

#### Pulling the Image

The container is built and pushed to GitHub Container Registry on demand. You can pull it using:

```bash
docker pull ghcr.io/craigbuilds/hlcs-docker-builder:latest
```

#### Running the Container


### CI/CD

The container is built and deployed on-demand via manual workflow dispatch. To trigger a build:

1. Go to the [Actions tab](../../actions/workflows/build-and-deploy.yml)
2. Click "Run workflow"
3. Select the branch and run

The workflow uses GitHub Actions cache for Docker layers, registry fallback for image pulls, and builds images for a single platform to maximise speed.

### What's Included

- ROS2 Humble Desktop
- Python3 and pip
- Colcon build tools
- Git
- asyncua
- UaExpert
- Pyside6
- RTI Connext Libraries
- RTI Connext RMW
- RTI Opcua Gateway
- ROS Bridge
- Other ROS Tools
- A Preconfigured ~/.bashrc

### Building Locally

To build the container locally:

```bash
docker build -t hlcs-ros2-humble .
```
