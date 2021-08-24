#!/usr/bin/env bash

# configure iptables
iptables -P FORWARD DROP
iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT
iptables -A FORWARD -i wg0 -d {{ cidr_block }} -j ACCEPT
iptables -A FORWARD -o wg0 -s {{ cidr_block }} -j ACCEPT

iptables -t nat -A POSTROUTING -o eth0 ! -d {{ cidr_block }} -j MASQUERADE

# setup routes
{% for peer in peers %}
ip route add {{ peer.cidr_block }} via {{ vpn_ip }} dev wg0
{% endfor %}

