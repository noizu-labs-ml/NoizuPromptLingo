# DirenvConfig

Elixir SDK for [direnv-config](https://github.com/noizu/direnv-config) (dc) -- read and write YAML-backed directory configuration.

## Installation

Add `direnv_config` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:direnv_config, "~> 0.1.0"}
  ]
end
```

## Quick Start

### Reading configuration

```elixir
# Read all config for the current directory
{:ok, config} = DirenvConfig.read()

# Read a specific key
{:ok, value} = DirenvConfig.read("my_key")

# Read from a specific path
{:ok, config} = DirenvConfig.read(path: "/path/to/project")
```

### Writing configuration

```elixir
# Set a key in the nearest config file
:ok = DirenvConfig.write("my_key", "my_value")

# Set a key at a specific path
:ok = DirenvConfig.write("my_key", "my_value", path: "/path/to/project")
```

## Documentation

Full documentation and CLI usage at the [main repository](https://github.com/noizu/direnv-config).

## License

MIT -- see [LICENSE](LICENSE) for details.
