#!/bin/bash

mkdir -p /data/db /data/mongo-log/

touch /data/mongo-log/mongod.log

mongod --bind_ip_all --fork --logpath /data/mongo-log/mongod.log

pm2 start /app/build/index.js  # --no-daemon # I need it as daemon

text-generation-launcher --port 1129