#!/usr/bin/env bash

source ./talos_ips.sh

read -p "Launch rolling reboot of nodes? <y/N/cp=include control plane> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
  echo "Here we gooooo!"
elif [[ $prompt == "cp" || $prompt == "CP" ]]
then
    echo "Including control plane nodes"
    for ip in "${CONTROLPLANE[@]}"; do
      echo "Rebooting control plane $ip"
      talosctl reboot -n $ip --wait
      talosctl health -n $ip --wait-timeout 5m  # Ensure control plane is fully healthy
    done
done

else
  echo "Exiting"
  exit 0
fi

echo ""

for ip in "${WORKERS[@]}"; do
  echo "Rebooting worker $ip"
  talosctl reboot -n $ip --wait
done
