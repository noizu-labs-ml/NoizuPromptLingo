defmodule NPLWeb.KeyController do
  use NPLWeb, :controller

  def create(conn, %{"user_id" => user_id} = params) do
    label = params["label"] || "default"

    case NoizuPromptLingua.Auth.generate_api_key(user_id, label) do
      {:ok, key, raw_key} ->
        conn
        |> put_status(201)
        |> json(%{
          id: key.id,
          label: key.label,
          key_prefix: key.key_prefix,
          key: raw_key,
          created_at: key.inserted_at
        })

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> json(%{error: inspect(changeset.errors)})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{error: "user_id required"})
  end

  def index(conn, %{"user_id" => user_id}) do
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

    json(conn, %{keys: keys})
  end

  def delete(conn, %{"key_id" => key_id}) do
    user_id = conn.body_params["user_id"]

    if is_nil(user_id) do
      conn
      |> put_status(400)
      |> json(%{error: "user_id required"})
    else
      case NoizuPromptLingua.Auth.revoke_api_key(key_id, user_id) do
        {:ok, _} -> json(conn, %{ok: true})
        {:error, :not_found} ->
          conn
          |> put_status(404)
          |> json(%{error: "not found"})
      end
    end
  end
end
