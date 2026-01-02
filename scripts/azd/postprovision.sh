#!/bin/bash
set -e

gh variable set MDP_POOL_NAME --body "$MDP_POOL_NAME" --repo "$GITHUB_ORG_URL/$GITHUB_REPOSITORY_NAME"