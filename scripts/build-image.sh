#!/bin/bash

# Build and push Docker image script

set -e

IMAGE_NAME="anujspmishra/rbac-test-pod"
TAG="latest"

echo "Building Docker image for RBAC testing..."
cd docker
docker build -t ${IMAGE_NAME}:${TAG} .

echo "Image built successfully!"
echo "To push to Docker Hub, run:"
echo "docker login"
echo "docker push ${IMAGE_NAME}:${TAG}"

echo ""
echo "To test locally:"
echo "docker run -it ${IMAGE_NAME}:${TAG} /bin/bash"
