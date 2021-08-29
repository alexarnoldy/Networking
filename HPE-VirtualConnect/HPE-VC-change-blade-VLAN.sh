#!/bin/bash

PASSWORD=Sus3IHVRulz!
CHASSIS=$1
BLADE=$2
IPADDR=$(./find-current-VC.exp ${CHASSIS} ${PASSWORD} | awk '/NEXTIP/ {print$2}')
echo ${IPADDR}

./find-blade-vlan.exp ${IPADDR} ${PASSWORD} ${CHASSIS} ${BLADE} | grep true
