#!/bin/bash

DockerTagName="ghcr.io/bodaay/huggingchatallinone/hugging-chat-full:1.0"

DockerFileToBuild="Dockerfile"
docker build -f $DockerFileToBuild -t $DockerTagName .