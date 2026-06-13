#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="noizu-ink-landing"
TAG="${1:-latest}"

echo "Building ${IMAGE_NAME}:${TAG}..."
docker build -t "${IMAGE_NAME}:${TAG}" .

echo ""
echo "Done. Run with:"
echo "  docker run -p 8080:80 ${IMAGE_NAME}:${TAG}"
echo ""
echo "Then open http://localhost:8080"
