## Starting NexentaEdge as a Fleet of small footprint servers (up to 384)

Details:

* Instance type r3.large
* 1 ephemeral SSD 32GB mounted at /mnt
* 25G ENA or 10G ixgbe VF, placement group, MTU 9000
* NexentaEdge docker container pre-pulled

Quick Start instructions:

* generate 10G (ixgbe VF) or 25G (ENA) AMI with packer-10G.json or packer-25G.json

``` 
packer build \
	-var 'aws_access_key=YOUR ACCESS KEY' \
	-var 'aws_secret_key=YOUR SECRET KEY' \
	packer-10G.json
```

this command will return AMI ID.


* start 128 node cluster

```
./run.sh AMI_ID 128
```

* login to first node using pem file and initialize cluster as usual
