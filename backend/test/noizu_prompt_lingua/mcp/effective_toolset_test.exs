defmodule NoizuPromptLingua.MCP.EffectiveToolsetTest do
  use NoizuPromptLingua.DataCase

  require Noizu.EntityReference.Records

  alias Noizu.MCP.Ctx
  alias Noizu.EntityReference.Records, as: R
  alias NoizuPromptLingua.Acl
  alias NoizuPromptLingua.MCP.EffectiveToolset
  alias NoizuPromptLingua.MCP.KeyToolsets
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.Schema.McpTool

  @tool "Ticket.List"
  # F5: resolve/2 output is keyed canonical underscore
  @tool_canonical "Ticket_List"
  @group "tickets"

  defp ticket_specs do
    NoizuPromptLingua.Domains.Tickets.MCP.__mcp__(:tools)
    |> Noizu.MCP.Server.Features.Tools.expand()
  end

  defp ticket_spec(name) do
    Enum.find(ticket_specs(), &(&1.definition.name == name))
  end

  defp scope_config(groups) when is_map(groups), do: %{"groups" => groups}

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

  # The global `tobor` template row — resolution must NEVER read it (I10):
  # scope clones freeze its config at creation, root/static listings are
  # key-gated only.
  defp create_template(config), do: create_scope("tobor", config)

  defp key_ctx(config) do
    uniq = System.unique_integer([:positive])

    user =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "ets-#{uniq}@example.com",
        user_name: "ets#{uniq}",
        handle: "ets#{uniq}",
        status: :active
      }
      |> NoizuPromptLingua.Repo.insert!()

    {:ok, key, _raw} = MCPApiKeys.generate_api_key(user.id, "ets", toolset_config: config)

    %Ctx{server: NoizuPromptLingua.MCP, assigns: %{auth_claims: %{"api_key_id" => key.id}}}
  end

  defp client(config), do: %{id: "c1", kind: :api_key, toolset_config: config}

  # ── cascade precedence (scope < client; no template layer) ──────────────────

  describe "cascade precedence (scope < client)" do
    test "template is never overlaid at request time (I10)" do
      create_template(scope_config(%{@group => %{"disabled" => true, "hidden" => true}}))
      scope = create_scope("acme", scope_config(%{@group => %{"tools" => %{}}}))

      state = EffectiveToolset.lookup(EffectiveToolset.resolve(scope, nil, nil), @tool)
      assert state == EffectiveToolset.default_state()
    end

    test "scope hidden; client visible beats scope hidden" do
      scope = create_scope("acme", scope_config(%{@group => %{"hidden" => true}}))

      refute EffectiveToolset.lookup(EffectiveToolset.resolve(scope, nil, nil), @tool).visible

      client = client(scope_config(%{@group => %{"tools" => %{@tool => %{"hidden" => false}}}}))
      assert EffectiveToolset.state(@group, @tool, scope, client).visible
    end

    test "client disabled wins over scope enabled" do
      scope =
        create_scope(
          "acme",
          scope_config(%{@group => %{"tools" => %{@tool => %{"disabled" => false}}}})
        )

      client = client(scope_config(%{@group => %{"tools" => %{@tool => %{"disabled" => true}}}}))

      refute EffectiveToolset.state(@group, @tool, scope, client).enabled
    end

    test "absent from every layer = enabled + visible (inverted semantics)" do
      scope = create_scope("acme", scope_config(%{@group => %{"tools" => %{}}}))

      state = EffectiveToolset.lookup(EffectiveToolset.resolve(scope, nil, nil), @tool)
      assert state == EffectiveToolset.default_state()
    end

    test "tool-level flag beats group-level flag in the same layer" do
      scope =
        create_scope(
          "acme",
          scope_config(%{
            @group => %{"hidden" => true, "tools" => %{@tool => %{"hidden" => false}}}
          })
        )

      states = EffectiveToolset.resolve(scope, nil, nil)
      assert EffectiveToolset.lookup(states, @tool).visible
    end

    test "group-level flags apply to every tool of the group" do
      scope = create_scope("acme", scope_config(%{@group => %{"disabled" => true}}))

      states = EffectiveToolset.resolve(scope, nil, nil)

      for spec <- ticket_specs(), spec.definition.meta["category"] not in ["Discovery"] do
        refute EffectiveToolset.lookup(states, spec.definition.name).enabled
      end
    end
  end

  describe "include set" do
    test "client config cannot add groups beyond the scope include set" do
      scope = create_scope("acme", scope_config(%{"sessions" => %{"tools" => %{}}}))
      client = client(scope_config(%{@group => %{"disabled" => true}}))

      states = EffectiveToolset.resolve(scope, client, nil)
      refute Map.has_key?(states, @tool_canonical)
    end

    test "nil scope (static servers): client groups only — template ignored (I10)" do
      create_template(scope_config(%{"sessions" => %{"tools" => %{}}}))
      client = client(scope_config(%{@group => %{"disabled" => true}}))

      states = EffectiveToolset.resolve(nil, client, nil)
      assert Map.has_key?(states, @tool_canonical)
      refute EffectiveToolset.lookup(states, @tool).enabled

      # template groups must not enter the root universe
      session_tools =
        NoizuPromptLingua.MCP.Sessions.__mcp__(:tools)
        |> Noizu.MCP.Server.Features.Tools.expand()
        |> Enum.map(&NoizuPromptLingua.MCP.ToolNames.canonical(&1.definition.name))

      for name <- session_tools do
        refute Map.has_key?(states, name)
      end
    end
  end

  # ── overrides (§7) ──────────────────────────────────────────────────────────

  describe "name/description overrides" do
    test "flow through the cascade into the state" do
      scope =
        create_scope(
          "acme",
          scope_config(%{
            @group => %{
              "tools" => %{
                @tool => %{
                  "name_override" => "Tickets_Listing",
                  "description_override" => "List tickets, focused view"
                }
              }
            }
          })
        )

      state = EffectiveToolset.lookup(EffectiveToolset.resolve(scope, nil, nil), @tool)
      assert state.name_override == "Tickets_Listing"
      assert state.description_override == "List tickets, focused view"
    end

    test "client layer wins over scope layer when non-null (§2.7)" do
      scope =
        create_scope(
          "acme",
          scope_config(%{
            @group => %{
              "tools" => %{
                @tool => %{
                  "name_override" => "Scope_Name",
                  "description_override" => "Scope description"
                }
              }
            }
          })
        )

      # client overrides only the name — the description inherits the scope value
      client =
        client(
          scope_config(%{@group => %{"tools" => %{@tool => %{"name_override" => "Client_Name"}}}})
        )

      state = EffectiveToolset.state(@group, @tool, scope, client)
      assert state.name_override == "Client_Name"
      assert state.description_override == "Scope description"
    end

    test "apply_state renames the spec definition for listing" do
      spec = ticket_spec(@tool)

      renamed =
        EffectiveToolset.apply_state(spec, %{
          enabled: true,
          visible: true,
          name_override: "Tickets_Listing",
          description_override: "Custom description",
          expires_at: nil
        })

      assert renamed.definition.name == "Tickets_Listing"
      assert renamed.definition.description == "Custom description"
      refute renamed.hidden
    end
  end

  # ── temporal windows (§3 via MCP.Window) ────────────────────────────────────

  describe "expires_at via temporal windows" do
    test "hide_until in the future hides the tool" do
      at = DateTime.utc_now()

      state =
        EffectiveToolset.state(
          @group,
          @tool,
          %{
            "config" =>
              scope_config(%{
                @group => %{
                  "tools" => %{
                    @tool => %{
                      "hide_until" => DateTime.add(at, 3600, :second) |> DateTime.to_iso8601()
                    }
                  }
                }
              })
          },
          nil,
          at
        )

      refute state.visible
      assert state.enabled
    end

    test "hide_until in the past is a no-op" do
      at = DateTime.utc_now()

      state =
        EffectiveToolset.state(
          @group,
          @tool,
          %{
            "config" =>
              scope_config(%{
                @group => %{
                  "tools" => %{
                    @tool => %{
                      "hide_until" => DateTime.add(at, -3600, :second) |> DateTime.to_iso8601()
                    }
                  }
                }
              })
          },
          nil,
          at
        )

      assert state.visible
      assert is_nil(state.expires_at)
    end

    test "enable_for_hours grants visibility with an expires_at" do
      at = DateTime.utc_now()
      anchor = DateTime.add(at, -3600, :second)

      state =
        EffectiveToolset.state(
          @group,
          @tool,
          %{
            "config" =>
              scope_config(%{
                @group => %{
                  "tools" => %{
                    @tool => %{
                      "enable_for_hours" => 24,
                      "enabled_at" => DateTime.to_iso8601(anchor)
                    }
                  }
                }
              })
          },
          nil,
          at
        )

      assert state.visible
      assert %DateTime{} = state.expires_at
      assert_in_delta DateTime.diff(state.expires_at, at) / 3600, 23, 0.1
    end

    test "expired enable window falls back to base flags" do
      at = DateTime.utc_now()
      anchor = DateTime.add(at, -48 * 3600, :second)

      state =
        EffectiveToolset.state(
          @group,
          @tool,
          %{
            "config" =>
              scope_config(%{
                @group => %{
                  "tools" => %{
                    @tool => %{
                      "enable_for_hours" => 24,
                      "enabled_at" => DateTime.to_iso8601(anchor)
                    }
                  }
                }
              })
          },
          nil,
          at
        )

      assert state.visible
      assert is_nil(state.expires_at)
    end

    test "live enable window LIFTS disabled (enforcement wiring)" do
      at = DateTime.utc_now()
      anchor = DateTime.add(at, -3600, :second)

      state =
        EffectiveToolset.state(
          @group,
          @tool,
          %{
            "config" =>
              scope_config(%{
                @group => %{
                  "tools" => %{
                    @tool => %{
                      "disabled" => true,
                      "enable_for_hours" => 24,
                      "enabled_at" => DateTime.to_iso8601(anchor)
                    }
                  }
                }
              })
          },
          nil,
          at
        )

      assert state.enabled
      assert %DateTime{} = state.expires_at
    end

    test "live enable window LIFTS hidden (enforcement wiring)" do
      at = DateTime.utc_now()
      anchor = DateTime.add(at, -3600, :second)

      state =
        EffectiveToolset.state(
          @group,
          @tool,
          %{
            "config" =>
              scope_config(%{
                @group => %{
                  "tools" => %{
                    @tool => %{
                      "hidden" => true,
                      "enable_for_hours" => 24,
                      "enabled_at" => DateTime.to_iso8601(anchor)
                    }
                  }
                }
              })
          },
          nil,
          at
        )

      assert state.visible
      assert state.enabled
    end

    test "expired enable window does NOT lift disabled (no-op after expiry)" do
      at = DateTime.utc_now()
      anchor = DateTime.add(at, -48 * 3600, :second)

      state =
        EffectiveToolset.state(
          @group,
          @tool,
          %{
            "config" =>
              scope_config(%{
                @group => %{
                  "tools" => %{
                    @tool => %{
                      "disabled" => true,
                      "enable_for_hours" => 24,
                      "enabled_at" => DateTime.to_iso8601(anchor)
                    }
                  }
                }
              })
          },
          nil,
          at
        )

      refute state.enabled
      assert is_nil(state.expires_at)
    end

    # Regression: the read path used to re-stamp a stored set_at anchor to
    # "now" on EVERY read, so a set_at-era window (set_at + hours) never
    # expired and permanently lifted disabled/hidden (fail-open leak).
    test "set_at-era window past expiry is NOT re-anchored to now (stay disabled)" do
      at = DateTime.utc_now()
      stored_anchor = DateTime.add(at, -6, :hour) |> DateTime.to_iso8601()

      state =
        EffectiveToolset.state(
          @group,
          @tool,
          %{
            "config" =>
              scope_config(%{
                @group => %{
                  "tools" => %{
                    @tool => %{
                      "disabled" => true,
                      "enable_for_hours" => 2,
                      "set_at" => stored_anchor
                    }
                  }
                }
              })
          },
          nil,
          at
        )

      refute state.enabled
      assert is_nil(state.expires_at)
    end

    test "live set_at-era window keeps its ORIGINAL anchor (expires = set_at + hours)" do
      at = DateTime.utc_now()
      stored_anchor = DateTime.add(at, -3600, :second)
      anchor_iso = DateTime.to_iso8601(stored_anchor)

      state =
        EffectiveToolset.state(
          @group,
          @tool,
          %{
            "config" =>
              scope_config(%{
                @group => %{
                  "tools" => %{
                    @tool => %{
                      "disabled" => true,
                      "enable_for_hours" => 2,
                      "set_at" => anchor_iso
                    }
                  }
                }
              })
          },
          nil,
          at
        )

      assert state.enabled
      # anchored at stored_anchor (1h ago) + 2h => ~1h from now; a re-stamped
      # anchor would report the full 2h.
      assert_in_delta DateTime.diff(state.expires_at, at) / 3600, 1, 0.1
    end

    test "hide_until suppresses listing but does not disable execution" do
      at = DateTime.utc_now()

      state =
        EffectiveToolset.state(
          @group,
          @tool,
          %{
            "config" =>
              scope_config(%{
                @group => %{
                  "tools" => %{
                    @tool => %{
                      "disabled" => false,
                      "hide_until" => DateTime.add(at, 3600, :second) |> DateTime.to_iso8601()
                    }
                  }
                }
              })
          },
          nil,
          at
        )

      refute state.visible
      assert state.enabled
    end

    test "KeyToolsets.state/3 honors the window lift (ToolGuard path)" do
      at = DateTime.utc_now()
      anchor = DateTime.add(at, -3600, :second)
      slug = "win-lift"

      create_scope(
        slug,
        scope_config(%{
          @group => %{
            "tools" => %{
              @tool => %{
                "disabled" => true,
                "enable_for_hours" => 24,
                "enabled_at" => DateTime.to_iso8601(anchor)
              }
            }
          }
        })
      )

      ctx = %Ctx{
        server: NoizuPromptLingua.MCP,
        assigns: %{custom_scope_slug: slug, auth_claims: %{}}
      }

      flags = KeyToolsets.state(@group, @tool, ctx)
      refute flags.disabled
      refute flags.hidden
    end
  end

  # ── hidden vs disabled semantics ────────────────────────────────────────────

  describe "hidden vs disabled through apply_state/apply_to_specs" do
    test "hidden tool stays in the resolved set but is flagged hidden for listings" do
      scope =
        create_scope(
          "acme",
          scope_config(%{@group => %{"tools" => %{@tool => %{"hidden" => true}}}})
        )

      states = EffectiveToolset.resolve(scope, nil, nil)

      # hidden ≠ removed from the state map (Session.Manifest reports it)
      assert EffectiveToolset.lookup(states, @tool).visible == false

      # ...and the listing spec keeps its identity but is flagged hidden
      # (MCP.Server.list_tools drops on spec.hidden)
      kept =
        EffectiveToolset.apply_state(ticket_spec(@tool), EffectiveToolset.lookup(states, @tool))

      refute is_nil(kept)
      assert kept.hidden
    end

    test "disabled tool is dropped from listings entirely" do
      scope =
        create_scope(
          "acme",
          scope_config(%{@group => %{"tools" => %{@tool => %{"disabled" => true}}}})
        )

      states = EffectiveToolset.resolve(scope, nil, nil)

      assert EffectiveToolset.apply_state(
               ticket_spec(@tool),
               EffectiveToolset.lookup(states, @tool)
             )
             |> is_nil()
    end

    test "default state is a no-op (registration-hidden specs keep their flag)" do
      spec = %{ticket_spec(@tool) | hidden: true}
      assert EffectiveToolset.apply_state(spec, EffectiveToolset.default_state()) == spec
    end
  end

  # ── ctx plumbing + thin callers ─────────────────────────────────────────────

  describe "ctx plumbing" do
    test "client_for_ctx resolves the active API key + toolset_config" do
      ctx = key_ctx(scope_config(%{@group => %{"disabled" => true}}))

      assert %{kind: :api_key, toolset_config: config} = EffectiveToolset.client_for_ctx(ctx)
      assert is_map(config)

      assert EffectiveToolset.config_for_ctx(ctx) != nil
    end

    test "KeyToolsets.state honors scope config via ctx assigns (custom endpoint)" do
      create_scope("acme", scope_config(%{@group => %{"disabled" => true}}))

      ctx = %Ctx{
        server: NoizuPromptLingua.MCP,
        assigns: %{custom_scope_slug: "acme", auth_claims: %{}}
      }

      assert KeyToolsets.state(@group, @tool, ctx).disabled
    end

    test "KeyToolsets.state_from_config is pure (no template layer)" do
      create_template(scope_config(%{@group => %{"disabled" => true}}))

      assert KeyToolsets.state_from_config(
               scope_config(%{@group => %{"tools" => %{}}}),
               @group,
               @tool
             ) ==
               %{disabled: false, hidden: false}
    end
  end

  describe "storage normalizer keeps new entry keys" do
    test "create persists overrides + window fields on tool entries" do
      scope =
        create_scope(
          "acme",
          scope_config(%{
            @group => %{
              "tools" => %{
                @tool => %{
                  "name_override" => "Tickets_Listing",
                  "hide_until" => "2099-01-01T00:00:00Z"
                }
              }
            }
          })
        )

      entry = get_in(scope.config, ["groups", @group, "tools", @tool])
      assert entry["name_override"] == "Tickets_Listing"
      assert entry["hide_until"] == "2099-01-01T00:00:00Z"
    end

    test "empty string override is absent (§2.7)" do
      scope =
        create_scope(
          "acme",
          scope_config(%{@group => %{"tools" => %{@tool => %{"name_override" => ""}}}})
        )

      entry = get_in(scope.config, ["groups", @group, "tools", @tool])
      refute Map.has_key?(entry, "name_override")

      state = EffectiveToolset.lookup(EffectiveToolset.resolve(scope, nil, nil), @tool)
      assert is_nil(state.name_override)
    end

    test "override caps: name ≤ 128, description ≤ 1024 (§2.7)" do
      scope =
        create_scope(
          "acme",
          scope_config(%{
            @group => %{
              "tools" => %{
                @tool => %{
                  "name_override" => String.duplicate("n", 500),
                  "description_override" => String.duplicate("d", 5000)
                }
              }
            }
          })
        )

      entry = get_in(scope.config, ["groups", @group, "tools", @tool])
      assert String.length(entry["name_override"]) == 128
      assert String.length(entry["description_override"]) == 1024
    end
  end

  # ── alacarte: the ?t= URL tool-selection layer ───────────────────────────────

  describe "url toolset param layer" do
    # Compiled param layer (UrlToolsetParam output shape): re-enable @tool.
    @param_reenable %{
      "groups" => %{@group => %{"tools" => %{@tool_canonical => %{"disabled" => false, "hidden" => false}}}}
    }

    defp ctx_with_param(assigns_extra) do
      base = key_ctx(scope_config(%{}))
      %Ctx{base | assigns: Map.merge(base.assigns, assigns_extra)}
    end

    test "param beats scope disabled (resolution + ToolGuard ctx path)" do
      create_scope(
        "acme",
        scope_config(%{@group => %{"tools" => %{@tool => %{"disabled" => true}}}})
      )

      scope = MCPCustomScopes.get_by_slug("acme")
      client = %{id: :url_toolset_param, kind: :url_param, toolset_config: @param_reenable}

      state = EffectiveToolset.state(@group, @tool, scope, client)
      assert state.enabled and state.visible

      ctx = ctx_with_param(%{custom_scope_slug: "acme", toolset_param_cfg: @param_reenable})

      flags = KeyToolsets.state(@group, @tool, ctx)
      refute flags.disabled
      refute flags.hidden
    end

    test "param beats client key flags (union merge, param wins per key)" do
      create_scope("acme", scope_config(%{@group => %{"tools" => %{}}}))

      # stored key config disables @tool at the group level; the param re-enables it
      %Ctx{assigns: base_assigns} = key_ctx(scope_config(%{@group => %{"disabled" => true}}))

      ctx = %Noizu.MCP.Ctx{
        server: NoizuPromptLingua.MCP,
        assigns:
          base_assigns
          |> Map.put(:toolset_param_cfg, @param_reenable)
          |> Map.put(:custom_scope_slug, "acme")
      }

      flags = KeyToolsets.state(@group, @tool, ctx)
      refute flags.disabled
      refute flags.hidden

      # without the param layer the stored key disable holds
      %Ctx{assigns: plain} = key_ctx(scope_config(%{@group => %{"disabled" => true}}))

      plain_ctx = %Noizu.MCP.Ctx{
        server: NoizuPromptLingua.MCP,
        assigns: Map.put(plain, :custom_scope_slug, "acme")
      }

      assert KeyToolsets.state(@group, @tool, plain_ctx).disabled
    end

    test "white-list entry for a tool absent from the stored client config survives (union, not overlay)" do
      create_scope("acme", scope_config(%{@group => %{"tools" => %{}}}))
      scope = MCPCustomScopes.get_by_slug("acme")

      merged =
        EffectiveToolset.client_with_param(ctx_with_param(%{toolset_param_cfg: @param_reenable}), scope)

      tools = get_in(merged.toolset_config, ["groups", @group, "tools"])
      assert Map.has_key?(tools, @tool_canonical)

      # param wins per key over the stored client's hidden flag
      state = EffectiveToolset.state(@group, @tool, scope, merged)
      assert state.visible and state.enabled
    end

    test "param cannot widen the include set (scope groups govern)" do
      create_scope("acme", scope_config(%{"sessions" => %{"tools" => %{}}}))

      param_layer = %{
        "groups" => %{"organizations" => %{"tools" => %{"Organization_List" => %{}}}}
      }

      scope = MCPCustomScopes.get_by_slug("acme")

      client =
        EffectiveToolset.client_with_param(ctx_with_param(%{toolset_param_cfg: param_layer}), scope)

      states = EffectiveToolset.resolve(scope, client, nil)
      assert Map.has_key?(states, "Session_Create")
      refute Map.has_key?(states, "Organization_List")
    end

    test "nil scope drops the param (never widens a root universe)" do
      ctx = ctx_with_param(%{toolset_param_cfg: @param_reenable})
      client = EffectiveToolset.client_with_param(ctx, nil)
      assert client == EffectiveToolset.client_for_ctx(ctx)
    end

    test "param_only_client carries ONLY the param layer (catalog contract)" do
      ctx = ctx_with_param(%{toolset_param_cfg: @param_reenable})
      client = EffectiveToolset.param_only_client(ctx)
      assert client.toolset_config == @param_reenable

      # no param → nil (the stored client layer stays out of catalog_specs)
      assert EffectiveToolset.param_only_client(key_ctx(scope_config(%{}))) == nil
    end

    test "ACL stays final over the param layer (deny hides + disables a param-enabled tool)" do
      create_scope("acme", scope_config(%{@group => %{"tools" => %{@tool => %{"disabled" => true}}}}))
      scope = MCPCustomScopes.get_by_slug("acme")

      user_id = Ecto.UUID.generate()
      user_ref = R.ref(module: NoizuPromptLingua.Users.User, id: user_id)

      {:ok, _} =
        Acl.create_rule(%{
          subject_ref: user_ref,
          resource_ref: R.ref(module: McpTool, id: @tool_canonical),
          action: "mcp.tool",
          effect: "deny"
        })

      client = %{id: :url_toolset_param, kind: :url_param, toolset_config: @param_reenable}

      # without ACL: the param re-enables the scope-disabled tool
      assert EffectiveToolset.state(@group, @tool, scope, client).enabled

      # with the denied user: ACL has the final word
      state = EffectiveToolset.state(@group, @tool, scope, client, user_ref, DateTime.utc_now())
      refute state.enabled
      refute state.visible

      # and resolve/4 agrees (listing path)
      states = EffectiveToolset.resolve(scope, client, user_ref)
      refute EffectiveToolset.lookup(states, @tool).visible
    end
  end
end
