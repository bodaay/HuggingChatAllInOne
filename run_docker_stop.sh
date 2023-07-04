#!/bin/bash


docker ps -q --filter ancestor="ghcr.io/bodaay/huggingchatallinone/hugging-chat-full:1.0" | xargs -r docker stop