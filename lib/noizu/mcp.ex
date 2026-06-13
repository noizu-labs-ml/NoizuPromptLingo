defmodule Noizu.MCP do
  @moduledoc """
  Model Context Protocol (MCP) for Elixir — server and client.

  `Noizu.MCP` implements the [Model Context Protocol](https://modelcontextprotocol.io)
  so Elixir applications can expose MCP servers (over stdio or Streamable HTTP) and
  consume MCP servers as a client.

  ## Defining a server

      defmodule MyApp.MCP do
        use Noizu.MCP.Server,
          name: "myapp",
          version: "1.0.0",
          instructions: "Tools for MyApp."

        tool MyApp.MCP.GetWeather
      end

      defmodule MyApp.MCP.GetWeather do
        use Noizu.MCP.Server.Tool,
          description: "Get current weather for a location",
          annotations: [read_only_hint: true]

        input do
          field :location, :string, required: true, description: "City name or zip code"
          field :units, :enum, values: [:celsius, :fahrenheit], default: :celsius
        end

        @impl true
        def call(%{location: location, units: units}, _ctx) do
          {:ok, "Weather in \#{location}: 21 degrees \#{units}"}
        end
      end

  Run it over stdio (e.g. for Claude Code / Claude Desktop):

      children = [{MyApp.MCP, transport: :stdio}]

  See `Noizu.MCP.Server` for the full server API and `Noizu.MCP.Server.Tool` for
  the tool definition DSL.
  """

  @doc "Protocol revisions supported by this library, newest first."
  defdelegate supported_versions, to: Noizu.MCP.Protocol.Version, as: :supported

  @doc "The newest protocol revision supported by this library."
  defdelegate latest_version, to: Noizu.MCP.Protocol.Version, as: :latest
end
