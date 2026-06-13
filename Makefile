.PHONY: build run app install clean test lint format open help spec-update spec-constants

APP_NAME := KopiGajj
SRC_DIR  := src
BUILD_DIR := build

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

build: ## Build the Swift package (debug)
	cd $(SRC_DIR) && swift build

run: build ## Build and run the executable
	cd $(SRC_DIR) && swift run $(APP_NAME)

app: ## Build and package as macOS .app bundle
	bash build-app.sh

install: app ## Build .app and copy to /Applications
	cp -r $(BUILD_DIR)/$(APP_NAME).app /Applications/
	@echo "Installed to /Applications/$(APP_NAME).app"

clean: ## Remove build artifacts
	rm -rf $(BUILD_DIR)
	cd $(SRC_DIR) && swift package clean

test: ## Run Swift tests
	cd $(SRC_DIR) && swift test

lint: ## Lint Swift source files
	cd $(SRC_DIR) && swiftlint lint

format: ## Format Swift source files
	cd $(SRC_DIR) && swiftformat .

open: app ## Build .app and open it
	open $(BUILD_DIR)/$(APP_NAME).app

xcode: ## Open project in Xcode
	cd $(SRC_DIR) && xed .

spec-update: ## Update a spec constant: make spec-update KEY=chord_prefix NEW="⌘⇧X"
	python3 .tmp/spec-constants.py $(KEY) $(NEW)

spec-constants: ## List all spec constants and current values
	python3 .tmp/spec-constants.py --list
