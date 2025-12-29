#!/bin/bash
set -e

ref=${3:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")}

batch_id=$(date +%s)

echo "Starting batch ID: $batch_id"
for i in $(seq 1 $num_workflows); do
  echo "Starting workflow run$i"
  gh workflow run "$workflow_name" --ref "$ref"
done

sleep 3

gh run list --workflow "$workflow_name" --limit $num_workflows

