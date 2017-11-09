#!/bin/bash

function usage() {
	echo "Usage: run.sh <amiId> <instanceNum>"
	exit 1
}

test "x$1" = x && usage
test "x$2" = x && usage

export AMI_NEDGE=$1
export INSTANCE_NUM=$2

source ec2-env.sh

for i in `seq 1 $INSTANCE_NUM`; do
	export EC2_INSTANCE_NAME=${EC2_INSTANCE_PREFIX}$i
	../bin/create-ec2-instance.sh &>/tmp/create-ec2-instance.$$.$i.log &
done
echo "Scheduled $INSTANCE_NUM instance(s) creation tasks... waiting"
wait

NODE_IPS=""
for i in `seq 1 $INSTANCE_NUM`; do
	export EC2_INSTANCE_NAME=${EC2_INSTANCE_PREFIX}$i
	IP=$(../bin/get-IP-nedge.sh)
	NODE_IP=$(ssh -o "StrictHostKeyChecking no" -i $PEM_FILE ubuntu@$IP ip a show ens4|awk '/inet6 fe80/{print $2}'|awk -F/ '{print $1}')
	if test "x$NODE_IPS" = x; then
		NODE_IPS=$NODE_IP
	else
		NODE_IPS="$NODE_IPS $NODE_IP"
	fi
done

CORO_FILE=/tmp/corosync.conf.$$
cp node/corosync.conf $CORO_FILE
echo "nodelist {" >> $CORO_FILE
i=1
for ip in $NODE_IPS; do
	echo "  node {" >> $CORO_FILE
	echo "    ring0_addr: $ip%ens4" >> $CORO_FILE
	echo "    nodeid: $i" >> $CORO_FILE
	echo "  }" >> $CORO_FILE
	let i=i+1
done
echo "}" >> $CORO_FILE
echo "Prepared corosync.conf ..."

i=1
for ip in $NODE_IPS; do
	ssh -i $PEM_FILE -t ubuntu@$IP "sudo docker rm -f bladesim"
	scp -i $PEM_FILE $CORO_FILE ubuntu@$IP:/home/ubuntu/node/corosync.conf
	if test $i = 1; then
		NESETUP_FILE=/tmp/nesetup.json.$$
		cp node/nesetup.json $NESETUP_FILE
		sed 's/aggregator": 0/aggregator": 1/' -i $NESETUP_FILE
		scp -i $PEM_FILE $NESETUP_FILE ubuntu@$IP:/home/ubuntu/node/nesetup.json
	fi
	ssh -i $PEM_FILE -t ubuntu@$IP "sudo /home/ubuntu/node/start.sh"
	let i=i+1
done
echo "Cluster started."

#rm -f /tmp/create-ec2-instance.$$.* $CORO_FILE $NESETUP_FILE
