#!/bin/bash

source /opt/intel/oneapi/setvars.sh
export LD_LIBRARY_PATH=/ollama_binaries:$LD_LIBRARY_PATH

/ollama_binaries/ollama serve &
sleep 2s
/ollama_binaries/ollama pull tinyllama:1.1b-chat-v1-q8_0

python /project/sample.py
python /project/rag_scan.py
python /project/rag_query.py
