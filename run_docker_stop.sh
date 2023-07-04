#!/bin/bash


docker ps -q --filter ancestor="ghcr.io/bodaay/huggingchatallinone/hugging-chat-full:latest" | xargs -r docker stop