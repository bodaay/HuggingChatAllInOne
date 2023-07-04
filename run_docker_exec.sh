#!/bin/bash

docker exec -it `docker ps -q --filter ancestor=ghcr.io/bodaay/huggingchatallinone/hugging-chat-full:1.0` bash