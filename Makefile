SHELL := /bin/bash
.DEFAULT_GOAL := help

FE_DIR := frontend
CY_RESULTS := $(FE_DIR)/cypress/results

# ── Dependencies ──────────────────────────────────────────────────────────

.PHONY: install
install: install-py install-fe ## Install all dependencies

.PHONY: install-py
install-py: ## Install Python dependencies
	uv sync

.PHONY: install-fe
install-fe: ## Install frontend dependencies
	cd $(FE_DIR) && npm install

# ── Backend ───────────────────────────────────────────────────────────────

.PHONY: serve
serve: ## Start MCP server
	uv run npl-mcp

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

# ── Frontend ──────────────────────────────────────────────────────────────

.PHONY: fe-dev
fe-dev: ## Start frontend dev server (port 3000)
	cd $(FE_DIR) && npm run dev

.PHONY: fe-build
fe-build: ## Build frontend static export
	cd $(FE_DIR) && npm run build

.PHONY: fe-lint
fe-lint: ## Lint frontend
	cd $(FE_DIR) && npm run lint

# ── Cypress ───────────────────────────────────────────────────────────────

.PHONY: cy-open
cy-open: ## Open Cypress interactive runner
	cd $(FE_DIR) && npx cypress open

.PHONY: cy-run
cy-run: ## Run all Cypress tests headless
	cd $(FE_DIR) && npx cypress run

.PHONY: cy-run-chat
cy-run-chat: ## Run chat feature tests headless
	cd $(FE_DIR) && npx cypress run --spec 'cypress/e2e/features/chat/**/*.feature'

.PHONY: cy-install
cy-install: ## Install Cypress binary (first-time setup)
	cd $(FE_DIR) && npx cypress install

.PHONY: cy-results
cy-results: ## Open Cypress results folder (videos + screenshots)
	@echo "Videos:      $(CY_RESULTS)/videos/"
	@echo "Screenshots: $(CY_RESULTS)/screenshots/"
	@ls -lh $(CY_RESULTS)/videos/*.mp4 2>/dev/null || echo "  (no videos yet)"
	@ls -lh $(CY_RESULTS)/screenshots/**/*.png 2>/dev/null || echo "  (no screenshots yet)"

.PHONY: cy-clean
cy-clean: ## Remove Cypress result artifacts
	rm -rf $(CY_RESULTS)

# ── Compound ──────────────────────────────────────────────────────────────

.PHONY: dev
dev: ## Start backend + frontend dev server (requires two terminals)
	@echo "Run in separate terminals:"
	@echo "  make serve    # backend on :8000"
	@echo "  make fe-dev   # frontend on :3000"

# ── Help ──────────────────────────────────────────────────────────────────

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
