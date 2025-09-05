# sonar-jetson

Containerized YOLO/ONNX runtime environment for NVIDIA Jetson (JetPack 6 / L4T r36) with convenient build/run scripts and sensible defaults for camera and GUI support.

## Requirements
- NVIDIA Jetson Orin (t234) with JetPack 6.x and Docker.
- GPU access via CDI (`nvidia-ctk cdi`) or legacy `--runtime nvidia`.
- Optional: X11 for GUI (`DISPLAY`), V4L2 camera (e.g., `/dev/video0`).

## Quick Start

0) Change to docker folder
```
cd docker
```

1) Build the image
```
./build.sh
```

2) Run the dev container
```
./run.sh
```

3) Verify inside the container
- `python3 -c "import ultralytics, onnx, cv2, onnxruntime as ort; print('ok', ultralytics.__version__)"`
- `v4l2-ctl --list-devices` (confirm camera access)

- `python3 scripts/gpu_check.py` (check gpu enabled libraries)
- `yolo version` (check yolo and return version - generates `/yolo/settings.json`)

## Troubleshooting
- No GUI windows: ensure `DISPLAY` is set and `xhost +si:localuser:root` on host.
- No camera: check `CAM_DEV` path and `v4l2-ctl --list-devices` on host.
- GPU not visible: prefer CDI (`nvidia-ctk cdi list` shows `nvidia.com/gpu`), else the script falls back to `--runtime nvidia`.
