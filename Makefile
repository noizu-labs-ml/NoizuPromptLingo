.PHONY: build run app open clean test help

APP_NAME := therobotpaints
BUILD_DIR := build

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

build: ## Build the Swift package (debug)
	swift build

run: build ## Build and run raw executable
	swift run $(APP_NAME)

app: ## Build and package as macOS .app bundle
	bash build-app.sh

open: app ## Build .app and open it
	open $(BUILD_DIR)/$(APP_NAME).app

clean: ## Remove build artifacts
	rm -rf $(BUILD_DIR)
	swift package clean

test: ## Run Swift tests
	swift test

xcode: ## Open project in Xcode
	xed .
