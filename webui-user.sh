#!/bin/bash
#########################################################
# Uncomment and change the variables below to your need:#
#########################################################

# Install directory without trailing slash
#install_dir="/home/$(whoami)"

# Name of the subdirectory
#clone_dir="stable-diffusion-webui"

# Commandline arguments for webui.py, for example: export COMMANDLINE_ARGS="--medvram --opt-split-attention"
# Add --no-download-sd-model to skip the default ~4GB v1-5 download (place your own .ckpt/.safetensors in models/Stable-diffusion/)
export COMMANDLINE_ARGS="--listen --port 2222"

# python3 executable
#python_cmd="python3"

# git executable
#export GIT="git"

# python3 venv without trailing slash (defaults to ${install_dir}/${clone_dir}/venv)
#venv_dir="venv"

# script to launch to start the app
#export LAUNCH_SCRIPT="launch.py"

# RTX 50-series (sm_120): use CUDA 12.8 PyTorch wheels instead of default cu121 / torch 2.1.2
export TORCH_COMMAND="pip install torch torchvision --index-url https://download.pytorch.org/whl/cu128"

# Default clone URL is camenduru/stablediffusion (same tree & commit cf1d67 as old Stability-AI repo).
# Override if you mirror elsewhere: export STABLE_DIFFUSION_REPO="https://..."

# Requirements file to use for stable-diffusion-webui
#export REQS_FILE="requirements_versions.txt"

# Fixed git repos
#export K_DIFFUSION_PACKAGE=""
#export GFPGAN_PACKAGE=""

# Fixed git commits
#export STABLE_DIFFUSION_COMMIT_HASH=""
#export CODEFORMER_COMMIT_HASH=""
#export BLIP_COMMIT_HASH=""

# Uncomment to enable accelerated launch
#export ACCELERATE="True"

# Uncomment to disable TCMalloc
#export NO_TCMALLOC="True"

###########################################
