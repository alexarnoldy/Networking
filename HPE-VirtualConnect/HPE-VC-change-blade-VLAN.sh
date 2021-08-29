#!/bin/bash

PASSWORD=$(cat ~/.VCPW)
CHASSIS=$1
BLADE=$2
IPADDR=$(./find-current-VC.exp ${CHASSIS} ${PASSWORD} | awk '/NEXTIP/ {print$2}')
echo ${IPADDR}

CURRENT_VLAN=($(./find-blade-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} | grep true))

echo net1=${CURRENT_VLAN[0]}
echo net2=${CURRENT_VLAN[1]}

