#!/bin/bash
set -e

workflow_name=${1:-"ci.yml"}
num_workflows=${2:-5}
wait_time=${3:-0}
batch_id=$(date +%s)
ref=${4:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")}
gh_timeout_seconds=${GH_CMD_TIMEOUT_SECONDS:-30}
gh_repo=${GH_REPO:-""}

infer_github_repo() {
  local remote_url
  remote_url=$(git remote get-url origin 2>/dev/null || true)

  if [ -z "$remote_url" ]; then
    remote_url=$(git remote get-url upstream 2>/dev/null || true)
  fi

  if [ -z "$remote_url" ]; then
    remote_url=$(git remote -v 2>/dev/null | awk '/\(fetch\)$/ {print $2; exit}')
  fi

  if [ -z "$remote_url" ]; then
    return 1
  fi

  # Supports HTTPS and SSH GitHub remotes.
  remote_url=${remote_url#https://github.com/}
  remote_url=${remote_url#git@github.com:}
  remote_url=${remote_url#ssh://git@github.com/}
  remote_url=${remote_url%.git}

  case "$remote_url" in
    */*)
    echo "$remote_url"
    return 0
    ;;
  esac

  return 1
}

run_with_timeout() {
  if command -v timeout >/dev/null 2>&1; then
    timeout "$gh_timeout_seconds" "$@"
  else
    "$@"
  fi
}

if ! run_with_timeout gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login"
  exit 1
fi

if [ -z "$gh_repo" ]; then
  gh_repo=$(infer_github_repo || true)
fi

if [ -z "$gh_repo" ]; then
  echo "Unable to determine GitHub repository. Set GH_REPO=owner/repo or run: gh repo set-default"
  exit 1
fi

echo "Starting batch ID: $batch_id"
for i in $(seq 1 $num_workflows); do
  echo "Starting workflow run$i"
  if ! run_with_timeout gh workflow run "$workflow_name" --ref "$ref" --repo "$gh_repo"; then
    echo "Failed or timed out while starting workflow run$i (timeout=${gh_timeout_seconds}s)."
    exit 1
  fi
  if [ "$wait_time" -gt 0 ]; then
    sleep "$wait_time"
  fi
done

sleep 3

if ! run_with_timeout gh run list --workflow "$workflow_name" --limit "$num_workflows" --repo "$gh_repo"; then
  echo "Failed or timed out while listing runs (timeout=${gh_timeout_seconds}s)."
  exit 1
fi
