#!/bin/bash

DockerTagName="ghcr.io/bodaay/huggingchatallinone/hugging-chat-full:latest"

DockerFileToBuild="Dockerfile"
docker build -f $DockerFileToBuild -t $DockerTagName .