#!/bin/bash
set -e

red='\033[0;31m'
green='\033[0;32m'
no_color='\033[0m'
container_name=appsumo-next-next-1
is_running=$(docker ps --filter "name=$container_name" --filter "status=running" --quiet)

if [ -z ${is_running} ]; then
  echo -e "\n${red}Error: Container: ${container_name} is not running"
  exit 0
fi

if [ ! -f runme.sh ]; then
  echo -e "\n${red}Error: runme.sh file does not exist."
  exit 0
fi

volume_id=$(docker inspect $container_name  | jq -r '.[0].Mounts[] | select(.Type == "volume") | .Name')

echo -e "\n${green}Removing container: ${container_name}${no_color}"
docker container stop $container_name
docker container rm $container_name

echo -e "\n${green}Removing next volume: ${volume_id}${no_color}"
docker volume rm $volume_id

echo -e "\n${green}Removing images (docker system prune -a)${no_color}"
docker system prune -a

echo -e "\n${green}Building and running using runme!${no_color}"
./runme.sh -l && ./runme.sh -b && ./runme.sh -r
