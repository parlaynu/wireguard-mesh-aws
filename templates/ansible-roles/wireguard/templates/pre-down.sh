#!/usr/bin/env bash

iptables -P FORWARD ACCEPT
iptables -D FORWARD -i eth0 -o eth0 -j ACCEPT
iptables -D FORWARD -i wg0 -o eth0 -d {{ cidr_block }} -j ACCEPT
iptables -D FORWARD -i eth0 -o wg0 -s {{ cidr_block }} -j ACCEPT

iptables -t nat -D POSTROUTING -o eth0 ! -d {{ cidr_block }} -j MASQUERADE


