.PHONY: help compile test test-cov coverage coverage-html coverage-xml clean install install-completions install-go-litellm dev refresh setup-litellm

UV_TOOL_PYTHON ?= $(shell cat .python-version)

help:
	@echo "Available targets:"
	@echo "  test          Run tests"
	@echo "  test-cov      Run tests with coverage report"
	@echo "  coverage      Run tests and show coverage summary"
	@echo "  coverage-html Generate HTML coverage report"
	@echo "  coverage-xml  Generate XML coverage report (for CI)"
	@echo "  clean         Remove build artifacts and coverage files"
	@echo "  install       Install the CLI via uv + default go-litellm gateway + completions"
	@echo "  install-go-litellm  Build/install the Go gateway → ~/.local/bin/go-litellm"
	@echo "  install-completions  Install bash/zsh completions only"
	@echo "  refresh       Reinstall the tool (force refresh cache)"
	@echo "  dev           Install dev dependencies"
	@echo "  setup-litellm Setup litellm venv with custom callbacks"

compile:
	@true

test:
	uv run pytest

test-cov:
	uv run pytest --cov --cov-report=term-missing

coverage:
	uv run pytest --cov --cov-report=term-missing

coverage-html:
	uv run pytest --cov --cov-report=html
	@echo "Coverage report generated in htmlcov/index.html"

coverage-xml:
	uv run pytest --cov --cov-report=xml
	@echo "Coverage report generated in coverage.xml"

coverage-all: coverage-html coverage-xml
	@echo "All coverage reports generated"

clean:
	rm -rf htmlcov/
	rm -f coverage.xml
	rm -f .coverage
	rm -rf __pycache__/
	rm -rf run_claude/__pycache__/
	rm -rf tests/__pycache__/
	rm -rf .pytest_cache/
	rm -rf *.egg-info/
	rm -rf dist/
	rm -rf build/

install-go-litellm:
	$(MAKE) -C repos/go-litellm install
	@mkdir -p run_claude/bin
	@cp repos/go-litellm/bin/go-litellm run_claude/bin/go-litellm
	@chmod +x run_claude/bin/go-litellm
	@echo "run-claude: bundled gateway at run_claude/bin/go-litellm (default; no FRONT_PROXY_COMMAND)"

install:
	@if ! command -v go >/dev/null 2>&1; then \
		echo "run-claude: go not found; skip default gateway (go-litellm)."; \
		echo "run-claude: install Go 1.22+ and rerun: make install-go-litellm"; \
	else \
		$(MAKE) install-go-litellm; \
	fi
	@if ! command -v uv >/dev/null 2>&1; then \
		echo "run-claude: uv not found; skipping install."; \
		exit 0; \
	fi
	@if ! uv tool install --python "$(UV_TOOL_PYTHON)" . --force --refresh --no-sources; then \
		echo "run-claude: uv tool install failed; install skipped."; \
		echo "run-claude: rerun with a healthy uv toolchain when needed."; \
	fi
	@$(MAKE) install-completions

install-completions:
	@DATA_DIR="$${XDG_DATA_HOME:-$$HOME/.local/share}"; \
	BASH_DIR="$$DATA_DIR/bash-completion/completions"; \
	ZSH_DIR="$$DATA_DIR/zsh/site-functions"; \
	if ! mkdir -p "$$BASH_DIR" "$$ZSH_DIR" 2>/dev/null; then \
		echo "run-claude: cannot write completion dirs; skipping."; \
		exit 0; \
	fi; \
	cp completions/run-claude.bash "$$BASH_DIR/run-claude"; \
	cp completions/_run-claude "$$ZSH_DIR/_run-claude"; \
	echo "run-claude: completions installed (bash-completion + zsh)"; \
	if ! grep -qs "zsh/site-functions" "$$HOME/.zshrc" 2>/dev/null; then \
		echo "run-claude: zsh users — add to .zshrc before compinit:"; \
		echo "  fpath=($$ZSH_DIR \$$fpath)"; \
	fi

refresh:
	rm -rf ${HOME}/.local/share/uv/tools/run-claude
	@if ! command -v uv >/dev/null 2>&1; then \
		echo "run-claude: uv not found; refresh skipped."; \
		exit 0; \
	fi
	@if ! uv tool install --python "$(UV_TOOL_PYTHON)" . --refresh --force --verbose --no-sources; then \
		echo "run-claude: uv tool install failed."; \
		echo "run-claude: rerun refresh when uv is functioning."; \
		exit 0; \
	fi
	run-claude status
dev:
	uv sync --dev

# Setup litellm venv with run_claude callbacks
# This creates a separate venv at ~/.local/share/litellm/.venv
setup-litellm:
	@echo "Setting up litellm venv with custom callbacks..."
	@LITELLM_HOME="$${HOME}/.local/share/litellm"; \
	VENV="$${LITELLM_HOME}/.venv"; \
	mkdir -p "$${LITELLM_HOME}"; \
	if [ ! -d "$${VENV}" ]; then \
		uv venv --python 3.11 "$${VENV}"; \
	fi; \
	. "$${VENV}/bin/activate" && \
	uv pip install -e "$(CURDIR)/repos/litellm[proxy]" && \
	uv pip install litellm-proxy-extras psycopg2-binary prometheus_client opentelemetry-api opentelemetry-sdk && \
	uv pip install prisma==0.11.0 && \
	uv pip install -e "$(CURDIR)" && \
	echo "$(CURDIR)" > "$${VENV}/.run_claude_installed"
	@echo "Done. Litellm venv configured at ~/.local/share/litellm/.venv"
	@echo "Custom callbacks (ProviderCompatCallback) are now available."
