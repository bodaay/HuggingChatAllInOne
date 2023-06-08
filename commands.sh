#!/bin/bash

mkdir -p /data/db /data/mongo-log/

touch /data/mongo-log/mongod.log

mongod --fork --logpath /data/mongo-log/mongod.log

text-generation-launcher --port 8080