#!/bin/bash

docker ps -aq |xargs -l -i docker rm -f {}
docker network prune -f
docker volume ls -q |xargs -l docker volume rm || true
docker-compose down -t0

docker-compose up --build

