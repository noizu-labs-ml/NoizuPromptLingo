defmodule CodefreshWeb.EnterpriseController do
  use CodefreshWeb, :controller

  alias Codefresh.{Enterprise, Organizations, Guardian}

  action_fallback CodefreshWeb.FallbackController

  # GET /api/v1/organizations/:organization_id/sso-config
  def get_sso_config(conn, %{"organization_id" => org_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _role} <- Organizations.authorize(user, org_id, "admin") do
      case Enterprise.get_sso_config(org_id) do
        nil ->
          send_resp(conn, 404, "")

        config ->
          json(conn, %{sso_config: render_config(config)})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # PUT /api/v1/organizations/:organization_id/sso-config
  def put_sso_config(conn, %{"organization_id" => org_id, "sso_config" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _role} <- Organizations.authorize(user, org_id, "admin") do
      case Enterprise.configure_sso(org_id, params) do
        {:ok, config} ->
          json(conn, %{sso_config: render_config(config)})

        {:error, %Ecto.Changeset{} = cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def put_sso_config(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Expected {sso_config: {provider, enabled?, sso_required?, metadata, role_mapping?}}"})
  end

  # GET /api/v1/organizations/:organization_id/audit-log.csv
  def export_audit_log(conn, %{"organization_id" => org_id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _role} <- Organizations.authorize(user, org_id, "admin") do
      opts = build_date_opts(params)

      conn =
        conn
        |> put_resp_content_type("text/csv")
        |> put_resp_header(
          "content-disposition",
          "attachment; filename=\"audit-log-#{org_id}.csv\""
        )
        |> send_chunked(200)

      Enterprise.export_audit_log_csv(conn, org_id, opts)
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp render_config(c) do
    %{
      id: c.id,
      organization_id: c.organization_id,
      provider: c.provider,
      enabled: c.enabled,
      sso_required: c.sso_required,
      sso_config: render_sso_config(c),
      role_mapping: c.role_mapping,
      inserted_at: c.inserted_at,
      updated_at: c.updated_at
    }
  end

  defp render_sso_config(c) do
    %{
      idp_metadata_url: get_in(c.metadata, ["idp_metadata_url"]),
      entity_id: get_in(c.metadata, ["entity_id"]),
      certificate: get_in(c.metadata, ["x509_cert"])
    }
  end

  defp build_date_opts(params) do
    []
    |> maybe_add_date(params, "since", :since)
    |> maybe_add_date(params, "until", :until)
  end

  defp maybe_add_date(opts, params, key, atom) do
    case Map.get(params, key) do
      nil ->
        opts

      str ->
        case DateTime.from_iso8601(str) do
          {:ok, dt, _} -> Keyword.put(opts, atom, dt)
          _ -> opts
        end
    end
  end
end
