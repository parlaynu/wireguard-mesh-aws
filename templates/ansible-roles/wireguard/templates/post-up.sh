#!/usr/bin/env bash

iptables -P FORWARD DROP
iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT
iptables -A FORWARD -i wg0 -o eth0 -d {{ cidr_block }} -j ACCEPT
iptables -A FORWARD -o wg0 -i eth0 -s {{ cidr_block }} -j ACCEPT

iptables -t nat -A POSTROUTING -o eth0 ! -d {{ cidr_block }} -j MASQUERADE

