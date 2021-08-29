#!/bin/bash

PASSWORD=$(cat ~/.VCPW)
CHASSIS=$1
BLADE=$2
TARGET_VLAN=$3
IPADDR=$(./find-current-VC.exp ${CHASSIS} ${PASSWORD} | awk '/NEXTIP/ {print$2}')

#./find-blade-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} | grep true
#CURRENT_VLAN_NET1=($(NET=1;./find-blade-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${NET} | egrep "${TARGET_VLAN} | true"))
#CURRENT_VLAN_NET2=($(NET=2;./find-blade-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${NET} | grep true))

for EACH in 1 2
do
	CURRENT_VLAN=($(NET=${EACH};./find-blade-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${NET} | grep true))
	NEXT_VLAN=($(NET=${EACH};./find-blade-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${NET} | grep ${TARGET_VLAN}))
	NET=${EACH};./find-blade-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${NET} > /tmp/blade-vlan${EACH}
echo current vlan is ${CURRENT_VLAN[0]} 
echo next vlan is ${NEXT_VLAN[0]}

### Run change-blade-native-vlan.exp against the first value in CURRENT_VLAN and NEXT_VLAN
done

exit


#echo net1=${CURRENT_VLAN_NET1[0]}
#echo net2=${CURRENT_VLAN_NET2[0]}
#NET=1;./change-blade-native-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${NET} ${CURRENT_VLAN_NET1} ${TARGET_VLAN}
#NET=2;./change-blade-native-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${NET} ${CURRENT_VLAN_NET2} ${TARGET_VLAN}

#NET=1;./find-blade-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${NET} | grep true
#NET=2;./find-blade-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} ${NET} | grep true
