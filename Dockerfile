# ROS2 Humble Docker Container
# Base image includes ROS2 Humble Desktop with all core ROS2 packages
FROM osrf/ros:humble-desktop

# Prevent interactive prompts during package installation
# This ensures the Docker build process runs without user input
ENV DEBIAN_FRONTEND=noninteractive

# Install essential development tools
# - wget, gpg: Required for downloading and verifying VSCode installation
# - python3-pip: Python package manager for installing additional Python libraries
# - python3-colcon-common-extensions: ROS2 build tool for compiling ROS2 packages
# - git: Version control for managing code
# - vim: Text editor for quick file edits
RUN apt-get update && apt-get install -y \
    wget \
    gpg \
    python3-pip \
    python3-colcon-common-extensions \
    git \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install VSCode for development
# Downloads Microsoft's GPG key, adds VSCode repository, and installs VSCode
# Gracefully handles network failures (builds will succeed even if VSCode install fails)
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg 2>/dev/null || true \
    && if [ -f /tmp/packages.microsoft.gpg ] && [ -s /tmp/packages.microsoft.gpg ]; then \
        install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg \
        && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list \
        && apt-get update \
        && apt-get install -y code; \
    fi \
    && rm -f /tmp/packages.microsoft.gpg \
    && rm -rf /var/lib/apt/lists/*

# Set up workspace directory
# This is where ROS2 packages and code will be stored
RUN mkdir -p /workspace
WORKDIR /workspace

# Auto-source ROS2 environment on shell startup
# Ensures ROS2 commands (ros2, colcon, etc.) are available immediately
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

# Start an interactive bash shell by default
CMD ["/bin/bash"]
