#!/bin/bash
# Helper script to start the ROS2 development container on VMs
# Usage: ./start-dev-container.sh [workspace_path]

set -e

CONTAINER_NAME="ros2-dev"
IMAGE_NAME="ghcr.io/craigbuilds/hlcs-docker-builder:latest"
WORKSPACE_PATH="${1:-$(pwd)}"

# Check if container already exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container '${CONTAINER_NAME}' already exists."
    
    # Check if it's running
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container is already running."
    else
        echo "Starting existing container..."
        docker start ${CONTAINER_NAME}
    fi
else
    echo "Creating and starting new container '${CONTAINER_NAME}'..."
    docker run -d \
        --name ${CONTAINER_NAME} \
        --restart unless-stopped \
        -v "${WORKSPACE_PATH}:/workspace" \
        ${IMAGE_NAME} \
        sleep infinity
    echo "Container started successfully!"
fi

echo ""
echo "To enter the container, run:"
echo "  docker exec -it ${CONTAINER_NAME} bash"
echo ""
echo "To run commands from the host, run:"
echo "  docker exec ${CONTAINER_NAME} <command>"
echo ""
echo "Workspace mounted at: ${WORKSPACE_PATH}"
