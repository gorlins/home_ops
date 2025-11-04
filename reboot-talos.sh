#!/usr/bin/env bash

CONTROLPLANE=("18" "123" "127")
WORKERS=("112" "118" "119")

read -p "Launch rolling reboot of nodes? <y/N/cp=include control plane> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
  echo "Here we gooooo!"
  NODES=("${WORKERS[@]}")
elif [[ $prompt == "cp" || $prompt == "CP" ]]
then
    echo "Including control plane nodes"
    NODES=("${CONTROLPLANE[@]}" "${WORKERS[@]}")
else
  echo "Exiting"
  exit 0
fi

echo ""

for ip in "${NODES[@]}"; do
  # Commands to be executed for each item
  echo "Rebooting 10.8.8.$ip"
  sleep 5
  talosctl reboot -n 10.8.8.$ip --wait
done
