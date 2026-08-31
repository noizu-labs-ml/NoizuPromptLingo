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

    test "stamps enabled_at when anchoring enable_for_hours" do
      normalized = Window.normalize_entry(%{}, %{"enable_for_hours" => 24})

      assert normalized["enable_for_hours"] == 24
      assert {:ok, %DateTime{}, _} = DateTime.from_iso8601(normalized["enabled_at"])

      # anchor is fresh (stamped now)
      stamped = DateTime.from_iso8601(normalized["enabled_at"]) |> elem(1)
      assert DateTime.diff(DateTime.utc_now(), stamped) < 5
    end

    test "keeps an existing anchor (re-normalize does not slide the window)" do
      config = %{
        "enable_for_hours" => 24,
        "enabled_at" => "2026-08-30T00:00:00Z"
      }

      normalized = Window.normalize_entry(%{}, config)
      assert normalized["enabled_at"] == "2026-08-30T00:00:00Z"
    end

    test "drops invalid values silently (strict rejection lives on the changeset)" do
      assert Window.normalize_entry(%{}, %{"hide_until" => "someday"}) == %{}
      assert Window.normalize_entry(%{}, %{"enable_for_hours" => 0}) == %{}
      assert Window.normalize_entry(%{}, %{"hide_until" => @future, "enable_for_hours" => 24}) == %{}
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

      tool = MCPCustomScopes.normalize_config(config, "custom")["groups"]["sessions"]["tools"]["Session_List"]
      assert tool["enable_for_hours"] == 48
      assert is_binary(tool["enabled_at"])
    end

    test "evaluates end-to-end after normalization round-trip" do
      config = %{
        "groups" => %{
          "sessions" => %{"tools" => %{"Session_Create" => %{"hide_until" => "2026-09-07T12:00:00Z"}}}
        }
      }

      tool = MCPCustomScopes.normalize_config(config, "custom")["groups"]["sessions"]["tools"]["Session_Create"]
      assert {false, %DateTime{}} = Window.evaluate(tool, @now)
      assert {true, nil} = Window.evaluate(tool, ~U[2026-09-08 12:00:00Z])
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
                "Session_Create" => %{"hide_until" => "2026-09-07T12:00:00Z", "enable_for_hours" => 24}
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
