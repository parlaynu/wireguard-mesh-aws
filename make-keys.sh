#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  echo "Usage: $(basename $0) num_sites"
  exit 1
fi

WG=$(which wg)
if [ $? -ne 0 ]; then
  echo "Error: wireguard utility 'wg' not in path; unable to generate keys"
  exit 1
fi

for ((i=0; i<$1; i++))
do
  prv=$(wg genkey)
  pub=$(echo ${prv} | wg pubkey)
  echo "site: ${i}"
  echo "    vpn_private_key = \"${prv}\""
  echo "    vpn_public_key  = \"${pub}\""
done

