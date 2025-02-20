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
$ mkdir -p /tmp/gpu && \
 cd /tmp/gpu && \
 wget https://github.com/oneapi-src/level-zero/releases/download/v1.19.2/level-zero_1.19.2+u24.04_amd64.deb && \ 
 wget https://github.com/intel/intel-graphics-compiler/releases/download/v2.5.6/intel-igc-core-2_2.5.6+18417_amd64.deb && \
 wget https://github.com/intel/intel-graphics-compiler/releases/download/v2.5.6/intel-igc-opencl-2_2.5.6+18417_amd64.deb && \
 wget https://github.com/intel/compute-runtime/releases/download/24.52.32224.5/intel-level-zero-gpu_1.6.32224.5_amd64.deb && \
 wget https://github.com/intel/compute-runtime/releases/download/24.52.32224.5/intel-opencl-icd_24.52.32224.5_amd64.deb && \
 wget https://github.com/intel/compute-runtime/releases/download/24.52.32224.5/libigdgmm12_22.5.5_amd64.deb && \
 sudo dpkg -i *.deb && \
 rm *.deb

$ echo export ZES_ENABLE_SYSMAN=1 >> ~/.bashrc

$ wget -qO - https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | \
  sudo gpg --dearmor --output /usr/share/keyrings/oneapi-archive-keyring.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | \
  sudo tee /etc/apt/sources.list.d/oneAPI.list && \
  sudo apt update && \
  sudo apt install --no-install-recommends -q -y \
    intel-oneapi-common-vars=2024.0.0-49406 \
    intel-oneapi-common-oneapi-vars=2024.0.0-49406 \
    intel-oneapi-compiler-dpcpp-cpp=2024.0.2-49895 \
    intel-oneapi-dpcpp-ct=2024.0.0-49381 \
    intel-oneapi-mkl=2024.0.0-49656 \
    intel-oneapi-mpi=2021.11.0-49493 \
    intel-oneapi-dal=2024.0.1-25 \
    intel-oneapi-ippcp=2021.9.1-5 \
    intel-oneapi-ipp=2021.10.1-13 \
    intel-oneapi-tlt=2024.0.0-352 \
    intel-oneapi-ccl=2021.11.2-5 \
    intel-oneapi-dnnl=2024.0.0-49521 \
    intel-oneapi-tcm-1.0=1.0.0-435

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
