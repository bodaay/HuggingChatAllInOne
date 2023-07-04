#!/bin/bash


docker ps -q --filter ancestor="ghcr.io/bodaay/huggingchatallinone:latest" | xargs -r docker stop