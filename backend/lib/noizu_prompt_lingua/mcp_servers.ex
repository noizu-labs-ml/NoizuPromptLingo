defmodule NoizuPromptLingua.MCPServers do
  require Logger

  @moduledoc """
  Catalog of MCP servers exposed on subdomains. Single source of truth shared
  by the config endpoint (`/api/v1/auth/mcp/config`) and any client that needs
  to render setup commands (`claude mcp add`, `codex mcp add`, `grok mcp add`).

  The `:root` server maps to the bare host (`<host>/mcp`); every other entry is
  served at `<id>.<host>/mcp`. Keep this list in sync with the `host:` scopes
  wired in `NoizuPromptLinguaWeb.Router`.
  """

  # %{id: label/required/desc}. `id` doubles as the subdomain label (except root).
  @servers [
    %{id: "root", label: "Root MCP", required: true, desc: "Core tools, NPL, discovery"},
    %{id: "sessions", label: "Sessions", required: true, desc: "Session management"},
    %{
      id: "organizations",
      label: "Organizations",
      required: true,
      desc: "Organization management"
    },
    %{id: "projects", label: "Projects", required: false, desc: "Project management"},
    %{id: "tickets", label: "Tickets", required: false, desc: "Task & ticket tracking"},
    %{id: "assets", label: "Assets", required: false, desc: "Media asset lifecycle"},
    %{id: "artifacts", label: "Artifacts", required: false, desc: "Versioned content storage"},
    %{id: "chat", label: "Chat", required: false, desc: "Chat rooms & messages"},
    %{id: "review", label: "Review", required: false, desc: "Artifact review & overlays"},
    %{id: "wiki", label: "Wiki", required: false, desc: "Wiki spaces, pages & comments"},
    %{
      id: "github",
      label: "GitHub",
      required: false,
      desc: "GitHub integration — repos, branches, PRs, issues"
    },
    %{
      id: "personas",
      label: "Personas",
      required: false,
      desc: "Personas — bio, work log/journal & knowledge base"
    },
    %{
      id: "instructions",
      label: "Instructions",
      required: false,
      desc: "Reusable versioned prompts rendered with params for sub-agents"
    },
    %{id: "memory", label: "Memory", required: false, desc: "Knowledge memory and associations"},
    %{
      id: "markdown",
      label: "Markdown",
      required: false,
      desc: "URL/HTML→Markdown conversion & heading filter/collapse"
    },
    %{
      id: "notifications",
      label: "Notifications",
      required: false,
      desc: "Per-recipient notification inbox — Notify DMs, Monitor poll, watches, follow-ups"
    },
    %{
      id: "pubsub",
      label: "PubSub",
      required: false,
      desc: "Org-scoped pubsub channels — publish, follow, availability pointers"
    },
    %{
      id: "browser",
      label: "Browser",
      required: false,
      desc: "Drive a Playwright browser on the user's machine via a local controller"
    },
    %{
      id: "customers",
      label: "Customers",
      required: false,
      desc: "Customer/user personas (ICPs) & segments, linkable to tickets"
    },
    %{
      id: "market",
      label: "Market",
      required: false,
      desc: "Competitors, keyword research & market/competitor reports"
    },
    %{
      id: "campaigns",
      label: "Campaigns",
      required: false,
      desc: "Marketing/SEO/PPC campaigns, ad copy, landing pages & domain names"
    },
    %{
      id: "unicode",
      label: "Unicode Codex",
      required: false,
      desc: "Layered Unicode glyph/control-code browser and NPL special usages"
    }
  ]

  @server_modules %{
    "organizations" => NoizuPromptLingua.MCP.Organizations,
    "projects" => NoizuPromptLingua.MCP.Projects,
    "clients" => NoizuPromptLingua.MCP.Clients,
    "sessions" => NoizuPromptLingua.MCP.Sessions,
    "artifacts" => NoizuPromptLingua.Domains.Artifacts.MCP,
    "chat" => NoizuPromptLingua.Domains.Chat.MCP,
    "review" => NoizuPromptLingua.Domains.Review.MCP,
    "tickets" => NoizuPromptLingua.Domains.Tickets.MCP,
    "assets" => NoizuPromptLingua.Domains.Assets.MCP,
    "wiki" => NoizuPromptLingua.Domains.Wiki.MCP,
    "github" => NoizuPromptLingua.Domains.Github.MCP,
    "personas" => NoizuPromptLingua.Domains.Personas.MCP,
    "instructions" => NoizuPromptLingua.Domains.Instructions.MCP,
    "memory" => NoizuPromptLingua.Domains.Memory.MCP,
    "markdown" => NoizuPromptLingua.Domains.Markdown.MCP,
    "notifications" => NoizuPromptLingua.Domains.Notifications.MCP,
    "pubsub" => NoizuPromptLingua.Domains.PubSub.MCP,
    "browser" => NoizuPromptLingua.Domains.Browser.MCP,
    "customers" => NoizuPromptLingua.Domains.Customers.MCP,
    "market" => NoizuPromptLingua.Domains.Market.MCP,
    "campaigns" => NoizuPromptLingua.Domains.Campaigns.MCP,
    "unicode" => NoizuPromptLingua.Domains.UnicodeCodex.MCP
  }

  @doc "All configured MCP servers."
  def all, do: @servers

  @doc "MCP servers that can be included in custom scopes."
  def customizable do
    Enum.reject(@servers, &(&1.id == "root"))
  end

  @doc """
  Ids of the required core groups that participate in custom/all_in_one scopes.

  Derived from the `required` flag on the catalog, excluding `root` (root is the
  bare-host endpoint and is never a selectable group). These are the groups an
  `all_in_one` scope auto-includes and protects behind the typed-confirm flow.
  """
  def required_ids do
    customizable() |> Enum.filter(& &1.required) |> Enum.map(& &1.id)
  end

  @doc "Resolve a public server id to its MCP server module."
  def server_module(id) when is_binary(id), do: Map.get(@server_modules, id)
  def server_module(_), do: nil

  @doc """
  Resolve the MCP group id (`organizations`, `tickets`, ...) that owns `module`
  — the SERVER module itself (e.g. `NoizuPromptLingua.MCP.Organizations`) or
  any registered tool module beneath it. Tool modules do NOT always share the
  server module's namespace (e.g. `NoizuPromptLingua.Domains.Tickets.Tools.*`
  register on `NoizuPromptLingua.Domains.Tickets.MCP`), so ownership is a
  reverse index over each server's `__mcp__(:tools)` registrations, cached per
  module (`:persistent_term`). Returns `nil` for modules outside every known
  group (root-only tools such as Discovery / NPL cannot be key-gated by group).
  """
  def group_id_for_tool_module(module) when is_atom(module) do
    case :persistent_term.get({__MODULE__, :tool_group, module}, :miss) do
      :miss ->
        group_id = compute_group_id(module)

        if group_id do
          :persistent_term.put({__MODULE__, :tool_group, module}, group_id)
        end

        group_id

      group_id ->
        group_id
    end
  end

  def group_id_for_tool_module(_), do: nil

  defp compute_group_id(module) do
    case module_group_id(module) do
      nil ->
        # A tool module registered under MORE than one group is shared
        # infrastructure (Discovery tools register on every domain server) —
        # ambiguous ownership means ungated, never a guess.
        @server_modules
        |> Enum.filter(fn {_id, server_mod} -> module in registered_tool_modules(server_mod) end)
        |> case do
          [{id, _}] -> id
          _ -> nil
        end

      id ->
        id
    end
  end

  defp module_group_id(candidate) do
    @server_modules
    |> Enum.find(fn {_id, mod} -> mod == candidate end)
    |> case do
      {id, _} -> id
      _ -> nil
    end
  end

  defp registered_tool_modules(server_mod) do
    if Code.ensure_loaded?(server_mod) and function_exported?(server_mod, :__mcp__, 1) do
      server_mod.__mcp__(:tools)
      |> Enum.map(fn {tool_module, _opts} -> tool_module end)
    else
      []
    end
  rescue
    _ -> []
  end

  @doc """
  Returns the MCP servers with full connection URLs, derived from the configured
  `PHX_HOST`. Suitable for JSON serialization to clients building setup commands.

  `packaging` selects the endpoint set (design spec §1):

    * `:default` — full static server list + all custom scopes (unchanged output).
    * `:core_custom` — core-variant endpoint(s) + custom-scope endpoint(s).
    * `:all_in_one` — the all_in_one endpoint(s) + any task-segmented one-offs
      (scopes whose config carries `segment: true`).
    * `:setup` — the signed-in user's default custom endpoint (Tobor Locker
      clone, short uuid handle), falling back to the global `tobor` package
      when no user is present.

  `opts` (`:organization_id`, `:project_id`, `:user_id`) scope the non-default
  packaging sets to global presets plus rows matching the given org/project.
  `:user_id` selects the per-account default for `:setup`.
  """
  def for_host(host, packaging \\ :default, opts \\ [])

  def for_host(nil, packaging, opts), do: for_host(default_host(), packaging, opts)

  def for_host(host, packaging, opts) when is_binary(host) do
    packaging_servers(host, packaging, opts)
  end

  defp packaging_servers(host, :default, _opts) do
    static =
      Enum.map(@servers, fn %{id: id} = s ->
        subdomain = if id == "root", do: host, else: "#{id}.#{host}"
        Map.put(s, :url, "https://#{subdomain}/mcp")
      end)

    custom =
      case list_custom_scopes_safely() do
        {:ok, scopes} ->
          Enum.map(scopes, fn scope ->
            %{
              id: "custom:#{scope.slug}",
              label: "Custom: #{scope.name}",
              required: false,
              desc: scope.description || "Custom MCP include scope",
              url: custom_url(scope.slug, host)
            }
          end)

        {:error, reason} ->
          Logger.warning(
            "[MCPServers] custom scopes unavailable, serving static servers only: #{inspect(reason)}"
          )

          []
      end

    static ++ custom
  end

  defp packaging_servers(host, :core_custom, opts) do
    NoizuPromptLingua.MCPCustomScopes.scopes_for(["core_variant", "custom"], opts)
    |> Enum.map(&scope_entry(&1, host))
  end

  defp packaging_servers(host, :all_in_one, opts) do
    _ = NoizuPromptLingua.MCPCustomScopes.get_default_package()

    scoped =
      NoizuPromptLingua.MCPCustomScopes.scopes_for(["all_in_one", "custom", "core_variant"], opts)

    all = Enum.filter(scoped, &(&1.kind == "all_in_one"))
    segments = Enum.filter(scoped, &segment_scope?/1)

    (all ++ segments)
    |> Enum.uniq_by(& &1.id)
    |> Enum.map(&scope_entry(&1, host))
  end

  defp packaging_servers(host, :setup, opts) do
    [
      opts
      |> setup_scope()
      |> scope_entry(host)
      |> Map.merge(%{required: true, default: true})
    ]
  end

  @doc """
  Scope the setup UI should advertise: the caller's per-account default
  (cloned from Tobor Locker) when `:user_id` is set, otherwise the global
  `tobor` package.
  """
  def setup_scope(opts \\ []) do
    case Keyword.get(opts, :user_id) do
      user_id when is_binary(user_id) and user_id != "" ->
        NoizuPromptLingua.MCPCustomScopes.ensure_account_default(user_id)

      _ ->
        NoizuPromptLingua.MCPCustomScopes.get_default_package()
    end
  end

  @doc """
  Individual subdomain endpoints a user can add a-la-carte on top of the
  default package. Excludes `root` (replaced by the default grouped endpoint).
  """
  def ala_carte(host) when is_binary(host) do
    Enum.map(customizable(), fn %{id: id} = s ->
      Map.put(s, :url, "https://#{id}.#{host}/mcp")
    end)
  end

  def ala_carte(_), do: ala_carte(default_host())

  def scope_entry(scope, host) do
    %{
      id: "custom:#{scope.slug}",
      label: scope_label(scope),
      required: false,
      kind: scope.kind,
      desc: scope.description || "Custom MCP include scope",
      url: custom_url(scope.slug, host)
    }
  end

  # The static server catalog must always be served even if the
  # `mcp_custom_scopes` table is missing or unhealthy — otherwise
  # `/auth/mcp/config` 500s and the client setup panel vanishes silently.
  defp list_custom_scopes_safely do
    {:ok, NoizuPromptLingua.MCPCustomScopes.list()}
  rescue
    e -> {:error, e}
  end

  defp scope_label(%{kind: "core_variant", name: name}), do: "Core: #{name}"
  defp scope_label(%{kind: "all_in_one", name: name}), do: "All-in-One: #{name}"
  defp scope_label(%{name: name}), do: "Custom: #{name}"

  defp segment_scope?(%{config: config}) when is_map(config) do
    Map.get(config, "segment") == true or Map.get(config, :segment) == true
  end

  defp segment_scope?(_), do: false

  def custom_url(slug, nil), do: custom_url(slug, default_host())
  def custom_url(slug, host), do: "https://#{host}/custom/#{slug}/mcp"

  @doc "The default public host (PHX_HOST / endpoint config) used to build URLs."
  def default_host do
    Application.get_env(:noizu_prompt_lingua, NoizuPromptLinguaWeb.Endpoint)
    |> case do
      %{url: %{host: host}} when is_binary(host) and host != "" -> host
      kw when is_list(kw) -> kw |> Keyword.get(:url, []) |> Keyword.get(:host, "localhost")
      _ -> System.get_env("PHX_HOST") || "localhost"
    end
  end
end
