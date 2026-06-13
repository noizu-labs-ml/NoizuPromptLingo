INSTALL_DIR ?= $(HOME)/.local/bin

.PHONY: compile build test install install-rust clean

compile: build

build:
	@if ! command -v cargo >/dev/null 2>&1; then \
		echo "secret-bucket: cargo not found; skipping Rust build"; \
		exit 1; \
	fi
	@cargo build --release
	@echo "Built target/release/secret-bucket"

test:
	@if ! command -v cargo >/dev/null 2>&1; then \
		echo "secret-bucket: cargo not found; Rust tests skipped"; \
		exit 1; \
	fi
	@cargo test

install:
	@if ! command -v cargo >/dev/null 2>&1; then \
		echo "secret-bucket: cargo not found; skipping install"; \
	else \
		$(MAKE) build; \
		mkdir -p $(INSTALL_DIR); \
		install -m 755 target/release/secret-bucket $(INSTALL_DIR)/secret-bucket; \
		echo "Installed secret-bucket"; \
	fi

install-rust: build
	@mkdir -p $(INSTALL_DIR)
	@install -m 755 target/release/secret-bucket $(INSTALL_DIR)/secret-bucket
	@echo "Installed secret-bucket"

clean:
	@cargo clean
