SHELL := /bin/bash

HOST ?= 127.0.0.1
PORT ?= 8080
PID_FILE ?= .modal-genai-gateway.pid
LOG_DIR ?= .logs
LOG_FILE ?= $(LOG_DIR)/gateway.log

# Model apps in dependency order (gateway last).
APPS := llm image tts stt music sfx video threed

.PHONY: help sync secrets deploy deploy-ci deploy-gateway $(addprefix deploy-,$(APPS)) \
        serve start stop restart status logs test smoke

help:
	@printf "Modal GenAI — targets:\n"
	@printf "  make sync             Install gateway deps (uv)\n"
	@printf "  make secrets          Print the modal secret commands to run\n"
	@printf "  make deploy           Deploy ALL model apps + gateway to Modal (interactive auth)\n"
	@printf "  make deploy-ci        Non-interactive deploy: env tokens + secrets + all apps\n"
	@printf "  make deploy-llm       Deploy just the vLLM LLM app (image/tts/...)\n"
	@printf "  make deploy-gateway   Deploy the OpenAI-compatible gateway (do last)\n"
	@printf "  make serve            Run the gateway LOCALLY against deployed Modal apps\n"
	@printf "  make start/stop/status  Manage the local gateway in the background\n"
	@printf "  make test             Run the offline test suite (stub mode)\n"
	@printf "  make smoke            Hit the running gateway across every modality\n"

sync:
	uv sync

secrets:
	@printf "Create the Modal secrets the apps expect:\n\n"
	@printf "  modal secret create huggingface HF_TOKEN=hf_xxx\n"
	@printf "  modal secret create modal-genai-vllm MODAL_GENAI_VLLM_KEY=$$(openssl rand -hex 24)\n"
	@printf "  modal secret create modal-genai-gateway \\\\\n"
	@printf "      MODAL_GENAI_API_KEY=$$(openssl rand -hex 24) \\\\\n"
	@printf "      MODAL_GENAI_VLLM_KEY=<same as above>\n"

# Deploy every model app, then the gateway.
deploy: $(addprefix deploy-,$(APPS)) deploy-gateway
	@echo "All apps deployed. Update config/models.yaml vLLM base_urls with the printed URLs, then re-run 'make deploy-gateway'."

# Non-interactive: auth via MODAL_TOKEN_ID/SECRET, (re)create secrets, deploy all.
# Reads from the environment or .env. See deploy-ci.sh for SKIP_SECRETS / ONLY /
# SKIP_GATEWAY knobs.
deploy-ci:
	./deploy-ci.sh

deploy-llm:
	modal deploy modal_apps/llm.py
deploy-image:
	modal deploy modal_apps/image.py
deploy-tts:
	modal deploy modal_apps/tts.py
deploy-stt:
	modal deploy modal_apps/stt.py
deploy-music:
	modal deploy modal_apps/music.py
deploy-sfx:
	modal deploy modal_apps/sfx.py
deploy-video:
	modal deploy modal_apps/video.py
deploy-threed:
	modal deploy modal_apps/threed.py
deploy-gateway:
	modal deploy modal_apps/gateway.py

# Run the gateway locally (dispatches to deployed Modal apps; needs a modal token).
serve:
	uv run --extra modal modal-genai-gateway

start:
	@mkdir -p "$(LOG_DIR)"
	@if [[ -f "$(PID_FILE)" ]] && kill -0 "$$(cat "$(PID_FILE)")" 2>/dev/null; then \
		echo "Gateway already running: pid $$(cat "$(PID_FILE)")"; \
	else \
		nohup env MODAL_GENAI_HOST="$(HOST)" MODAL_GENAI_PORT="$(PORT)" uv run --extra modal modal-genai-gateway >"$(LOG_FILE)" 2>&1 & \
		echo $$! >"$(PID_FILE)"; \
		for attempt in 1 2 3 4 5; do curl -fsS "http://$(HOST):$(PORT)/health" >/dev/null 2>&1 && break; sleep 1; done; \
		if curl -fsS "http://$(HOST):$(PORT)/health" >/dev/null 2>&1; then \
			echo "Started gateway on http://$(HOST):$(PORT) pid $$(cat "$(PID_FILE)")"; \
		else \
			echo "Gateway failed to start. Recent logs:"; tail -40 "$(LOG_FILE)" 2>/dev/null || true; rm -f "$(PID_FILE)"; exit 1; \
		fi; \
	fi

stop:
	@if [[ -f "$(PID_FILE)" ]] && kill -0 "$$(cat "$(PID_FILE)")" 2>/dev/null; then \
		kill "$$(cat "$(PID_FILE)")"; echo "Stopped gateway"; rm -f "$(PID_FILE)"; \
	else echo "Gateway is not running"; rm -f "$(PID_FILE)"; fi

restart: stop start

status:
	@if [[ -f "$(PID_FILE)" ]] && kill -0 "$$(cat "$(PID_FILE)")" 2>/dev/null; then \
		echo "Gateway running: pid $$(cat "$(PID_FILE)")"; curl -fsS "http://$(HOST):$(PORT)/health" || true; echo; \
	else echo "Gateway is not running"; fi

logs:
	@mkdir -p "$(LOG_DIR)"; touch "$(LOG_FILE)"; tail -f "$(LOG_FILE)"

test:
	MODAL_GENAI_STUB_MODE=1 uv run pytest

smoke:
	BASE_URL="http://$(HOST):$(PORT)" ./smoke-test.sh
