## Starting NexentaEdge as a "Blade/SSD" simulated cluster

Details:

* Instance type r3.2xlarge
* 1 ephemeral SSD 160GB mounted at /mnt
* 10G ixgbe VF, placement group, MTU 3000
* NexentaEdge docker container pre-pulled

Quick Start instructions:

* generate AMI with

``` 
packer build \
	-var 'aws_access_key=YOUR ACCESS KEY' \
	-var 'aws_secret_key=YOUR SECRET KEY' \
	packer.json
```

this command will return AMI ID.


* start 20 node cluster

```
./run.sh AMI_ID 20
```

* login to first node using pem file and initialize cluster as usual
