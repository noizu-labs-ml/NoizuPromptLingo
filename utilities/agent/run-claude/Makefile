.PHONY: help compile test test-cov coverage coverage-html coverage-xml clean install dev refresh setup-litellm

help:
	@echo "Available targets:"
	@echo "  test          Run tests"
	@echo "  test-cov      Run tests with coverage report"
	@echo "  coverage      Run tests and show coverage summary"
	@echo "  coverage-html Generate HTML coverage report"
	@echo "  coverage-xml  Generate XML coverage report (for CI)"
	@echo "  clean         Remove build artifacts and coverage files"
	@echo "  install       Install the tool via uv"
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

install:
	@if ! command -v uv >/dev/null 2>&1; then \
		echo "run-claude: uv not found; skipping install."; \
		exit 0; \
	fi
	@if ! uv tool install . --force --refresh --no-sources; then \
		echo "run-claude: uv tool install failed; install skipped."; \
		echo "run-claude: rerun with a healthy uv toolchain when needed."; \
	fi
refresh:
	rm -rf ${HOME}/.local/share/uv/tools/run-claude
	@if ! command -v uv >/dev/null 2>&1; then \
		echo "run-claude: uv not found; refresh skipped."; \
		exit 0; \
	fi
	@if ! uv tool install . --refresh --force --verbose --no-sources; then \
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
