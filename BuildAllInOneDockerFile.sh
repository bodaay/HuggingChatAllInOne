#!/bin/bash

DockerFileToBuild="Dockerfile"
docker build -f $DockerFileToBuild -t khalefa/hugging-chat-full:1.0 .