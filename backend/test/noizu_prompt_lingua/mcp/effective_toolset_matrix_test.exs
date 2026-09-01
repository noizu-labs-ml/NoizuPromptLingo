defmodule NoizuPromptLingua.MCP.EffectiveToolsetMatrixTest do
  @moduledoc """
  Old-vs-new snapshot matrix (F2 spec test case 9): runs the LEGACY resolution
  composition (`KeyToolsets.overlay/2` + `state_from_config/3`, group-disabled =>
  absent, keys never add groups) and the NEW `EffectiveToolset.resolve/4` cascade
  over a fixture matrix (scope kinds × key configs) and asserts identical
  listing + execution decisions — invariants I1–I10 encoded.
  """

  use NoizuPromptLingua.DataCase

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.Tools
  alias NoizuPromptLingua.MCP.EffectiveToolset
  alias NoizuPromptLingua.MCP.KeyToolsets
  alias NoizuPromptLingua.MCP.ToolNames
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.MCPServers

  @group "tickets"
  @tool_hidden "Ticket.List"
  @tool_plain "Ticket.Get"

  # ── fixture matrix ──────────────────────────────────────────────────────────

  # Keyed fixtures (fetch by key via scope/1) — never Enum.at/position.
  defp scopes do
    [
      flags:
        {"custom:flags",
         %{
           "groups" => %{
             @group => %{
               "tools" => %{
                 @tool_hidden => %{"hidden" => true},
                 @tool_plain => %{"disabled" => true}
               }
             }
           }
         }, "custom"},
      group_disabled:
        {"custom:group-disabled",
         %{"groups" => %{"chat" => %{"disabled" => true}, @group => %{}}}, "custom"},
      empty: {"custom:empty", %{"groups" => %{}}, "custom"},
      all_in_one_empty: {"all_in_one:empty", %{}, "all_in_one"},
      all_in_one_confirmed:
        {"all_in_one:confirmed-disable",
         %{
           "groups" => %{
             hd(MCPServers.required_ids()) => %{
               "disabled" => true,
               "confirmed" => true,
               "disabled_confirmed_at" => "2026-01-01T00:00:00Z"
             }
           }
         }, "all_in_one"}
    ]
  end

  defp scope(key), do: Keyword.fetch!(scopes(), key)

  defp keys do
    [
      {"key:none", nil},
      {"key:group-hidden", %{"groups" => %{@group => %{"hidden" => true}}}},
      {"key:tool-disabled",
       %{
         "groups" => %{
           @group => %{"tools" => %{@tool_hidden => %{"hidden" => false}}}
         }
       }},
      {"key:foreign-group", %{"groups" => %{"sessions" => %{"disabled" => true}}}}
    ]
  end

  # ── the legacy composition (pre-refactor semantics, spec §1.2) ─────────────

  # %{canonical_name => %{listed: boolean, callable: boolean}}
  defp legacy_decisions(scope_cfg, kind, key_cfg) do
    scope_norm = MCPCustomScopes.normalize_config(scope_cfg || %{}, kind)
    merged = if key_cfg, do: KeyToolsets.overlay(scope_norm, key_cfg), else: scope_norm

    merged["groups"]
    |> Enum.flat_map(fn {gid, gcfg} ->
      names = group_tool_names(gid)

      cond do
        names == [] ->
          []

        gcfg["disabled"] == true ->
          # group absent — contributes zero specs
          Enum.map(names, fn name ->
            {ToolNames.canonical(name), %{listed: false, callable: false}}
          end)

        true ->
          Enum.map(names, fn name ->
            %{disabled: d, hidden: h} = KeyToolsets.state_from_config(merged, gid, name)
            {ToolNames.canonical(name), %{listed: not (d or h), callable: not d}}
          end)
      end
    end)
    |> Map.new()
  end

  defp group_tool_names(gid) do
    case MCPServers.server_module(gid) do
      module when is_atom(module) and not is_nil(module) ->
        module.__mcp__(:tools)
        |> Tools.expand()
        |> Enum.reject(&(category(&1) == "Discovery"))
        |> Enum.map(& &1.definition.name)

      _ ->
        []
    end
  end

  defp category(spec),
    do: (spec.definition.meta && spec.definition.meta["category"]) || "Uncategorized"

  defp new_decisions(scope_cfg, kind, key_cfg) do
    scope = %{"config" => scope_cfg, "kind" => kind}
    client = if key_cfg, do: %{id: "k1", kind: :api_key, toolset_config: key_cfg}, else: nil

    EffectiveToolset.resolve(scope, client, nil)
    |> Map.new(fn {name, ts} ->
      {name, %{listed: ts.visible and ts.enabled, callable: ts.enabled}}
    end)
  end

  # ── the matrix (I1 + I2) ────────────────────────────────────────────────────

  describe "old vs new snapshot matrix" do
    test "listing + execution decisions identical across scope kinds × key configs" do
      for {_key, {scope_tag, cfg, kind}} <- scopes(), {key_tag, key} <- keys() do
        legacy = legacy_decisions(cfg, kind, key)
        new = new_decisions(cfg, kind, key)

        union = MapSet.union(MapSet.new(Map.keys(legacy)), MapSet.new(Map.keys(new)))

        for name <- union do
          l = Map.get(legacy, name, %{listed: false, callable: false})
          n = Map.get(new, name, %{listed: false, callable: false})

          assert n.listed == l.listed,
                 "#{scope_tag} × #{key_tag}: listing mismatch for #{name} (legacy=#{inspect(l)} new=#{inspect(n)})"

          assert n.callable == l.callable,
                 "#{scope_tag} × #{key_tag}: execution mismatch for #{name} (legacy=#{inspect(l)} new=#{inspect(n)})"
        end
      end
    end
  end

  # ── per-invariant explicit cases ────────────────────────────────────────────

  describe "I1 scope-only resolution" do
    test "hidden tool stays in the state map (invisible); disabled group dropped" do
      {_, cfg, kind} = scope(:flags)
      states = EffectiveToolset.resolve(%{"config" => cfg, "kind" => kind}, nil, nil)

      hidden = EffectiveToolset.lookup(states, @tool_hidden)
      refute hidden.visible
      assert hidden.enabled

      disabled = EffectiveToolset.lookup(states, @tool_plain)
      refute disabled.enabled
    end
  end

  describe "I2 keys never add tools or groups" do
    test "key-only group is ignored on a scoped endpoint" do
      {_, cfg, kind} = scope(:empty)

      client = %{
        id: "k",
        kind: :api_key,
        toolset_config: %{"groups" => %{"sessions" => %{"disabled" => true}}}
      }

      states = EffectiveToolset.resolve(%{"config" => cfg, "kind" => kind}, client, nil)
      assert states == %{}
    end
  end

  describe "I3 key disabled blocks execution" do
    test "key-disabled tool resolves enabled: false" do
      {_, cfg, kind} = scope(:flags)

      key = %{"groups" => %{@group => %{"tools" => %{@tool_plain => %{"disabled" => true}}}}}

      states =
        EffectiveToolset.resolve(
          %{"config" => cfg, "kind" => kind},
          %{id: "k", kind: :api_key, toolset_config: key},
          nil
        )

      refute EffectiveToolset.lookup(states, @tool_plain).enabled
    end
  end

  describe "I4 hidden-only remains callable" do
    test "visible false, enabled true" do
      {_, cfg, kind} = scope(:flags)
      states = EffectiveToolset.resolve(%{"config" => cfg, "kind" => kind}, nil, nil)

      hidden = EffectiveToolset.lookup(states, @tool_hidden)
      refute hidden.visible
      assert hidden.enabled
    end
  end

  describe "I5 OAuth-only (nil client) = scope-only state" do
    test "nil client == client with empty config" do
      {_, cfg, kind} = scope(:flags)

      a = EffectiveToolset.resolve(%{"config" => cfg, "kind" => kind}, nil, nil)

      b =
        EffectiveToolset.resolve(
          %{"config" => cfg, "kind" => kind},
          %{id: "k", kind: :api_key, toolset_config: nil},
          nil
        )

      assert a == b
    end
  end

  describe "I6 static-hidden specs survive default state" do
    test "apply_state is a no-op for the default state" do
      spec = %{definition: %{name: "X.Y", description: "d", meta: %{}}, module: nil, hidden: true}

      assert EffectiveToolset.apply_state(spec, EffectiveToolset.default_state()) == spec
    end
  end

  describe "I7 ungated categories never key-gated" do
    test "Discovery-category spec survives apply_to_specs even when its group is key-disabled" do
      uniq = System.unique_integer([:positive])

      user =
        %NoizuPromptLingua.Schema.Users.User{
          id: Ecto.UUID.generate(),
          email: "matrix-#{uniq}@example.com",
          user_name: "mx#{uniq}",
          handle: "mx#{uniq}",
          status: :active
        }
        |> NoizuPromptLingua.Repo.insert!()

      {:ok, key, _raw} =
        MCPApiKeys.generate_api_key(user.id, "matrix",
          toolset_config: %{"groups" => %{@group => %{"disabled" => true}}}
        )

      ctx = %Ctx{
        server: NoizuPromptLingua.MCP,
        assigns: %{auth_claims: %{"api_key_id" => key.id}}
      }

      discovery_spec =
        NoizuPromptLingua.Domains.Tickets.MCP.__mcp__(:tools)
        |> Tools.expand()
        |> Enum.find(&(&1.definition.name == @tool_plain))
        |> put_in([Access.key(:definition), Access.key(:meta)], %{"category" => "Discovery"})

      plain_spec =
        NoizuPromptLingua.Domains.Tickets.MCP.__mcp__(:tools)
        |> Tools.expand()
        |> Enum.find(&(&1.definition.name == @tool_plain))

      kept = EffectiveToolset.apply_to_specs([discovery_spec, plain_spec], ctx)

      assert Enum.map(kept, & &1.definition.name) == [discovery_spec.definition.name]
    end
  end

  describe "I8 components pseudo-group gating unchanged" do
    test "state_from_config flags the pseudo-group entry" do
      config = %{"groups" => %{"components" => %{"tools" => %{"Comp.X" => %{"hidden" => true}}}}}

      assert KeyToolsets.state_from_config(config, "components", "Comp.X") ==
               %{disabled: false, hidden: true}
    end
  end

  describe "I9 all_in_one required-core enforcement on read" do
    test "unconfirmed disable is force-enabled; confirmed disable is honored" do
      req = hd(MCPServers.required_ids())
      [tool_name | _] = group_tool_names(req)

      force_enabled =
        EffectiveToolset.resolve(
          %{"config" => %{"groups" => %{req => %{"disabled" => true}}}, "kind" => "all_in_one"},
          nil,
          nil
        )

      assert EffectiveToolset.lookup(force_enabled, tool_name).enabled

      confirmed =
        EffectiveToolset.resolve(
          %{
            "config" => %{
              "groups" => %{
                req => %{"disabled" => true, "confirmed" => true}
              }
            },
            "kind" => "all_in_one"
          },
          nil,
          nil
        )

      refute EffectiveToolset.lookup(confirmed, tool_name).enabled
    end
  end

  describe "I10 template isolation" do
    test "template flags never reach custom clones, root listings, or state/5" do
      create_scope(MCPCustomScopes.default_package_slug(), %{
        "groups" => %{@group => %{"disabled" => true, "hidden" => true}}
      })

      # clone with NO flags — template must not bleed in
      clone = create_scope("clone-acme", %{"groups" => %{@group => %{"tools" => %{}}}})
      clone_states = EffectiveToolset.resolve(clone, nil, nil)

      assert EffectiveToolset.lookup(clone_states, @tool_plain) ==
               EffectiveToolset.default_state()

      # root/static universe: client groups only
      client = %{
        id: "k",
        kind: :api_key,
        toolset_config: %{"groups" => %{"chat" => %{"tools" => %{}}}}
      }

      root_states = EffectiveToolset.resolve(nil, client, nil)

      for name <- Map.keys(root_states) do
        refute String.starts_with?(ToolNames.dotted(name), "Ticket."),
               "template tickets group leaked into root universe: #{name}"
      end

      # ToolGuard hot path: nil scope + nil client => ungated regardless of template
      assert EffectiveToolset.state(@group, @tool_plain, nil, nil) ==
               EffectiveToolset.default_state()
    end
  end

  # ── helpers ─────────────────────────────────────────────────────────────────

  defp create_scope(slug, config, extra \\ []) do
    {:ok, scope} =
      MCPCustomScopes.create(
        %{
          "slug" => slug,
          "name" => slug,
          "kind" => "custom",
          "config" => config
        }
        |> Map.merge(Map.new(extra))
      )

    scope
  end
end
