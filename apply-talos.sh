#!/usr/bin/env bash

CONTROLPLANE=("18" "123" "127")
WORKERS=("112" "118" "119")
NODES=("${CONTROLPLANE[@]}" "${WORKERS[@]}")

task talos:generate-config

for ip in "${NODES[@]}"; do
  # Commands to be executed for each item
#  echo "Applying $ip"
  task talos:apply-node IP=10.8.8.$ip
done
