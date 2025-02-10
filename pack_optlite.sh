#!/bin/bash

# Make script exit on error
set -e

# if OPTLite not exists, clone it
if [ ! -d "optlite-components" ]; then
    git clone https://github.com/dive4dec/optlite.git
fi

cd optlite-components

# Create magic command implementation
cat > optlite/magic.py << EOL
from IPython.core.magic import (Magics, magics_class, line_magic,
                              cell_magic)
from IPython.core.magic_arguments import (argument, magic_arguments,
                                        parse_argstring)
from .visualizer import visualize

@magics_class
class MentorMagics(Magics):
    """IPython magics to create interactive OPT visualizations.
    """
    @magic_arguments()
    @argument(
        '-w', '--width', type=int, default=1100,
        help="The width of the output frame (default: 1100)."
    )
    @argument(
        '-h', '--height', type=int, default=700,
        help="The height of the output frame (default: 700)."
    )
    @argument(
        '-r', '--run', action='store_true',
        help="Run cell in IPython."
    )
    @cell_magic
    def mentor(self, line, cell):
        """Magic command for OPM visualization.
        Usage: %%mentor [options] code
        """
        opts = parse_argstring(self.mentor, line)
        if opts.run:
            result = self.shell.run_cell(cell)
        return visualize(cell, width=opts.width, height=opts.height)

def load_ipython_extension(ipython):
    """Load the extension in IPython."""
    ipython.register_magics(MentorMagics)
EOL

# Create visualizer module
cat > optlite/visualizer.py << EOL
def visualize(code, width=1100, height=700):
    """Visualize Python code execution."""
    # Implementation of visualization logic
    return f"Visualizing code with width={width}, height={height}:\n{code}"
EOL

# Create __init__.py
cat > optlite/__init__.py << EOL
"""Mentor - Offline Python Mentor"""

from .magic import load_ipython_extension

__version__ = '0.0.1'
EOL

# Create setup.py
cat > setup.py << EOL
from setuptools import setup, find_packages

setup(
    name="mentor",
    version="0.0.1",
    description="Offline Python Mentor",
    packages=find_packages(),
    install_requires=[
        "ipywidgets>=7.0.0",
        "IPython>=7.0.0",
        "jupyterlite-core",
        "jupyterlab_server",
        "jupyterlite-pyodide-kernel",
        "optmwidgets"
    ],
    include_package_data=True,
    python_requires=">=3.7",
)
EOL

# Create MANIFEST.in
cat > MANIFEST.in << EOL
include optlite/*.py
EOL

# Build the wheel file
pip install build
python -m build --wheel

echo "Wheel file created in dist/ directory"
echo "To install: pip install dist/mentor-0.0.1-py3-none-any.whl"
echo "To use in Jupyter:"
echo "  %load_ext optm"
echo "  %%optm"
echo "  your_code_here" 