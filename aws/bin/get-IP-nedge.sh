#!/bin/bash
set -e

if ! test -e ./ec2-env.sh; then
	echo "./ec2-env.sh not found"
	exit 1
fi
source ./ec2-env.sh

aws ec2 describe-instances --filters  "Name=tag:Name,Values=${EC2_INSTANCE_NAME}" \
	| jq --raw-output .Reservations[].Instances[].PublicIpAddress | grep -v null
