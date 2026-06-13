defmodule Noizu.MCP.Server.ResourceTemplate do
  @moduledoc """
  Define an MCP resource template (RFC 6570 `{var}` URIs) as a module.

      defmodule MyApp.MCP.TableSchema do
        use Noizu.MCP.Server.ResourceTemplate,
          uri_template: "db://{table}/schema",
          name: "Table Schema",
          mime_type: "application/json"

        @impl true
        def read(_uri, %{table: table}, _ctx) do
          {:ok, MyApp.Repo.schema_json(table)}
        end

        @impl true
        def complete(:table, prefix, _ctx) do
          {:ok, Enum.filter(MyApp.Repo.tables(), &String.starts_with?(&1, prefix))}
        end

        @impl true
        def list(_ctx) do
          {:ok, Enum.map(MyApp.Repo.tables(), &%Noizu.MCP.Types.Resource{uri: "db://\#{&1}/schema"})}
        end
      end

  ## `use` options

  `:uri_template` (required), plus the same metadata options as
  `Noizu.MCP.Server.Resource` (`:name`, `:title`, `:description`, `:mime_type`,
  `:annotations`, `:icons`, `:meta`, `:subscribable`).

  ## Callbacks

    * `c:read/3` (required) — receives the concrete URI and the template
      variables, atom-keyed. Same return contract as
      `c:Noizu.MCP.Server.Resource.read/2`.
    * `c:complete/3` (optional) — powers `completion/complete` for template
      variables. Return `{:ok, values}` or `{:ok, values, has_more: true,
      total: n}`.
    * `c:list/1` (optional) — makes the template's instances enumerable in
      `resources/list`.
  """

  alias Noizu.MCP.Types

  @callback read(uri :: String.t(), vars :: map(), ctx :: Noizu.MCP.Ctx.t()) ::
              {:ok, term()} | {:error, term()}

  @callback complete(variable :: atom(), value :: String.t(), ctx :: Noizu.MCP.Ctx.t()) ::
              {:ok, [String.t()]} | {:ok, [String.t()], keyword()} | {:error, term()}

  @callback list(ctx :: Noizu.MCP.Ctx.t()) ::
              {:ok, [Types.Resource.t()]} | {:error, term()}

  @doc "The wire definition advertised by `resources/templates/list`."
  @callback definition() :: Types.ResourceTemplate.t()

  @doc false
  @callback __mcp_resource_template__(:subscribable | :mime_type | :variables) :: term()

  @optional_callbacks complete: 3, list: 1

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Noizu.MCP.Server.ResourceTemplate

      uri_template =
        Keyword.get(opts, :uri_template) ||
          raise ArgumentError, "ResourceTemplate requires :uri_template"

      @__mcp_template_uri__ uri_template
      @__mcp_template_vars__ Noizu.MCP.UriTemplate.variables(uri_template)
      @__mcp_template_opts__ opts

      @impl Noizu.MCP.Server.ResourceTemplate
      def definition do
        opts = @__mcp_template_opts__

        %Noizu.MCP.Types.ResourceTemplate{
          uri_template: @__mcp_template_uri__,
          name: opts[:name],
          title: opts[:title],
          description: opts[:description],
          mime_type: opts[:mime_type],
          annotations: opts[:annotations],
          icons: opts[:icons],
          meta: opts[:meta]
        }
      end

      @impl Noizu.MCP.Server.ResourceTemplate
      def __mcp_resource_template__(:subscribable),
        do: @__mcp_template_opts__[:subscribable] == true

      def __mcp_resource_template__(:mime_type), do: @__mcp_template_opts__[:mime_type]
      def __mcp_resource_template__(:variables), do: @__mcp_template_vars__
    end
  end
end
