#!/bin/bash
SourceFolder="Sources/HuggingChat/BackEnd"
cd $SourceFolder
DockerFileToBuild="Dockerfile"
docker build -f $DockerFileToBuild -t khalefa/hugging-chat-full:1.0 .