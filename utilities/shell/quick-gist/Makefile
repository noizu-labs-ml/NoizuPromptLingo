INSTALL_DIR := $(HOME)/.local/bin

.PHONY: compile test install

compile:
	@true

test:
	@true

install:
	@mkdir -p $(INSTALL_DIR)
	@src=$$(realpath quick-gist); dst=$$(realpath $(INSTALL_DIR)/quick-gist 2>/dev/null); \
	if [ "$$src" = "$$dst" ]; then \
		echo "quick-gist: already installed (same file) — skipping"; \
	else \
		install -m 755 quick-gist $(INSTALL_DIR)/quick-gist; \
	fi
