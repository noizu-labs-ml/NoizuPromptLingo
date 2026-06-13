defmodule BoeWeb.AuthController do
  use BoeWeb, :controller

  alias Boe.Accounts
  alias Boe.Guardian

  def register(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, access_token, _claims} =
          Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {1, :hour})

        {:ok, refresh_token, _claims} =
          Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {7, :day})

        conn
        |> put_status(:created)
        |> json(%{
          user: %{id: user.id, email: user.email},
          access_token: access_token,
          refresh_token: refresh_token
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_changeset_errors(changeset)})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, access_token, _claims} =
          Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {1, :hour})

        {:ok, refresh_token, _claims} =
          Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {7, :day})

        conn
        |> put_status(:ok)
        |> json(%{
          user: %{id: user.id, email: user.email},
          access_token: access_token,
          refresh_token: refresh_token
        })

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid email or password"})
    end
  end

  def refresh(conn, %{"refresh_token" => refresh_token}) do
    case Guardian.decode_and_verify(refresh_token, %{"typ" => "refresh"}) do
      {:ok, claims} ->
        case Guardian.resource_from_claims(claims) do
          {:ok, user} ->
            {:ok, access_token, _claims} =
              Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {1, :hour})

            conn
            |> put_status(:ok)
            |> json(%{access_token: access_token})

          {:error, _reason} ->
            conn
            |> put_status(:unauthorized)
            |> json(%{error: "Invalid refresh token"})
        end

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid refresh token"})
    end
  end

  def me(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    conn
    |> put_status(:ok)
    |> json(%{user: %{id: user.id, email: user.email}})
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
