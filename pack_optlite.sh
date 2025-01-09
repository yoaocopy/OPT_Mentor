#!/bin/bash

# Make script exit on error
set -e

# if OPTLite not exists, clone it
if [ ! -d "optlite" ]; then
    git clone https://github.com/dive4dec/optlite.git
fi

cd optlite

# Create magic command implementation
cat > optlite/magic.py << EOL
from IPython.core.magic import Magics, magics_class, line_cell_magic
from .visualizer import visualize

@magics_class
class MentorMagic(Magics):
    @line_cell_magic
    def mentor(self, line, cell=None):
        """Magic command for OPTLite visualization.
        Usage: %%mentor [options] code
        """
        code = cell if cell is not None else line
        return visualize(code)

def load_ipython_extension(ipython):
    """Load the extension in IPython."""
    ipython.register_magics(MentorMagic)
EOL

# Update __init__.py to include magic command
cat >> optlite/__init__.py << EOL

# Add magic command support
from .magic import load_ipython_extension
EOL

# Update setup.py to include magic command
cat > setup.py << EOL
from setuptools import setup, find_packages

setup(
    name="opm",
    version="0.0.1",
    packages=find_packages(),
    install_requires=[
        "ipywidgets>=7.0.0",
        "IPython>=7.0.0",
    ],
    include_package_data=True,
)
EOL

# Build the wheel file
pip install build
python -m build --wheel

echo "Wheel file created in dist/ directory"
echo "To install: pip install dist/optlite-0.1.0-py3-none-any.whl"
echo "To use in Jupyter:"
echo "  %load_ext optlite"
echo "  %%mentor"
echo "  your_code_here" 