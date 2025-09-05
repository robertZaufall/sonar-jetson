#!/usr/bin/env bash
set -euo pipefail

APP_NAME=sonar

DISPLAY_FLAGS=()
if [ -n "${DISPLAY:-}" ]; then
  if command -v xhost >/dev/null 2>&1; then
    xhost +si:localuser:root || true
  fi
  DISPLAY_FLAGS=(-e DISPLAY="$DISPLAY" -v /tmp/.X11-unix:/tmp/.X11-unix)
fi

CAM_DEV=${CAM_DEV:-/dev/video0}

[ -S /tmp/argus_socket ] || sudo mkdir -p /tmp/argus_socket

DOCKER_FLAGS=(
  --rm -it
  --net=host --ipc=host
  -v /tmp/argus_socket:/tmp/argus_socket
  -v "$(cd .. && pwd)":/opt/${APP_NAME}
  -v /run/jtop.sock:/run/jtop.sock
  -w /opt/${APP_NAME}
  --name ${APP_NAME}
)

# Optionally add camera device if present
if [ -e "${CAM_DEV}" ]; then
  DOCKER_FLAGS+=(--device "${CAM_DEV}:/dev/video0")
else
  echo "Warning: camera device ${CAM_DEV} not found; continuing without video"
fi

USE_CDI=false
if command -v nvidia-ctk >/dev/null 2>&1; then
  if nvidia-ctk cdi list 2>/dev/null | grep -q 'nvidia.com/gpu'; then
    USE_CDI=true
    DOCKER_FLAGS+=(--device nvidia.com/gpu=all)
    if nvidia-ctk cdi list 2>/dev/null | grep -q 'nvidia.com/pva'; then
      DOCKER_FLAGS+=(--device nvidia.com/pva=all)
    fi
  fi
fi

if [ "${USE_CDI}" = false ]; then
  DOCKER_FLAGS+=(--runtime nvidia -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES=all)
fi
echo "Using DOCKER_FLAGS=${DOCKER_FLAGS[@]}"
exec docker run "${DOCKER_FLAGS[@]}" "${DISPLAY_FLAGS[@]}" "${APP_NAME}:latest" bash
