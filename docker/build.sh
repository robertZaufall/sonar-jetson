#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME=sonar

BASE_IMAGE=dustynv/l4t-ml:r36.4.0
echo "Using BASE_IMAGE=${BASE_IMAGE}"
if ! docker image inspect "$BASE_IMAGE" >/dev/null 2>&1; then
  docker pull "$BASE_IMAGE"
fi
docker build --build-arg BASE_IMAGE="$BASE_IMAGE" --build-arg APP_NAME="$APP_NAME" -t "${APP_NAME}:latest" -f Dockerfile ..
