# SDK Layout

Read-only client libraries for `dc` stores. Each SDK shares the same API surface and validates against shared contract tests.

```
sdk/
├── contract-tests/                 # Cross-language test fixtures
│   ├── fixtures/
│   │   ├── simple-store/           #   Single-config store (.meta, .version, cluster/.active)
│   │   └── nested-store/           #   Multi-config store (.meta, .version, app/.active)
│   └── expectations.yaml           #   Expected results for contract test assertions
├── elixir/                         # Elixir SDK
│   ├── lib/
│   │   ├── direnv_config.ex        #   Public API module
│   │   └── direnv_config/
│   │       ├── cli.ex              #   CLI backend (shells out to dc)
│   │       ├── client.ex           #   DcClient GenServer
│   │       ├── native.ex           #   Native backend (reads YAML directly)
│   │       ├── path.ex             #   Path expression parser
│   │       ├── store.ex            #   Store resolution
│   │       ├── version.ex          #   Version tracking
│   │       └── watcher.ex          #   File-change watcher
│   ├── test/
│   │   ├── contract_test.exs       #   Contract test suite
│   │   └── direnv_config/          #   Unit tests (native, path, store)
│   ├── mix.exs                     #   Package manifest
│   ├── .formatter.exs
│   └── .tool-versions              #   asdf versions (erlang, elixir)
├── php/                            # PHP SDK
│   ├── src/
│   │   ├── Backend/
│   │   │   ├── BackendInterface.php    # Backend contract
│   │   │   ├── CliBackend.php          # CLI backend
│   │   │   └── NativeBackend.php       # Native backend
│   │   ├── Exception/
│   │   │   ├── ConfigNotFoundException.php
│   │   │   ├── DcException.php
│   │   │   └── StoreNotFoundException.php
│   │   ├── DcClient.php            #   Public API
│   │   ├── PathExpression.php       #   Path expression parser
│   │   ├── Segment.php             #   Path segment
│   │   ├── Store.php               #   Store resolution
│   │   └── Version.php             #   Version tracking
│   ├── tests/                      #   PHPUnit tests (contract, native, path, store)
│   ├── composer.json               #   Package manifest
│   ├── phpunit.xml
│   └── .tool-versions              #   asdf versions (php)
├── python/                         # Python SDK
│   ├── src/direnv_config/
│   │   ├── __init__.py             #   Package exports
│   │   ├── cli.py                  #   CLI backend
│   │   ├── client.py               #   DcClient
│   │   ├── native.py               #   Native backend
│   │   ├── path.py                 #   Path expression parser
│   │   ├── store.py                #   Store resolution
│   │   └── version.py              #   Version tracking
│   ├── tests/                      #   pytest tests (contract, native, path, store)
│   ├── pyproject.toml              #   Package manifest
│   └── .gitignore
├── typescript/                     # TypeScript SDK
│   ├── src/
│   │   ├── backends/               #   CLI and native backends
│   │   ├── client.ts               #   DcClient
│   │   ├── path.ts                 #   Path expression parser
│   │   ├── store.ts                #   Store resolution
│   │   ├── version.ts              #   Version tracking
│   │   └── index.ts                #   Package exports
│   ├── test/                       #   Vitest tests (contract, native, path, store)
│   ├── package.json                #   Package manifest
│   ├── tsconfig.json
│   ├── tsup.config.ts              #   Build config (bundling)
│   └── vitest.config.ts            #   Test config
└── README.md                       # SDK overview and quick-start
```

## Architecture

Each SDK implements two backends:

- **Native** — reads YAML files directly from `~/.local/state/direnv-config/` (no `dc` binary required)
- **CLI** — shells out to the `dc` binary for resolution

All SDKs validate against `contract-tests/expectations.yaml` using the shared fixtures.
