# For build automation - Allows building from any ai-dock base image
# Use a *cuda*base* image as default because pytorch brings the libs
ARG IMAGE_BASE="ghcr.io/ai-dock/python:3.10-v2-cuda-12.1.1-base-22.04"
FROM ${IMAGE_BASE}

ARG USER=user

LABEL org.opencontainers.image.source="https://github.com/phonehomephone/comfyui-py312"
LABEL org.opencontainers.image.description="A custom build of ai-dock/comfyui updated to use Python 3.12."
LABEL maintainer="https://github.com/phonehomephone/"

# --- START: Final Python, User, and System Tools Section ---
# Switch to root user to install system packages
USER root

# Forcefully remove the old, conflicting system pip package.
RUN apt-get remove -y python3-pip || true

# Add deadsnakes PPA, install Python 3.12, AND create the user
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.12 python3.12-venv python3.12-dev && \
    useradd -m user

# Make python3.12 the default python3 command
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 2 && \
    update-alternatives --set python3 /usr/bin/python3.12

# Use Python 3.12's built-in 'ensurepip' to bootstrap a compatible pip, then upgrade it.
RUN python3 -m ensurepip && \
    python3 -m pip install --upgrade pip

# ---- THIS IS THE FINAL FIX ----
# Upgrade the system-level packages that Supervisor depends on to be Python 3.12 compatible.
# setuptools provides the modern pkg_resources, fixing the 'ImpImporter' error at its source.
# Upgrading supervisor itself ensures it uses modern dependencies.
RUN python3 -m pip install --upgrade setuptools supervisor
# ---- END OF FINAL FIX ----

# --- END: Final Corrected Section ---

ENV COMFYUI_VENV=$VENV_DIR/comfyui
ENV COMFYUI_VENV_PYTHON=$COMFYUI_VENV/bin/python
ENV COMFYUI_VENV_PIP=$COMFYUI_VENV/bin/pip

ENV API_VENV=$VENV_DIR/api
ENV API_VENV_PYTHON=$API_VENV/bin/python
ENV API_VENV_PIP=$API_VENV/bin/pip

ENV IMAGE_SLUG="comfyui"
ENV OPT_SYNC=ComfyUI

# Prepare environment
# Changed to 3.12 to reflect the new version
ARG PYTHON_VERSION="3.12"
ENV PYTHON_VERSION=${PYTHON_VERSION}
ARG PYTORCH_VERSION="2.4.0"
ENV PYTORCH_VERSION="${PYTORCH_VERSION}"
COPY --chown=0:1111 ./COPY_ROOT_0/ /
ARG IMAGE_BASE
RUN set -eo pipefail && /opt/ai-dock/bin/build/layer0/init.sh | tee /var/log/build.log

# This line is just for cache busting, can be left as is
RUN echo "bust cache"

# Install software
ARG COMFYUI_BUILD_REF
ENV COMFYUI_BUILD_REF=${COMFYUI_BUILD_REF}
COPY --chown=0:1111 ./COPY_ROOT_1/ /
RUN set -eo pipefail && /opt/ai-dock/bin/build/layer1/init.sh | tee -a /var/log/build.log

# Copy overrides and models into later layers for fast rebuilds
COPY --chown=0:1111 ./COPY_ROOT_99/ /
RUN set -eo pipefail && /opt/ai-dock/bin/build/layer99/init.sh | tee -a /var/log/build.log
ENV PYTHON_DEFAULT_VENV=comfyui

# Keep init.sh as-is and place additional logic in /opt/ai-dock/bin/preflight.d
CMD ["init.sh"]