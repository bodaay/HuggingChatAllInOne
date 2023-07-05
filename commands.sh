#!/bin/bash



mkdir -p /data/db /data/mongo-log/

touch /data/mongo-log/mongod.log

mongod --bind_ip_all --fork --logpath /data/mongo-log/mongod.log

#Run our python dynamin env generator
python3 /app/dynamic_env_generator.py

# rebuild the app after updating .env file
cd /app/ && npm run build
export PORT=8080
pm2 start /app/build/index.js #--no-daemon # I need it as daemon


text-generation-launcher --port 1129