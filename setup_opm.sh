#!/bin/bash

set -e

echo "Setting up opt-mentor..."

mkdir -p opt-mentor
cd opt-mentor

cp ../opm-0.0.1-py2.py3-none-any.whl .
cp ../optmwidgets-0.1.5-py2.py3-none-any.whl .

# Dockerfile
cat > Dockerfile << 'EOF'
FROM continuumio/miniconda3:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create conda environment
RUN conda create -n opm-env python=3.12 -y && \
    conda run -n opm-env conda install -c conda-forge -y \
    nodejs \
    jupyterlite-core \
    jupyterlab_server \
    jupyterlite-pyodide-kernel \
    ipywidgets>=7.0.0 \
    ipython>=7.0.0

# Add conda environment to PATH
ENV PATH /opt/conda/envs/opm-env/bin:$PATH

# Activate conda environment
SHELL ["conda", "run", "-n", "opm-env", "/bin/bash", "-c"]

WORKDIR /opt/jupyterlite

COPY content/ ./content/

# Install OPM package first
COPY opm-0.0.1-py2.py3-none-any.whl .
RUN pip install opm-0.0.1-py2.py3-none-any.whl
COPY optmwidgets-0.1.5-py2.py3-none-any.whl .
RUN pip install optmwidgets-0.1.5-py2.py3-none-any.whl

# Then build JupyterLite
RUN jupyter lite init && \
    jupyter lite build --contents content/notebooks

EXPOSE 8000

CMD ["conda", "run", "-n", "opm-env", "jupyter", "lite", "serve", "--port", "8000", "--ip", "0.0.0.0"]
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
   "outputs": [],
   "source": [
    "# First make sure IPython is available\n",
    "import IPython\n",
    "print(f'IPython version: {IPython.__version__}')\n",
    "\n",
    "# Then load the magic command\n",
    "%load_ext divewidgets"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Use the magic command with options\n",
    "%%opm -w 1100 -h 700\n",
    "print('Hello from OPT_Mentor!')"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Example with run option\n",
    "%%opm -r\n",
    "x = 10\n",
    "y = 20\n",
    "print(f'Sum is: {x + y}')"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Current Python File Path\n",
    "import sys\n",
    "print(sys.executable)"
   ]
  },
   {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# divewidgets extension file path\n",
    "import sys\n",
    "!{sys.executable} -m pip show divewidgets"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3 (ipykernel)",
   "language": "python",
   "name": "python3"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

echo "Building Docker image..."
docker build -t opt-mentor . --no-cache

echo "Setup complete! You can now run the container with:"
echo "docker run -p 8888:8000 --name opt-mentor opt-mentor" 