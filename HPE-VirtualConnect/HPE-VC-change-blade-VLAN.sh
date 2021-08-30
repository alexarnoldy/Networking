#!/bin/bash

PASSWORD=$(cat ~/.VCPW)
CHASSIS=$1
BLADE=$2
TARGET_VLAN=$3
IPADDR=$(./find-current-VC.exp ${CHASSIS} ${PASSWORD} | awk '/NEXTIP/ {print$2}')

for EACH in 1 2
do
	CURRENT_VLAN=$(NET=${EACH};./find-blade-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${NET} | grep true | awk '{print$1}')
	NEXT_VLAN=$(NET=${EACH};./find-blade-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${NET} | grep -v Last | grep ${TARGET_VLAN} | awk '{print$1}')
	NET=${EACH};./find-blade-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${NET} > /tmp/blade-vlan${EACH}
echo current vlan is ${CURRENT_VLAN} 
echo next vlan is ${NEXT_VLAN}

	NET=${EACH};./change-blade-net${EACH}-native-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${CURRENT_VLAN} ${NEXT_VLAN}  
	echo current vlan for ${BLADE} is: $(NET=${EACH};./find-blade-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${NET} | grep true)
done
