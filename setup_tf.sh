#!/bin/bash

# Update and upgrade packages
sudo apt-get update
sudo apt-get upgrade -y

# Check if Miniconda is already installed
if [ ! -d "$HOME/miniconda" ]; then
    # Install Miniconda
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
    bash miniconda.sh -b -p $HOME/miniconda
else
    echo "Miniconda already installed. Use the -u option to update if necessary."
fi
export PATH="$HOME/miniconda/bin:$PATH"
conda init
source ~/.bashrc

# Create and activate a new conda environment with Python 3.9
mkdir -p project
cd project
conda create --name myenv python=3.9 -y
source activate myenv

# Install required libraries
# Skipping picamera installation for non-Raspberry Pi systems
if grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null; then
    python -m pip install "picamera[array]"
else
    echo "Skipping picamera installation: Not a Raspberry Pi"
fi

# Install TensorFlow Lite runtime
pip install tflite-runtime

# Verify the installation
python -c "import tflite_runtime; print(tflite_runtime.__version__)"

# Install example code
if [ -d "examples" ]; then
    echo "examples directory already exists. Skipping clone."
else
    git clone https://github.com/tensorflow/examples --depth 1
fi
cd examples

# Check if setup.sh exists and run it if available
if [ -f setup.sh ]; then
    sh setup.sh
else
    echo "setup.sh not found, skipping this step."
fi

# Install additional dependencies
sudo apt-get install -y libatlas-base-dev
