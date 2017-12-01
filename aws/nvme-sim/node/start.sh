#!/bin/bash

mount -a
if ! mount | grep nvme0n1; then
	mkfs.ext4 -b 4096 /dev/nvme0n1
	mount /dev/nvme0n1 /mnt
	mkdir -p /mnt/store{1,2,3,4,5,6} &>/dev/null
fi

docker run --name nvme-sim --privileged=true --network host \
	-e HOST_HOSTNAME=$(hostname) \
	-v /home/ec2-user/node/corosync.conf:/opt/nedge/etc/corosync/corosync.conf:ro \
	-v /home/ec2-user/node/nesetup.json:/opt/nedge/etc/ccow/nesetup.json:ro \
	-v /home/ec2-user/node/var:/opt/nedge/var \
	-v /etc/localtime:/etc/localtime:ro \
	-v /mnt:/data -d \
	nexenta/nedge start -j ccowserv -j rest
