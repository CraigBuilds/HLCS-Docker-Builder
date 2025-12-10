# ROS2 Humble Docker Container.
# Uses: https://github.com/osrf/docker_images/blob/master/ros/humble/ubuntu/jammy/desktop/Dockerfile
# Which itself uses https://github.com/osrf/docker_images/tree/master/ros/humble/ubuntu/jammy/ros-base/Dockerfile
# Which itself  uses https://github.com/osrf/docker_images/blob/master/ros/humble/ubuntu/jammy/ros-core/Dockerfile
FROM osrf/ros:humble-desktop

# Allow Debian/Ubuntu tools (like apt) to run in non-interactive mode.
ENV DEBIAN_FRONTEND=noninteractive

# Update and install basic apt dependencies (is this needed, or is this included in osrf/ros:humble-desktop?)
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-colcon-common-extensions \
    git \

# Sets /workspace as the working directory for subsequent Dockerfile instructions and for the default shell inside the container. Equivalent to cd /workspace before all future commands.
RUN mkdir -p /workspace
WORKDIR /workspace

# Source ROS2 setup in bashrc
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc

# Add a host bootstrap script into the image. Developers can extract this script from the container and run it on the host machine to install host tools (e.g, VSCode and VSCode extensions)
# Usage: 1) Run the container and extract the script
# docker run --rm your.registry/ros2-dev:humble cat /opt/bootstrap/install_host_tools.sh > install_host_tools.sh
# 2) Run the script
# chmod +x install_host_tools.sh && ./install_host_tools.sh
COPY scripts/install_host_tools.sh /opt/bootstrap/install_host_tools.sh
RUN chmod +x /opt/bootstrap/install_host_tools.sh

# Default command
CMD ["/bin/bash"]
