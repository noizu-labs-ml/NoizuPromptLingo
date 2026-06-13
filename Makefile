INSTALL_DIR ?= $(HOME)/.local/bin

.PHONY: compile test install

compile:
	@true

test:
	@true

install:
	@mkdir -p $(INSTALL_DIR)
	@for f in bin/helm-upgrade bin/helm-rollback bin/helm-publish; do \
		install -m 755 "$$f" "$(INSTALL_DIR)/$$(basename $$f)"; \
		echo "✓ Installed $$(basename $$f)"; \
	done
