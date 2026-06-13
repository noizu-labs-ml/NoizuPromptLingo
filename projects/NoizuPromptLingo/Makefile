SHELL := /bin/bash
.DEFAULT_GOAL := help

FE_DIR := frontend
CY_RESULTS := $(FE_DIR)/cypress/results
APP_URL := http://127.0.0.1:8765

# -- Dependencies ---------------------------------------------------------

.PHONY: install
install: install-py install-fe ## Install all dependencies

.PHONY: install-py
install-py: ## Install Python dependencies
	uv sync

.PHONY: install-fe
install-fe: ## Install frontend dependencies
	cd $(FE_DIR) && npm install

# -- Backend --------------------------------------------------------------

.PHONY: serve
serve: ## Start MCP server
	uv run npl-mcp

.PHONY: serve-dev
serve-dev: ## Start MCP server with frontend auto-rebuild on changes
	uv run npl-mcp --watch-frontend

.PHONY: test
test: ## Run Python tests
	uv run -m pytest

.PHONY: test-x
test-x: ## Run Python tests, stop on first failure
	uv run -m pytest -x

.PHONY: lint
lint: ## Lint Python source
	uvx ruff check src

.PHONY: fmt
fmt: ## Format Python source
	uvx ruff format src

.PHONY: docs-regen
docs-regen: ## Regenerate npl-full.md from conventions
	uv run npl-docs-regen

# -- Frontend -------------------------------------------------------------

.PHONY: fe-dev
fe-dev: ## Start frontend dev server (port 3000)
	cd $(FE_DIR) && npm run dev

.PHONY: fe-build
fe-build: ## Build frontend static export
	cd $(FE_DIR) && npm run build

.PHONY: fe-lint
fe-lint: ## Lint frontend
	cd $(FE_DIR) && npm run lint

# -- Cypress ---------------------------------------------------------------

.PHONY: cy-open
cy-open: _check-app ## Open Cypress interactive runner
	cd $(FE_DIR) && npx cypress open

.PHONY: cy-run
cy-run: _check-app ## Run all Cypress tests headless
	cd $(FE_DIR) && npx cypress run

.PHONY: cy-run-chat
cy-run-chat: _check-app ## Run chat feature tests headless
	cd $(FE_DIR) && npx cypress run --spec 'cypress/e2e/features/chat/**/*.feature'

.PHONY: cy-smoke
cy-smoke: _check-app ## Run @smoke-tagged scenarios only
	cd $(FE_DIR) && npx cypress run --env tags=@smoke

.PHONY: cy-tier1
cy-tier1: _check-app ## Run Tier 1 CRUD tests
	cd $(FE_DIR) && npx cypress run --env tags=@tier1

.PHONY: cy-regression
cy-regression: _check-app ## Run full regression (excludes @wip)
	cd $(FE_DIR) && npx cypress run --env tags='not @wip'

.PHONY: cy-install
cy-install: ## Install Cypress binary (first-time setup)
	cd $(FE_DIR) && npx cypress install

.PHONY: cy-results
cy-results: ## List Cypress result artifacts (videos + screenshots)
	@echo "Videos:      $(CY_RESULTS)/videos/"
	@echo "Screenshots: $(CY_RESULTS)/screenshots/"
	@ls -lh $(CY_RESULTS)/videos/*.mp4 2>/dev/null || echo "  (no videos yet)"
	@ls -lh $(CY_RESULTS)/screenshots/**/*.png 2>/dev/null || echo "  (no screenshots yet)"

.PHONY: cy-clean
cy-clean: ## Remove Cypress result artifacts
	rm -rf $(CY_RESULTS)

# -- Smoke Test ------------------------------------------------------------

.PHONY: smoke-test
smoke-test: ## Smoke test chat features (starts server if needed)
	@if curl -sf $(APP_URL)/api/health >/dev/null 2>&1; then \
		echo "Server already running at $(APP_URL)"; \
		cd $(FE_DIR) && npx cypress run --spec 'cypress/e2e/features/chat/**/*.feature'; \
	else \
		echo "Starting server..."; \
		cd $(FE_DIR) && npx start-server-and-test 'cd .. && uv run npl-mcp' $(APP_URL)/api/health \
			"npx cypress run --spec 'cypress/e2e/features/chat/**/*.feature'"; \
	fi

# -- Health Checks ---------------------------------------------------------

.PHONY: _check-app
_check-app:
	@curl -sf $(APP_URL)/api/health >/dev/null 2>&1 || { \
		echo ""; \
		echo "  WARNING: Server not running at $(APP_URL)"; \
		echo "  Start it with:  uv run npl-mcp"; \
		echo ""; \
		exit 1; \
	}

# -- Help ------------------------------------------------------------------

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
