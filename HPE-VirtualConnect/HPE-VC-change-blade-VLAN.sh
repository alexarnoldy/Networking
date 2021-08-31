#!/bin/bash

## Script to set the Virtual Connect native VLAN for a blade in a C7000 chassis.
##
## Usage: HPE-VC-change-blade-VLAN.sh <Chassis number, i.e. 3>  <Blade number, i.e. 09> <New VLAN, i.e. 249>
##
## alex.arnoldy@suse.com 08/30/2021

PASSWORD=$(cat ~/.VCPW)
CHASSIS=$1
BLADE=$2
TARGET_VLAN=$3
IPADDR=$(./find-current-VC.exp ${CHASSIS} ${PASSWORD} | awk '/NEXTIP/ {print$2}')

## Test for the correct number of arguments provided with the command
[ -z "$3" ] && echo "Usage: HPE-VC-change-blade-VLAN.sh  <Chassis number, i.e. 3>  <Blade number, i.e. 09> <New VLAN, i.e. 249>" && exit

for EACH in 1 2
do
	CURRENT_VLAN=$(NET=${EACH};./find-blade-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${NET} | grep true | awk '{print$1}')
	NEXT_VLAN=$(NET=${EACH};./find-blade-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${NET} | grep -v Last | grep ${TARGET_VLAN} | awk '{print$1}')
	## Set CURRENT_VLAN to NEXT_VLAN, if no current native VLAN is found
[ -z "${CURRENT_VLAN}" ] && CURRENT_VLAN=${NEXT_VLAN}
	NET=${EACH};./find-blade-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${NET} > /tmp/blade-vlan${EACH}
#echo bash sending current vlan ${CURRENT_VLAN} 
#echo bash sending next vlan ${NEXT_VLAN}

	NET=${EACH};./change-blade-native-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${NET} ${CURRENT_VLAN} ${NEXT_VLAN}  
	echo current vlan for ${BLADE} is: $(NET=${EACH};./find-blade-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${NET} | grep true)
done
