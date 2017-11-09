#!/bin/sh
dhclient -6 ens4
ifconfig ens4 mtu 3000 up
timedatectl set-timezone America/Los_Angeles
