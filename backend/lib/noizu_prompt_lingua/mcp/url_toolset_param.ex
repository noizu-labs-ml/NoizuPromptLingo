defmodule NoizuPromptLingua.MCP.UrlToolsetParam do
  @moduledoc """
  The `?t=` URL tool-selection parameter for custom-scope MCP gateways
  (alacarte): base64url(JSON) decoded once at MCP initialize and compiled into
  a synthesized toolset layer that is merged into the CLIENT layer of the
  `EffectiveToolset` cascade (`[client(+param), scope]`) — param wins per key.

  The param NEVER changes the include set — the scope's groups govern which
  tools exist (entries outside that universe are dead) — it only flips per-tool
  flags within it. The ACL pass still runs last and cannot be bypassed.

  ## Parameter shape (strict)

      {
        "white-list": {"Tool_Name": true | false | {"visible": bool}},
        "black-list": {"Tool_Name": true | false | {"visible": bool}},
        "tools":      {"Tool_Name": true | false | {"visible": bool}},
        "default":    true | "basic_crud" | "core" | "full"
      }

  All keys optional; unknown top-level keys are REJECTED (fail-closed). The
  `white-list`/`black-list` sections also accept snake_case spellings
  (`white_list`/`black_list`) — normalized to kebab-case BEFORE validation
  (snake_case is the JSON convention most generators emit; kebab-case stays
  canonical). Presenting BOTH spellings of a section is ambiguous and rejected.

  ## Precedence (compile)

    1. `white-list` + `default` define the ENABLE SET — every universe tool
       absent from the set is stamped `disabled: true`; tools IN the set are
       stamped `disabled: false` (so a white-list re-enables a scope-disabled
       tool). A white-list pick also stamps `hidden: false` — the selection is
       what tools/list shows (statically-hidden flags are overridden) — while
       default-expansion members keep their current visibility. Empty/absent
       white-list with a `default` present still constrains.
    2. `black-list` disables — and loses entirely to a white-list (when one is
       present, set membership already decided).
    3. `white-list` entry `visible` flags (`{"visible": false}` = enabled but
       hidden from listings).
    4. `tools` map, lowest: `visible: true` re-enables a stored-disabled tool
       (stamps `disabled: false` + `hidden: false`) ONLY when no white-list /
       default constrains the enable set — it can never smuggle a tool into a
       constrained set. `visible: false` always hides.

  `default` expands the enable set: `true` = the endpoint's stored-enabled
  tools; a preset slug = that preset's tool set
  (`MCPCustomScopes.preset_tool_sets/1`); unknown preset = error. With a
  white-list also present, the expansions UNION.

  Universe: the scope's included (non-group-disabled) groups' live catalog
  tools, Discovery excluded, canonical underscore names. Entries outside the
  universe are dead.

  Registration-level visibility is out of the param's reach: a tool registered
  `hidden: true` (e.g. Session_List, Session_Archive) is kept off listings by
  the no-op default-state contract, the same way no client `toolset_config` can
  un-hide it today. A white-listed such tool is ENABLED (dispatchable) but not
  listed; the admin un-hides it at the scope/registration level instead.

  ## Errors (fail-closed)

  Absent param (`nil`/empty) = byte-identical current behavior (`:absent`).
  Everything else that does not cleanly decode → `{:error, reason}` for the
  gateway's HTTP 400 BEFORE the transport session starts: >12_000 raw chars,
  non-base64url charset, bad base64, >8_192 decoded bytes, non-JSON,
  schema-invalid shape, unknown preset.
  """

  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.MCPServers
  alias NoizuPromptLingua.MCP.ToolNames

  @max_raw_chars 12_000
  @max_decoded_bytes 8_192
  @charset ~r/^[A-Za-z0-9_-]*={0,2}$/
  @allowed_top_keys ~w(white-list black-list tools default)
  # snake_case spellings normalize to their kebab-case canonical keys BEFORE
  # shape validation; presenting both spellings of a section is rejected.
  @section_aliases %{"white_list" => "white-list", "black_list" => "black-list"}

  @type spec :: %{optional(String.t()) => term()}

  @type error ::
          :too_large
          | :invalid_charset
          | :invalid_base64
          | :invalid_json
          | :too_large_decoded
          | {:invalid_shape, String.t()}
          | {:unknown_preset, String.t()}

  @doc """
  Decode the raw `?t=` query parameter. `:absent` (nil/empty) means "no
  parameter" — byte-identical behavior. Structural failures return
  `{:error, reason}`; semantic checks (preset names) happen in `compile/2`.
  """
  @spec decode(term()) :: :absent | {:ok, spec()} | {:error, error()}
  def decode(nil), do: :absent
  def decode(""), do: :absent

  def decode(param) when is_binary(param) do
    cond do
      String.length(param) > @max_raw_chars ->
        {:error, :too_large}

      not Regex.match?(@charset, param) ->
        {:error, :invalid_charset}

      true ->
        with {:ok, json} <- url_decode(param),
             :ok <- decoded_size_guard(json),
             {:ok, body} <- json_decode(json),
             {:ok, body} <- normalize_aliases(body) do
          validate_shape(body)
        end
    end
  end

  def decode(_), do: {:error, {:invalid_shape, "parameter must be a string"}}

  # base64url without padding is the wire form; padded input (the `={0,2}`
  # charset allowance) re-pads through the padded decoder.
  defp url_decode(param) do
    case Base.url_decode64(param, padding: false) do
      {:ok, json} ->
        {:ok, json}

      :error ->
        case Base.url_decode64(param, padding: true) do
          {:ok, json} -> {:ok, json}
          :error -> {:error, :invalid_base64}
        end
    end
  end

  defp decoded_size_guard(json) when byte_size(json) <= @max_decoded_bytes, do: :ok
  defp decoded_size_guard(_), do: {:error, :too_large_decoded}

  defp json_decode(json) do
    case Jason.decode(json) do
      {:ok, %{} = body} -> {:ok, body}
      {:ok, _} -> {:error, {:invalid_shape, "must be a JSON object"}}
      {:error, _} -> {:error, :invalid_json}
    end
  end

  # AMENDMENT: `white_list`/`black_list` aliases fold into their kebab-case
  # canonical keys before shape validation, so both spellings decode to the
  # SAME spec (golden-vector tested). Both spellings at once is ambiguous —
  # fail closed rather than pick a winner by merge order.
  defp normalize_aliases(body) do
    conflicts =
      for {alias, canonical} <- @section_aliases,
          Map.has_key?(body, alias) and Map.has_key?(body, canonical) do
        {alias, canonical}
      end

    case conflicts do
      [] ->
        {:ok, Map.new(body, fn {key, value} -> {Map.get(@section_aliases, key, key), value} end)}

      [{alias, canonical} | _] ->
        {:error,
         {:invalid_shape, "ambiguous key: both \"#{alias}\" and \"#{canonical}\" present"}}
    end
  end

  # Strict shape: only the four known top-level keys; list/tools entries must
  # be booleans or `{"visible": bool}`; default must be true or a preset slug.
  defp validate_shape(%{} = spec) do
    unknown = Map.keys(spec) -- @allowed_top_keys

    if unknown == [] do
      validate_sections(spec)
    else
      {:error, {:invalid_shape, "unknown key(s): #{unknown |> Enum.sort() |> Enum.join(", ")}"}}
    end
  end

  defp validate_sections(spec) do
    with :ok <- validate_map_section(spec, "white-list"),
         :ok <- validate_map_section(spec, "black-list"),
         :ok <- validate_map_section(spec, "tools"),
         :ok <- validate_default(spec) do
      {:ok, spec}
    end
  end

  defp validate_map_section(spec, key) do
    case Map.get(spec, key) do
      nil ->
        :ok

      entries when is_map(entries) ->
        bad? =
          Enum.any?(entries, fn {name, entry} ->
            not is_binary(name) or name == "" or not valid_entry?(entry)
          end)

        if bad? do
          {:error,
           {:invalid_shape, "#{key} entries must be true, false, or {\"visible\": boolean}"}}
        else
          :ok
        end

      _ ->
        {:error, {:invalid_shape, "#{key} must be an object"}}
    end
  end

  defp valid_entry?(entry) when is_boolean(entry), do: true

  defp valid_entry?(%{} = entry) do
    case Map.to_list(entry) do
      [] -> true
      [{"visible", visible}] when is_boolean(visible) -> true
      _ -> false
    end
  end

  defp valid_entry?(_), do: false

  defp validate_default(spec) do
    case Map.get(spec, "default") do
      nil -> :ok
      true -> :ok
      slug when is_binary(slug) and slug != "" -> :ok
      _ -> {:error, {:invalid_shape, "default must be true or a preset name"}}
    end
  end

  @doc """
  Compile a decoded spec into the synthesized toolset layer — the same
  `%{"groups" => %{gid => %{"tools" => %{tool => flags}}}}` shape as a stored
  config — bounded by `scope`'s included groups. `{:error, {:unknown_preset,
  slug}}` for an unknown `default` preset.
  """
  @spec compile(spec(), NoizuPromptLingua.Schema.MCPCustomScope.t() | map() | nil) ::
          {:ok, map()} | {:error, error()}
  def compile(spec, scope) when is_map(spec) do
    # Idempotent second pass: decode already normalized (and validated) the
    # spec, but compile is also callable directly — spelling-agnostic there too.
    with {:ok, spec} <- normalize_aliases(spec),
         {:ok, expansion} <- resolve_default(Map.get(spec, "default"), scope) do
      {:ok, layer(spec, scope, expansion)}
    end
  end

  defp resolve_default(nil, _scope), do: {:ok, nil}
  defp resolve_default(true, scope), do: {:ok, {:stored, scope}}

  defp resolve_default(slug, _scope) when is_binary(slug) do
    case MCPCustomScopes.preset_tool_sets(slug) do
      {:ok, sets} -> {:ok, {:preset, sets}}
      _ -> {:error, {:unknown_preset, slug}}
    end
  end

  defp resolve_default(_, _scope), do: {:error, {:invalid_shape, "invalid default"}}

  # ── layer assembly (the precedence algorithm) ───────────────────────────────

  defp layer(spec, scope, expansion) do
    {_groups, universe, stored_enabled} = compile_context(scope)

    # F5: param tool names accept the dotted alias form — normalize to the
    # canonical underscore form used by the universe (later duplicate keys win).
    white = canonical_section(map_section(spec, "white-list"))
    black = canonical_section(map_section(spec, "black-list"))
    tools = canonical_section(map_section(spec, "tools"))

    white? = Map.has_key?(spec, "white-list")
    constrained? = white? or Map.has_key?(spec, "default")

    white_set = if white?, do: white_enabled(white, universe), else: MapSet.new()
    default_set = default_expansion(expansion, universe, stored_enabled)

    layer_groups =
      Map.new(universe, fn {gid, names} ->
        entries =
          Map.new(names, fn name ->
            # (1) enable-set opinion. A white-list pick implies VISIBILITY — the
            # selection is what tools/list shows (statically-hidden flags are
            # overridden) — while a default-expansion member keeps its current
            # visibility. Absent-from-set → disabled.
            flags =
              cond do
                not constrained? ->
                  %{}

                MapSet.member?(white_set, name) ->
                  %{"disabled" => false, "hidden" => false}

                MapSet.member?(default_set, name) ->
                  %{"disabled" => false}

                true ->
                  %{"disabled" => true}
              end

            flags =
              flags
              # (2) black-list — loses entirely when a white-list is present.
              |> apply_black_list(black, white?, name)
              # (3) white-list entry visible flags.
              |> apply_white_visible(white, name)
              # (4) tools map, lowest.
              |> apply_tools_visible(tools, constrained?, name)

            {name, flags}
          end)

        {gid, %{"tools" => entries}}
      end)

    %{"groups" => layer_groups}
  end

  defp default_expansion(expansion, universe, stored_enabled) do
    case expansion do
      {:stored, _scope} -> stored_enabled
      # presets expand to a FLAT enabled-name set over all their groups —
      # bounded by the universe by intersection
      {:preset, sets} -> MapSet.intersection(sets, universe_names(universe))
      _ -> MapSet.new()
    end
  end

  defp universe_names(universe),
    do: universe |> Enum.flat_map(fn {_gid, names} -> names end) |> MapSet.new()

  defp map_section(spec, key) do
    case Map.get(spec, key) do
      entries when is_map(entries) -> entries
      _ -> %{}
    end
  end

  defp canonical_section(entries),
    do: Map.new(entries, fn {name, entry} -> {ToolNames.canonical(name), entry} end)

  # (2) black-list — loses entirely when a white-list is present.
  defp apply_black_list(flags, black, false, name) do
    if Map.get(black, name) == true, do: Map.put(flags, "disabled", true), else: flags
  end

  defp apply_black_list(flags, _black, true, _name), do: flags

  # (3) white-list entry visible flags — only `{"visible": bool}` carries one.
  defp apply_white_visible(flags, white, name) do
    case Map.get(white, name) do
      %{"visible" => visible} when is_boolean(visible) ->
        Map.put(flags, "hidden", not visible)

      _ ->
        flags
    end
  end

  # (4) tools map, lowest — visible re-enables stored-disabled ONLY when no
  # enable-set constraint exists; visible:false always hides.
  defp apply_tools_visible(flags, tools, constrained?, name) do
    case entry_visible(Map.get(tools, name)) do
      nil ->
        flags

      true when constrained? ->
        # a constrained enable set cannot be re-entered via the tools map
        flags

      true ->
        flags |> Map.put("disabled", false) |> Map.put("hidden", false)

      false ->
        Map.put(flags, "hidden", true)
    end
  end

  # tools-map entries: `true` ≡ {"visible": true}; `false` ≡ {"visible": false}.
  defp entry_visible(true), do: true
  defp entry_visible(false), do: false
  defp entry_visible(%{"visible" => visible}) when is_boolean(visible), do: visible
  defp entry_visible(_), do: nil

  # white-list entries: everything EXCEPT an explicit `false` is in the set
  # (`true` and `{"visible": ...}` both enable; `visible: false` is
  # enabled-but-hidden).
  defp white_enabled(white, universe) do
    universe
    |> Enum.flat_map(fn {_gid, names} -> names end)
    |> Enum.filter(&(Map.get(white, &1) != nil and Map.get(white, &1) != false))
    |> MapSet.new()
  end

  # ── universe (bounded-by-groups is automatic) ────────────────────────────────

  # Returns {normalized groups, universe (%{gid => [canonical tool names]}),
  # stored-enabled set (universe tools whose stored entry is not disabled)}.
  # The param never widens this — group-disabled groups contribute nothing.
  defp compile_context(scope) do
    {config, kind} = {scope_config_of(scope), scope_kind(scope)}

    groups =
      try do
        # scope_config_of/1 already guarantees a map (non-maps folded to %{}).
        MCPCustomScopes.normalize_config(config, kind)
        |> Map.get("groups") || %{}
      rescue
        _ -> %{}
      end

    universe =
      Map.new(groups, fn {gid, gcfg} ->
        names =
          case gcfg do
            %{"disabled" => true} -> []
            _ -> group_catalog(gid)
          end

        {gid, names}
      end)

    {groups, universe, stored_enabled(groups, universe)}
  end

  defp scope_config_of(scope) do
    case scope do
      %{config: config} -> if(is_map(config), do: config, else: %{})
      %{"config" => config} -> if(is_map(config), do: config, else: %{})
      _ -> %{}
    end
  end

  defp scope_kind(scope) do
    case scope do
      %{kind: kind} when is_binary(kind) -> kind
      %{"kind" => kind} when is_binary(kind) -> kind
      _ -> "custom"
    end
  end

  defp stored_enabled(groups, universe) do
    universe
    |> Enum.flat_map(fn {gid, names} ->
      tools = get_in(groups, [gid, "tools"]) || %{}

      Enum.filter(names, fn name ->
        entry = Map.get(tools, name) || Map.get(tools, ToolNames.dotted(name)) || %{}
        Map.get(entry, "disabled") != true
      end)
    end)
    |> MapSet.new()
  end

  defp group_catalog(gid) do
    case MCPServers.server_module(gid) do
      module when is_atom(module) and not is_nil(module) ->
        if Code.ensure_loaded?(module) and function_exported?(module, :__mcp__, 1) do
          module.__mcp__(:tools)
          |> Noizu.MCP.Server.Features.Tools.expand()
          |> Enum.reject(&discovery_spec?/1)
          |> Enum.map(&ToolNames.canonical(&1.definition.name))
          |> Enum.uniq()
        else
          []
        end

      _ ->
        []
    end
  end

  defp discovery_spec?(spec) do
    ((spec.definition.meta && spec.definition.meta["category"]) || "Uncategorized") == "Discovery"
  end
end
