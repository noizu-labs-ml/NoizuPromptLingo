defmodule NoizuPromptLingua.Domains.RemoteAccessTest do
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.RemoteAccess
  alias NoizuPromptLingua.Repo

  setup do
    {:ok, org_id: insert_org(), user_id: Ecto.UUID.generate()}
  end

  test "claim / re-claim / name-taken / revoke / not-found lifecycle", %{
    org_id: org_id,
    user_id: user_id
  } do
    assert {:ok, tunnel, raw_token} = RemoteAccess.claim_tunnel(user_id, org_id, "My-Tunnel ")
    assert tunnel.name == "my-tunnel"
    assert tunnel.status == "active"
    assert is_binary(raw_token) and byte_size(raw_token) > 16
    refute tunnel.tunnel_token_hash == raw_token

    # Re-claim by the same user rotates the token
    assert {:ok, tunnel2, raw2} = RemoteAccess.claim_tunnel(user_id, org_id, "my-tunnel")
    assert tunnel2.id == tunnel.id
    assert raw2 != raw_token

    # Another user cannot take the name
    assert {:error, :name_taken} =
             RemoteAccess.claim_tunnel(Ecto.UUID.generate(), org_id, "my-tunnel")

    assert [claimed] = RemoteAccess.list_tunnels(user_id, org_id)
    assert claimed.id == tunnel.id

    # Only the owner can revoke
    assert {:error, :not_owner} = RemoteAccess.revoke_tunnel(Ecto.UUID.generate(), "my-tunnel")
    assert {:ok, revoked} = RemoteAccess.revoke_tunnel(user_id, "my-tunnel")
    assert revoked.status == "revoked"
    assert {:error, :not_found} = RemoteAccess.revoke_tunnel(user_id, "my-tunnel")

    # Revoked names can be re-claimed by others
    assert {:ok, _, _} = RemoteAccess.claim_tunnel(Ecto.UUID.generate(), org_id, "my-tunnel")
  end

  test "authorize_login / authorize_proxy / mark_disconnected validate tokens", %{
    org_id: org_id,
    user_id: user_id
  } do
    assert {:ok, tunnel, raw_token} = RemoteAccess.claim_tunnel(user_id, org_id, "frp-tunnel")

    assert :ok = RemoteAccess.authorize_login(raw_token)
    assert :deny = RemoteAccess.authorize_login("bogus-token")
    assert :deny = RemoteAccess.authorize_login(nil)

    assert :ok = RemoteAccess.authorize_proxy(raw_token, "FRP-Tunnel")
    assert :deny = RemoteAccess.authorize_proxy(raw_token, "other-name")
    assert :deny = RemoteAccess.authorize_proxy("bogus", "frp-tunnel")
    assert :deny = RemoteAccess.authorize_proxy(nil, "frp-tunnel")

    assert RemoteAccess.connected?("frp-tunnel")
    assert {:ok, _} = RemoteAccess.mark_disconnected(raw_token)
    refute RemoteAccess.connected?("frp-tunnel")
    assert :ok = RemoteAccess.mark_disconnected("bogus")

    assert is_binary(tunnel.name)
  end

  test "expired claims fail authorization", %{org_id: org_id, user_id: user_id} do
    assert {:ok, _tunnel, raw_token} =
             RemoteAccess.claim_tunnel(user_id, org_id, "old-tunnel", ttl_days: 0)

    # ttl 0 days expires immediately (± truncation to the second)
    Process.sleep(1100)
    assert :deny = RemoteAccess.authorize_login(raw_token)
  end

  defp insert_org do
    slug = "ra-org-#{System.unique_integer([:positive])}"

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "Remote Access Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
