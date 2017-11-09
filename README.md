# Provision NexentaEdge to Amazon EC2, Azure and GCP

Dependencies

* packer (latest)
* jq

AWS

* prepare ec2-env.sh
* install awscli (latest)
* generate AMI with

``` 
packer build \
	-var 'aws_access_key=YOUR ACCESS KEY' \
	-var 'aws_secret_key=YOUR SECRET KEY' \
	packer.json
```

GCP

* coming soon...

Azure

* coming soon...
