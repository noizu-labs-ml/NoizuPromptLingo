INSTALL_DIR ?= $(HOME)/.local/bin
LIB_INSTALL_DIR ?= $(HOME)/.local/lib/media-tools

.PHONY: compile build test install clean install-legacy

compile: build

build:
	@cargo build --release
	@echo "✓ Built target/release/generate-media-prompt"

test:
	@cargo build
	@cargo run -- --dry-run test/
	@echo "✓ Dry-run test passed"

install: build
	@mkdir -p $(INSTALL_DIR)
	@install -m 755 target/release/generate-media-prompt $(INSTALL_DIR)/generate-media-prompt
	@echo "✓ Installed generate-media-prompt (Rust)"

install-legacy:
	@mkdir -p $(INSTALL_DIR) $(LIB_INSTALL_DIR)
	@install -m 755 bin/generate-media-prompt $(INSTALL_DIR)/generate-media-prompt
	@install -m 644 lib/media-prompt-engine.py $(LIB_INSTALL_DIR)/media-prompt-engine.py
	@echo "✓ Installed generate-media-prompt (Python/bash)"

clean:
	@rm -f $(INSTALL_DIR)/generate-media-prompt
	@rm -rf $(LIB_INSTALL_DIR)
	@cargo clean 2>/dev/null || true
