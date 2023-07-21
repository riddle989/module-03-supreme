#!/bin/bash

############################ Host-1 ############################
sudo apt update
sudo apt install docker.io
apt-get install tcpdump

docker network create --subnet 10.1.0.4/24 vxlan-net
docker network ls
ip a

docker run -d --net vxlan-net --ip 10.1.0.30 ubuntu sleep 3000
docker ps
docker inspect fa | grep IPAddress
ping 172.10.0.10 -c 2

## Enter into the container "fafb" and configure the container
docker exec -it fafb bash
apt-get update
apt-get install net-tools
apt-get install iputils-ping
apt-get install tcpdump

ip link add vxlan-demo type vxlan id 100 remote 10.0.1.20 dstport 4789 dev enp0s8
ip a | grep vxlan
ip link set vxlan-demo up

brctl addif br-9516 vxlan-demo
route -n
############################ Host-1 ############################

############################ Host-2 ############################
sudo apt update
sudo apt install docker.io
apt-get install tcpdump

docker network create --subnet 10.1.0.5/24 vxlan-net
docker network ls
ip a

docker run -d --net vxlan-net --ip 10.1.0.40 ubuntu sleep 3000
docker ps
docker inspect fa | grep IPAddress
ping 172.10.0.10 -c 2

## Enter into the container "fafb" and configure the container
docker exec -it fafb bash
apt-get update
apt-get install net-tools
apt-get install iputils-ping
apt-get install tcpdump

ip link add vxlan-demo type vxlan id 100 remote 10.0.1.10 dstport 4789 dev enp0s8
ip a | grep vxlan
ip link set vxlan-demo up

brctl addif br-9516 vxlan-demo
route -n
############################ Host-2 ############################
