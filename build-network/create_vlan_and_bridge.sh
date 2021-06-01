#!/bin/bash -x

## Demo script to create a new VLAN and bridge on a remote host, then deploy a Vyos router to it.
## This is a very manual process that relies on the Vyos router being configured for DHCP on the outside
## interface, eth1 for 10.0.0.1 on the inside, plus lots of configs documented in vyos.adoc in my GH

## Usage: ./create_vlan_and_bridge.sh <user>@<remote host> <VLAN #>
## I.e. ./create_vlan_and_bridge.sh admin@infra2 242

RHOST=$1
VLAN=$2

echo ${RHOST}
echo ${VLAN}

mkdir -p ./${VLAN}

## Copy the files in the template and Ansible/vyos directories into the newly created VLAN directory
## Ansible portion is disabled until I can preen through the old Anisble stuff 
#cp -rp ~/Ansible/build-network/template/* ./${VLAN}
#cp -rp ~/Ansible/vyos/ ./${VLAN}
cp -rp ./template/* ./${VLAN}/

## Change the files from their template names to their VLAN specific names 
mv ./${VLAN}/ifcfg-vlanXYZ ./${VLAN}/ifcfg-vlan${VLAN}
mv ./${VLAN}/ifcfg-brXYZ ./${VLAN}/ifcfg-br${VLAN}
mv ./${VLAN}/vyos-router-template ./${VLAN}/vyos-router-${VLAN}
mv ./${VLAN}/vyos-router-template.qcow2 ./${VLAN}/vyos-router-${VLAN}.qcow2

## Update the configs with the new VLAN
sed -i "s/XYZ/${VLAN}/" ./${VLAN}/ifcfg-br${VLAN}
sed -i "s/XYZ/${VLAN}/" ./${VLAN}/ifcfg-vlan${VLAN}
## Update the VM XML config file
# Update the bridge number and MAC addresses to match the VLAN
sed -i "y/XYZ/${VLAN}/" ./${VLAN}/vyos-router-${VLAN}
# Update the name of the router VM and VM images
sed -i "s/vyos-router-template/vyos-router-${VLAN}/" ./${VLAN}/vyos-router-${VLAN}
## Update the Ansible config files
## Disabled until Ansible gets worked out
#sed -i "s/XYZ/${VLAN}/" ./${VLAN}/vyos/group_vars/common.yml
#sed -i "s/vyos-router-template/vyos-router-${VLAN}/" ./${VLAN}/vyos/group_vars/common.yml

## Create the VLAN and bridge on each host in the ./infrastructure directory
for INFRA_HOST in $(ls -1 ./infrastructure)
do 
	scp  ./${VLAN}/ifcfg* ${INFRA_HOST}:/tmp
	ssh ${INFRA_HOST} sudo cp -p /tmp/ifcfg-*${VLAN} /etc/sysconfig/network/
	ssh ${INFRA_HOST} sudo systemctl restart network
done

## Copy the router to the host specified on the command line
scp  ./${VLAN}/vyos-router-${VLAN}* ${RHOST}:/tmp
## NTS: Need to have a larger FS mounted at the same point on each infra host to copy the qcow's into
ssh ${RHOST} sudo cp /tmp/vyos-router-${VLAN}.qcow2 /var/lib/libvirt/images/
ssh ${RHOST} sudo virsh define /tmp/vyos-router-${VLAN}
ssh ${RHOST} sudo virsh start vyos-router-${VLAN}

## Update the public key on the new router
## Disabled until name resolution is fixed
#until nc -zv vyos-router-template.rancher.local 22; do sleep 5; done
#./login.expect vyos@vyos-router-template.rancher.local



echo "Update the Ansible playbook in the ${VLAN} directory as needed, then run: ansible-playbook -i ~/Ansible/build-network/${VLAN}/vyos/production ~/Ansible/build-network/${VLAN}/vyos/site.yml"
