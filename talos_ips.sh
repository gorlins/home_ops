#!/usr/bin/env bash

CONFIG=talos/talconfig.yaml

mapfile -t CONTROLPLANE <<< `yq '(.nodes[] | select(.controlPlane)).ipAddress' $CONFIG`
mapfile -t WORKERS <<< `yq '(.nodes[] | select(.controlPlane|not)).ipAddress' $CONFIG`
NODES=("${CONTROLPLANE[@]}" "${WORKERS[@]}")

