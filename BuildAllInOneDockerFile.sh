#!/bin/bash

DockerTagName="ghcr.io/bodaay/huggingchatallinone:latest"

DockerFileToBuild="Dockerfile"
docker build -f $DockerFileToBuild -t $DockerTagName .