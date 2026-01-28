#!/bin/bash
set -e

workflow_name=${1:-"ci.yml"}
num_workflows=${2:-5}
wait_time=${3:-0}
batch_id=$(date +%s)
ref=${4:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")}

echo "Starting batch ID: $batch_id"
for i in $(seq 1 $num_workflows); do
  echo "Starting workflow run$i"
  gh workflow run "$workflow_name" --ref "$ref"
  if [ "$wait_time" -gt 0 ]; then
    sleep "$wait_time"
  fi
done

sleep 3

gh run list --workflow "$workflow_name" --limit $num_workflows

