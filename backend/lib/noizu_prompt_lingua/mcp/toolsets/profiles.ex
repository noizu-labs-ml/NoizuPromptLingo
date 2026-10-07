defmodule NoizuPromptLingua.MCP.Toolsets.Profiles do
  @moduledoc """
  The built-in capability profiles as pure DATA (PRD-N2 FR-2A-8, Decision 4).

  Profiles are VIRTUAL: never backed by `mcp_tool_sets` rows and never seeded —
  their slugs are reserved (see `NoizuPromptLingua.Schema.MCPToolSet`) so no set
  can shadow them. `full` is exactly `MCPServers.customizable()`; the four
  capability profiles (`agent-ops`, `pm-dev`, `content`, `comms`) derive their
  group membership from the compile-time `@profile_groups` annotation registry
  below — membership is CODE, immutable, and a new domain group auto-joins the
  profiles listed in its annotation (a brand-new group id needs one
  `@profile_groups` entry).

  `core` is the restricted starter surface: group-grain like the R1 four, but
  the ONLY profile carrying a per-tool policy (`@profile_tool_policies`, a
  mirror of the core-variant policy in `MCPCustomScopes`). Its slices and
  clones keep just the essential Overview/Get/Create tools per group — every
  other live catalog tool in its groups is stamped disabled (absent = enabled,
  the preset-seeding rule).

  N2a ships profiles as DATA only. N2b (gated on lib PRD-3/PRD-4) adds
  `custom/1`, which turns a profile into an immutable
  `%Noizu.MCP.Toolset.Custom{}` (FR-2B-4, Decision 4: `immutable: true`,
  `tools: %{}` — slicing only, no ops; grants/negotiations never mutate it,
  PRD-3 §4.1, while ACL still applies).

  The `browser` group participates in `full` (it is in `customizable()`) but
  carries no capability-profile annotation, so it appears only in `full`.
  """

  alias Noizu.MCP.Toolset.Custom
  alias NoizuPromptLingua.MCP.ToolSets
  alias NoizuPromptLingua.MCPServers

  @profile_slugs ~w(full agent-ops pm-dev content comms core)

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
    },
    "core" => %{
      label: "Core",
      description:
        "Restricted starter surface — organizations/projects Overview+Get, sessions Create+Overview. Clone to extend."
    }
  }

  # Decision 4 annotation DSL: group_id => [profile_slug]. The registry is the
  # single source of profile membership (excluding `full`, which is always the
  # whole customizable registry). Compile-validated below — an unknown group id
  # or unknown profile slug FAILS COMPILATION (D4: compile-time checks where
  # config must not boot).
  @profile_groups %{
    "organizations" => ["full", "agent-ops", "core"],
    "sessions" => ["full", "agent-ops", "pm-dev", "core"],
    "projects" => ["full", "agent-ops", "pm-dev", "core"],
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

  # Per-group ENABLE allowlists for policy profiles. Group-grain profiles (the
  # R1 four) resolve to EVERY catalog tool in their groups; a profile listed
  # here keeps only the listed tools per group (canonical underscore names) —
  # absent = enabled, so slices and clones stamp `enabled: false` on everything
  # else (`clone_config/1` / `custom/1`). `core` mirrors the restricted
  # core-variant policy in `MCPCustomScopes` (@core_variant_policy) with the
  # W5 always-on Session_Manifest exemption folded into sessions, spelled out
  # so the restricted surface is self-describing.
  @profile_tool_policies %{
    "core" => %{
      "organizations" => ~w(Organization_Overview Organization_Get),
      "projects" => ~w(Project_Overview Project_Get),
      "sessions" => ~w(Session_Create Session_Overview Session_Manifest)
    }
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

  @doc "The profile slugs, canonical order. Feeds the reserved-slug list in the MCPToolSet changeset."
  def slugs, do: @profile_slugs

  @doc """
  Profile DATA for `slug`: `%{slug, label, description, groups, tools}` with
  `groups` the expanded MCP group-id list (`full` = `MCPServers.customizable()`)
  and `tools` the per-group enabled allowlist when the profile carries one
  (nil = group-grain: every catalog tool in `groups`). nil for unknown slugs.
  """
  def get(slug) when slug in @profile_slugs do
    %{slug: slug}
    |> Map.merge(Map.fetch!(@profile_meta, slug))
    |> Map.put(:groups, groups_for(slug))
    |> Map.put(:tools, Map.get(@profile_tool_policies, slug))
  end

  def get(_), do: nil

  @doc "All profiles as DATA, canonical order."
  def all, do: Enum.map(@profile_slugs, &get/1)

  @doc """
  The tool-set config a clone of `slug` starts from (FR-2A-7): every expanded
  group `{"enabled" => true}`. For a policy profile (`core`) each policy group
  also carries its allowlist as per-tool entries — essentials present with the
  default (enabled) config, every other live catalog tool stamped
  `{"enabled" => false}` (absent = enabled; canonical spellings fold their
  dotted aliases). nil for unknown slugs.
  """
  def clone_config(slug) when slug in @profile_slugs do
    profile = get(slug)

    %{"groups" =>
      Map.new(profile.groups, fn group_id ->
        case Map.fetch(profile.tools || %{}, group_id) do
          {:ok, essential} -> {group_id, allowlist_group(group_id, essential)}
          :error -> {group_id, %{"enabled" => true}}
        end
      end)}
  end

  def clone_config(_), do: nil

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

  # Allowlist group config: walk the group's live catalog (Discovery excluded,
  # canonical underscore spellings — the MCPCustomScopes seed vocabulary) and
  # stamp `enabled: false` on every tool outside the essentials.
  defp allowlist_group(group_id, essential) do
    tools =
      group_id
      |> catalog_tool_names()
      |> Map.new(fn name ->
        if name in essential, do: {name, %{}}, else: {name, %{"enabled" => false}}
      end)

    %{"enabled" => true, "tools" => tools}
  end

  # Live catalog tool names for a group — canonical underscore, Discovery
  # excluded (mirror of the core-variant seed walk in MCPCustomScopes).
  defp catalog_tool_names(group_id) do
    case MCPServers.server_module(group_id) do
      module when is_atom(module) and not is_nil(module) ->
        module.__mcp__(:tools)
        |> Noizu.MCP.Server.Features.Tools.expand()
        |> Enum.reject(&discovery_spec?/1)
        |> Enum.map(&NoizuPromptLingua.MCP.ToolNames.canonical(&1.definition.name))
        |> Enum.uniq()

      _ ->
        []
    end
  end

  defp discovery_spec?(spec) do
    ((spec.definition.meta && spec.definition.meta["category"]) || "Uncategorized") == "Discovery"
  end

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

  @doc """
  The profile as an IMMUTABLE, protocol-dispatchable `%Noizu.MCP.Toolset.Custom{}`
  (FR-2B-4): `slug: "profile:<slug>"`, base = the root aggregate
  (`UniverseToolset` — no single server module covers a profile's universe),
  `include` = the expanded universe allowlist. Group-grain profiles carry
  `tools: %{}` (Decision 4: slicing only — profiles carry NO override ops, so
  grant layers skip them while the ACL layer still applies); a policy profile
  (`core`) assembles through `ToolSets.assemble_config_custom/2` so its
  allowlist flattens into the static layer — non-essential group tools go
  invisible + non-callable — while the immutability semantics stay intact.
  Accepts the `get/1` DATA map or a slug.
  """
  def custom(slug) when slug in @profile_slugs do
    profile = get(slug)

    case profile.tools do
      nil ->
        %Custom{
          slug: "profile:#{profile.slug}",
          base: NoizuPromptLingua.MCP.UniverseToolset,
          title: profile.label,
          description: profile.description,
          immutable: true,
          include: ToolSets.universe_include(profile.groups),
          exclude: [],
          tools: %{},
          metadata: %{profile: profile.slug}
        }

      _policy ->
        ToolSets.assemble_config_custom(clone_config(slug),
          slug: "profile:#{profile.slug}",
          title: profile.label,
          description: profile.description,
          immutable: true,
          metadata: %{profile: profile.slug}
        )
    end
  end

  def custom(%{slug: slug}), do: custom(slug)
  def custom(_), do: nil
end
