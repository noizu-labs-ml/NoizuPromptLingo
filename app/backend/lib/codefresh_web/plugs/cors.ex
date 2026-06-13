defmodule CodefreshWeb.Plugs.CORS do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_header("access-control-allow-origin", get_origin(conn))
    |> put_resp_header("access-control-allow-methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
    |> put_resp_header("access-control-allow-headers", "authorization, content-type")
    |> put_resp_header("access-control-max-age", "3600")
    |> handle_preflight()
  end

  defp get_origin(conn) do
    case get_req_header(conn, "origin") do
      [origin] -> origin
      _ -> "*"
    end
  end

  defp handle_preflight(%{method: "OPTIONS"} = conn) do
    conn |> send_resp(204, "") |> halt()
  end

  defp handle_preflight(conn), do: conn
end
