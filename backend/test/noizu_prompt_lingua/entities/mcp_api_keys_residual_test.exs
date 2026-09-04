defmodule NoizuPromptLingua.MCPApiKeysResidualTest do
  use NoizuPromptLingua.DataCase

  @moduledoc """
  Residual MCPApiKeys context paths not hit by the primary keys suite:
  list_all/list_for_user, get guards, parse_expires_at branches,
  normalize_toolset guards, and verify_api_key's prefix bucketing.
  """

  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema

  setup do
    n = System.unique_integer([:positive])

    user =
      %UserSchema{
        email: "res-#{n}@example.com",
        user_name: "res_user#{n}",
        handle: "res_h#{n}",
        status: :active
      }
      |> Repo.insert!()

    %{user: user}
  end

  test "list_all / list_for_user / get guards", %{user: user} do
    {:ok, key, _raw} = MCPApiKeys.generate_api_key(user.id, "listing")
    key_id = key.id

    assert Enum.any?(MCPApiKeys.list_all(), &(&1.id == key_id))
    assert [%{id: ^key_id}] = MCPApiKeys.list_for_user(user.id)
    assert [] == MCPApiKeys.list_for_user(Ecto.UUID.generate())

    assert %{} = MCPApiKeys.get(key_id)
    assert nil == MCPApiKeys.get(:not_a_binary)
  end

  test "parse_expires_at branches" do
    assert {:ok, nil} = MCPApiKeys.parse_expires_at(nil)
    assert {:ok, nil} = MCPApiKeys.parse_expires_at("")

    assert {:ok, %DateTime{}} = MCPApiKeys.parse_expires_at("2030-01-01T00:00:00Z")
    # present but unparseable ⇒ :error
    assert :error = MCPApiKeys.parse_expires_at("not-a-date")
    # present but in the past ⇒ :error
    assert :error = MCPApiKeys.parse_expires_at("2020-01-01T00:00:00Z")
    assert :error = MCPApiKeys.parse_expires_at(42)
  end

  test "normalize_toolset guards non-map input" do
    assert MCPApiKeys.normalize_toolset(%{"groups" => %{}}) == %{"groups" => %{}}
    assert MCPApiKeys.normalize_toolset("junk") == %{"groups" => %{}}
    assert MCPApiKeys.normalize_toolset(nil) == %{"groups" => %{}}
  end

  test "verify_api_key rejects unknown prefixes and bad secrets", %{user: user} do
    {:ok, _key, raw} = MCPApiKeys.generate_api_key(user.id, "verify")

    # unknown prefix bucket ⇒ nil (no key candidates)
    assert nil == MCPApiKeys.verify_api_key("zznope-" <> raw)
    refute match?({:ok, _}, MCPApiKeys.verify_api_key(raw <> "tampered"))
  end
end
