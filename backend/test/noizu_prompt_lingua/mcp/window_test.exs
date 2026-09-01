defmodule NoizuPromptLingua.MCP.WindowTest do
  use ExUnit.Case, async: true

  alias NoizuPromptLingua.MCP.Window
  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.Schema.MCPCustomScope

  @now ~U[2026-08-31 12:00:00Z]
  @future ~U[2026-09-07 12:00:00Z]
  @past ~U[2026-08-24 12:00:00Z]

  # ------------------------------------------------------------------
  # parse/1
  # ------------------------------------------------------------------

  describe "parse/1" do
    test "no window fields parses to nils" do
      assert {:ok, %{hide_until: nil, enable_for_hours: nil}} = Window.parse(%{})

      assert {:ok, %{hide_until: nil, enable_for_hours: nil}} =
               Window.parse(%{"disabled" => true, "hidden" => false})
    end

    test "hide_until accepts DateTime" do
      assert {:ok, %{hide_until: hide_until, enable_for_hours: nil}} =
               Window.parse(%{"hide_until" => @future})

      assert hide_until == @future
    end

    test "hide_until accepts NaiveDateTime (assumed UTC)" do
      assert {:ok, %{hide_until: hide_until}} =
               Window.parse(%{"hide_until" => DateTime.to_naive(@future)})

      assert hide_until == @future
    end

    test "hide_until accepts ISO8601 with offset" do
      assert {:ok, %{hide_until: %DateTime{}}} =
               Window.parse(%{"hide_until" => "2026-09-07T12:00:00Z"})
    end

    test "hide_until accepts naive ISO8601 string (assumed UTC)" do
      assert {:ok, %{hide_until: %DateTime{time_zone: "Etc/UTC"}}} =
               Window.parse(%{"hide_until" => "2026-09-07T12:00:00"})
    end

    test "hide_until rejects non-datetime values" do
      assert {:error, {:invalid_datetime, "hide_until"}} =
               Window.parse(%{"hide_until" => "tomorrow"})

      assert {:error, {:invalid_datetime, "hide_until"}} = Window.parse(%{"hide_until" => 123})
    end

    test "enable_for_hours accepts positive integers" do
      assert {:ok, %{hide_until: nil, enable_for_hours: 24}} =
               Window.parse(%{"enable_for_hours" => 24})
    end

    test "enable_for_hours=0 is rejected" do
      assert {:error, {:invalid_hours, _}} = Window.parse(%{"enable_for_hours" => 0})
    end

    test "negative / non-integer enable_for_hours rejected" do
      assert {:error, {:invalid_hours, _}} = Window.parse(%{"enable_for_hours" => -1})
      assert {:error, {:invalid_hours, _}} = Window.parse(%{"enable_for_hours" => "24"})
      assert {:error, {:invalid_hours, _}} = Window.parse(%{"enable_for_hours" => 1.5})
    end

    test "both fields set is rejected (mutually exclusive)" do
      assert {:error, :mutually_exclusive} =
               Window.parse(%{"hide_until" => @future, "enable_for_hours" => 24})
    end

    test "atom keys accepted" do
      assert {:ok, %{enable_for_hours: 24}} =
               Window.parse(%{hide_until: nil, enable_for_hours: 24})
    end

    test "non-map input rejected" do
      assert {:error, :invalid_entry} = Window.parse("nope")
    end
  end

  # ------------------------------------------------------------------
  # validate_entry/1
  # ------------------------------------------------------------------

  describe "validate_entry/1" do
    test "valid entries yield no errors" do
      assert [] = Window.validate_entry(%{})
      assert [] = Window.validate_entry(%{"hide_until" => "2026-09-07T12:00:00Z"})
      assert [] = Window.validate_entry(%{"enable_for_hours" => 1})
    end

    test "mutually exclusive pair yields an error message" do
      assert [msg] = Window.validate_entry(%{"hide_until" => @future, "enable_for_hours" => 24})
      assert msg =~ "mutually exclusive"
    end

    test "past hide_until is structurally valid (expiry is evaluation, not validation)" do
      assert [] = Window.validate_entry(%{"hide_until" => @past})
    end

    test "zero hours yields an error message" do
      assert [msg] = Window.validate_entry(%{"enable_for_hours" => 0})
      assert msg =~ "positive integer"
    end
  end

  # ------------------------------------------------------------------
  # evaluate/2
  # ------------------------------------------------------------------

  describe "evaluate/2 — hide_until" do
    test "future hide_until is hidden until the instant" do
      assert {false, expires_at} = Window.evaluate(%{"hide_until" => @future}, @now)
      assert expires_at == @future
    end

    test "past hide_until is visible with no expiry" do
      assert {true, nil} = Window.evaluate(%{"hide_until" => @past}, @now)
    end

    test "exactly at hide_until becomes visible" do
      assert {true, nil} = Window.evaluate(%{"hide_until" => @now}, @now)
    end

    test "no window is visible with no expiry" do
      assert {true, nil} = Window.evaluate(%{}, @now)
      assert {true, nil} = Window.evaluate(%{"hidden" => true}, @now)
    end

    test "string hide_until evaluates like a parsed datetime" do
      assert {false, %DateTime{}} =
               Window.evaluate(%{"hide_until" => "2026-09-07T12:00:00Z"}, @now)
    end
  end

  describe "evaluate/2 — enable_for_hours" do
    test "live window is visible and reports its expiry" do
      entry = %{"enable_for_hours" => 24, "enabled_at" => "2026-08-31T00:00:00Z"}
      expires = ~U[2026-09-01 00:00:00Z]

      assert {true, ^expires} = Window.evaluate(entry, @now)
    end

    test "elapsed window is inert: visible, no expiry" do
      entry = %{"enable_for_hours" => 24, "enabled_at" => "2026-08-29T00:00:00Z"}
      assert {true, nil} = Window.evaluate(entry, @now)
    end

    test "boundary: exactly at expiry the window has elapsed" do
      entry = %{"enable_for_hours" => 12, "enabled_at" => "2026-08-31T00:00:00Z"}
      assert {true, nil} = Window.evaluate(entry, ~U[2026-08-31 12:00:00Z])
    end

    test "unanchored window is inert" do
      assert {true, nil} = Window.evaluate(%{"enable_for_hours" => 24}, @now)
    end

    test "naive at is treated as UTC" do
      entry = %{"enable_for_hours" => 1, "enabled_at" => "2026-08-31T00:00:00Z"}

      assert {true, %DateTime{time_zone: "Etc/UTC"}} =
               Window.evaluate(entry, ~N[2026-08-31 00:30:00])
    end

    test "garbage input evaluates visible (inverted semantics)" do
      assert {true, nil} = Window.evaluate(nil, @now)
      assert {true, nil} = Window.evaluate(%{"enable_for_hours" => "x"}, @now)
    end
  end

  # ------------------------------------------------------------------
  # state/2 — combined {visible, expires_at, lifted?} (single parse)
  # ------------------------------------------------------------------

  describe "state/2" do
    test "hide_until: hidden now, expires when the hide lifts, never lifts" do
      assert {false, @future, false} = Window.state(%{"hide_until" => @future}, @now)
      assert {true, nil, false} = Window.state(%{"hide_until" => @past}, @now)
    end

    test "enable_for_hours: live window lifts and reports expiry" do
      entry = %{"enable_for_hours" => 24, "set_at" => "2026-08-31T00:00:00Z"}
      assert {true, ~U[2026-09-01 00:00:00Z], true} = Window.state(entry, @now)
    end

    test "enable_for_hours: elapsed / unanchored / no window are inert" do
      assert {true, nil, false} =
               Window.state(%{"enable_for_hours" => 24, "set_at" => "2026-08-29T00:00:00Z"}, @now)

      assert {true, nil, false} = Window.state(%{"enable_for_hours" => 24}, @now)
      assert {true, nil, false} = Window.state(%{}, @now)
      assert {true, nil, false} = Window.state(nil, @now)
    end
  end

  # ------------------------------------------------------------------
  # normalize_entry/2
  # ------------------------------------------------------------------

  describe "normalize_entry/2" do
    test "carries hide_until as ISO8601 UTC string" do
      base = %{"disabled" => true}

      normalized = Window.normalize_entry(base, %{"hide_until" => @future})
      assert normalized["hide_until"] == "2026-09-07T12:00:00Z"
      assert normalized["disabled"] == true
      refute Map.has_key?(normalized, "enable_for_hours")
    end

    test "stamps set_at when anchoring enable_for_hours" do
      normalized = Window.normalize_entry(%{}, %{"enable_for_hours" => 24})

      assert normalized["enable_for_hours"] == 24
      refute Map.has_key?(normalized, "enabled_at")
      assert {:ok, %DateTime{}, _} = DateTime.from_iso8601(normalized["set_at"])

      # anchor is fresh (stamped now)
      stamped = DateTime.from_iso8601(normalized["set_at"]) |> elem(1)
      assert DateTime.diff(DateTime.utc_now(), stamped) < 5
    end

    test "every write re-stamps set_at (re-set/extend resets the anchor)" do
      config = %{
        "enable_for_hours" => 24,
        "set_at" => "2026-08-30T00:00:00Z",
        "enabled_at" => "2026-08-30T00:00:00Z"
      }

      normalized = Window.normalize_entry(%{}, config)

      # stale anchors are not carried; the anchor slides to the new write
      refute normalized["set_at"] == "2026-08-30T00:00:00Z"
      refute Map.has_key?(normalized, "enabled_at")
      assert {:ok, stamped, _} = DateTime.from_iso8601(normalized["set_at"])
      assert DateTime.diff(DateTime.utc_now(), stamped) < 5
    end

    test "regression: hand-edited malformed anchor is INERT (no raise), window re-anchors" do
      # Before the fix this raised: elem/1 of the parse error tuple flowed
      # into DateTime.to_iso8601/1.
      normalized =
        Window.normalize_entry(%{}, %{
          "enable_for_hours" => 24,
          "enabled_at" => "not-a-timestamp"
        })

      assert normalized["enable_for_hours"] == 24
      assert is_binary(normalized["set_at"])

      # ...and the same malformed jsonb evaluates as a live re-anchored window
      assert {true, %DateTime{}} = Window.evaluate(normalized)

      # non-string garbage anchors are inert on write too
      normalized2 = Window.normalize_entry(%{}, %{"enable_for_hours" => 24, "enabled_at" => 42})
      assert is_binary(normalized2["set_at"])
    end

    test "evaluate prefers set_at over legacy enabled_at" do
      entry = %{
        "enable_for_hours" => 24,
        "set_at" => "2026-08-31T00:00:00Z",
        "enabled_at" => "2026-08-01T00:00:00Z"
      }

      assert {true, ~U[2026-09-01 00:00:00Z]} = Window.evaluate(entry, @now)
    end

    test "hide_until writes also stamp set_at" do
      normalized = Window.normalize_entry(%{}, %{"hide_until" => @future})
      assert is_binary(normalized["set_at"])
    end

    test "drops invalid values silently (strict rejection lives on the changeset)" do
      assert Window.normalize_entry(%{}, %{"hide_until" => "someday"}) == %{}
      assert Window.normalize_entry(%{}, %{"enable_for_hours" => 0}) == %{}

      assert Window.normalize_entry(%{}, %{"hide_until" => @future, "enable_for_hours" => 24}) ==
               %{}
    end
  end

  # ------------------------------------------------------------------
  # lifting?/2 — enable_for_hours lifts BOTH static flags while live
  # ------------------------------------------------------------------

  describe "lifting?/2" do
    test "live window lifts" do
      entry = %{"enable_for_hours" => 24, "set_at" => "2026-08-31T00:00:00Z"}
      assert Window.lifting?(entry, @now)
    end

    test "legacy enabled_at anchor still lifts" do
      entry = %{"enable_for_hours" => 24, "enabled_at" => "2026-08-31T00:00:00Z"}
      assert Window.lifting?(entry, @now)
    end

    test "elapsed window does not lift" do
      entry = %{"enable_for_hours" => 24, "set_at" => "2026-08-29T00:00:00Z"}
      refute Window.lifting?(entry, @now)
    end

    test "unanchored / malformed / hide_until entries never lift" do
      refute Window.lifting?(%{"enable_for_hours" => 24}, @now)
      refute Window.lifting?(%{"enable_for_hours" => 24, "set_at" => "garbage"}, @now)
      refute Window.lifting?(%{"hide_until" => @future}, @now)
      refute Window.lifting?(%{}, @now)
      refute Window.lifting?(nil, @now)
    end
  end

  # ------------------------------------------------------------------
  # Retention — prune expired windows >7d old on write
  # ------------------------------------------------------------------

  describe "normalize_entry/2 retention prune" do
    test "hide_until expired more than 7d ago is pruned" do
      ancient = DateTime.add(@now, -8 * 86_400, :second)

      assert Window.normalize_entry(%{}, %{"hide_until" => ancient}) == %{}
    end

    test "hide_until expired within 7d is kept (inert at evaluation)" do
      recent = DateTime.add(@now, -3 * 86_400, :second)

      normalized = Window.normalize_entry(%{}, %{"hide_until" => recent})
      assert is_binary(normalized["hide_until"])
      assert {true, nil} = Window.evaluate(normalized, DateTime.utc_now())
    end

    test "future hide_until is kept" do
      normalized = Window.normalize_entry(%{}, %{"hide_until" => @future})
      assert is_binary(normalized["hide_until"])
    end
  end

  # ------------------------------------------------------------------
  # Config-schema integration
  # ------------------------------------------------------------------

  describe "MCPCustomScopes.normalize_config/2 window carry-through" do
    test "window fields survive normalization on a tool entry" do
      config = %{
        "groups" => %{
          "sessions" => %{
            "tools" => %{
              "Session_Create" => %{"hidden" => true, "hide_until" => "2026-09-07T12:00:00Z"}
            }
          }
        }
      }

      normalized = MCPCustomScopes.normalize_config(config, "custom")
      tool = normalized["groups"]["sessions"]["tools"]["Session_Create"]

      assert tool["hidden"] == true
      assert tool["hide_until"] == "2026-09-07T12:00:00Z"
    end

    test "enable_for_hours gains an anchor through normalization" do
      config = %{
        "groups" => %{
          "sessions" => %{"tools" => %{"Session_List" => %{"enable_for_hours" => 48}}}
        }
      }

      tool =
        MCPCustomScopes.normalize_config(config, "custom")["groups"]["sessions"]["tools"][
          "Session_List"
        ]

      assert tool["enable_for_hours"] == 48
      assert is_binary(tool["set_at"])
    end

    test "regression: hand-edited malformed anchor in scope-config jsonb is inert on write" do
      config = %{
        "groups" => %{
          "sessions" => %{
            "tools" => %{"Session_List" => %{"enable_for_hours" => 48, "enabled_at" => "garbage"}}
          }
        }
      }

      # raised (DateTime.to_iso8601 on an error tuple) before the fix
      tool =
        MCPCustomScopes.normalize_config(config, "custom")["groups"]["sessions"]["tools"][
          "Session_List"
        ]

      assert tool["enable_for_hours"] == 48
      assert {:ok, %DateTime{}, _} = DateTime.from_iso8601(tool["set_at"])
    end

    test "evaluates end-to-end after normalization round-trip" do
      config = %{
        "groups" => %{
          "sessions" => %{
            "tools" => %{"Session_Create" => %{"hide_until" => "2026-09-07T12:00:00Z"}}
          }
        }
      }

      tool =
        MCPCustomScopes.normalize_config(config, "custom")["groups"]["sessions"]["tools"][
          "Session_Create"
        ]

      assert {false, %DateTime{}} = Window.evaluate(tool, @now)
      assert {true, nil} = Window.evaluate(tool, ~U[2026-09-08 12:00:00Z])
    end
  end

  # ------------------------------------------------------------------
  # Read-path anchor preservation (preserve_anchors: true) — the fail-open
  # leak fix: re-stamping set_at on every read would re-anchor the window to
  # "now", so a live enable_for_hours window would never expire and would
  # permanently lift disabled/hidden.
  # ------------------------------------------------------------------

  describe "normalize_config/3 preserve_anchors (read path)" do
    @stored_set_at "2026-08-30T00:00:00Z"

    test "stored set_at is carried verbatim (not re-stamped)" do
      config = %{
        "groups" => %{
          "sessions" => %{
            "tools" => %{"Session_List" => %{"enable_for_hours" => 2, "set_at" => @stored_set_at}}
          }
        }
      }

      tool =
        MCPCustomScopes.normalize_config(config, "custom", preserve_anchors: true)[
          "groups"
        ]["sessions"]["tools"]["Session_List"]

      assert tool["set_at"] == @stored_set_at
    end

    test "expired set_at window stays expired: does NOT lift, no expiry" do
      config = %{
        "groups" => %{
          "sessions" => %{
            "tools" => %{"Session_List" => %{"enable_for_hours" => 2, "set_at" => @stored_set_at}}
          }
        }
      }

      tool =
        MCPCustomScopes.normalize_config(config, "custom", preserve_anchors: true)[
          "groups"
        ]["sessions"]["tools"]["Session_List"]

      # set_at + 2h = 2026-08-30T02:00:00Z — long past evaluation time.
      refute Window.lifting?(tool)
      assert {true, nil, false} = Window.state(tool, DateTime.utc_now())
    end

    test "within the window, expiry anchors to the ORIGINAL set_at (not now)" do
      config = %{
        "groups" => %{
          "sessions" => %{
            "tools" => %{"Session_List" => %{"enable_for_hours" => 2, "set_at" => @stored_set_at}}
          }
        }
      }

      tool =
        MCPCustomScopes.normalize_config(config, "custom", preserve_anchors: true)[
          "groups"
        ]["sessions"]["tools"]["Session_List"]

      assert {true, ~U[2026-08-30T02:00:00Z], true} = Window.state(tool, ~U[2026-08-30T01:00:00Z])
    end

    test "unanchored / malformed-anchor entries gain NO anchor (stay inert)" do
      base = %{
        "groups" => %{"sessions" => %{"tools" => %{"Session_List" => %{"enable_for_hours" => 2}}}}
      }

      tool =
        MCPCustomScopes.normalize_config(base, "custom", preserve_anchors: true)["groups"][
          "sessions"
        ]["tools"]["Session_List"]

      assert tool["enable_for_hours"] == 2
      refute Map.has_key?(tool, "set_at")
      refute Window.lifting?(tool)

      bad = %{
        "groups" => %{
          "sessions" => %{
            "tools" => %{"Session_List" => %{"enable_for_hours" => 2, "set_at" => "garbage"}}
          }
        }
      }

      tool2 =
        MCPCustomScopes.normalize_config(bad, "custom", preserve_anchors: true)["groups"][
          "sessions"
        ]["tools"]["Session_List"]

      refute Map.has_key?(tool2, "set_at")
      refute Window.lifting?(tool2)
    end

    test "default (write) normalization still stamps fresh set_at" do
      config = %{
        "groups" => %{
          "sessions" => %{
            "tools" => %{"Session_List" => %{"enable_for_hours" => 2, "set_at" => @stored_set_at}}
          }
        }
      }

      tool =
        MCPCustomScopes.normalize_config(config, "custom")["groups"]["sessions"]["tools"][
          "Session_List"
        ]

      refute tool["set_at"] == @stored_set_at
      assert {:ok, %DateTime{}, _} = DateTime.from_iso8601(tool["set_at"])
    end
  end

  describe "MCPCustomScope.changeset/2 window validation" do
    defp config_changeset(config) do
      MCPCustomScope.changeset(%MCPCustomScope{}, %{
        "slug" => "win-test",
        "name" => "win test",
        "config" => config
      })
    end

    test "valid window config passes" do
      cs =
        config_changeset(%{
          "groups" => %{
            "sessions" => %{
              "tools" => %{
                "Session_Create" => %{"hide_until" => "2026-09-07T12:00:00Z"},
                "Session_List" => %{"enable_for_hours" => 24}
              }
            }
          }
        })

      refute cs.errors[:config]
    end

    test "mutually exclusive pair on a tool entry is rejected with the entry path" do
      cs =
        config_changeset(%{
          "groups" => %{
            "sessions" => %{
              "tools" => %{
                "Session_Create" => %{
                  "hide_until" => "2026-09-07T12:00:00Z",
                  "enable_for_hours" => 24
                }
              }
            }
          }
        })

      assert [{:config, {msg, _}}] = cs.errors
      assert msg =~ "groups.sessions.tools.Session_Create"
      assert msg =~ "mutually exclusive"
    end

    test "zero enable_for_hours is rejected with the entry path" do
      cs =
        config_changeset(%{
          "groups" => %{
            "projects" => %{"tools" => %{"Project_List" => %{"enable_for_hours" => 0}}}
          }
        })

      assert [{:config, {msg, _}}] = cs.errors
      assert msg =~ "groups.projects.tools.Project_List"
      assert msg =~ "positive integer"
    end

    test "invalid hide_until value is rejected" do
      cs =
        config_changeset(%{
          "groups" => %{"sessions" => %{"tools" => %{"Session_List" => %{"hide_until" => 42}}}}
        })

      assert [{:config, {msg, _}}] = cs.errors
      assert msg =~ "invalid datetime"
    end

    test "non-map config still rejected" do
      cs = config_changeset("bogus")
      assert cs.errors[:config]
    end
  end
end
