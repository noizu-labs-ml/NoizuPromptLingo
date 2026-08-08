defmodule NoizuPromptLingua.Tools.McpOverview do
  @moduledoc """
  Hidden tool auto-registered on every composite/custom endpoint (like the
  Discovery block). Given what the agent is working on, it returns a task-tailored
  Markdown overview of THIS endpoint's tools — cached + reviewable, recalled by
  task proximity (pgvector). See `Domains.MCPOverview.Service`.
  """
  use Noizu.MCP.Server.Tool,
    name: "mcp_overview",
    description:
      "Describe what you're working on; get a tailored Markdown overview of this " <>
        "endpoint's most relevant tools (with the rest listed briefly). Cached and " <>
        "recalled by task similarity.",
    hidden: true,
    annotations: [read_only_hint: true],
    category: "Discovery"

  input do
    field :task, :string,
      required: true,
      description: "What you're working on — a natural-language description of the current task."

    field :focus, :string,
      description: "Optional extra hint to bias the overview (a subsystem, goal, or constraint)."

    field :verbosity, :integer, description: "Optional detail level 0–9 (0 = tersest)."
  end

  output do
    field :overview_md, :string, required: true, description: "The tailored Markdown overview."

    field :generated, :boolean,
      required: true,
      description: "True if freshly generated (pending review)."

    field :cached, :boolean,
      required: true,
      description: "True if served from a prior recalled overview."
  end

  alias NoizuPromptLingua.Tools.Catalog
  alias NoizuPromptLingua.Domains.MCPOverview.Service

  @impl true
  def call(args, ctx) do
    task = args.task
    server = (ctx && ctx.server) || NoizuPromptLingua.MCP

    specs =
      Catalog.build(server, ctx)
      |> Enum.reject(&(&1.category == "Discovery"))

    opts = [
      focus: Map.get(args, :focus),
      verbosity: Map.get(args, :verbosity),
      runner: runner(ctx),
      model: model(ctx)
    ]

    case Service.overview(scope_slug(ctx), task, specs, opts) do
      {:ok, res} ->
        {:ok, %{overview_md: res.overview_md, generated: res.generated, cached: res.cached}}

      {:error, reason} ->
        {:error, "mcp_overview failed: #{inspect(reason)}"}
    end
  end

  # Custom endpoints carry the scope slug in ctx assigns; the root aggregator uses "root".
  defp scope_slug(%Noizu.MCP.Ctx{assigns: assigns}) do
    assigns[:custom_scope_slug] || assigns["custom_scope_slug"] || "root"
  end

  defp scope_slug(_), do: "root"

  defp runner(%Noizu.MCP.Ctx{assigns: a}), do: a[:runner] || a["runner"]
  defp runner(_), do: nil

  defp model(%Noizu.MCP.Ctx{assigns: a}), do: a[:model] || a["model"]
  defp model(_), do: nil
end
