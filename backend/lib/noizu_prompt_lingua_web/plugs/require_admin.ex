defmodule NoizuPromptLinguaWeb.Plugs.RequireAdmin do
  @behaviour Plug
  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    case get_user(conn) do
      {:ok, user} ->
        # Admin access is granted by the role enum (there is no separate
        # `admin` column anymore — :admin and :owner are the elevated roles).
        if user.role in [:admin, :owner] do
          assign(conn, :admin_user, user)
        else
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(403, Jason.encode!(%{error: "Admin access required"}))
          |> halt()
        end

      :error ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{error: "Authentication required"}))
        |> halt()
    end
  end

  defp get_user(conn) do
    case NoizuPromptLingua.Guardian.Plug.current_resource(conn) do
      %NoizuPromptLingua.Users.Sessions.UserSession{user: {:ref, _, id}} ->
        case NoizuPromptLingua.Repo.get(NoizuPromptLingua.Schema.Users.User, id) do
          nil -> :error
          user -> {:ok, user}
        end

      %NoizuPromptLingua.Users.Sessions.UserSession{user: %{id: id}} ->
        case NoizuPromptLingua.Repo.get(NoizuPromptLingua.Schema.Users.User, id) do
          nil -> :error
          user -> {:ok, user}
        end

      _ -> :error
    end
  end
end
