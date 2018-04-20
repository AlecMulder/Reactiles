#!/bin/bash

for i in $(seq 0 9);do
host="tile$i.local"
ip=$(ping -c 1 -t 1 $host | awk -F'[()]' '/PING/{print $2}')
echo "tile$i:" $ip
done
