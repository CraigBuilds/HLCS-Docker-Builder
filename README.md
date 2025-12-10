# HLCS-Docker-Builder

This repository contains Docker containers for ROS2 development, built and deployed on-demand via GitHub Actions.

## ROS2 Humble Container

A Docker container based on ROS2 Humble Desktop with development tools and HLCS dependencies. 

## Pulling and running the Image

## CI/CD

The container is built and deployed on-demand via manual workflow dispatch. To trigger a build:

1. Go to the [Actions tab](../../actions/workflows/build-and-deploy.yml)
2. Click "Run workflow"
3. Select the branch and run

The workflow uses GitHub Actions cache for Docker layers, registry fallback for image pulls, and builds images for a single platform to maximise speed.

The container is also tested in a separate workflow. The tests ensure that after pulling the container, you can:
 - Smoke test: run the ros2 cli tool, i.e `ros2 --help`
 - Access env vars with `echo ROS_VERSION`
 - Access Python with  `python -v`
 
## What's Included

- ROS2 Humble Desktop
- The HLCS ROS2 Workspace
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

## Building Locally

To build the container locally (not recommended unless you are developing the container):

```bash
#todo add instructions for cloning this repo and then building and running the container
```
