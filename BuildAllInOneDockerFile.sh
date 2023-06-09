#!/bin/bash

DockerTagName="khalefa/hugging-chat-full:1.0"

DockerFileToBuild="Dockerfile"
docker build -f $DockerFileToBuild -t $DockerTagName .