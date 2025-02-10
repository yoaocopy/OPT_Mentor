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
