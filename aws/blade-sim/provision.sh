#!/bin/bash
echo
echo "Provision Edge Cluster to similat Blade use-case"
echo

# Ephemeral device is mounted at /mnt
mkdir -p /mnt/store{1,2,3,4,5,6}

# Prepare docker environment
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-cache policy docker-ce
apt-get install -y docker-ce
docker pull nexenta/nedge

# Setup network and host parameters
echo "net.ipv6.conf.all.force_mld_version = 1" >> /etc/sysctl.conf
echo "net.ipv6.mld_max_msf = 512" >> /etc/sysctl.conf
echo "net.core.optmem_max = 131072" >> /etc/sysctl.conf
echo "net.core.netdev_max_backlog = 300000" >> /etc/sysctl.conf
echo "net.core.rmem_default = 100331648" >> /etc/sysctl.conf
echo "net.core.rmem_max = 100331648" >> /etc/sysctl.conf
echo "net.core.wmem_default = 103554432" >> /etc/sysctl.conf
echo "net.core.wmem_max = 100331648" >> /etc/sysctl.conf
echo "kernel.core_pattern = /opt/nedge/var/cores/core_%e.%p" >> /etc/sysctl.conf
echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf
echo "kernel.sched_min_granularity_ns = 10000000" >> /etc/sysctl.conf
echo "vm.dirty_ratio = 10" >> /etc/sysctl.conf
echo "vm.dirty_background_ratio = 5" >> /etc/sysctl.conf
echo "vm.dirty_expire_centisecs = 600" >> /etc/sysctl.conf
echo "vm.swappiness = 25" >> /etc/sysctl.conf
echo "kernel.sched_migration_cost_ns = 5000000" >> /etc/sysctl.conf
echo "net.core.busy_read = 50" >> /etc/sysctl.conf
echo "net.core.busy_poll = 50" >> /etc/sysctl.conf
echo "net.ipv4.tcp_fastopen = 3" >> /etc/sysctl.conf
echo "net.ipv4.tcp_mtu_probing = 1" >> /etc/sysctl.conf
echo "kernel.numa_balancing = 0" >> /etc/sysctl.conf
echo "vm.min_free_kbytes = 262144" >> /etc/sysctl.conf
echo "net.ipv6.ip6frag_high_thresh = 10000000" >> /etc/sysctl.conf
echo "net.ipv6.ip6frag_low_thresh = 7000000" >> /etc/sysctl.conf
echo "net.ipv6.ip6frag_time = 120" >> /etc/sysctl.conf
sysctl -p
