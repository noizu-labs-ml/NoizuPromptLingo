defmodule NoizuPromptLingua.Router do
  use Plug.Router

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason

  plug :match
  plug :dispatch

  get "/health" do
    send_resp(conn, 200, "ok")
  end

  post "/api/auth/sync" do
    case conn.body_params do
      %{"sub" => _, "email" => _} = params ->
        case NoizuPromptLingua.Auth.find_or_create_user(params) do
          {:ok, user} ->
            json(conn, 200, %{id: user.id, email: user.email, name: user.name})

          {:error, changeset} ->
            json(conn, 422, %{error: inspect(changeset.errors)})
        end

      _ ->
        json(conn, 400, %{error: "sub and email required"})
    end
  end

  post "/api/keys" do
    with user_id when is_binary(user_id) <- conn.body_params["user_id"],
         label <- conn.body_params["label"] || "default",
         {:ok, key, raw_key} <- NoizuPromptLingua.Auth.generate_api_key(user_id, label) do
      json(conn, 201, %{
        id: key.id,
        label: key.label,
        key_prefix: key.key_prefix,
        key: raw_key,
        created_at: key.inserted_at
      })
    else
      nil -> json(conn, 400, %{error: "user_id required"})
      {:error, changeset} -> json(conn, 422, %{error: inspect(changeset.errors)})
    end
  end

  get "/api/keys/:user_id" do
    keys =
      NoizuPromptLingua.Auth.list_api_keys(user_id)
      |> Enum.map(fn k ->
        %{
          id: k.id,
          label: k.label,
          key_prefix: k.key_prefix,
          status: k.status,
          last_used_at: k.last_used_at,
          created_at: k.inserted_at
        }
      end)

    json(conn, 200, %{keys: keys})
  end

  delete "/api/keys/:key_id" do
    case conn.body_params["user_id"] do
      nil ->
        json(conn, 400, %{error: "user_id required"})

      user_id ->
        case NoizuPromptLingua.Auth.revoke_api_key(key_id, user_id) do
          {:ok, _} -> json(conn, 200, %{ok: true})
          {:error, :not_found} -> json(conn, 404, %{error: "not found"})
        end
    end
  end

  post "/api/mcp/token" do
    with key_id when is_binary(key_id) <- conn.body_params["key_id"],
         user_id when is_binary(user_id) <- conn.body_params["user_id"],
         user_email when is_binary(user_email) <- conn.body_params["email"],
         user_name <- conn.body_params["name"],
         %{} = api_key <- NoizuPromptLingua.Auth.get_active_key(key_id, user_id),
         user <- %{id: user_id, email: user_email, name: user_name},
         {:ok, token, expires_at} <- NoizuPromptLingua.Token.mint(user, api_key) do
      json(conn, 200, %{token: token, expires_at: DateTime.to_iso8601(expires_at)})
    else
      nil -> json(conn, 400, %{error: "key_id, user_id, and email required"})
      {:error, :not_found} -> json(conn, 404, %{error: "key not found or not owned by user"})
      _ -> json(conn, 400, %{error: "invalid request"})
    end
  end

  forward "/mcp",
    to: NoizuPromptLingua.Plugs.AuthenticatedMCP

  match _ do
    send_resp(conn, 404, "not found")
  end

  defp json(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
  end
end
