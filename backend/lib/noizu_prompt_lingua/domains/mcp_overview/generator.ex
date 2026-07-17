defmodule NoizuPromptLingua.Domains.MCPOverview.Generator do
  @moduledoc """
  Composes a task-focused Markdown overview of a scope's tools.

  It ranks the scope's tools by proximity to the task vector (via
  `mcp_tool_vectors`), splits them into `near` (get depth) and `far` (a one-liner),
  builds a render `context`, and delegates the actual prose to a **config-selected
  adapter** implementing the `generate_overview/2` behaviour:

    * `Generator.LLM`  — default; drives the same GenAI client/provider config as
      the `mock_mcp` domain (`MockMCP.Models.resolve/3` default model).
    * `Generator.Stub` — deterministic, network-free; used by tests via
      `config :noizu_prompt_lingua, :mcp_overview, generator: ...Generator.Stub`.
  """

  @callback generate_overview(task :: String.t(), context :: map()) ::
              {:ok, String.t()} | {:error, term()}

  alias NoizuPromptLingua.Domains.MCPOverview.Store

  # How many nearest tools get depth in the overview; the rest are one-liners.
  @default_focus_count 8

  @doc "The configured overview-generation adapter (default `Generator.LLM`)."
  def adapter do
    Application.get_env(:noizu_prompt_lingua, :mcp_overview, [])[:generator] || __MODULE__.LLM
  end

  defp focus_count do
    Application.get_env(:noizu_prompt_lingua, :mcp_overview, [])[:focus_count] || @default_focus_count
  end

  @doc """
  Build a focused overview for `scope_slug`. `task_vec` may be `nil` (embeddings
  unconfigured) → an unfocused overview covering all `specs`. Returns
  `{:ok, markdown}` | `{:error, term}`.
  """
  def build(scope_slug, task, task_vec, specs, opts \\ []) do
    context = focus_context(scope_slug, task, task_vec, specs, opts)
    adapter().generate_overview(task, context)
  end

  @doc """
  Rank `specs` by task proximity and produce the render context
  (`%{scope_slug, focus, verbosity, runner, model, near: [...], far: [...]}`).
  Exposed for tests + adapters.
  """
  def focus_context(scope_slug, task, task_vec, specs, opts \\ []) do
    by_name = Map.new(specs, &{&1.name, &1})

    ranking =
      if task_vec, do: Store.nearest_tool_vectors(scope_slug, task_vec, limit: 1000), else: []

    {near, far} = partition(specs, ranking, by_name)

    %{
      scope_slug: scope_slug,
      task: task,
      focus: opts[:focus],
      verbosity: opts[:verbosity],
      runner: opts[:runner],
      model: opts[:model],
      near: near,
      far: far
    }
  end

  # No proximity signal (unindexed / no embeddings): everything is "near" with its
  # description, ordered by name — an unfocused but complete overview.
  defp partition(specs, [], _by_name) do
    {Enum.sort_by(specs, & &1.name) |> Enum.map(&entry(&1, nil)), []}
  end

  defp partition(specs, ranking, by_name) do
    ranked_names = Enum.map(ranking, & &1.tool_name)
    dist_by_name = Map.new(ranking, &{&1.tool_name, &1.distance})

    # Nearest `focus_count` (that exist in this spec set) get depth.
    near_names =
      ranked_names
      |> Enum.filter(&Map.has_key?(by_name, &1))
      |> Enum.take(focus_count())

    near_set = MapSet.new(near_names)

    near =
      Enum.map(near_names, fn name ->
        entry(by_name[name], Map.get(dist_by_name, name))
      end)

    far =
      specs
      |> Enum.reject(&MapSet.member?(near_set, &1.name))
      |> Enum.sort_by(& &1.name)
      |> Enum.map(&entry(&1, Map.get(dist_by_name, &1.name)))

    {near, far}
  end

  defp entry(spec, distance) do
    %{
      name: spec.name,
      group: Map.get(spec, :category) || "Uncategorized",
      description: Map.get(spec, :description) || "",
      distance: distance
    }
  end

  # ── Adapters ───────────────────────────────────────────────────────────────

  defmodule Stub do
    @moduledoc "Deterministic, network-free overview generator (tests/CI)."
    @behaviour NoizuPromptLingua.Domains.MCPOverview.Generator

    @impl true
    def generate_overview(task, context) do
      near =
        context.near
        |> Enum.map(fn t -> "- **#{t.name}** (#{t.group}): #{t.description}" end)
        |> Enum.join("\n")

      far =
        context.far
        |> Enum.map(fn t -> "- `#{t.name}`" end)
        |> Enum.join("\n")

      md =
        """
        # MCP Overview

        **Task:** #{task}#{focus_line(context.focus)}

        ## Most relevant tools
        #{if near == "", do: "_none_", else: near}
        """ <>
          if(far == "", do: "", else: "\n## Other tools\n#{far}\n")

      {:ok, String.trim(md) <> "\n"}
    end

    defp focus_line(nil), do: ""
    defp focus_line(""), do: ""
    defp focus_line(focus), do: "\n**Focus:** #{focus}"
  end

  defmodule LLM do
    @moduledoc """
    LLM-backed overview generator. Uses the GenAI client + default provider/model
    that the `mock_mcp` domain uses (`MockMCP.Models.resolve/3`).
    """
    @behaviour NoizuPromptLingua.Domains.MCPOverview.Generator
    alias NoizuPromptLingua.Domains.MockMCP.Models

    @system """
    You are documenting an MCP (Model Context Protocol) endpoint for an AI agent.
    Given the agent's current TASK and the endpoint's available tools — split into
    "most relevant" (closest to the task) and "other" — write a concise Markdown
    overview. Give the most-relevant tools real depth (what they do, when to reach
    for them, how they combine for this task); list the rest as brief one-liners.
    Return ONLY Markdown, no preamble or code fences.
    """

    @impl true
    def generate_overview(task, context) do
      messages = [
        GenAI.Message.system(@system),
        GenAI.Message.user(user_prompt(task, context))
      ]

      # App-default provider/model — the same GenAI path mock_mcp uses when a
      # definition has no active LLM connection (`Models.resolve/3` with nils).
      GenAI.chat()
      |> GenAI.with_model(Models.resolve(nil, nil, nil))
      |> GenAI.with_messages(messages)
      |> GenAI.run()
      |> case do
        {:ok, completion} ->
          case extract(completion) do
            nil -> {:error, {:unexpected_response, completion}}
            text -> {:ok, String.trim(text)}
          end

        {:error, reason} ->
          {:error, reason}

        other ->
          {:error, {:unexpected_response, other}}
      end
    end

    defp user_prompt(task, context) do
      focus = if context[:focus] in [nil, ""], do: "", else: "\nFocus hint: #{context.focus}"

      near =
        context.near
        |> Enum.map(fn t -> "- #{t.name} [#{t.group}]: #{t.description}" end)
        |> Enum.join("\n")

      far =
        context.far
        |> Enum.map(fn t -> "- #{t.name} [#{t.group}]: #{t.description}" end)
        |> Enum.join("\n")

      """
      TASK: #{task}#{focus}

      MOST RELEVANT TOOLS:
      #{if near == "", do: "(none)", else: near}

      OTHER TOOLS:
      #{if far == "", do: "(none)", else: far}
      """
    end

    defp extract(%{choices: [choice | _]}) do
      case choice[:message] || Map.get(choice, :message) do
        %{content: content} when is_binary(content) -> content
        %{content: content} when is_list(content) -> flatten_content(content)
        _ -> nil
      end
    end

    defp extract(_), do: nil

    defp flatten_content(content) do
      content
      |> Enum.map(fn
        t when is_binary(t) -> t
        %{text: t} when is_binary(t) -> t
        _ -> ""
      end)
      |> Enum.join("")
    end
  end
end
