
## LLM conversion to wasm format

This Dockerfile creates a Docker image based on Ubuntu 24.04, setting up an environment for building, converting and running wasm models, with a focus on web-based inference using WebAssembly. It installs tools, libraries, and dependencies to support the development and deployment of large language models (LLMs) in a web environment.

### Hardware Requirements
- **CPU**: 4+ cores (8+ recommended for better performance).
- **RAM**: 8 GB minimum (16 GB+ recommended for machine learning tasks).
- **GPU**: CUDA-compatible NVIDIA GPU (optional but recommended for accelerated machine learning).
- **Storage**: 20 GB+ free space (50 GB+ recommended for larger workloads).

### 1. Base Image

**Command**: 
``` dockerfile
FROM ubuntu:24.04
```

The image is built on Ubuntu 24.04, the latest Long-Term Support (LTS) version of Ubuntu at the time of writing.<br><br>



### 2. Essential Tools Installation

**Command**:
``` dockerfile
RUN apt-get update && apt-get install -y software-properties-common curl wget unzip git git-lfs nano
```
    
Updates the package list and installs:
-   software-properties-common: Tools for managing software repositories.
-   curl and wget: Utilities for downloading files from the web.
-   unzip: For extracting ZIP archives.
-   git and git-lfs: Version control system and large file storage extension.
-   nano: A lightweight text editor.<br><br>

### 3. Python Installation

**Command**:
``` dockerfile
RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update && apt-get install -y python3.12 python3-pip
```

Adds the deadsnakes PPA to access newer Python versions, updates the package list, and installs Python 3.12 along with pip (Python package manager).<br><br>

### 4. Machine Learning Python Libraries

-   **Commands**:
```dockerfile
RUN pip3 install --break-system-packages transformers peft bitsandbytes  RUN pip3 install --break-system-packages --pre -U -f https://mlc.ai/wheels mlc-llm-nightly-cu123 mlc-ai-nightly-cu123
```
    
-   Installs transformers, peft, and bitsandbytes—libraries for working with transformer-based machine learning models.
-   Installs nightly builds of mlc-llm-nightly-cu123 and mlc-ai-nightly-cu123 from a custom wheel source (https://mlc.ai/wheels), with CUDA support. The --pre flag allows pre-release versions, and -U upgrades existing packages. The --break-system-packages flag permits overriding system-managed packages.<br><br>

### 5. Emscripten SDK Setup

-   **Commands**:
```dockerfile
RUN mkdir -p ~/tools && cd ~/tools && \ wget https://github.com/emscripten-core/emsdk/archive/refs/heads/main.zip && \ unzip main.zip && cd emsdk-main && \ chmod +x ./emsdk_env.sh 

WORKDIR /root/tools/emsdk-main  

RUN ./emsdk update && \ ./emsdk install 3.1.56 && \ ./emsdk activate 3.1.56
```
    
-   Creates a ~/tools directory, downloads the Emscripten SDK (a toolchain for compiling C/C++ to WebAssembly) from GitHub, and extracts it.
-   Makes the emsdk_env.sh script executable.
-   Sets the working directory to the Emscripten SDK folder.
-   Updates the SDK, installs version 3.1.56, and activates it.<br><br>

### 6. Environment Variables for Emscripten

**Command**:
```dockerfile 
ENV PATH = /root/tools/emsdk-main:/root/tools/emsdk-main/upstream/emscripten:/root/tools/emsdk-main/node/20.18.0_64bit/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ENV EMSDK = /root/tools/emsdk-main 

ENV EMSDK_NODE = /root/tools/emsdk-main/node/20.18.0_64bit/bin/node 

ENV EMSCRIPTEN_ROOT=/root/tools/emsdk/upstream/emscripten
```
    
Sets environment variables to include Emscripten binaries and Node.js (version 20.18.0) in the system PATH, and defines locations for the Emscripten SDK and its components.<br><br>

### 7. TVM Web Runtime Build

**Command**:
```dockerfile
RUN  cd /usr/local/lib/python3.12/dist-packages/tvm/web && make  

ENV TVM_SOURCE_DIR=/usr/local/lib/python3.12/dist-packages/tvm
```

-   Builds the web runtime for TVM (Tensor Virtual Machine), a deep learning compiler framework, by running make in the TVM web directory.
-   Sets the TVM_SOURCE_DIR environment variable to the TVM installation path.<br><br>

### 8. mlc-llm Repository Setup

**Command**:
    

```dockerfile
WORKDIR /root/tools  

RUN git clone https://github.com/mlc-ai/mlc-llm.git ./mlc-llm && \ cd mlc-llm/web && chmod +x ./prep_emcc_deps.sh && ./prep_emcc_deps.sh && make
```
-   Clones the mlc-llm repository (a framework for deploying large language models) into /root/tools/mlc-llm.
-   Changes to the web directory, makes the prep_emcc_deps.sh script executable, runs it to prepare Emscripten dependencies, and builds the web components with make.<br><br>

### 9. TVM Emscripten Configuration Modification

**Command**:
```dockerfile    
RUN sed -i '/all_libs = \[\]/,+5c\ all_libs = []\n if not with_runtime:\n all_libs.append("\/usr\/local\/lib\/python3.12\/dist-packages\/tvm\/web\/dist\/wasm\/wasm_runtime.bc")#[find_lib_path("wasm_runtime.bc")[0]]\n\n all_libs.append("\/usr\/local\/lib\/python3.12\/dist-packages\/tvm\/web\/dist\/wasm\/tvmjs_support.bc")#[find_lib_path("tvmjs_support.bc")[0]]\n all_libs.append("\/usr\/local\/lib\/python3.12\/dist-packages\/tvm\/web\/dist\/wasm\/webgpu_runtime.bc")#[find_lib_path("webgpu_runtime.bc")[0]]' /usr/local/lib/python3.12/dist-packages/tvm/contrib/emcc.py
```
    
Uses sed to modify the emcc.py file in TVM’s contrib directory. It replaces a section of code to directly specify paths to WebAssembly bitcode files (wasm_runtime.bc, tvmjs_support.bc, webgpu_runtime.bc) instead of relying on a dynamic find_lib_path function, ensuring these libraries are correctly linked during compilation.