#!/bin/bash

docker exec -it `docker ps -q --filter ancestor=ghcr.io/bodaay/huggingchatallinone:latest` bash