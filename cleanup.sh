#!/bin/bash

## Remove docekr container
docker rm --force 8939

## remove docker bridge
docker netowrk rm "${NETWORK_NAME}"

## Remove vxlan
ip link delete vxlan-demo


# check any vxlan
ip a | grep vxlan

# Check docker birdge network
docker network ls