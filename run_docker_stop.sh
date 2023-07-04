#!/bin/bash


docker ps -q --filter ancestor="khalefa/hugging-chat-full:1.0" | xargs -r docker stop