#!/bin/bash

mount -a
if ! mount | grep xvdb; then
	mkfs.ext4 -b 4096 /dev/xvdb
	mount -a
	mkdir -p /mnt/store{1,2,3,4,5,6} &>/dev/null
fi

docker run --name fleet --privileged=true --network host \
	-e HOST_HOSTNAME=$(hostname) \
	-v /home/ubuntu/node/corosync.conf:/opt/nedge/etc/corosync/corosync.conf:ro \
	-v /home/ubuntu/node/nesetup.json:/opt/nedge/etc/ccow/nesetup.json:ro \
	-v /home/ubuntu/node/var:/opt/nedge/var \
	-v /etc/localtime:/etc/localtime:ro \
	-v /mnt:/data -d \
	nexenta/nedge start -j ccowserv -j ccowgws3
