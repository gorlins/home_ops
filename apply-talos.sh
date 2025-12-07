#!/usr/bin/env bash

source ./talos_ips.sh

task talos:generate-config

for ip in "${NODES[@]}"; do
  # Commands to be executed for each item
#  echo "Applying $ip"
  task talos:apply-node IP=10.8.8.$ip
done
