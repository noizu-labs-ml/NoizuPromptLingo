# Native macOS host for llm-toolkit.
# Starts or attaches to the Hono process on :3100 (which also serves the console).

.PHONY: build test run app icon clean

SWIFT ?= swift
CONFIG ?= debug
APP_NAME := LLM Toolkit
BUILD_DIR := .build
APP_DIR := $(BUILD_DIR)/$(APP_NAME).app

build: ## Compile the Swift package
	$(SWIFT) build -c $(CONFIG)

test: ## Route + locator + launch-plan tests
	$(SWIFT) test

run: ## Launch (attaches to :3100 / starts pnpm dev:api)
	$(SWIFT) run LLMToolkit

app: ## Assemble a double-clickable .app under .build/
	$(SWIFT) build -c release
	@bin="$$($(SWIFT) build -c release --show-bin-path)/LLMToolkit"; \
	rm -rf "$(APP_DIR)"; \
	mkdir -p "$(APP_DIR)/Contents/MacOS" "$(APP_DIR)/Contents/Resources"; \
	cp "$$bin" "$(APP_DIR)/Contents/MacOS/LLMToolkit"; \
	cp Info.plist "$(APP_DIR)/Contents/Info.plist"; \
	if [ -f Resources/LLMToolkit.icns ]; then \
		cp Resources/LLMToolkit.icns "$(APP_DIR)/Contents/Resources/LLMToolkit.icns"; \
	fi; \
	for png in Sources/LLMToolkit/Resources/*.png; do \
		[ -f "$$png" ] && cp "$$png" "$(APP_DIR)/Contents/Resources/"; \
	done; \
	echo "✓ $(APP_DIR)"

icon: ## Rebuild dock icon from Assets/LLMToolkitIcon-1024.png
	bash scripts/generate-app-icon.sh

clean:
	$(SWIFT) package clean
	rm -rf "$(APP_DIR)"
