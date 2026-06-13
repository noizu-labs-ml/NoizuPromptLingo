INSTALL_DIR ?= $(HOME)/.local/bin
LOCAL_MODEL_LINK := bin/colo-local-model-link

.PHONY: compile test install local-model-link-on local-model-link-off local-model-link-status local-model-link-logs

compile:
	@true

test:
	@true

install:
	@mkdir -p $(INSTALL_DIR)
	@for f in bin/colo-*; do \
		install -m 755 "$$f" "$(INSTALL_DIR)/$$(basename $$f)"; \
		echo "✓ Installed $$(basename $$f)"; \
	done

local-model-link-on:
	@$(LOCAL_MODEL_LINK) on

local-model-link-off:
	@$(LOCAL_MODEL_LINK) off

local-model-link-status:
	@$(LOCAL_MODEL_LINK) status

local-model-link-logs:
	@$(LOCAL_MODEL_LINK) logs
