#!/usr/bin/env bash

echo '*** Launching Jupyter Notebook server.'
echo '*** Once the server is running, access it at "http://localhost:8888".'
echo '*** You may use "Control-C" to terminate the server.'

jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --NotebookApp.notebook_dir=/home/docker-user/
