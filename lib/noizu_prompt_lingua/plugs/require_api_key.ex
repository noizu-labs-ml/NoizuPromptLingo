defmodule NoizuPromptLingua.Plugs.RequireApiKey do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> key] <- get_req_header(conn, "authorization"),
         %{} = api_key <- NoizuPromptLingua.Auth.verify_api_key(key) do
      conn
      |> assign(:api_key, api_key)
      |> assign(:current_user, api_key.user)
    else
      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{error: "valid API key required"}))
        |> halt()
    end
  end
end
