defmodule NoizuPromptLingua.Domains.Memory.AgentsTest do
  @moduledoc "Call-sign registry — PG only, no Weaviate."
  use NoizuPromptLingua.MemoryCase, async: false

  test "register with an explicit call sign, then resolve by call sign and by uuid" do
    org = insert_org()
    {:ok, cs} = Agents.register(org, :team_member, call_sign: "viper", display_name: "Viper")
    assert cs.call_sign == "viper"
    assert cs.kind == :team_member

    assert {:ok, %{scope_type: :team_member, scope_id: id}} = Agents.resolve_scope(org, :team_member, "viper")
    assert id == cs.id
    assert Agents.resolve(org, cs.id).call_sign == "viper"
  end

  test "auto-generates a unique, well-formed call sign when none is supplied" do
    org = insert_org()
    {:ok, a} = Agents.register(org, :team_member)
    {:ok, b} = Agents.register(org, :team_member)
    assert a.call_sign != b.call_sign
    assert a.call_sign =~ ~r/^[a-z0-9][a-z0-9\-_]*$/
  end

  test "call signs are unique per organization" do
    org = insert_org()
    {:ok, _} = Agents.register(org, :weego, call_sign: "weego")
    assert {:error, _} = Agents.register(org, :team_member, call_sign: "weego")
  end

  test "the weego resolves without an explicit ref" do
    org = insert_org()
    {:ok, w} = Agents.register(org, :weego, call_sign: "weego")
    assert {:ok, %{scope_type: :weego, scope_id: id}} = Agents.resolve_scope(org, :weego, nil)
    assert id == w.id
  end

  test "persona scope resolves through the personas domain" do
    org = insert_org()
    pid = insert_persona(org, "ada")
    assert {:ok, %{scope_type: :persona, scope_id: ^pid}} = Agents.resolve_scope(org, :persona, "ada")
  end
end
