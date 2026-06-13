defmodule Codefresh.Enterprise do
  @moduledoc """
  Context for enterprise-tier features: SSO configuration (US-142) and
  audit log export (US-143).
  """

  import Ecto.Query, only: [from: 2]

  alias Codefresh.Repo
  alias Codefresh.Enterprise.SsoConfig

  # ---------------------------------------------------------------------------
  # SSO Config (US-142)
  # ---------------------------------------------------------------------------

  @doc """
  Upsert SSO configuration for an organization.

  Returns `{:ok, sso_config}` or `{:error, changeset}`.
  """
  def configure_sso(organization_id, attrs) when is_binary(organization_id) do
    existing = get_sso_config(organization_id)

    record = existing || %SsoConfig{}

    record
    |> SsoConfig.changeset(Map.put(attrs, "organization_id", organization_id))
    |> case do
      %Ecto.Changeset{valid?: false} = cs ->
        {:error, cs}

      cs ->
        if existing do
          Repo.update(cs)
        else
          Repo.insert(cs)
        end
    end
  end

  @doc """
  Fetch SSO config for an organization. Returns `nil` if not configured.
  """
  def get_sso_config(organization_id) when is_binary(organization_id) do
    Repo.get_by(SsoConfig, organization_id: organization_id)
  end

  # ---------------------------------------------------------------------------
  # Audit log export (US-143)
  # ---------------------------------------------------------------------------

  @doc """
  Streams audit log rows for `organization_id` as CSV to `conn` using
  `Plug.Conn.chunk/2`. Caller must have already sent headers and opened
  the chunked response.

  Optional filters in `opts`:
    - `:since`  — `DateTime` lower bound (inclusive)
    - `:until`  — `DateTime` upper bound (inclusive)
  """
  def export_audit_log_csv(conn, organization_id, opts \\ []) do
    since = Keyword.get(opts, :since)
    until_ = Keyword.get(opts, :until)

    # Raw table queries don't auto-coerce UUID strings — use type/2 to cast.
    # :binary_id accepts the string form ("xxxxxxxx-xxxx-...") and encodes it.
    base =
      from e in "audit_events",
        where: e.organization_id == type(^organization_id, :binary_id),
        order_by: [asc: e.timestamp],
        select: %{
          id: e.id,
          actor_user_id: e.actor_user_id,
          action: e.action,
          subject_type: e.subject_type,
          subject_id: e.subject_id,
          subject_slug: e.subject_slug,
          timestamp: e.timestamp,
          metadata: e.metadata
        }

    query =
      base
      |> maybe_filter_since(since)
      |> maybe_filter_until(until_)

    header = "id,actor_user_id,action,subject_type,subject_id,subject_slug,timestamp,metadata\n"
    {:ok, conn} = Plug.Conn.chunk(conn, header)

    conn =
      Repo.transaction(fn ->
        query
        |> Repo.stream(max_rows: 500)
        |> Enum.reduce(conn, fn row, c ->
          line = csv_row(row)

          case Plug.Conn.chunk(c, line) do
            {:ok, c2} -> c2
            {:error, :closed} -> throw(:client_closed)
          end
        end)
      end)
      |> case do
        {:ok, c} -> c
        _ -> conn
      end

    conn
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp maybe_filter_since(query, nil), do: query

  defp maybe_filter_since(query, %DateTime{} = since) do
    from e in query, where: e.timestamp >= ^since
  end

  defp maybe_filter_until(query, nil), do: query

  defp maybe_filter_until(query, %DateTime{} = until_) do
    from e in query, where: e.timestamp <= ^until_
  end

  defp csv_row(row) do
    [
      to_string(row.id),
      to_string(row.actor_user_id || ""),
      to_string(row.action),
      to_string(row.subject_type),
      to_string(row.subject_id || ""),
      csv_escape(row.subject_slug || ""),
      DateTime.to_iso8601(row.timestamp),
      Jason.encode!(row.metadata || %{})
    ]
    |> Enum.join(",")
    |> Kernel.<>("\n")
  end

  defp csv_escape(s) when is_binary(s) do
    if String.contains?(s, [",", "\"", "\n"]) do
      "\"" <> String.replace(s, "\"", "\"\"") <> "\""
    else
      s
    end
  end
end
