defmodule NoizuPromptLinguaWeb.Plugs.RateLimit do
  @behaviour Plug
  import Plug.Conn

  @default_limits %{
    auth: {10, 60_000},
    auth_sensitive: {5, 60_000}
  }

  @impl true
  def init(opts) do
    action = Keyword.fetch!(opts, :action)
    {limit, period} = @default_limits[action] || {10, 60_000}
    %{action: action, limit: limit, period: period}
  end

  @impl true
  def call(conn, %{action: action, limit: limit, period: period}) do
    ip = client_ip(conn)
    key = "#{action}:#{ip}"

    case Hammer.check_rate(key, period, limit) do
      {:allow, _count} ->
        conn

      {:deny, _limit} ->
        retry_after = div(period, 1000)

        conn
        |> put_resp_header("retry-after", Integer.to_string(retry_after))
        |> put_resp_content_type("application/json")
        |> send_resp(429, Jason.encode!(%{error: "Too many requests. Try again later."}))
        |> halt()
    end
  end

  defp client_ip(conn) do
    case get_req_header(conn, "x-forwarded-for") do
      [forwarded | _] -> forwarded |> String.split(",") |> List.first() |> String.trim()
      [] -> conn.remote_ip |> :inet.ntoa() |> to_string()
    end
  end
end
