# elixir-github (0.1.0)

Lightweight GitHub REST API wrapper with streaming support and structured responses.

## Installation
```elixir
{:noizu_github, github: "noizu-labs/elixir-github"}
```

## Configuration
```elixir
config :noizu_github,
  api_key: "ghp_...",
  owner: "my-org",
  repo: "my-repo"
```

## Core API

```elixir
# Generic API call
Noizu.Github.api_call(type, url, body, model, options)
# type: :get | :post | :put | :patch | :delete
# model: Module implementing from_json/1
# options: [stream: bool, raw: bool, token: override, request_log_callback: fn, response_log_callback: fn]
```

### Helpers
```elixir
Noizu.Github.github_base()          # "https://api.github.com"
Noizu.Github.repo_name(options)     # From options or config
Noizu.Github.repo_owner(options)    # From options or config
Noizu.Github.headers(options)       # Auth + API version headers
```

## Struct Modules
- `Noizu.Github.Structs.Issue` / `Issues`
- `Noizu.Github.Structs.Branch` / `Branches`
- `Noizu.Github.Structs.Commit`
- `Noizu.Github.Structs.User`
- `Noizu.Github.Structs.Label`
- `Noizu.Github.Structs.Reaction`

Each implements `from_json/1` for response parsing.

## Streaming
```elixir
{:ok, response} = Noizu.Github.api_call(:post, url, body, Model,
  stream: fn event, payload ->
    case event do
      {:status, code} -> %{payload | status: code}
      {:headers, headers} -> %{payload | headers: headers}
      {:data, data} -> process_chunk(data, payload)
    end
  end
)
```

## Key Concepts
1. Single `api_call/5` handles all request types
2. Model callback (`from_json/1`) handles domain-specific parsing
3. Finch HTTP pooling (pool: `Noizu.Github.Finch`, 600s timeout)
4. GitHub API v2022-11-28 headers auto-included
