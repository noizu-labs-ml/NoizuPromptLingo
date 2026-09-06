defmodule NoizuPromptLinguaWeb.TRPResponse do
  @moduledoc """
  Shared REST error rendering for TRP-backed domain results (tickets,
  type/field definitions, …).

  House ruling for the 500-family sweep (fix/error-family): a TRP-backed
  feature whose backend is down degrades to a clean 503 "PM backend not
  configured" — never a raw 500, and never the misleading 403 the old
  catch-alls produced. TRP-side validation errors (422) pass their field
  errors through as 422, and 404s stay 404s.
  """

  import Phoenix.Controller, only: [json: 2]
  import Plug.Conn, only: [put_status: 2]

  alias NoizuPromptLingua.TRP

  @doc "Render a `{:error, reason}` from a TRP-backed domain call."
  def respond_error(conn, {:error, :trp_not_configured}) do
    conn
    |> put_status(:service_unavailable)
    |> json(%{error: "PM backend not configured"})
  end

  def respond_error(conn, {:error, :trp_org_required}) do
    conn
    |> put_status(:service_unavailable)
    |> json(%{error: "PM backend not configured"})
  end

  def respond_error(conn, {:error, {:transport, _reason}}) do
    conn
    |> put_status(:service_unavailable)
    |> json(%{error: "PM backend unavailable"})
  end

  def respond_error(conn, {:error, %TRP.Error{status: 404}}) do
    conn
    |> put_status(:not_found)
    |> json(%{error: "Not found in PM backend"})
  end

  def respond_error(conn, {:error, %TRP.Error{status: 422, errors: errors}})
      when is_map(errors) and map_size(errors) > 0 do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{errors: errors})
  end

  def respond_error(conn, {:error, %TRP.Error{status: 422}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "PM backend rejected the request"})
  end

  def respond_error(conn, {:error, %TRP.Error{}}) do
    # TRP 5xx / unexpected statuses — dependency failure, not the caller's fault.
    conn
    |> put_status(:service_unavailable)
    |> json(%{error: "PM backend unavailable"})
  end

  def respond_error(conn, {:error, reason}) do
    # Unmodeled domain errors keep the legacy 422-typed rendering.
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: to_string(reason)})
  end
end
