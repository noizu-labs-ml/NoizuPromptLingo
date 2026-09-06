defmodule NoizuPromptLingua.MCP.UrlToolsetParamTest do
  @moduledoc """
  Alacarte `?t=` URL tool-selection parameter: the decode error taxonomy and
  the full compile precedence matrix (white-list > black-list > white-list
  visible flags > tools map), bounded by the scope's included groups.

  decode/compile are pure (catalog walks are module-backed) — no DB rows here.
  """

  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.MCP.UrlToolsetParam

  # sessions with a stored-disabled tool + tickets wide open. The universe is
  # the two groups' live catalogs (canonical underscore names).
  @scope %{
    "kind" => "custom",
    "config" => %{
      "groups" => %{
        "sessions" => %{"tools" => %{"Session_List" => %{"disabled" => true}}},
        "tickets" => %{"tools" => %{}}
      }
    }
  }

  defp encode(spec), do: Base.url_encode64(Jason.encode!(spec), padding: false)

  defp compile_ok!(spec, scope \\ @scope) do
    assert {:ok, layer} = UrlToolsetParam.compile(spec, scope)
    layer
  end

  defp flags(layer, group, tool),
    do: get_in(layer, ["groups", group, "tools", tool]) || :absent

  # ── decode/1: error taxonomy ────────────────────────────────────────────────

  describe "decode/1" do
    test "nil and empty are absent (byte-identical no-param behavior)" do
      assert UrlToolsetParam.decode(nil) == :absent
      assert UrlToolsetParam.decode("") == :absent
    end

    test "raw size cap: >12_000 chars" do
      assert {:error, :too_large} = UrlToolsetParam.decode(String.duplicate("a", 12_001))
    end

    test "charset guard rejects base64-standard and whitespace spellings" do
      assert {:error, :invalid_charset} = UrlToolsetParam.decode("ab+cd")
      assert {:error, :invalid_charset} = UrlToolsetParam.decode("ab/cd")
      assert {:error, :invalid_charset} = UrlToolsetParam.decode("ab cd")
    end

    test "bad base64" do
      # length ≡ 1 (mod 4) is never valid base64
      assert {:error, :invalid_base64} = UrlToolsetParam.decode("abcde")
    end

    test "valid base64 of non-JSON" do
      assert {:error, :invalid_json} = UrlToolsetParam.decode("abcd")
    end

    test "decoded size cap: >8_192 decoded bytes (under the 12_000 raw-char cap)" do
      # ~8.6KB key: decoded ≈ 8.6KB (>8_192) while raw base64 ≈ 11.5KB (<12_000)
      spec = %{"tools" => %{String.duplicate("a", 8_600) => true}}
      assert {:error, :too_large_decoded} = UrlToolsetParam.decode(encode(spec))
    end

    test "padded base64url is accepted (decoder re-pads)" do
      padded = Base.url_encode64(Jason.encode!(%{}), padding: true)
      assert {:ok, %{}} = UrlToolsetParam.decode(padded)
    end

    test "unknown top-level keys are rejected (fail-closed)" do
      assert {:error, {:invalid_shape, msg}} = UrlToolsetParam.decode(encode(%{"bogus" => 1}))
      assert msg =~ "bogus"
    end

    test "non-object JSON is rejected" do
      assert {:error, {:invalid_shape, _}} = UrlToolsetParam.decode(encode([1, 2]))
    end

    test "list/tools entries must be booleans or {\"visible\": bool}" do
      assert {:error, {:invalid_shape, _}} =
               UrlToolsetParam.decode(encode(%{"white-list" => %{"Session_List" => "yes"}}))

      assert {:error, {:invalid_shape, _}} =
               UrlToolsetParam.decode(encode(%{"tools" => %{"Session_List" => %{"extra" => 1}}}))
    end

    test "empty tool names are rejected" do
      assert {:error, {:invalid_shape, _}} =
               UrlToolsetParam.decode(encode(%{"black-list" => %{"" => true}}))
    end

    test "default must be true or a preset slug" do
      assert {:error, {:invalid_shape, _}} = UrlToolsetParam.decode(encode(%{"default" => false}))
      assert {:error, {:invalid_shape, _}} = UrlToolsetParam.decode(encode(%{"default" => 1}))
      assert {:error, {:invalid_shape, _}} = UrlToolsetParam.decode(encode(%{"default" => ""}))
    end

    test "a valid spec round-trips" do
      spec = %{
        "white-list" => %{"Session_List" => true},
        "black-list" => %{"Session_Get" => true},
        "tools" => %{"Session_Create" => %{"visible" => true}},
        "default" => "core"
      }

      assert {:ok, ^spec} = UrlToolsetParam.decode(encode(spec))
    end

    # ── snake_case aliases (golden vectors, both spellings) ────────────────────

    test "white_list/black_list aliases normalize to the kebab-case spec" do
      snake = %{
        "white_list" => %{"Session_List" => true},
        "black_list" => %{"Session_Get" => true}
      }

      kebab = %{
        "white-list" => %{"Session_List" => true},
        "black-list" => %{"Session_Get" => true}
      }

      assert UrlToolsetParam.decode(encode(snake)) == {:ok, kebab}
    end

    test "aliases are rejected when BOTH spellings of a section are present" do
      ambiguous = %{"white-list" => %{"Session_List" => true}, "white_list" => %{}}
      assert {:error, {:invalid_shape, msg}} = UrlToolsetParam.decode(encode(ambiguous))
      assert msg =~ "white_list" and msg =~ "white-list"

      ambiguous_black = %{"black-list" => %{}, "black_list" => %{}}
      assert {:error, {:invalid_shape, msg}} = UrlToolsetParam.decode(encode(ambiguous_black))
      assert msg =~ "black_list" and msg =~ "black-list"
    end
  end

  # ── compile/2: the precedence matrix ────────────────────────────────────────

  describe "compile/1 precedence: white-list defines the enable set" do
    test "in-set tools enabled, absent-from-set disabled across ALL groups" do
      layer = compile_ok!(%{"white-list" => %{"Session_List" => true}})

      # a white-list pick implies visibility (the selection is what tools/list shows)
      assert flags(layer, "sessions", "Session_List") == %{
               "disabled" => false,
               "hidden" => false
             }

      assert flags(layer, "sessions", "Session_Create") == %{"disabled" => true}
      assert flags(layer, "sessions", "Session_Manifest") == %{"disabled" => true}
      assert flags(layer, "tickets", "Ticket_List") == %{"disabled" => true}
    end

    test "empty white-list disables the whole universe" do
      layer = compile_ok!(%{"white-list" => %{}})
      assert flags(layer, "sessions", "Session_Create") == %{"disabled" => true}
      assert flags(layer, "tickets", "Ticket_Get") == %{"disabled" => true}
    end

    test "white-list beats black-list" do
      layer =
        compile_ok!(%{
          "white-list" => %{"Session_List" => true},
          "black-list" => %{"Session_List" => true, "Session_Create" => true}
        })

      # white-list wins over the black-list: enabled AND visible
      assert flags(layer, "sessions", "Session_List") == %{
               "disabled" => false,
               "hidden" => false
             }

      assert flags(layer, "sessions", "Session_Create") == %{"disabled" => true}
    end

    test "white-list visible:false = enabled but hidden" do
      layer = compile_ok!(%{"white-list" => %{"Session_List" => %{"visible" => false}}})

      assert flags(layer, "sessions", "Session_List") == %{"disabled" => false, "hidden" => true}
    end

    test "snake_case aliases compile to the IDENTICAL layer (golden vector)" do
      kebab = compile_ok!(%{"white-list" => %{"Session_List" => true}})
      snake = compile_ok!(%{"white_list" => %{"Session_List" => true}})
      assert snake == kebab

      kebab = compile_ok!(%{"black-list" => %{"Session_List" => true}})
      snake = compile_ok!(%{"black_list" => %{"Session_List" => true}})
      assert snake == kebab
    end
  end

  describe "compile/1 precedence: black-list (unconstrained)" do
    test "black-list disables; other tools carry no opinions" do
      layer = compile_ok!(%{"black-list" => %{"Session_List" => true}})

      assert flags(layer, "sessions", "Session_List") == %{"disabled" => true}
      assert flags(layer, "sessions", "Session_Create") == %{}
      assert flags(layer, "tickets", "Ticket_List") == %{}
    end

    test "black-list false is inert" do
      layer = compile_ok!(%{"black-list" => %{"Session_List" => false}})
      assert flags(layer, "sessions", "Session_List") == %{}
    end
  end

  describe "compile/1 precedence: default expansions" do
    test "default:true = stored-enabled; black-list trims it" do
      layer =
        compile_ok!(%{"default" => true, "black-list" => %{"Session_Create" => true}})

      # stored-disabled Session_List stays disabled (out of the stored-enabled set)
      assert flags(layer, "sessions", "Session_List") == %{"disabled" => true}
      # stored-enabled but blacklisted
      assert flags(layer, "sessions", "Session_Create") == %{"disabled" => true}
      # stored-enabled, untouched (in-set => explicit disabled:false)
      assert flags(layer, "tickets", "Ticket_Get") == %{"disabled" => false}
    end

    test "default:\"core\" expands the core preset bounded by the universe" do
      layer = compile_ok!(%{"default" => "core"})

      assert flags(layer, "sessions", "Session_Create") == %{"disabled" => false}
      assert flags(layer, "sessions", "Session_Overview") == %{"disabled" => false}
      assert flags(layer, "sessions", "Session_Manifest") == %{"disabled" => false}
      assert flags(layer, "sessions", "Session_Get") == %{"disabled" => true}

      # tickets has no core set — the preset decides, bounded by the universe
      assert flags(layer, "tickets", "Ticket_List") == %{"disabled" => true}
    end

    test "default:\"full\" enables every universe tool (full covers all customizable groups)" do
      layer = compile_ok!(%{"default" => "full"})

      assert flags(layer, "sessions", "Session_Archive") == %{"disabled" => false}
      assert flags(layer, "sessions", "Session_Manifest") == %{"disabled" => false}
      assert flags(layer, "tickets", "Ticket_List") == %{"disabled" => false}
      assert flags(layer, "tickets", "Ticket_Comment") == %{"disabled" => false}
    end

    test "default:\"basic_crud\" keeps the entity CRUD set" do
      layer = compile_ok!(%{"default" => "basic_crud"})

      assert flags(layer, "tickets", "Ticket_List") == %{"disabled" => false}
      assert flags(layer, "tickets", "Ticket_Comment") == %{"disabled" => true}
      assert flags(layer, "sessions", "Session_Create") == %{"disabled" => false}
      assert flags(layer, "sessions", "Session_Archive") == %{"disabled" => true}
    end

    test "unknown preset errors" do
      assert {:error, {:unknown_preset, "nope"}} =
               UrlToolsetParam.compile(%{"default" => "nope"}, @scope)
    end

    test "white-list and default union into one enable set" do
      layer =
        compile_ok!(%{"default" => "core", "white-list" => %{"Ticket_List" => true}})

      assert flags(layer, "sessions", "Session_Create")["disabled"] == false
      assert flags(layer, "tickets", "Ticket_List")["disabled"] == false
      assert flags(layer, "tickets", "Ticket_Comment") == %{"disabled" => true}
    end
  end

  describe "compile/1 precedence: tools map (lowest)" do
    test "visible re-enables a stored-disabled tool when unconstrained" do
      layer = compile_ok!(%{"tools" => %{"Session_List" => %{"visible" => true}}})

      assert flags(layer, "sessions", "Session_List") == %{
               "disabled" => false,
               "hidden" => false
             }

      assert flags(layer, "sessions", "Session_Create") == %{}
    end

    test "true is the visible:true shorthand; visible:false hides" do
      layer =
        compile_ok!(%{
          "tools" => %{"Session_List" => true, "Session_Create" => %{"visible" => false}}
        })

      assert flags(layer, "sessions", "Session_List") == %{
               "disabled" => false,
               "hidden" => false
             }

      assert flags(layer, "sessions", "Session_Create") == %{"hidden" => true}
    end

    test "a constrained enable set cannot be re-entered via the tools map" do
      layer =
        compile_ok!(%{
          "white-list" => %{"Session_Create" => true},
          "tools" => %{"Session_List" => %{"visible" => true}}
        })

      assert flags(layer, "sessions", "Session_List") == %{"disabled" => true}
      assert flags(layer, "sessions", "Session_Create") == %{
               "disabled" => false,
               "hidden" => false
             }
    end

    test "visible:false still hides under a constrained set (narrowing is safe)" do
      layer =
        compile_ok!(%{
          "white-list" => %{"Session_Create" => true, "Session_Overview" => true},
          "tools" => %{"Session_Overview" => %{"visible" => false}}
        })

      assert flags(layer, "sessions", "Session_Overview") == %{
               "disabled" => false,
               "hidden" => true
             }
    end

    test "dotted tool-name aliases are canonicalized (F5: lookup points accept either form)" do
      # white-list pick (implies visibility) …
      layer = compile_ok!(%{"white-list" => %{"Ticket.List" => true}})
      assert flags(layer, "tickets", "Ticket_List") == %{
               "disabled" => false,
               "hidden" => false
             }

      # … and an unconstrained tools-map re-enable, both via the dotted alias
      layer = compile_ok!(%{"tools" => %{"Session.List" => %{"visible" => true}}})

      assert flags(layer, "sessions", "Session_List") == %{
               "disabled" => false,
               "hidden" => false
             }
    end
  end

  describe "compile/1 universe bounds" do
    test "entries outside the universe are dead" do
      layer =
        compile_ok!(%{"white-list" => %{"Organization_List" => true, "Nonexistent_Tool" => true}})

      names =
        layer["groups"]
        |> Enum.flat_map(fn {_gid, g} -> Map.keys(g["tools"]) end)

      assert "Organization_List" not in names
      assert "Nonexistent_Tool" not in names
    end

    test "include set is invariant: layer groups == scope groups" do
      layer = compile_ok!(%{"white-list" => %{"Ticket_List" => true}})
      assert MapSet.new(Map.keys(layer["groups"])) == MapSet.new(["sessions", "tickets"])
    end

    test "group-disabled groups contribute nothing" do
      scope = %{
        "kind" => "custom",
        "config" => %{
          "groups" => %{"sessions" => %{}, "tickets" => %{"disabled" => true}}
        }
      }

      layer = compile_ok!(%{"white-list" => %{"Ticket_List" => true}}, scope)
      assert layer["groups"]["tickets"]["tools"] == %{}
      assert flags(layer, "sessions", "Session_Create") == %{"disabled" => true}
    end

    test "accepts a real scope struct and nil scope" do
      struct_scope = %NoizuPromptLingua.Schema.MCPCustomScope{
        kind: "custom",
        config: @scope["config"]
      }

      assert {:ok, _} = UrlToolsetParam.compile(%{"white-list" => %{"Session_List" => true}}, struct_scope)

      # nil scope: empty universe, layer is inert — never a widening vehicle
      assert {:ok, layer} = UrlToolsetParam.compile(%{"white-list" => %{"Session_List" => true}}, nil)
      assert layer["groups"] == %{}
    end
  end
end
