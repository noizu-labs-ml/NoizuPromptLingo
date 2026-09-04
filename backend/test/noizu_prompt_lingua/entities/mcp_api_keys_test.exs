defmodule NoizuPromptLingua.MCPApiKeysTest do
  use NoizuPromptLingua.DataCase

  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCPCustomScopes

  setup do
    uniq = System.unique_integer([:positive])

    user =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "keys-#{uniq}@example.com",
        user_name: "keyuser#{uniq}",
        handle: "ku#{uniq}",
        status: :active
      }
      |> NoizuPromptLingua.Repo.insert!()

    %{user: user}
  end

  test "generate_api_key persists prefix+hash and returns raw once", %{user: user} do
    assert {:ok, key, raw} = MCPApiKeys.generate_api_key(user.id, "ci")
    assert String.starts_with?(raw, key.key_prefix)
    assert byte_size(key.key_prefix) == 8
    refute Map.has_key?(MCPApiKeys.mask(key), :key_hash)
    assert key.status == "active"
    assert key.toolset_config == %{}
  end

  test "generate_api_key accepts a normalized toolset_config", %{user: user} do
    config = %{
      "groups" => %{
        "sessions" => %{"disabled" => true},
        "tickets" => %{"tools" => %{"Ticket.List" => %{"hidden" => true}}}
      }
    }

    {:ok, key, _raw} = MCPApiKeys.generate_api_key(user.id, "ts", toolset_config: config)

    assert key.toolset_config["groups"]["sessions"]["disabled"] == true
    assert key.toolset_config["groups"]["tickets"]["tools"]["Ticket.List"]["hidden"] == true
  end

  test "normalize_toolset drops unknown groups and non-boolean flags", %{user: user} do
    config = %{
      "groups" => %{
        "sessions" => %{"disabled" => "yes", "hidden" => true, "bogus" => 1},
        "no_such_group" => %{"disabled" => true}
      },
      "junk" => true
    }

    {:ok, key, _raw} = MCPApiKeys.generate_api_key(user.id, "norm", toolset_config: config)
    groups = key.toolset_config["groups"]

    refute Map.has_key?(groups, "no_such_group")
    refute Map.has_key?(key.toolset_config, "junk")
    # non-boolean disabled is dropped; hidden survives
    refute Map.has_key?(groups["sessions"], "disabled")
    assert groups["sessions"]["hidden"] == true
  end

  test "update normalizes toolset and honors owner_id guard", %{user: user} do
    {:ok, key, _raw} = MCPApiKeys.generate_api_key(user.id, "upd")

    {:ok, updated} =
      MCPApiKeys.update(
        key,
        %{toolset_config: %{"groups" => %{"projects" => %{"hidden" => true}}}}, owner_id: user.id)

    assert updated.toolset_config["groups"]["projects"]["hidden"] == true

    # wrong owner is forbidden
    assert {:error, :forbidden} =
             MCPApiKeys.update(key, %{label: "nope"}, owner_id: Ecto.UUID.generate())

    # admin path (no owner_id) works
    assert {:ok, _} = MCPApiKeys.update(key, %{label: "admin-label"})
  end

  test "update with no toolset_config arg leaves stored config untouched", %{user: user} do
    {:ok, key, _raw} =
      MCPApiKeys.generate_api_key(user.id, "keep",
        toolset_config: %{"groups" => %{"sessions" => %{"hidden" => true}}}
      )

    {:ok, updated} = MCPApiKeys.update(key, %{label: "renamed"}, owner_id: user.id)

    assert updated.label == "renamed"
    assert updated.toolset_config["groups"]["sessions"]["hidden"] == true
  end

  test "clone carries toolset config and produces a fresh secret", %{user: user} do
    {:ok, source, raw_source} =
      MCPApiKeys.generate_api_key(user.id, "orig",
        toolset_config: %{
          "groups" => %{"tickets" => %{"tools" => %{"Ticket.Get" => %{"disabled" => true}}}}
        }
      )

    {:ok, clone, raw_clone} = MCPApiKeys.clone(source, user_id: user.id, label: "clone")

    assert clone.id != source.id
    assert clone.label == "clone"
    assert raw_clone != raw_source
    assert String.starts_with?(raw_clone, clone.key_prefix)

    assert clone.toolset_config["groups"]["tickets"]["tools"]["Ticket.Get"]["disabled"] == true
    assert source.toolset_config["groups"]["tickets"]["tools"]["Ticket.Get"]["disabled"] == true
  end

  test "clone by id and default label fallback", %{user: user} do
    {:ok, source, _raw} = MCPApiKeys.generate_api_key(user.id, "by-id")

    {:ok, clone, _raw} = MCPApiKeys.clone(source.id)

    assert clone.user_id == user.id
    assert clone.label == "by-id"
  end

  test "copy_toolset_from adopts a custom scope's config", %{user: user} do
    {:ok, scope} =
      MCPCustomScopes.create(%{
        "slug" => "adopt-me",
        "name" => "Adopt Me",
        "config" => %{
          "groups" => %{
            "sessions" => %{"hidden" => true},
            "projects" => %{"tools" => %{"Project.List" => %{"disabled" => true}}}
          }
        }
      })

    {:ok, key, _raw} = MCPApiKeys.generate_api_key(user.id, "adopter")

    {:ok, updated} = MCPApiKeys.copy_toolset_from(key, "adopt-me")

    assert updated.toolset_config["groups"]["sessions"]["hidden"] == true

    assert updated.toolset_config["groups"]["projects"]["tools"]["Project.List"]["disabled"] ==
             true

    # by UUID too
    {:ok, key2, _raw} = MCPApiKeys.generate_api_key(user.id, "adopter2")
    {:ok, updated2} = MCPApiKeys.copy_toolset_from(key2, scope.id)
    assert updated2.toolset_config["groups"]["sessions"]["hidden"] == true

    assert {:error, :not_found} = MCPApiKeys.copy_toolset_from(key, "no-such-scope")
  end

  test "mask exposes prefix + toolset, never hash or raw", %{user: user} do
    {:ok, key, raw} = MCPApiKeys.generate_api_key(user.id, "mask")
    masked = MCPApiKeys.mask(key)

    refute Map.has_key?(masked, :key_hash)
    refute masked[:key_prefix] == raw
    assert masked[:key_prefix] == key.key_prefix
    assert Map.has_key?(masked, :toolset_config)

    assert MCPApiKeys.mask(nil) == nil
  end

  test "revoke flips status; get finds any status", %{user: user} do
    {:ok, key, _raw} = MCPApiKeys.generate_api_key(user.id, "revoke-me")

    {:ok, revoked} = MCPApiKeys.revoke(key.id)
    assert revoked.status == "revoked"
    assert %{} = MCPApiKeys.get(key.id)
  end
end
