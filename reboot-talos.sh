#!/usr/bin/env bash

CONTROLPLANE=("18" "123" "127")
WORKERS=("112" "118" "119")

read -p "Launch rolling reboot of nodes? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
  echo "Here we gooooo!"
else
  echo "Exiting"
  exit 0
fi

echo ""

read -p "Include control plane? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
  NODES=("${CONTROLPLANE[@]}" "${WORKERS[@]}")
else
  NODES=("${WORKERS[@]}")
fi

for ip in "${NODES[@]}"; do
  # Commands to be executed for each item
  echo "Rebooting 10.8.8.$ip"
  talosctl reboot -n 10.8.8.$ip --wait
done
