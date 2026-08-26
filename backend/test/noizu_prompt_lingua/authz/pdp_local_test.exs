defmodule NoizuPromptLingua.Authz.Pdp.LocalTest do
  # Local.check/1 queries OAuth Clients/Grants on the app repo — needs sandbox checkout
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Authz.Pdp.Local

  test "API-key style request (no client_id) with user_id allows" do
    assert :ok =
             Local.check(%{
               user_id: Ecto.UUID.generate()
             })
  end

  test "unknown client_id denies" do
    assert {:error, :client_not_allowed} =
             Local.check(%{
               user_id: Ecto.UUID.generate(),
               client_id: "dcr_does_not_exist_xyz"
             })
  end

  test "revoked grant_id denies when grant missing" do
    assert {:error, :grant_revoked} =
             Local.check(%{
               user_id: Ecto.UUID.generate(),
               grant_id: "pg_missing_grant_xyz"
             })
  end
end
