#!/bin/false

source /opt/ai-dock/etc/environment.sh

build_common_main() {
    build_common_install_api
}

build_common_install_api() {
    # ComfyUI API wrapper
    $APT_INSTALL libmagic1
    $API_VENV_PIP install --no-cache-dir --upgrade \
        -r /opt/ai-dock/api-wrapper/requirements.txt
}

build_common_install_comfyui() {
    # --- START: DEBUGGING ---
    # This will print every command that is executed from this point on.
    set -x
    
    echo "DEBUG: Current directory is $(pwd)"
    echo "DEBUG: Listing contents of /opt before cloning..."
    ls -la /opt
    # --- END: DEBUGGING ---

    # Set to latest release if not provided
    if [[ -z $COMFYUI_BUILD_REF ]]; then
        export COMFYUI_BUILD_REF="$(curl -s https://api.github.com/repos/comfyanonymous/ComfyUI/tags | \
            jq -r '.[0].name')"
        env-store COMFYUI_BUILD_REF
    fi

    cd /opt
    git clone https://github.com/comfyanonymous/ComfyUI
    
    # --- START: DEBUGGING ---
    echo "DEBUG: Listing contents of /opt after cloning..."
    ls -la /opt
    # --- END: DEBUGGING ---
    
    cd /opt/ComfyUI
    git checkout "$COMFYUI_BUILD_REF"

    echo "Pre-installing PyTorch for Python 3.12 and CUDA 12.1 to override requirements.txt..."
    $COMFYUI_VENV_PIP install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

    echo "Installing other dependencies from requirements.txt..."
    # --- START: DEBUGGING ---
    echo "DEBUG: Verifying requirements.txt exists before pip install..."
    ls -la /opt/ComfyUI/requirements.txt
    # --- END: DEBUGGING ---
    
    $COMFYUI_VENV_PIP install --no-cache-dir \
        -r /opt/ComfyUI/requirements.txt
    
    # --- START: DEBUGGING ---
    # This turns off the detailed command printing.
    set +x
    # --- END: DEBUGGING ---
}

# build_common_run_tests() {
#     installed_pytorch_version=$("$COMFYUI_VENV_PYTHON" -c "import torch; print(torch.__version__)")
#     if [[ "$installed_pytorch_version" != "$PYTORCH_VERSION"* ]]; then
#         echo "Expected PyTorch ${PYTORCH_VERSION} but found ${installed_pytorch_version}\n"
#         exit 1
#     fi
# }

build_common_main "$@"