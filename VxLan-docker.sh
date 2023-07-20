#!/bin/bash

if [[ ${UID} -ne 0 ]]
then
	echo -e "Root previlage needed" >&2
	exit 1
fi

echo -e "\n ############ Installing docker ############ \n"
apt update
apt install docker.io

# if [[ "${?}" -ne 0 ]]
# then
#     echo -e "Docker installetion unsuccessful"
# fi


echo -e "\n ############ Installing tcpdump ############ \n"
apt-get install tcpdump




echo -e "\n ############ Creating Subnet for Docker ############ \n"
read -p "Enter the docker Subnet CIDR(Formant Hint: 10.1.1.20/24) ===> " SUBNET_CIDR
echo -e "\n"
read -p "Enter the docker Subnet Name ===> " SUBNET_NAME
echo -e "\n"
SUBNET_ID=$(docker network create --subnet "${SUBNET_CIDR}" "${SUBNET_NAME}")
if [[ "${?}" -ne 0 ]]
then
    echo -e "Docker installetion unsuccessful. Msg: ${SUBNET_ID}"
    exit 1
fi
EFFECTIVE_SUBNET_ID="br-${SUBNET_ID}"
echo -e "Subnet Id ===> ${EFFECTIVE_SUBNET_ID}"
echo -e "\n"



echo -e "\n ############ Creating Docker Container ############ \n"
NETWORK_RANGE=$(sipcalc "${SUBNET_CIDR}" | grep "Network range")
read -p "Enter the docker Container IP Address.${NETWORK_RANGE} ===> " CONTAINER_IP
echo -e "\n"
read -p "Enter the docker Container Name ===> " CONTAINER_NAME
echo -e "\n"
CONTAINER_ID=$(docker run -d --name "${CONTAINER_NAME}" --net "${SUBNET_NAME}" --ip "${CONTAINER_IP}" ubuntu sleep 3000)
if [[ "${?}" -ne 0 ]]
then
    echo -e "Docker container creation unsuccessful. Msg: ${CONTAINER_ID}"
    exit 1
fi
echo -e "Container Id ===> ${CONTAINER_ID} \n"



echo -e "\n ############ Creating VxLan ############ \n"
read -p "Enter the VxLan Name ===> " VXLAN_NAME
echo -e "\n"
read -p "Enter the VxLan ID / VNI ===> " VNI
echo -e "\n"
read -p "Enter the Remote machine/ VTEP IP Address ===> " VTEP_IP
VXLAN_CREATION=$(ip link add "${VXLAN_NAME}" type vxlan id "${VNI}" remote "${VTEP_IP}" dstport 4789 dev enp0s8)
if [[ "${?}" -ne 0 ]]
then
    echo -e "VxLan container creation unsuccessful. Msg: ${VXLAN_CREATION}"
    exit 1
fi



echo -e "\n ############ Set VxLan up ############ \n"
VXLAN_STATUS=$(ip link set ${VXLAN_NAME} up)
if [[ "${?}" -ne 0 ]]
then
    echo -e "VxLan container creation unsuccessful. Msg: ${VXLAN_STATUS}"
    exit 1
fi
echo "Successfully set up the VxLan"


echo -e "\n ############ Add VxLan to the docker bridge ############ \n"
BRIDGE_CONNECTION=$(brctl addif "${EFFECTIVE_SUBNET_ID}" "${VXLAN_NAME}")
if [[ "${?}" -ne 0 ]]
then
    echo -e "Connection to VxLan from Docekr bridge network unsuccessful. Msg: ${BRIDGE_CONNECTION}"
    exit 1
fi
echo "Successfully attached the VxLan to the docekr bridge network"

echo -e "\n ############ Get into Doker Container & Installing network tools ############ \n"





docker exec -it "${CONTAINER_ID}" bash
apt-get update
apt-get install net-tools
apt-get install iputils-ping
apt-get install tcpdump
exit
