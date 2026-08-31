defmodule NoizuPromptLingua.OAuth.ConsentManifestTest do
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.OAuth.ConsentManifest

  @sections [
    %{group: "chat", label: "Chat", required: false, tools: ["Chat_Send", "Chat_List"]},
    %{group: "sessions", label: "Sessions", required: true, tools: ["Session_Create"]},
    %{group: "tickets", label: "Tickets", required: false, tools: []}
  ]

  describe "narrowing/2" do
    test "fully-allowed request yields empty narrowing (legacy behavior)" do
      params = %{
        "allow_group" => %{"chat" => "on", "sessions" => "on", "tickets" => "on"},
        "allow_tool" => %{"chat" => %{"Chat_Send" => "on", "Chat_List" => "on"}}
      }

      assert ConsentManifest.narrowing(@sections, params) == %{"groups" => %{}}
    end

    test "missing params entirely (no checkboxes submitted) narrows every optional group" do
      narrowing = ConsentManifest.narrowing(@sections, %{})

      assert narrowing["groups"]["chat"] == %{"disabled" => true}
      assert narrowing["groups"]["tickets"] == %{"disabled" => true}
      # Required groups are never narrowed.
      refute Map.has_key?(narrowing["groups"], "sessions")
    end

    test "unchecked tool narrows only that tool" do
      params = %{
        "allow_group" => %{"chat" => "on"},
        "allow_tool" => %{"chat" => %{"Chat_Send" => "on"}}
      }

      assert ConsentManifest.narrowing(@sections, params) == %{
               "groups" => %{
                 "chat" => %{"tools" => %{"Chat_List" => %{"disabled" => true}}},
                 "tickets" => %{"disabled" => true}
               }
             }
    end

    test "group unchecked wins even if some tools remain checked" do
      params = %{
        "allow_tool" => %{"chat" => %{"Chat_Send" => "on"}}
      }

      assert ConsentManifest.narrowing(@sections, params)["groups"]["chat"] == %{"disabled" => true}
    end

    test "tolerates non-map params (absent nesting)" do
      params = %{"allow_group" => nil, "allow_tool" => "garbage"}

      assert %{"groups" => groups} = ConsentManifest.narrowing(@sections, params)
      assert groups["chat"] == %{"disabled" => true}
    end
  end

  describe "sections/0" do
    test "one section per tobor default-package group with required keys" do
      sections = ConsentManifest.sections()

      expected_groups = MapSet.new(NoizuPromptLingua.MCPCustomScopes.default_package_groups())

      assert length(sections) > 0
      assert MapSet.new(sections, & &1.group) == expected_groups

      for section <- sections do
        assert is_binary(section.group)
        assert is_binary(section.label)
        assert is_boolean(section.required)
        assert is_list(section.tools)
        assert Enum.all?(section.tools, &is_binary/1)
      end

      required = MapSet.new(NoizuPromptLingua.MCPServers.required_ids())

      for section <- sections do
        assert section.required == MapSet.member?(required, section.group)
      end
    end
  end
end
