#!/usr/bin/env bash

# remove routes
{% for peer in peers %}
ip route del {{ peer.cidr_block }} via {{ vpn_ip }} dev wg0
{% endfor %}

# configure iptables
iptables -P FORWARD ACCEPT
iptables -D FORWARD -i eth0 -o eth0 -j ACCEPT
iptables -D FORWARD -i wg0 -d {{ cidr_block }} -j ACCEPT
iptables -D FORWARD -o wg0 -s {{ cidr_block }} -j ACCEPT

iptables -t nat -D POSTROUTING -o eth0 ! -d {{ cidr_block }} -j MASQUERADE


