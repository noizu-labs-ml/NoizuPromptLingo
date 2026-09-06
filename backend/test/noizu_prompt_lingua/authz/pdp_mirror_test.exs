defmodule NoizuPromptLingua.Authz.PdpMirrorTest do
  use NoizuPromptLingua.DataCase, async: false
  @moduletag :db

  alias NoizuPromptLingua.Authz.Pdp
  alias NoizuPromptLingua.Authz.Pdp.Mirror
  alias NoizuPromptLingua.OAuth.Clients
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.McpPairingGrant
  alias NoizuPromptLingua.Schema.Users.User

  setup do
    NoizuPromptLingua.OAuthTestSchema.ensure!()

    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "mirror-#{uniq}@example.com",
        user_name: "mirror#{uniq}",
        handle: "mirror#{uniq}",
        status: :active,
        verified: true,
        flagged: false
      }
      |> Repo.insert!()

    %{user: user}
  end

  test "mirror_pairing_grant! creates an active grant the local PDP honors", %{user: user} do
    resource = "https://mirror.example/mcp"

    {:ok, reg} = register_client("mirror-cli")
    client_id = reg["client_id"]

    grant = Mirror.mirror_pairing_grant!(user.id, client_id, resource)

    assert %McpPairingGrant{} = grant
    assert grant.status == "active"
    assert grant.grant_id =~ ~r/^pg_/

    # idempotent consent: a second mirror returns the same grant
    assert Mirror.mirror_pairing_grant!(user.id, client_id, resource).id == grant.id

    assert :ok = Pdp.check(%{user_id: user.id, client_id: client_id, resource: resource})
  end

  test "revoke_pairing_grant! flips the grant so grant_id tokens are denied", %{user: user} do
    {:ok, reg} = register_client("mirror-revoke-cli")

    grant = Mirror.mirror_pairing_grant!(user.id, reg["client_id"], "https://r.example/mcp")

    assert {:ok, _} = Mirror.revoke_pairing_grant!(grant.grant_id)
    assert {:error, :not_found} = Mirror.revoke_pairing_grant!(grant.grant_id)

    assert {:error, :grant_revoked} =
             Pdp.check(%{user_id: user.id, grant_id: grant.grant_id})
  end

  defp register_client(name) do
    Clients.register(%{
      "client_name" => name,
      "redirect_uris" => ["http://127.0.0.1:9876/callback"],
      "token_endpoint_auth_method" => "none"
    })
  end
end
