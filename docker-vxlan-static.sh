#!/bin/bash


### Both fox vm1 and vm2 ###
sudo apt update
sudo apt install docker.io
apt-get install tcpdump
### Both fox vm1 and vm2 ###

### Create docker network and container ###
# For VM-1 #
docker network create --subnet 10.1.1.20/24 vxlan-net
-> 39135d3292468fd9c1ed5f64db96e5e33ced9f76da996ba5a28a8a33c3e45618
docker network ls
ip a

docker run -d --net vxlan-net --ip 10.1.1.30 ubuntu sleep 3000
-> 7e7d88a2f67ae27dedd996fdc60757b37dd2633595f9432e7a5b87ecfeda5159
docker ps
docker inspect fa | grep IPAddress
ping 172.10.0.10 -c 2
# For VM-1 #

# For VM-2 #
docker network create --subnet 10.1.1.22/24 vxlan-net
-> ad42af96b1c84948ddf0d03dc717999154a05752f364fef29ef2393ea70eca08
docker network ls
ip a

docker run -d --net vxlan-net --ip 10.1.1.40 ubuntu sleep 3000
-> 082d296a47b049e33f89fcb41f28dedb69206f1da57129c7343b9a1e3e05b84e
docker ps
docker inspect fa | grep IPAddress
ping 172.10.0.10 -c 2
# For VM-2 #
### Create docker network and container ###

### Ping from one container to another ###
# From container in VM-1 #
ping 10.1.1.40  ## not reachable
# From container in VM-1 #

# From container in VM-2 #
ping 10.1.1.30  ## not reachable
# From container in VM-2 #
### Ping from one container to another ###

### Create Vxlan and set up ###
# VM-1 #
ip link add vxlan-demo type vxlan id 100 remote 10.0.1.20 dstport 4789 dev enp0s8
ip a | grep vxlan
ip link set vxlan-demo up

brctl addif br-9516 vxlan-demo
route -n
# VM-1 #

# VM-2 #
ip link add vxlan-demo type vxlan id 100 remote 10.0.1.10 dstport 4789 dev enp0s8
ip a | grep vxlan
ip link set vxlan-demo up

brctl addif br-9516 vxlan-demo
route -
# VM-2 #
### Create Vxlan and set up ###


### Enter into the container and configure the container ###
# VM-1 #
docker exec -it 7e7d88a2f67ae27dedd996fdc60757b37dd2633595f9432e7a5b87ecfeda5159 bash
apt-get update
apt-get install net-tools
apt-get install iputils-ping
apt-get install tcpdump
# VM-1 #
# VM-2 #
docker exec -it 082d296a47b049e33f89fcb41f28dedb69206f1da57129c7343b9a1e3e05b84e bash
apt-get update
apt-get install net-tools
apt-get install iputils-ping
apt-get install tcpdump
# VM-2 #
### Enter into the container and configure the container ###


### Ping from one container to another ###
# From container in VM-1 #
ping 10.1.1.40  ## reachable
# From container in VM-1 #

# From container in VM-2 #
ping 10.1.1.30  ## reachable
# From container in VM-2 #
### Ping from one container to another ###
