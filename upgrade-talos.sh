#!/usr/bin/env bash

source ./talos_ips.sh

task talos:generate-config

for ip in "${CONTROLPLANE[@]}"; do
  echo "Upgrading control plane $ip"
  task talos:upgrade-node IP=$ip
  talosctl health -n $ip --wait-timeout 5m  # Ensure control plane is fully healthy
done

for ip in "${WORKERS[@]}"; do
  echo "Upgrading worker $ip"
  task talos:upgrade-node IP=$ip
done
