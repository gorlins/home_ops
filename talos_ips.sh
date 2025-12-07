#!/usr/bin/env bash

CONTROLPLANE=("120" "123" "127")
WORKERS=("112" "118" "119")
NODES=("${CONTROLPLANE[@]}" "${WORKERS[@]}")
