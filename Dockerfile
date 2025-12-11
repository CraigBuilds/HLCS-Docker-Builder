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
    xvfb \
    libxcb-xinerama0 \
    libxcb-cursor0 \
    libdbus-1-3 \
    libegl1 \
    libfontconfig1
# PySide6/Qt runtime dependencies: 'pip install pyside6' only installs Python bindings and Qt libraries as binary wheels,
# but these binaries dynamically link to system libraries that must be installed separately via apt.
# These are platform-specific shared libraries (.so files) that Qt expects to find at runtime:
# xvfb: Virtual X server for headless GUI testing (allows GUI apps to run without a physical display)
# libxcb-xinerama0: X11 protocol library for multi-monitor support (Qt's xcb platform plugin requires this)
# libxcb-cursor0: X11 cursor management library (needed for mouse cursor rendering)
# libdbus-1-3: D-Bus IPC library (Qt uses D-Bus for system integration like notifications and session management)
# libegl1: OpenGL ES rendering library (Qt's graphics rendering backend requires EGL for hardware acceleration)
# libfontconfig1: Font configuration library (Qt needs this to discover and render system fonts)
# Reference: Qt documentation on Linux/X11 dependencies, PySide6 GitHub issues (#common runtime errors), and testing via ldd on Qt binaries

# Install PySide6 using pip (pinned to version 6.6.1 for reproducible builds)
RUN pip3 install pyside6==6.6.1

# Install Python packages via pip
RUN pip3 install asyncua

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

# Add PySide6 test script for validation
COPY scripts/test_pyside6.py /opt/bootstrap/test_pyside6.py
RUN chmod +x /opt/bootstrap/test_pyside6.py

# Default command
CMD ["/bin/bash"]
