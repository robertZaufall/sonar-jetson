#!/usr/bin/env bash
set -euo pipefail

# Resolve paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

APP_NAME=sonar_base

BASE_IMAGE=dustynv/l4t-ml:r36.4.0
echo "Using BASE_IMAGE=${BASE_IMAGE}"
if ! docker image inspect "$BASE_IMAGE" >/dev/null 2>&1; then
  docker pull "$BASE_IMAGE"
fi

# Use absolute path for -f to avoid context-relative resolution issues
DOCKERFILE_PATH="${SCRIPT_DIR}/Dockerfile_base"
if [ ! -f "${DOCKERFILE_PATH}" ]; then
  echo "Error: Dockerfile not found at ${DOCKERFILE_PATH}" >&2
  exit 1
fi

docker build \
  --build-arg BASE_IMAGE="$BASE_IMAGE" \
  -t "${APP_NAME}:latest" \
  -f "${DOCKERFILE_PATH}" \
  "${REPO_ROOT}"
