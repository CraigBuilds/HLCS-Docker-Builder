# 1) ROS2 Humble Docker Container.
FROM osrf/ros:humble-desktop

# 2) Allow Debian/Ubuntu tools (like apt) to run in non-interactive mode.
ENV DEBIAN_FRONTEND=noninteractive

# 3) Update and install basic apt dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-colcon-common-extensions \
    git \

# Sets /workspace as the working directory for subsequent Dockerfile instructions and for the default shell inside the container. Equivalent to cd /workspace before all future commands.
RUN mkdir -p /workspace
WORKDIR /workspace

# Source ROS2 setup in bashrc
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc

# Default command
CMD ["/bin/bash"]
