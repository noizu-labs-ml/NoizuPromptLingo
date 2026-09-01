defmodule NoizuPromptLingua.MCP.Toolsets.Profiles do
  @moduledoc """
  The 5 built-in capability profiles as pure DATA (PRD-N2 FR-2A-8, Decision 4).

  Profiles are VIRTUAL: never backed by `mcp_tool_sets` rows and never seeded —
  their slugs are reserved (see `NoizuPromptLingua.Schema.MCPToolSet`) so no set
  can shadow them. `full` is exactly `MCPServers.customizable()`; the four
  capability profiles (`agent-ops`, `pm-dev`, `content`, `comms`) derive their
  group membership from the compile-time `@profile_groups` annotation registry
  below — membership is CODE, immutable, and a new domain group auto-joins the
  profiles listed in its annotation (a brand-new group id needs one
  `@profile_groups` entry).

  N2a ships profiles as DATA only. N2b (gated on lib PRD-3/PRD-4) adds
  `custom/1`, which turns a profile into an immutable
  `%Noizu.MCP.Toolset.Custom{}` — the seam is deliberately not built here.

  The `browser` group participates in `full` (it is in `customizable()`) but
  carries no capability-profile annotation, so it appears only in `full`.
  """

  alias NoizuPromptLingua.MCPServers

  @profile_slugs ~w(full agent-ops pm-dev content comms)

  @profile_meta %{
    "full" => %{
      label: "Full Access",
      description: "Every customizable MCP group — the complete surface."
    },
    "agent-ops" => %{
      label: "Agent Operations",
      description: "Org, project, session, notification and memory tooling for autonomous agents."
    },
    "pm-dev" => %{
      label: "Project Management & Dev",
      description:
        "Tickets, review, GitHub, instructions, sessions and projects for PM/dev workflows."
    },
    "content" => %{
      label: "Content",
      description:
        "Artifacts, assets, wiki, markdown, market, campaigns, customers and unicode tooling."
    },
    "comms" => %{
      label: "Communications",
      description: "Chat, notifications, pubsub, personas, memory and wiki tooling."
    }
  }

  # Decision 4 annotation DSL: group_id => [profile_slug]. The registry is the
  # single source of profile membership (excluding `full`, which is always the
  # whole customizable registry). Compile-validated below — an unknown group id
  # or unknown profile slug FAILS COMPILATION (D4: compile-time checks where
  # config must not boot).
  @profile_groups %{
    "organizations" => ["full", "agent-ops"],
    "sessions" => ["full", "agent-ops", "pm-dev"],
    "projects" => ["full", "agent-ops", "pm-dev"],
    "notifications" => ["full", "agent-ops", "comms"],
    "memory" => ["full", "agent-ops", "comms"],
    "tickets" => ["full", "pm-dev"],
    "review" => ["full", "pm-dev"],
    "github" => ["full", "pm-dev"],
    "instructions" => ["full", "pm-dev"],
    "artifacts" => ["full", "content"],
    "assets" => ["full", "content"],
    "wiki" => ["full", "content", "comms"],
    "markdown" => ["full", "content"],
    "market" => ["full", "content"],
    "campaigns" => ["full", "content"],
    "customers" => ["full", "content"],
    "unicode" => ["full", "content"],
    "chat" => ["full", "comms"],
    "pubsub" => ["full", "comms"],
    "personas" => ["full", "comms"]
  }

  defp customizable_ids, do: MCPServers.customizable() |> Enum.map(& &1.id)

  @doc """
  Validate a `@profile_groups`-shaped registry against the customizable group
  ids and the profile slug list. Raises ArgumentError naming the first offender.
  Called from this module's body at compile time (Decision 4) and by the
  negative compile-check test.
  """
  def validate_registry!(registry, valid_group_ids, valid_slugs) when is_map(registry) do
    Enum.each(registry, fn {group_id, slugs} ->
      unless group_id in valid_group_ids do
        raise ArgumentError,
              "Profiles @profile_groups: unknown MCP group id #{inspect(group_id)} — " <>
                "must be one of MCPServers.customizable() ids"
      end

      Enum.each(List.wrap(slugs), fn slug ->
        unless slug in valid_slugs do
          raise ArgumentError,
                "Profiles @profile_groups: unknown profile slug #{inspect(slug)} for group " <>
                  "#{inspect(group_id)} — must be one of #{inspect(valid_slugs)}"
        end
      end)
    end)

    :ok
  end

  # Compile-time registry validation (Decision 4): raising from @after_compile
  # fails the compilation of this module, so a bad annotation can never boot
  # (D4: compile-time checks where config must not boot). Module-body local
  # calls cannot resolve own functions, hence the hook.
  @after_compile __MODULE__

  def __after_compile__(_env, _bytecode) do
    validate_registry!(@profile_groups, customizable_ids(), @profile_slugs)
  end

  @doc "The 5 profile slugs, canonical order. Feeds the reserved-slug list in the MCPToolSet changeset."
  def slugs, do: @profile_slugs

  @doc """
  Profile DATA for `slug`: `%{slug, label, description, groups}` with `groups`
  the expanded MCP group-id list (`full` = `MCPServers.customizable()`). nil for
  unknown slugs.
  """
  def get(slug) when slug in @profile_slugs do
    %{slug: slug}
    |> Map.merge(Map.fetch!(@profile_meta, slug))
    |> Map.put(:groups, groups_for(slug))
  end

  def get(_), do: nil

  @doc "All 5 profiles as DATA, canonical order."
  def all, do: Enum.map(@profile_slugs, &get/1)

  @doc """
  Expanded group ids for a profile slug: `full` = `MCPServers.customizable()`
  (registry order); capability profiles = every group annotated with that slug
  (annotation order). Unknown slug => [].
  """
  def groups_for("full"), do: customizable_ids()

  def groups_for(slug) when is_binary(slug) do
    Enum.flat_map(@profile_groups, fn {group_id, slugs} ->
      if slug in slugs, do: [group_id], else: []
    end)
  end

  def groups_for(_), do: []

  @doc """
  Inverse of the annotation registry: group_id => [profile_slug], `full`
  prepended (it covers every customizable group). Unknown / non-customizable
  group => [].
  """
  def groups_for_tool(group_id) do
    slugs =
      case Map.fetch(@profile_groups, group_id) do
        {:ok, slugs} -> ["full" | Enum.reject(slugs, &(&1 == "full"))]
        :error -> ["full"]
      end

    if group_id in customizable_ids(), do: slugs, else: []
  end
end
