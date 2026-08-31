.PHONY: help build test install uninstall clean tidy

PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin
VERSION ?= 0.1.0
GOFLAGS ?= -trimpath
LDFLAGS ?= -s -w -X github.com/noizu-labs/go-litellm/internal/version.Version=$(VERSION)
export CGO_ENABLED ?= 0

help:
	@echo "go-litellm — CGO-free LiteLLM / ex-litellm drop-in"
	@echo ""
	@echo "  make build      build bin/go-litellm"
	@echo "  make test       go test ./..."
	@echo "  make install    build + copy to $(BINDIR)/go-litellm"
	@echo "  make uninstall  remove $(BINDIR)/go-litellm"
	@echo "  make tidy       go mod tidy"
	@echo ""
	@echo "run-claude launches this binary by default (no FRONT_PROXY_COMMAND required)"

build:
	mkdir -p bin
	go build $(GOFLAGS) -ldflags '$(LDFLAGS)' -o bin/go-litellm ./cmd/go-litellm

test:
	go test ./...

tidy:
	go mod tidy

install: build
	mkdir -p "$(BINDIR)"
	install -m 0755 bin/go-litellm "$(BINDIR)/go-litellm"
	@echo "installed $(BINDIR)/go-litellm (run-claude default gateway)"

uninstall:
	rm -f "$(BINDIR)/go-litellm"

clean:
	rm -rf bin
