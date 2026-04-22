#!/bin/bash

set -e

echo "Setting up ProtoMCP..."

if ! command -v git &> /dev/null; then
    echo "Error: git is required but not installed."
    echo "Please install git from https://git-scm.com/downloads"
    exit 1
fi
echo "Cloning ProtoMCP repository..."
git clone https://github.com/SahanUday/ProtoMCP.git
cd ProtoMCP

# Check dependencies
echo "Checking dependencies..."

if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed."
    echo "Please install Python 3 from https://www.python.org/downloads/"
    exit 1
fi

if ! command -v pip &> /dev/null; then
    echo "Error: pip is required but not installed."
    echo "Please ensure pip is installed with Python 3."
    exit 1
fi

if ! command -v bun &> /dev/null; then
    echo "Error: bun is required but not installed."
    echo "Please install bun from https://bun.sh/"
    exit 1
fi

echo "All dependencies found."

# Create virtual environment
echo "Creating Python virtual environment..."
python3 -m venv venv

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install Python dependencies
echo "Installing Python dependencies..."
pip install "jaclang==0.14.0" \
            "jac-client==0.3.12" \
            "jac-mcp==0.1.10" \
            "jasketch-mcp-server==1.0.5" \
            "byllm==0.6.4"

echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. cd ProtoMCP"
echo "2. source venv/bin/activate"
echo "3. jac start main.jac"
echo "4. Open http://localhost:8000"
