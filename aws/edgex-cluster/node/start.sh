#!/bin/sh

docker run --name s3data --privileged=true --network host \
	-e HOST_HOSTNAME=$(hostname) \
	-v /home/ubuntu/node/corosync.conf:/opt/nedge/etc/corosync/corosync.conf:ro \
	-v /home/ubuntu/node/nesetup.json:/opt/nedge/etc/ccow/nesetup.json:ro \
	-v /home/ubuntu/node/var:/opt/nedge/var \
	-v /etc/localtime:/etc/localtime:ro \
	-v /data:/data -d \
	nexenta/nedge start -j ccowserv -j ccowgws3
