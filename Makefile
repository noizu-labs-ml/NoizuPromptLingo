INSTALL_DIR := $(HOME)/.local/bin
LAYOUT_DIR  := $(HOME)/.config/zellij/layouts

.PHONY: compile test install

compile:
	@true

test:
	@true

install:
	@mkdir -p $(INSTALL_DIR)
	@for f in bin/*; do \
		src=$$(realpath "$$f"); dst=$$(realpath "$(INSTALL_DIR)/$$(basename $$f)" 2>/dev/null); \
		if [ "$$src" = "$$dst" ]; then \
			echo "$$(basename $$f): same file — skipping"; \
		else \
			install -m 755 "$$f" $(INSTALL_DIR)/; \
		fi; \
	done
	@mkdir -p $(LAYOUT_DIR)
	@for f in layouts/*.kdl; do \
		[ -f "$$f" ] || continue; \
		install -m 644 "$$f" $(LAYOUT_DIR)/; \
		echo "layout: $$(basename $$f) → $(LAYOUT_DIR)/"; \
	done
