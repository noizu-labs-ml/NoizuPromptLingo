defmodule NoizuPromptLingua.MCP.KeysToolsTest do
  use NoizuPromptLingua.DataCase

  # Happy paths + self-scoping for the Key.* management MCP tools.

  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.MCP.Keys.Tools.{
    KeyClone,
    KeyCreate,
    KeyGet,
    KeyList,
    KeyRevoke,
    KeyUpdate
  }

  setup do
    uniq = System.unique_integer([:positive])

    user =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "kt-#{uniq}@example.com",
        user_name: "kt#{uniq}",
        handle: "kt#{uniq}",
        status: :active
      }
      |> NoizuPromptLingua.Repo.insert!()

    %{user: user, ctx: %Ctx{assigns: %{auth_claims: %{"sub" => user.id}}}}
  end

  test "Key.Create returns raw key exactly once + masked record", %{ctx: ctx} do
    {:ok, result} =
      KeyCreate.call(%{"label" => "cli"}, ctx)

    assert is_binary(result.raw_key) and result.raw_key != ""
    assert result.key[:key_prefix] == String.slice(result.raw_key, 0, 8)
    refute Map.has_key?(result.key, :key_hash)
  end

  test "Key.Create seeds toolset and adopts from scope", %{ctx: ctx, user: user} do
    {:ok, scope} =
      MCPCustomScopes.create(%{
        "slug" => "kt-seed",
        "name" => "KT Seed",
        "config" => %{"groups" => %{"sessions" => %{"hidden" => true}}}
      })

    {:ok, from_config} =
      KeyCreate.call(
        %{
          "label" => "t1",
          "toolset_config" => %{"groups" => %{"tickets" => %{"disabled" => true}}}
        },
        ctx
      )

    assert from_config.key[:toolset_config]["groups"]["tickets"]["disabled"] == true

    {:ok, from_scope} =
      KeyCreate.call(%{"label" => "t2", "toolset_from_scope" => scope.slug}, ctx)

    assert from_scope.key[:toolset_config]["groups"]["sessions"]["hidden"] == true

    # bad scope ref fails BEFORE minting — no orphan key
    assert {:error, msg} =
             KeyCreate.call(%{"label" => "t3", "toolset_from_scope" => "missing-scope"}, ctx)

    assert msg =~ "not found"
    assert length(MCPApiKeys.list_for_user(user.id)) == 2
  end

  test "Key.List masks and scopes to the caller", %{ctx: ctx, user: user} do
    uniq = System.unique_integer([:positive])

    other =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "other-#{uniq}@example.com",
        user_name: "other#{uniq}",
        handle: "o#{uniq}",
        status: :active
      }
      |> NoizuPromptLingua.Repo.insert!()

    {:ok, _, _} = MCPApiKeys.generate_api_key(user.id, "mine")
    {:ok, _, _} = MCPApiKeys.generate_api_key(other.id, "theirs")

    {:ok, result} = KeyList.call(%{}, ctx)

    assert result.count == 1
    assert hd(result.keys)[:label] == "mine"
  end

  test "Key.Get / Key.Update / Key.Clone / Key.Revoke lifecycle", %{ctx: ctx} do
    {:ok, created} = KeyCreate.call(%{"label" => "cycle"}, ctx)
    key_id = created.key[:id]

    {:ok, got} = KeyGet.call(%{"key" => key_id}, ctx)
    assert got.key[:label] == "cycle"
    assert got.key[:id] == key_id

    {:ok, updated} =
      KeyUpdate.call(
        %{
          "key" => key_id,
          "label" => "renamed",
          "toolset_config" => %{"groups" => %{"tickets" => %{"tools" => %{"Ticket.Get" => %{"hidden" => true}}}}}
        },
        ctx
      )

    assert updated.key[:label] == "renamed"

    assert updated.key[:toolset_config]["groups"]["tickets"]["tools"]["Ticket.Get"]["hidden"] ==
             true

    {:ok, cloned} = KeyClone.call(%{"key" => key_id, "label" => "twin"}, ctx)
    assert cloned.key[:label] == "twin"
    assert is_binary(cloned.raw_key)

    assert cloned.key[:toolset_config]["groups"]["tickets"]["tools"]["Ticket.Get"]["hidden"] ==
             true

    {:ok, revoked} = KeyRevoke.call(%{"key" => key_id}, ctx)
    assert revoked.key[:status] == "revoked"

    # revoked key's config survives but ownership check still works
    assert %{} = MCPApiKeys.get(key_id)
  end

  test "Key tools refuse to touch another user's key", %{ctx: ctx, user: user} do
    uniq = System.unique_integer([:positive])

    other =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "nope-#{uniq}@example.com",
        user_name: "nope#{uniq}",
        handle: "n#{uniq}",
        status: :active
      }
      |> NoizuPromptLingua.Repo.insert!()

    {:ok, other_key, _raw} = MCPApiKeys.generate_api_key(other.id, "foreign")
    _ = user

    assert {:error, msg} = KeyGet.call(%{"key" => other_key.id}, ctx)
    assert msg =~ "not found (or not yours)"

    assert {:error, msg} = KeyUpdate.call(%{"key" => other_key.id, "label" => "hax"}, ctx)
    assert msg =~ "not found (or not yours)"

    assert {:error, msg} = KeyClone.call(%{"key" => other_key.id}, ctx)
    assert msg =~ "not found (or not yours)"

    assert {:error, msg} = KeyRevoke.call(%{"key" => other_key.id}, ctx)
    assert msg =~ "not found (or not yours)"
  end

  test "unauthenticated ctx is rejected", %{} do
    assert {:error, "authentication required"} = KeyCreate.call(%{}, %Ctx{assigns: %{}})
    assert {:error, "authentication required"} = KeyList.call(%{}, %Ctx{assigns: %{}})
  end
end
