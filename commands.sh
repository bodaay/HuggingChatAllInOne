#!/bin/bash

mkdir -p /data/db /data/mongo-log/

touch /data/mongo-log/mongod.log

mongod --bind_ip_all --fork --logpath /data/mongo-log/mongod.log

#Run out python dynamin env generator
python3 /app/dynamic_env_generator.py
# --node-args="-r dotenv/config"
#pm2 start /app/build/index.js --no-daemon # I need it as daemon

# npm install -g vite



text-generation-launcher --port 1129