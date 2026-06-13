defmodule CodefreshWeb.AuthController do
  use CodefreshWeb, :controller

  alias Codefresh.Accounts
  alias Codefresh.Guardian

  # ──────────────────────────────────────────────────────────────────────────
  # Register (invite-gated)
  # ──────────────────────────────────────────────────────────────────────────

  def register(conn, %{"user" => user_params, "invite_token" => raw_token})
      when is_binary(raw_token) and raw_token != "" do
    case Accounts.register_user_with_invite(user_params, raw_token) do
      {:ok, %{user: user, organization: org}} ->
        {:ok, access_token, _claims} =
          Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {1, :hour})

        {:ok, refresh_token, _claims} =
          Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {7, :day})

        conn
        |> put_status(:created)
        |> json(%{
          user: %{id: user.id, email: user.email},
          organization: %{id: org.id, slug: org.slug, name: org.name},
          access_token: access_token,
          refresh_token: refresh_token
        })

      {:error, :invalid_invite_token} ->
        unauthorized(conn, "Invalid invite token")

      {:error, :invite_inactive} ->
        unauthorized(conn, "Invite token is expired, revoked, or fully redeemed")

      {:error, :invite_email_mismatch} ->
        unauthorized(conn, "Invite is bound to a different email address")

      {:error, :email_required} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Email required — this invite is bound to a specific address"})

      {:error, :org_not_found} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "The organization referenced by this invite no longer exists"})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_changeset_errors(changeset)})
    end
  end

  def register(conn, %{"user" => _user_params}) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "invite_token required for signup"})
  end

  def register(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Malformed request: expected {user, invite_token}"})
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Login / refresh / me (unchanged behavior)
  # ──────────────────────────────────────────────────────────────────────────

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
        unauthorized(conn, "Invalid email or password")
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
            unauthorized(conn, "Invalid refresh token")
        end

      {:error, _reason} ->
        unauthorized(conn, "Invalid refresh token")
    end
  end

  def me(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    conn
    |> put_status(:ok)
    |> json(%{user: %{id: user.id, email: user.email}})
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp unauthorized(conn, message) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: message})
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
