#!/bin/bash

docker exec -it `docker ps -q --filter ancestor=khalefa/hugging-chat-full:1.0` bash