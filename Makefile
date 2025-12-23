.PHONY: help trigger-mdp-test-workflows 


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

# Load azd environment variables if azd is installed and initialized
ifneq ($(shell command -v azd 2> /dev/null),)
	AZD_VALUES := $(shell azd env get-values --output json | jq -r 'to_entries|map("\(.key)=\(.value)")|.[]')
	$(foreach kv,$(AZD_VALUES),$(eval export $(kv)))
endif

# Default target
help: ## Show this help message
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

trigger-mdp-test-workflows:
	./scripts/mdp-run-workflow-batch.sh "mdp-test.yml" 50