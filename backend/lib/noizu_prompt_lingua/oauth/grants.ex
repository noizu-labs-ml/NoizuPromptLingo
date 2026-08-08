defmodule NoizuPromptLingua.OAuth.Grants do
  @moduledoc "MCP pairing grants (user consent records)."

  import Ecto.Query
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.McpPairingGrant

  def get_active(grant_id) when is_binary(grant_id) do
    Repo.one(
      from g in McpPairingGrant,
        where: g.grant_id == ^grant_id and g.status == "active"
    )
  end

  def find_active(user_id, client_id, resource) do
    Repo.one(
      from g in McpPairingGrant,
        where:
          g.user_id == ^user_id and g.client_id == ^client_id and g.resource == ^resource and
            g.status == "active",
        order_by: [desc: g.inserted_at],
        limit: 1
    )
  end

  def approve!(user_id, client_id, resource, scope \\ "mcp") do
    case find_active(user_id, client_id, resource) do
      %McpPairingGrant{} = existing ->
        existing

      nil ->
        grant_id = "pg_" <> random_id(12)

        %McpPairingGrant{}
        |> McpPairingGrant.changeset(%{
          grant_id: grant_id,
          user_id: user_id,
          client_id: client_id,
          resource: resource,
          scope: scope || "mcp",
          authorization_details: [],
          status: "active"
        })
        |> Repo.insert!()
    end
  end

  def revoke!(grant_id) when is_binary(grant_id) do
    case get_active(grant_id) do
      nil ->
        {:error, :not_found}

      grant ->
        grant
        |> McpPairingGrant.changeset(%{status: "revoked"})
        |> Repo.update()
    end
  end

  def list_for_user(user_id) do
    Repo.all(
      from g in McpPairingGrant,
        where: g.user_id == ^user_id and g.status == "active",
        order_by: [desc: g.inserted_at]
    )
  end

  defp random_id(n), do: :crypto.strong_rand_bytes(n) |> Base.url_encode64(padding: false)
end
