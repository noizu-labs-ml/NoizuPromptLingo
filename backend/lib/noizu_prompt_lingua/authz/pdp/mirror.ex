defmodule NoizuPromptLingua.Authz.Pdp.Mirror do
  @moduledoc """
  Write-through helpers that keep pairing-grant axis data consistent for the PDP.

  Full SpiceDB tuple mirroring (org membership, tool catalog) is deferred until
  a SpiceDB cluster is deployed; local PDP reads Ecto directly.
  """

  alias NoizuPromptLingua.OAuth.Grants

  @doc "Ensure a pairing grant exists after OAuth consent (axis 3)."
  def mirror_pairing_grant!(user_id, client_id, resource, scope \\ "mcp") do
    Grants.approve!(user_id, client_id, resource, scope)
  end

  @doc "Revoke pairing grant (instant axis-3 deny for grant_id tokens)."
  def revoke_pairing_grant!(grant_id) do
    Grants.revoke!(grant_id)
  end
end
