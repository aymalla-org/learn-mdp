#!/bin/bash
set -e

# Set DevOpsInfrastructure service principal ID
principal_id=$(az ad sp list --display-name 'DevOpsInfrastructure' --query '[0].id' -o tsv)
azd env set DEVOPSINFRASTRUCTURE_PRINCIPLE_ID "$principal_id"