#!/usr/bin/env bash

CONTROLPLANE=("120" "123" "127")
WORKERS=("70" "112" "118" "119")
mapfile -t NODES <<< `talosctl get nodename | tail -n +2 | cut -d' ' -f1`
