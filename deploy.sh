#!/bin/bash

# Install dependencies
apt-get update && apt-get install -y ffmpeg git python3-venv

# Set environment variables
export TMPDIR=/temp_dir
export PYTHONPATH=.
export PREFIX=INFER
export HYDRA_FULL_ERROR=1
export USER=micro

# Create directory
mkdir /temp_dir

# Create Python virtual environment
#python3 -m venv myenv

# Activate the virtual environment
source myenv/bin/activate

# Install Python dependencies
pip install -r requirements.txt

# Create app directory
mkdir app
cd app

# Clone fairseq and install
git clone https://github.com/pytorch/fairseq 
cd fairseq
pip install --editable ./ && pip install tensorboardX

# Download the model
wget -P ./models_new 'https://dl.fbaipublicfiles.com/mms/asr/mms1b_fl102.pt'

# Navigate back to the main directory
cd ..
cd ..
# Run the API
python api.py

# Deactivate the virtual environment
deactivate
