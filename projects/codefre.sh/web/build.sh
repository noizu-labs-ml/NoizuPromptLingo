#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE="ops.noizu.com/app-codefresh"
TAG="${1:-latest}"

echo "Compiliing"
npm run build

echo "Building ${IMAGE}:${TAG} ..."
docker build \
  --platform linux/amd64 \
  -t "${IMAGE}:${TAG}" \
  "${SCRIPT_DIR}"

echo "Pushing ${IMAGE}:${TAG} ..."
docker push "${IMAGE}:${TAG}"

echo "Done."
