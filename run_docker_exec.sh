#!/bin/bash

docker exec -it `docker ps -q --filter ancestor=ghcr.io/bodaay/huggingchatallinone/hugging-chat-full:latest` bash