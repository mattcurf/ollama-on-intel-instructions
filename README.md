# Installation of Ollama natively in Ubuntu 24.04 without docker

The following instructions show how to install Ollama accelerated for Intel GPU on Ubuntu 24.04, without using docker.  It will walk 
through the steps installing the GPU drivers, oneAPI runtime library, and ipex-llm accelerated Ollama library.  It then shows use
of Ollama directly on the command line, and via a simple Python script.

References:
* https://github.com/intel/ipex-llm/blob/main/docs/mddocs/Quickstart/llama_cpp_quickstart.md
* https://github.com/intel/ipex-llm/blob/main/docs/mddocs/Quickstart/install_linux_gpu.md#install-gpu-driver

## Support

This repo is provided as is, and no support is provided or intended.

## Step 1: GPU driver installation

Perform the following steps in a terminal window to install the GPU drivers: 
```
$ wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | sudo gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg && \
  echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu noble unified" | sudo tee /etc/apt/sources.list.d/intel-gpu-noble.list && \
  sudo apt update && \
  sudo apt install -q -y \
    libze-intel-gpu1 \
    libze1 \
    intel-opencl-icd \
    clinfo \
    libze-dev \
    intel-ocloc

$ echo export ZES_ENABLE_SYSMAN=1 >> ~/.bashrc

$ wget -qO - https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | sudo gpg --yes --dearmor --output /usr/share/keyrings/oneapi-archive-keyring.gpg && \ 
  echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list && \
  apt update && \
  apt install --no-install-recommends -q -y \
    intel-oneapi-base-toolkit

$ echo export SYCL_CACHE_PERSISTENT=1 >> ~/.bashrc

$ sudo gpasswd -a ${USER} render
$ newgrp render

$ sudo reboot
```

## Step 2: Python installation

After rebooting the system above, perform the following steps in a terminal window to isntall the Python libraries and Ollama runtime optimized for Intel GPU:
```
$ wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
$ bash Miniforge3-$(uname)-$(uname -m).sh -b
$ source ~/miniforge3/bin/activate 
$ conda create -n ollama-rag python=3.11 -y
$ conda activate ollama-rag
$ pip install --pre --upgrade ipex-llm[cpp] 
$ source /opt/intel/oneapi/setvars.sh
$ mkdir ~/ollama_binaries
$ cd ~/ollama_binaries
$ init-ollama
```

## Step 3: Running Ollama server and client

In one terminal window, run the following to start the Ollama server:
```
$ cd ~/ollama_binaries
$ source /opt/intel/oneapi/setvars.sh
$ source ~/miniforge3/bin/activate 
$ conda activate ollama-rag
$ export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
$ ./ollama serve
```

In a second terminal window, run the following to start a Ollama client connecting to the server in the first terminal window:
```
$ cd ~/ollama_binaries
$ source /opt/intel/oneapi/setvars.sh
$ source ~/miniforge3/bin/activate 
$ conda activate ollama-rag
$ export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
$ ./ollama run llama2:7b
What is the meaning of life?
```

## Step 4: Accessing Ollama via Python app

While leaving the terminal window running with 'ollama serve', perform the following in a new terminal window:
```
$ source ~/miniforge3/bin/activate 
$ conda activate ollama-rag
$ pip install langchain_community
$ python sample.py
```

## Step 5: Enabling RAG with Ollama

While leaving the terminal window running with 'ollama serve', perform the following in a new terminal window to scan and index the short story about 'Snowball' from the docs folder (Snowball is a short story about a bunny created by ChatGPT).  Other .docx documents could also be added to this folder and scanned for a richer set of Q&A from the large language model:

```
$ source ~/miniforge3/bin/activate 
$ conda activate ollama-rag
$ pip install docx2txt langchain_chroma
$ python rag_scan.py
```

Then run the following to invoke Ollama with the additional context of the documents scanned above:
```
$ python rag_query.py
Question: What is the name of Snowball's friend?
Answer: Milo
Question: What type of animal was Milo?
Answer: Milo is a field mouse.
Question: What are some other places Snowball might like to explore?
Answer: Other places Snowball might like to explore include:

1. The forest: With its towering trees and dense underbrush, the forest would provide Snowball with plenty of hiding spots and obstacles to navigate. He could climb trees, chase squirrels, and discover hidden streams.
2. The meadow's edges: Snowball might enjoy exploring the meadow's borders, where the grass meets the trees or the stream runs. This area would offer a mix of familiarity and new sights, sounds, and smells.
3. A nearby hill: Snowball might be intrigued by the prospect of climbing a hill for a panoramic view of the meadow. He could see far and wide, spotting animals and landmarks he's never seen before.
Question: exit
```

# Validation

While this is an example without Docker, an example Dockerfile and makefile are used to validate this content inside a docker container.  Assuming Docker is installed and configured for non-root user access, perform the following to execute the tests:
  
```
$ sudo apt install make
$ make
```
