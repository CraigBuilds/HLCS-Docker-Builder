# ROS2 Humble Docker Container
FROM osrf/ros:humble-desktop

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and VSCode
RUN apt-get update && apt-get install -y \
    wget \
    gpg \
    python3-pip \
    python3-colcon-common-extensions \
    git \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install VSCode (may fail in restricted network environments)
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg 2>/dev/null || true \
    && if [ -f /tmp/packages.microsoft.gpg ] && [ -s /tmp/packages.microsoft.gpg ]; then \
        install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg \
        && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list \
        && apt-get update \
        && apt-get install -y code; \
    fi \
    && rm -f /tmp/packages.microsoft.gpg \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
RUN mkdir -p /workspace
WORKDIR /workspace

# Source ROS2 setup in bashrc
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc

# Default command
CMD ["/bin/bash"]
