SDKS := elixir php python rust typescript

.PHONY: test build publish public clean help $(SDKS)

help:
	@echo "SDK orchestrator — fans out to: $(SDKS)"
	@echo ""
	@echo "Targets:"
	@echo "  test       Run tests for all SDKs"
	@echo "  build      Build all SDKs"
	@echo "  publish    Publish all SDKs to their registries"
	@echo "  public     Alias for publish"
	@echo "  clean      Clean all SDK build artifacts"
	@echo ""
	@echo "Per-SDK:  make test-<sdk>  build-<sdk>  publish-<sdk>  clean-<sdk>"
	@echo "  e.g.    make test-typescript   make build-rust"

test:
	@for sdk in $(SDKS); do \
		echo ""; \
		echo "========== test: $$sdk =========="; \
		$(MAKE) -C $$sdk test || exit 1; \
	done

build:
	@for sdk in $(SDKS); do \
		echo ""; \
		echo "========== build: $$sdk =========="; \
		$(MAKE) -C $$sdk build || exit 1; \
	done

publish: build
	@for sdk in $(SDKS); do \
		echo ""; \
		echo "========== publish: $$sdk =========="; \
		$(MAKE) -C $$sdk publish || exit 1; \
	done

public: publish

clean:
	@for sdk in $(SDKS); do \
		echo ""; \
		echo "========== clean: $$sdk =========="; \
		$(MAKE) -C $$sdk clean; \
	done

# Per-SDK convenience targets: test-<sdk>, build-<sdk>, publish-<sdk>, clean-<sdk>
$(foreach sdk,$(SDKS),$(eval test-$(sdk): ; $$(MAKE) -C $(sdk) test))
$(foreach sdk,$(SDKS),$(eval build-$(sdk): ; $$(MAKE) -C $(sdk) build))
$(foreach sdk,$(SDKS),$(eval publish-$(sdk): ; $$(MAKE) -C $(sdk) publish))
$(foreach sdk,$(SDKS),$(eval clean-$(sdk): ; $$(MAKE) -C $(sdk) clean))
