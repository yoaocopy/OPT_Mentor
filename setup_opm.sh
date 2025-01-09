#!/bin/bash

set -e

echo "Setting up opt-mentor..."

mkdir -p opt-mentor
cd opt-mentor

cp ../opm-0.0.1-py2.py3-none-any.whl .

# Dockerfile
cat > Dockerfile << 'EOF'
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && \
    apt-get install -y \
    software-properties-common \
    curl \
    tzdata \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get update \
    && apt-get install -y \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    nodejs \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --upgrade pip wheel setuptools && \
    pip install jupyterlite-core jupyterlab_server && \
    pip install jupyterlite-pyodide-kernel  # Add Pyodide kernel support

WORKDIR /opt/jupyterlite

COPY content/ ./content/

RUN jupyter lite init && \
    jupyter lite build --contents content/notebooks

COPY opm-0.0.1-py2.py3-none-any.whl .
RUN pip install opm-0.0.1-py2.py3-none-any.whl

EXPOSE 8000

CMD ["jupyter", "lite", "serve"]
EOF

# config
mkdir -p content
cat > jupyter-lite.json << 'EOF'
{
    "jupyter-lite-schema-version": 0,
    "jupyter-config-data": {
        "appName": "OPT_Mentor JupyterLite",
        "collaborative": true,
        "faviconUrl": "",
        "disabledExtensions": [],
        "settingsOverrides": {
            "@jupyterlab/translation-extension:plugin": {
                "locale": "en"
            }
        }
    }
}
EOF

# demo notebook
mkdir -p content/notebooks
cat > content/notebooks/opt_mentor_demo.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# OPT_Mentor Demo\n",
    "This is a demo of OPT_Mentor running in JupyterLite"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "# Load the magic command\n",
    "%load_ext opm\n",
    "\n",
    "# Use the magic command\n",
    "%%mentor\n",
    "print('Hello from opt-mentor!')"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3 (ipykernel)",
   "language": "python",
   "name": "python3"
  }
 }
}
EOF

echo "Building Docker image..."
docker build -t opt-mentor . --no-cache

echo "Setup complete! You can now run the container with:"
echo "docker run -p 8888:8000 opt-mentor --name opt-mentor" 