#!/bin/bash

if ! test -e ./ec2-env.sh; then
	echo "./ec2-env.sh not found"
	exit 1
fi
if test "x$1" = x; then
	echo "Usage: create-ec2-instance.sh <instanceName>"
	exit 1
fi
source ./ec2-env.sh
EC2_INSTANCE_NAME=$1

if ! aws ec2 describe-placement-groups|jq --raw-output .PlacementGroups[].GroupName | grep $EC2_PLACEMENT_GROUP >/dev/null; then
	aws ec2 create-placement-group --group-name $EC2_PLACEMENT_GROUP --strategy cluster &>/dev/null
fi

instance_id=$(aws ec2 run-instances --image-id "$AMI_NEDGE" \
     --instance-type "$EC2_INSTANCE_TYPE" --placement '{"GroupName":"'$EC2_PLACEMENT_GROUP'"}' \
     --network-interfaces '[{"DeviceIndex":0,"Groups":["'$VPC_SECURITY_GROUP'"],"SubnetId":"'$SUBNET_CLUSTER'","DeleteOnTermination":true,"AssociatePublicIpAddress":true}]' \
     --key-name "$KEY_NAME_NEDGE" | jq --raw-output .Instances[].InstanceId)
test ! $? = 0 && exit $?

echo "${instance_id} is being created"

eni_id=$(aws ec2 create-network-interface --subnet-id $SUBNET_REPLICAST --description "replicast" --groups $REP_SECURITY_GROUP --ipv6-address-count 1 | jq --raw-output .NetworkInterface.NetworkInterfaceId)
echo "${eni_id} is being created"

aws ec2 wait instance-exists --instance-ids "$instance_id"

aws ec2 create-tags --resources "${instance_id}" --tags Key=Name,Value="${EC2_INSTANCE_NAME}"

aws ec2 wait instance-running --instance-ids "$instance_id"

aws ec2 attach-network-interface --device-index 1 --instance-id $instance_id --network-interface-id $eni_id
echo "${instance_id} attached replicast interface"

echo "${instance_id} was tagged waiting to login"

aws ec2 wait instance-status-ok --instance-ids "$instance_id"

echo "Ready to login"
