.DEFAULT_GOAL := help

ELIXIR_MCPS := doc-pointers elixir-google-mcp dropbox-mcp

.PHONY: help deps

help:
	@echo "NPL llm plugin"
	@echo "  make deps   mix deps.get in $(ELIXIR_MCPS)"
	@echo "  make help   this text"

deps:
	@for dir in $(ELIXIR_MCPS); do \
	  echo "==> mix deps.get ($$dir)"; \
	  (cd "$$dir" && mix deps.get); \
	done
