defmodule ExLiteLLM.Proxy.Health do
  @moduledoc """
  Health + liveness/readiness responses for the LiteLLM tier.

  Mirrors litellm's health endpoints
  (`litellm/proxy/health_endpoints/_health_endpoints.py`):

    * `GET /health/readiness` — public, k8s readiness probe
    * `GET /health/liveliness` / `GET /health/liveness` — public liveness probes
    * `GET /health` — (Phase 1) basic liveness; later runs a per-model round-trip
      like the Python proxy (`?model=` scoping). run-claude polls this to decide
      the proxy is up.

  Phase 1 returns healthy shells; the per-deployment health check is filled in
  once the router + provider layer exist.
  """

  import Plug.Conn

  @doc "GET /health — run-claude's liveness poll target."
  def health(conn) do
    json(conn, 200, %{
      healthy_endpoints: [],
      unhealthy_endpoints: [],
      healthy_count: 0,
      unhealthy_count: 0
    })
  end

  @doc "GET /health/readiness — public readiness probe."
  def readiness(conn) do
    json(conn, 200, %{
      status: "connected",
      db: db_status(),
      litellm_version: ExLiteLLM.version()
    })
  end

  @doc "GET /health/liveliness|liveness — public liveness probe."
  def liveness(conn), do: json(conn, 200, %{status: "alive"})

  defp db_status do
    # Cheap check: is the repo process alive? Deep checks come with persistence.
    case Process.whereis(ExLiteLLM.Schema.Repo) do
      nil -> "unconnected"
      _pid -> "connected"
    end
  end

  defp json(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
  end
end
