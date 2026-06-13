INSTALL_DIR := $(HOME)/.local/bin

.PHONY: compile test install clean

compile:
	@true

test:
	@for f in bin/*; do \
		bash -n "$$f" && echo "✓ $$f" || exit 1; \
	done

install:
	@mkdir -p $(INSTALL_DIR)
	@for f in bin/*; do \
		install -m 755 "$$f" "$(INSTALL_DIR)/$$(basename $$f)"; \
		echo "✓ $$(basename $$f) → $(INSTALL_DIR)/"; \
	done

clean:
	@true
