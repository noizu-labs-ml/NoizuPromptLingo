.PHONY: compile test install uninstall dev

PROJ_DIR := $(shell cd "$(dir $(abspath $(lastword $(MAKEFILE_LIST))))" && pwd)
PREFIX   ?= $(HOME)/.local

compile:
	@true

test:
	@true

install: ## Install deps + symlink claude-assist to ~/.local/bin
	@if [ -d "$(PROJ_DIR)/node_modules" ]; then \
		echo "==> pnpm dependencies already present; skipping refresh."; \
	elif ! command -v curl >/dev/null 2>&1 || ! curl -fsS --max-time 3 https://registry.npmjs.org >/dev/null 2>&1; then \
		echo "==> Fatal: registry.npmjs.org not reachable and node_modules is missing."; \
		exit 1; \
	else \
		echo "==> Installing pnpm dependencies..."; \
		cd "$(PROJ_DIR)" && CI=true pnpm install --prefer-offline; \
	fi
	@echo "==> Symlinking claude-assist → $(PREFIX)/bin/claude-assist"
	@mkdir -p "$(PREFIX)/bin"
	@ln -sf "$(PROJ_DIR)/bin/claude-assist" "$(PREFIX)/bin/claude-assist"
	@echo "Done. Run 'claude-assist' from anywhere."

uninstall: ## Remove the symlink
	rm -f "$(PREFIX)/bin/claude-assist"

dev: ## Launch (same as running claude-assist)
	"$(PROJ_DIR)/bin/claude-assist"
