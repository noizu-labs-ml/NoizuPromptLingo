defmodule NoizuPromptLingua.TRP.Provisioning do
  @moduledoc """
  Best-effort TRP-side provisioning for NPL-created resources.

  v1 scope (W8): mirror-org creation. `POST /api/v1/organizations` is JWT-only
  (docs/api/shared-key-api.md §4.1), so this rides the service identity
  (`NoizuPromptLingua.TRP.ServiceAuth`). Callers NEVER block the local path:
  every failure returns `{:error, reason}` and the local resource stands, with
  the caller logging a warning (re-provisioning is an ops action).

  Key-scope note: a newly mirrored org is NOT in the shared key's
  `scope_orgs`; widening the scope is an admin operation on TRP
  (`PATCH /api/v1/admin/keys/:id`) and stays with W8/W10 ops, not runtime.
  """

  require Logger

  alias NoizuPromptLingua.TRP.{Config, ServiceAuth}

  @doc """
  Create the TRP mirror org for a locally-created org.

  Returns `{:ok, %{id:, slug:, name:}}` on success, `{:error, term}` otherwise
  (`:trp_not_configured` / `:trp_service_not_configured` when activation env
  is absent — the expected state until W8 activation flips the env on).
  """
  def provision_org(%{slug: slug, name: name}) when is_binary(slug) and is_binary(name) do
    unless Config.configured?() do
      {:error, :trp_not_configured}
    else
      case ServiceAuth.authed_request(:post, "/api/v1/organizations", %{
             json: %{organization: %{slug: slug, name: name}}
           }) do
        {:ok, %{} = body} ->
          org = pick(body, :organization) || %{}
          Logger.info("TRP org provisioned: slug=#{slug} trp_id=#{pick(org, :id)}")
          {:ok, org}

        {:error, %NoizuPromptLingua.TRP.Error{status: 422}} = err ->
          # Most commonly slug-already-taken (org provisioned by an earlier
          # attempt). Surface it; do not guess — the census reconciles.
          Logger.warning("TRP org provisioning rejected for slug=#{slug}: validation error")
          err

        {:error, _} = err ->
          err
      end
    end
  end

  def provision_org(_), do: {:error, :invalid_org_attrs}

  # Req/Jason key-style tolerance (atom- or string-keyed decoded JSON).
  defp pick(map, key) when is_map(map) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end

  defp pick(_, _), do: nil
end
