defmodule Noizu.MCP.Server do
  @moduledoc """
  Define an MCP server.

      defmodule MyApp.MCP do
        use Noizu.MCP.Server,
          name: "myapp",
          version: "1.0.0",
          instructions: "Weather and reporting tools for MyApp."

        tool MyApp.MCP.GetWeather
        tool MyApp.MCP.SendEmail, name: "send_email_v2"
        resource MyApp.MCP.Config
        resource_template MyApp.MCP.TableSchema
        prompt MyApp.MCP.CodeReview
      end

  `use Noizu.MCP.Server` makes the module a supervisable child
  (`children = [{MyApp.MCP, transport: :stdio}]`), registers components
  declared with `tool/2`, `resource/2`, `resource_template/2`, and `prompt/2`,
  derives the server's capabilities automatically, and provides notification
  helpers:

      MyApp.MCP.notify_changed(:tools)                    # list-changed fan-out
      MyApp.MCP.notify_resource_updated("config://app")   # to subscribed sessions

  ## `use` options

    * `:name` (required) — server name advertised in `serverInfo`
    * `:version` (required) — server version string
    * `:title`, `:description`, `:website_url`, `:icons` — optional
      `serverInfo` metadata
    * `:instructions` — usage hints delivered to the client on initialize

  ## Escape hatch: behaviours without macros

  Everything the DSL generates is an implementation of this module's
  behaviour. Skip the component registrations and implement the `handle_*`
  callbacks directly; implementing a callback is what enables the
  corresponding capability:

      defmodule MyApp.RawMCP do
        use Noizu.MCP.Server, name: "raw", version: "1.0.0"

        @impl true
        def handle_list_tools(_cursor, _ctx),
          do: {:ok, [%Noizu.MCP.Types.Tool{name: "echo"}], nil}

        @impl true
        def handle_call_tool("echo", args, _ctx),
          do: {:ok, inspect(args)}
      end

  Behaviour-level handlers receive **string-keyed, unvalidated** arguments —
  validation/casting is part of the component DSL layer.
  """

  alias Noizu.MCP.{Ctx, Error}
  alias Noizu.MCP.Types

  @doc """
  Per-session initialization, invoked once the handshake completes. Seed
  session assigns via `Noizu.MCP.Ctx.assign/3` on the returned ctx. Runs in the
  session process — keep it fast.
  """
  @callback init(Ctx.t(), init_params :: map()) :: {:ok, Ctx.t()} | {:error, term()}

  @doc "List tools for `tools/list`. Return `{:ok, tools, next_cursor}`."
  @callback handle_list_tools(cursor :: String.t() | nil, Ctx.t()) ::
              {:ok, [Types.Tool.t()], String.t() | nil} | {:error, Error.t()}

  @doc "Execute a tool for `tools/call`. See `Noizu.MCP.Server.Tool` for return values."
  @callback handle_call_tool(name :: String.t(), args :: map(), Ctx.t()) ::
              {:ok, term()} | {:error, term()}

  @doc "List resources for `resources/list`."
  @callback handle_list_resources(cursor :: String.t() | nil, Ctx.t()) ::
              {:ok, [Types.Resource.t()], String.t() | nil} | {:error, Error.t()}

  @doc "List resource templates for `resources/templates/list`."
  @callback handle_list_resource_templates(cursor :: String.t() | nil, Ctx.t()) ::
              {:ok, [Types.ResourceTemplate.t()], String.t() | nil} | {:error, Error.t()}

  @doc "Read a resource. See `Noizu.MCP.Server.Resource` for return values."
  @callback handle_read_resource(uri :: String.t(), Ctx.t()) ::
              {:ok, term()} | {:error, term()}

  @doc "Approve or reject a `resources/subscribe`. Return `:ok` to accept."
  @callback handle_subscribe(uri :: String.t(), Ctx.t()) :: :ok | {:error, Error.t()}

  @doc "Hook for `resources/unsubscribe` (the runtime updates subscription state regardless)."
  @callback handle_unsubscribe(uri :: String.t(), Ctx.t()) :: :ok | {:error, Error.t()}

  @doc "List prompts for `prompts/list`."
  @callback handle_list_prompts(cursor :: String.t() | nil, Ctx.t()) ::
              {:ok, [Types.Prompt.t()], String.t() | nil} | {:error, Error.t()}

  @doc "Render a prompt for `prompts/get`. See `Noizu.MCP.Server.Prompt` for return values."
  @callback handle_get_prompt(name :: String.t(), args :: map(), Ctx.t()) ::
              {:ok, [Types.PromptMessage.t()]}
              | {:ok, [Types.PromptMessage.t()], keyword()}
              | {:error, Error.t()}

  @doc """
  Complete an argument value for `completion/complete`.

  `ref` is `{:prompt, name}` or `{:resource_template, uri_template}`;
  `argument` is `{name, partial_value}`. Return `{:ok, values}` or
  `{:ok, values, total: n, has_more: true}`.
  """
  @callback handle_complete(
              ref :: {:prompt, String.t()} | {:resource_template, String.t()},
              argument :: {String.t(), String.t()},
              Ctx.t()
            ) ::
              {:ok, [String.t()]} | {:ok, [String.t()], keyword()} | {:error, Error.t()}

  @doc false
  @callback server_info() :: Types.Implementation.t()

  @doc false
  @callback __mcp__(atom()) :: term()

  @optional_callbacks init: 2,
                      handle_list_tools: 2,
                      handle_call_tool: 3,
                      handle_list_resources: 2,
                      handle_list_resource_templates: 2,
                      handle_read_resource: 2,
                      handle_subscribe: 2,
                      handle_unsubscribe: 2,
                      handle_list_prompts: 2,
                      handle_get_prompt: 3,
                      handle_complete: 3

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Noizu.MCP.Server
      import Noizu.MCP.Server,
        only: [
          tool: 1,
          tool: 2,
          resource: 1,
          resource: 2,
          resource_template: 1,
          resource_template: 2,
          prompt: 1,
          prompt: 2
        ]

      Module.register_attribute(__MODULE__, :__mcp_tools__, accumulate: true)
      Module.register_attribute(__MODULE__, :__mcp_resources__, accumulate: true)
      Module.register_attribute(__MODULE__, :__mcp_resource_templates__, accumulate: true)
      Module.register_attribute(__MODULE__, :__mcp_prompts__, accumulate: true)
      @__mcp_server_opts__ opts
      @before_compile Noizu.MCP.Server

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {Noizu.MCP.Server.Supervisor, :start_link, [__MODULE__, opts]},
          type: :supervisor
        }
      end

      def start_link(opts \\ []) do
        Noizu.MCP.Server.Supervisor.start_link(__MODULE__, opts)
      end

      @doc "Notify all connected clients that a component list changed."
      def notify_changed(kind) when kind in [:tools, :resources, :prompts] do
        for session <- Noizu.MCP.Server.Supervisor.sessions(__MODULE__) do
          Noizu.MCP.Server.Session.notify_changed(session, kind)
        end

        :ok
      end

      @doc "Notify sessions subscribed to `uri` that the resource changed."
      def notify_resource_updated(uri) when is_binary(uri) do
        for session <- Noizu.MCP.Server.Supervisor.sessions(__MODULE__) do
          Noizu.MCP.Server.Session.notify_resource_updated(session, uri)
        end

        :ok
      end
    end
  end

  @doc "Register a tool module (see `Noizu.MCP.Server.Tool`). Options: `:name`, `:description` overrides."
  defmacro tool(module, opts \\ []) do
    quote do
      @__mcp_tools__ {unquote(module), unquote(opts)}
    end
  end

  @doc "Register a resource module (see `Noizu.MCP.Server.Resource`)."
  defmacro resource(module, opts \\ []) do
    quote do
      @__mcp_resources__ {unquote(module), unquote(opts)}
    end
  end

  @doc "Register a resource template module (see `Noizu.MCP.Server.ResourceTemplate`)."
  defmacro resource_template(module, opts \\ []) do
    quote do
      @__mcp_resource_templates__ {unquote(module), unquote(opts)}
    end
  end

  @doc "Register a prompt module (see `Noizu.MCP.Server.Prompt`)."
  defmacro prompt(module, opts \\ []) do
    quote do
      @__mcp_prompts__ {unquote(module), unquote(opts)}
    end
  end

  defmacro __before_compile__(env) do
    opts = Module.get_attribute(env.module, :__mcp_server_opts__)
    tools = env.module |> Module.get_attribute(:__mcp_tools__) |> Enum.reverse()
    resources = env.module |> Module.get_attribute(:__mcp_resources__) |> Enum.reverse()

    templates =
      env.module |> Module.get_attribute(:__mcp_resource_templates__) |> Enum.reverse()

    prompts = env.module |> Module.get_attribute(:__mcp_prompts__) |> Enum.reverse()

    name = Keyword.get(opts, :name) || raise ArgumentError, "use Noizu.MCP.Server requires :name"

    version =
      Keyword.get(opts, :version) || raise ArgumentError, "use Noizu.MCP.Server requires :version"

    defines? = fn fa -> Module.defines?(env.module, fa) end

    tools? =
      tools != [] or defines?.({:handle_list_tools, 2}) or defines?.({:handle_call_tool, 3})

    resources? =
      resources != [] or templates != [] or defines?.({:handle_list_resources, 2}) or
        defines?.({:handle_read_resource, 2})

    prompts? =
      prompts != [] or defines?.({:handle_list_prompts, 2}) or defines?.({:handle_get_prompt, 3})

    completions? =
      prompts != [] or templates != [] or defines?.({:handle_complete, 3})

    default_impls =
      [
        # tools
        unless defines?.({:handle_list_tools, 2}) or tools == [] do
          quote do
            @impl Noizu.MCP.Server
            def handle_list_tools(cursor, _ctx) do
              Noizu.MCP.Server.Features.Tools.list_registered(__mcp__(:tools), cursor)
            end
          end
        end,
        unless defines?.({:handle_call_tool, 3}) or tools == [] do
          quote do
            @impl Noizu.MCP.Server
            def handle_call_tool(name, args, ctx) do
              Noizu.MCP.Server.Features.Tools.dispatch(__mcp__(:tools), name, args, ctx)
            end
          end
        end,
        # resources
        unless defines?.({:handle_list_resources, 2}) or (resources == [] and templates == []) do
          quote do
            @impl Noizu.MCP.Server
            def handle_list_resources(cursor, ctx) do
              Noizu.MCP.Server.Features.Resources.list_registered(
                __mcp__(:resources),
                __mcp__(:resource_templates),
                cursor,
                ctx
              )
            end
          end
        end,
        unless defines?.({:handle_list_resource_templates, 2}) or templates == [] do
          quote do
            @impl Noizu.MCP.Server
            def handle_list_resource_templates(cursor, _ctx) do
              Noizu.MCP.Server.Features.Resources.list_registered_templates(
                __mcp__(:resource_templates),
                cursor
              )
            end
          end
        end,
        unless defines?.({:handle_read_resource, 2}) or (resources == [] and templates == []) do
          quote do
            @impl Noizu.MCP.Server
            def handle_read_resource(uri, ctx) do
              Noizu.MCP.Server.Features.Resources.dispatch_read(
                __mcp__(:resources),
                __mcp__(:resource_templates),
                uri,
                ctx
              )
            end
          end
        end,
        unless defines?.({:handle_subscribe, 2}) or (resources == [] and templates == []) do
          quote do
            @impl Noizu.MCP.Server
            def handle_subscribe(uri, _ctx) do
              Noizu.MCP.Server.Features.Resources.check_subscribe(
                __mcp__(:resources),
                __mcp__(:resource_templates),
                uri
              )
            end
          end
        end,
        # prompts
        unless defines?.({:handle_list_prompts, 2}) or prompts == [] do
          quote do
            @impl Noizu.MCP.Server
            def handle_list_prompts(cursor, _ctx) do
              Noizu.MCP.Server.Features.Prompts.list_registered(__mcp__(:prompts), cursor)
            end
          end
        end,
        unless defines?.({:handle_get_prompt, 3}) or prompts == [] do
          quote do
            @impl Noizu.MCP.Server
            def handle_get_prompt(name, args, ctx) do
              Noizu.MCP.Server.Features.Prompts.dispatch_get(__mcp__(:prompts), name, args, ctx)
            end
          end
        end,
        # completion
        unless defines?.({:handle_complete, 3}) or (prompts == [] and templates == []) do
          quote do
            @impl Noizu.MCP.Server
            def handle_complete(ref, argument, ctx) do
              Noizu.MCP.Server.Features.Completion.dispatch(
                __mcp__(:prompts),
                __mcp__(:resource_templates),
                ref,
                argument,
                ctx
              )
            end
          end
        end
      ]
      |> Enum.reject(&is_nil/1)

    quote do
      @impl Noizu.MCP.Server
      def server_info do
        %Noizu.MCP.Types.Implementation{
          name: unquote(name),
          version: unquote(version),
          title: unquote(opts[:title]),
          description: unquote(opts[:description]),
          website_url: unquote(opts[:website_url]),
          icons: unquote(opts[:icons])
        }
      end

      @impl Noizu.MCP.Server
      def __mcp__(:tools), do: unquote(Macro.escape(tools))
      def __mcp__(:resources), do: unquote(Macro.escape(resources))
      def __mcp__(:resource_templates), do: unquote(Macro.escape(templates))
      def __mcp__(:prompts), do: unquote(Macro.escape(prompts))
      def __mcp__(:instructions), do: unquote(opts[:instructions])
      def __mcp__(:opts), do: unquote(Macro.escape(opts))

      def __mcp__(:capabilities) do
        Noizu.MCP.Server.build_capabilities(__MODULE__, %{
          tools?: unquote(tools?),
          resources?: unquote(resources?),
          prompts?: unquote(prompts?),
          completions?: unquote(completions?),
          user_subscribe?: unquote(defines?.({:handle_subscribe, 2}))
        })
      end

      unquote(default_impls)
    end
  end

  @doc false
  # Runtime capability derivation: component modules are compiled by the time
  # a server starts, so subscribability can be checked here, not at macro time.
  def build_capabilities(server, flags) do
    subscribable? =
      flags.user_subscribe? or
        Enum.any?(server.__mcp__(:resources), fn {module, _} ->
          module.__mcp_resource__(:subscribable)
        end) or
        Enum.any?(server.__mcp__(:resource_templates), fn {module, _} ->
          module.__mcp_resource_template__(:subscribable)
        end)

    %{}
    |> then(fn caps ->
      if flags.tools?, do: Map.put(caps, "tools", %{"listChanged" => true}), else: caps
    end)
    |> then(fn caps ->
      if flags.resources? do
        Map.put(caps, "resources", %{"listChanged" => true, "subscribe" => subscribable?})
      else
        caps
      end
    end)
    |> then(fn caps ->
      if flags.prompts?, do: Map.put(caps, "prompts", %{"listChanged" => true}), else: caps
    end)
    |> then(fn caps ->
      if flags.completions?, do: Map.put(caps, "completions", %{}), else: caps
    end)
    |> Map.put("logging", %{})
  end
end
