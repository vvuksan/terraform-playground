#!/bin/bash

if [ `grep -c 16.04 /etc/issue` -gt 0 ]; then
	NAT_DEVICE="ens4"
else
	NAT_DEVICE="eth0"
fi


# Redirect stdout ( > ) into a log file.
exec > /tmp/setup-nat-routing.log
exec 2>&1

set -e

echo "NAT: Enabling routing features in the kernel"
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
echo 0 | sudo tee /proc/sys/net/ipv4/conf/$NAT_DEVICE/send_redirects
sudo mkdir -p /etc/sysctl.d/
echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/nat.conf
echo "net.ipv4.conf.$NAT_DEVICE.send_redirects = 0" | sudo tee -a /etc/sysctl.d/nat.conf

echo "NAT: Setting up NAT-MASQUERADE"
sudo iptables -t nat -A POSTROUTING -o $NAT_DEVICE -s 0.0.0.0/0 -j MASQUERADE

# Cloudinit changes the package repositories, which can make fail next steps.
# Let's wait for it to finish.
while pgrep cloud-init > /dev/null; do echo "Waiting for cloudinit to finish..."; sleep 1; done

echo "Save iptables state"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent
