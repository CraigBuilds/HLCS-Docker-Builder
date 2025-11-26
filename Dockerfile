# ROS2 Humble Development Environment Container
FROM osrf/ros:humble-desktop

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=humble

# Update and install basic dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install development tools
# Note: VSCode can be installed after container is running via:
#   wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
#   sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
#   sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
#   sudo apt update && sudo apt install code
# Or use VSCode Remote-Containers extension from the host
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-colcon-common-extensions \
    git \
    vim \
    nano \
    build-essential \
    cmake \
    gdb \
    clang \
    clang-format \
    clang-tidy \
    valgrind \
    htop \
    tmux \
    tree \
    sudo \
    bash-completion \
    iputils-ping \
    net-tools \
    ssh-client \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Install Python development tools
# Note: In restricted network environments, these can be installed after container is running
RUN pip3 install --no-cache-dir \
    pytest \
    pylint \
    black \
    flake8 \
    mypy \
    ipython \
    jupyter || true

# Create a non-root user for development
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Create workspace directory with proper permissions
RUN mkdir -p /workspace && chown -R $USERNAME:$USERNAME /workspace

# Switch to non-root user
USER $USERNAME
WORKDIR /workspace

# Source ROS2 setup in bashrc for the user
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc && \
    echo "if [ -f /workspace/install/setup.bash ]; then source /workspace/install/setup.bash; fi" >> ~/.bashrc

# Default command - start bash shell for interactive development
CMD ["/bin/bash"]
