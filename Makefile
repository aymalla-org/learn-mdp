.PHONY: help init validate build lint azd-up azd-down azd-deploy azd-provision azd-show clean trigger-test-workflow-batch


# Load environment file if exists
ENV_FILE := .env
ifeq ($(filter $(MAKECMDGOALS),config clean),)
	ifneq ($(strip $(wildcard $(ENV_FILE))),)
		ifneq ($(MAKECMDGOALS),config)
			include $(ENV_FILE)
			export
		endif
	endif
endif

# Load azd environment variables if azd is installed and an environment is configured
ifneq ($(shell command -v azd 2> /dev/null),)
AZD_ENV_JSON := $(shell azd env get-values --output json 2>/dev/null || true)
ifneq ($(strip $(AZD_ENV_JSON)),)
AZD_VALUES := $(shell printf '%s\n' '$(AZD_ENV_JSON)' | jq -r 'to_entries|map("\(.key)=\(.value)")|.[]')
$(foreach kv,$(AZD_VALUES),$(eval export $(kv)))
endif
endif

# Default target
help: ## Show this help message
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

trigger-workflow-batch: ## Trigger MDP test workflows in batch
	@echo "Triggering MDP test workflows in batch..."
	./scripts/run-workflow-batch.sh "mdp-test.yml" 100

cancel-queued-workflows: ## Cancel MDP test workflows in batch
	@echo "Cancelling MDP test workflows in batch..."
	gh run list --limit 1000 --json databaseId,status,name,workflowName \
	  -q '.[] | select(.status=="queued") | .databaseId' \
	  | xargs -r -n1 gh run cancel

init: ## Initialize Azure Developer CLI
	@echo "Initializing Azure Developer CLI..."
	azd init

validate: ## Validate Bicep templates (packages and validates)
	@echo "Validating Bicep templates..."
	@echo "Building and validating Bicep templates using azd..."
	azd package --all

# Build Bicep to ARM JSON (packages templates)
build:
	@echo "Building Bicep templates..."
	@echo "Packaging Bicep templates using azd..."
	azd package --all

lint: ## Lint Bicep templates (packages and lints)
	@echo "Linting Bicep templates..."
	@echo "Packaging and linting Bicep templates using azd..."
	azd package --all

azd-up: ## Deploy infrastructure using Azure Developer CLI
	@echo "Provisioning resources and Deploying Application with Azure Developer CLI..."
	azd up

azd-down: ## Destroy infrastructure using Azure Developer CLI
	@echo "WARNING: This will permanently delete all resources and purge soft-deleted items!"
	@echo "Deleting infrastructure with Azure Developer CLI..."
	azd down --force --purge

azd-deploy: ## Deploy using Azure Developer CLI
	@echo "Deploying with Azure Developer CLI..."
	azd deploy

azd-provision: ## Provision resources using Azure Developer CLI
	@echo "Provisioning resources with Azure Developer CLI..."
	azd provision

azd-show: ## Show deployment outputs
	@echo "Environment values:"
	azd env get-values
	@echo ""
	@echo "Deployment details:"
	azd show

clean: ## Clean generated ARM JSON files
	@echo "Cleaning generated ARM JSON files..."
	@rm -f infra/main.json infra/modules/*.json
	@echo "Clean complete!"
