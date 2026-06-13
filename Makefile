INSTALL_DIR := $(HOME)/.local/bin

.PHONY: compile test install

compile:
	@true

test:
	@true

install:
	@mkdir -p $(INSTALL_DIR)
	@src=$$(realpath bin/make-repo); dst=$$(realpath $(INSTALL_DIR)/make-repo 2>/dev/null); \
	if [ "$$src" = "$$dst" ]; then \
		echo "make-repo: already installed (same file) — skipping"; \
	else \
		install -m 755 bin/make-repo $(INSTALL_DIR)/make-repo; \
	fi
	@src=$$(realpath bin/fork-repo); dst=$$(realpath $(INSTALL_DIR)/fork-repo 2>/dev/null); \
	if [ "$$src" = "$$dst" ]; then \
		echo "fork-repo: already installed (same file) — skipping"; \
	else \
		install -m 755 bin/fork-repo $(INSTALL_DIR)/fork-repo; \
	fi
