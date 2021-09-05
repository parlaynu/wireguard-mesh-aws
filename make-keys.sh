#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  echo "Usage: $(basename $0) [site_name [...]]"
  exit 1
fi

WG=$(which wg)
if [ $? -ne 0 ]; then
  echo "Error: wireguard utility 'wg' not in path; unable to generate keys"
  exit 1
fi

for site in "$@"
do
  prv=$(wg genkey)
  pub=$(echo ${prv} | wg pubkey)
  echo "site: ${site}"
  echo "    vpn_private_key = \"${prv}\""
  echo "    vpn_public_key  = \"${pub}\""
done

