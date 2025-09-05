import json, platform

def _ocv_flag(info: str, key: str):
    for line in info.splitlines():
        if key.lower() in line.lower():
            return line.split(":")[-1].strip().upper().startswith("YES")
    return None

def gpu_accel_check():
    out = {
        "python": platform.python_version(),
        "platform": platform.platform(),
    }

    # PyTorch
    try:
        import torch
        d = {
            "installed": True,
            "version": torch.__version__,
            "cuda_built": bool(torch.version.cuda),
            "cuda_version": torch.version.cuda,
            "gpu_available": torch.cuda.is_available(),
            "cudnn_available": torch.backends.cudnn.is_available(),
        }
        if d["gpu_available"]:
            p = torch.cuda.get_device_properties(0)
            d.update(device=p.name, total_mem_GB=round(p.total_memory / 1024**3, 2))
        if d["cudnn_available"]:
            d["cudnn_version"] = torch.backends.cudnn.version()
        out["pytorch"] = d
    except Exception as e:
        out["pytorch"] = {"installed": False, "error": str(e)}

    # TensorRT
    try:
        import tensorrt as trt
        out["tensorrt"] = {"installed": True, "version": trt.__version__}
    except Exception as e:
        out["tensorrt"] = {"installed": False, "error": str(e)}

    # ONNX Runtime (checks GPU providers if present)
    try:
        import onnxruntime as ort
        providers = ort.get_available_providers()
        out["onnxruntime"] = {
            "installed": True,
            "version": ort.__version__,
            "providers": providers,
            "gpu_available": any(p in providers for p in ("CUDAExecutionProvider", "TensorrtExecutionProvider")),
        }
    except Exception as e:
        out["onnxruntime"] = {"installed": False, "error": str(e)}

    # CuPy
    try:
        import cupy as cp
        ndev = cp.cuda.runtime.getDeviceCount()
        out["cupy"] = {
            "installed": True,
            "version": cp.__version__,
            "gpu_count": ndev,
            "gpu_available": ndev > 0,
        }
    except Exception as e:
        out["cupy"] = {"installed": False, "error": str(e)}

    # OpenCV (build flags + runtime CUDA device count + DNN CUDA backend)
    try:
        import cv2
        info = cv2.getBuildInformation()
        cuda_built = _ocv_flag(info, "NVIDIA CUDA") or _ocv_flag(info, "CUDA")
        cudnn_built = _ocv_flag(info, "cuDNN")
        try:
            cuda_devices = cv2.cuda.getCudaEnabledDeviceCount()
        except Exception:
            cuda_devices = 0
        dnn_cuda = hasattr(cv2.dnn, "DNN_BACKEND_CUDA")
        out["opencv"] = {
            "installed": True,
            "version": cv2.__version__,
            "cuda_built": bool(cuda_built),
            "cudnn_built": bool(cudnn_built),
            "cuda_runtime_devices": int(cuda_devices),
            "dnn_cuda_backend_available": bool(dnn_cuda),
        }
    except Exception as e:
        out["opencv"] = {"installed": False, "error": str(e)}

    print(json.dumps(out, indent=2))

if __name__ == "__main__":
    gpu_accel_check()
