# OPM (Offline Python Mentor)

OPM is a serverless implementation of Online Python Tutor Lite (OPTLite) designed for offline use and enhanced educational environments. This project builds upon the [optlite](https://github.com/dive4dec/optlite) concept while making it more accessible and secure for educational settings.

## Features

- **Serverless Operation**: Runs entirely in the browser using [Pyodide](https://pyodide.org)
- **Offline Capability**: Can be used without internet connection
- **Enhanced Security**: No server-side code execution, reducing security risks
- **Educational Focus**: Perfect for classroom settings and online exams
- **Safe Exam Browser Compatible**: Works with [Safe Exam Browser](https://safeexambrowser.org/)
- **Interactive Visualization**: Visual representation of Python program execution
- **Live Editing Mode**: Real-time code editing and visualization

## Installation
1. Ensure you have Docker installed on your system
2. Run the setup script:
   ```bash
   ./setup_opm.sh
   ```
3. The script will:
   - Build the Docker image
   - Configure the JupyterLite environment

## Project Structure

```
OPM_Mentor
├── optlite-components/                 # Core visualization components
├── opm-0.0.1-py2.py3-none-any.whl      # Python package wheel
├── optmwidgets-0.1.5-py2.py3-none-any.whl      # Python package wheel of optmwidgets
├── pack_optlite.sh                     # Script for packaging the application
└── setup_opm.sh                        # Setup script for OPM environment
```

## Usage
Run the container with:
```bash
docker run -p 8888:8000 opt-mentor --name opt-mentor
```
Access at http://localhost:8888

## Development
The project consists of several key components:
- **OPT Lite**: The core visualization engine
- **JupyterLite Integration**: For notebook-based interactions
- **Pyodide Runtime**: For in-browser Python execution
- **[optmwidgets](https://github.com/chiwangso2/optmwidgets)**: A widget built on top of [divewidgets](https://github.com/dive4dec/divewidgets) that provide programming ai assistant using webllm and langchain.

## Requirements
- Docker

## Acknowledgments

- Based on [optlite](https://github.com/dive4dec/optlite)
- Uses [Pyodide](https://pyodide.org) for in-browser Python execution
- Integrates with [JupyterLite](https://jupyterlite.readthedocs.io/) for notebook functionality 