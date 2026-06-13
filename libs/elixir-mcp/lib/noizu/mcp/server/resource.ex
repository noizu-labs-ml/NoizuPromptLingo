defmodule Noizu.MCP.Server.Resource do
  @moduledoc """
  Define an MCP resource as a module.

      defmodule MyApp.MCP.Config do
        use Noizu.MCP.Server.Resource,
          uri: "config://app",
          name: "App Config",
          mime_type: "application/json",
          subscribable: true

        @impl true
        def read(_uri, _ctx), do: {:ok, Jason.encode!(MyApp.config())}
      end

  ## `use` options

    * `:uri` (required) — the resource URI
    * `:name`, `:title`, `:description`, `:mime_type`, `:size`, `:annotations`,
      `:icons`, `:meta` — advertised in `resources/list`
    * `:subscribable` — when true, clients may `resources/subscribe` to this
      URI and the server's `resources.subscribe` capability is enabled. Publish
      changes with `MyServer.notify_resource_updated(uri)`.

  ## Return values from `c:read/2`

    * `{:ok, String.t()}` — text contents (with the declared mime type)
    * `{:ok, {:blob, binary()}}` — binary contents (base64-encoded on the wire)
    * `{:ok, ResourceContents.t() | [ResourceContents.t()]}` — full control
    * `{:error, Noizu.MCP.Error.t()}` — protocol error
      (`Noizu.MCP.Error.resource_not_found/1` for missing resources)
  """

  alias Noizu.MCP.Types

  @doc "Read the resource. See the module docs for return values."
  @callback read(uri :: String.t(), ctx :: Noizu.MCP.Ctx.t()) ::
              {:ok, term()} | {:error, term()}

  @doc "The wire definition advertised by `resources/list`."
  @callback definition() :: Types.Resource.t()

  @doc false
  @callback __mcp_resource__(:subscribable | :mime_type) :: term()

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Noizu.MCP.Server.Resource

      uri = Keyword.get(opts, :uri) || raise ArgumentError, "Resource requires :uri"

      @__mcp_resource_uri__ uri
      @__mcp_resource_opts__ opts

      @impl Noizu.MCP.Server.Resource
      def definition do
        opts = @__mcp_resource_opts__

        %Noizu.MCP.Types.Resource{
          uri: @__mcp_resource_uri__,
          name: opts[:name],
          title: opts[:title],
          description: opts[:description],
          mime_type: opts[:mime_type],
          size: opts[:size],
          annotations: opts[:annotations],
          icons: opts[:icons],
          meta: opts[:meta]
        }
      end

      @impl Noizu.MCP.Server.Resource
      def __mcp_resource__(:subscribable), do: @__mcp_resource_opts__[:subscribable] == true
      def __mcp_resource__(:mime_type), do: @__mcp_resource_opts__[:mime_type]
    end
  end
end
