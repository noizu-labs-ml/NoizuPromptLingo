defmodule TheRobotWarsWeb.AuthController do
  use TheRobotWarsWeb, :controller

  alias TheRobotWars.Guardian
  alias TheRobotWars.Organizations

  def register(conn, %{"invite_token" => raw_token, "user" => user_params}) do
    with {:ok, invite} <- Organizations.find_active_invite_by_raw_token(raw_token),
         {:ok, {user, _credential}} <-
           TheRobotWars.Users.register(
             %{
               user_name: user_params["user_name"] || user_params["email"],
               name: %{
                 first: user_params["first_name"] || "",
                 last: user_params["last_name"] || ""
               },
               email: user_params["email"],
               password: user_params["password"]
             },
             Noizu.Context.system(),
             []
           ),
         {:ok, session} <- create_session_for_user(user),
         {:ok, access_token, _} <-
           Guardian.encode_and_sign(session, %{}, token_type: "access", ttl: {1, :hour}),
         {:ok, refresh_token, %{"jti" => refresh_jti}} <-
           Guardian.encode_and_sign(session, %{}, token_type: "refresh", ttl: {7, :day}) do
      if invite.organization_id do
        TheRobotWars.Authz.ScopedMemberships.add_member(
          "organization", invite.organization_id, user.id, "viewer"
        )
      end

      Organizations.increment_invite_uses(invite)
      TheRobotWars.Auth.TokenStore.store_refresh_jti(refresh_jti)
      TheRobotWars.Events.dispatch(:user_registered, %{user_id: user.id, email: user.email})

      orgs = Organizations.list_user_organizations(user.id)

      conn
      |> put_status(:created)
      |> json(%{
        user: serialize_user(user),
        organizations: orgs,
        access_token: access_token,
        refresh_token: refresh_token
      })
    else
      {:error, :invalid_token} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid or expired invite token"})

      {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_changeset_errors(changeset)})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def register(conn, _params) do
    conn |> put_status(:bad_request) |> json(%{error: "invite_token is required"})
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case TheRobotWars.Users.Credentials.authenticate({:login, {email, password}}, Noizu.Context.system(), []) do
      {:ok, session} ->
        {:ok, access_token, _} =
          Guardian.encode_and_sign(session, %{}, token_type: "access", ttl: {1, :hour})

        {:ok, refresh_token, %{"jti" => refresh_jti}} =
          Guardian.encode_and_sign(session, %{}, token_type: "refresh", ttl: {7, :day})

        TheRobotWars.Auth.TokenStore.store_refresh_jti(refresh_jti)
        user = resolve_user_from_session(session)
        orgs = Organizations.list_user_organizations(user.id)

        conn
        |> put_status(:ok)
        |> json(%{
          user: serialize_user(user),
          organizations: orgs,
          access_token: access_token,
          refresh_token: refresh_token
        })

      {:error, :invalid_credentials} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid email or password"})

      {:error, {:login, :invalid_credentials}} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid email or password"})

      {:error, :invalid_email} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: "Invalid email format"})

      {:error, :invalid_password} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: "Password too short"})
    end
  end

  def request_magic_link(conn, %{"email" => email}) do
    frontend_url = Application.get_env(:the_robot_wars, :frontend_url, "http://localhost:3000")

    case TheRobotWars.Auth.SmartTokenAuth.request_magic_link(email) do
      {:ok, %{encoded_key: encoded_key, user: _user}} ->
        magic_link = "#{frontend_url}/auth/verify?token=#{encoded_key}"
        TheRobotWars.Auth.SmartTokenEmail.send_magic_link(email, magic_link)

        response = %{message: "If an account exists with that email, a magic link has been sent."}

        response =
          if Application.get_env(:the_robot_wars, :dev_routes) do
            Map.put(response, :dev_link, magic_link)
          else
            response
          end

        conn |> put_status(:ok) |> json(response)

      {:error, :not_found} ->
        conn
        |> put_status(:ok)
        |> json(%{message: "If an account exists with that email, a magic link has been sent."})
    end
  end

  def verify_magic_link(conn, %{"token" => token_key}) do
    case TheRobotWars.Auth.SmartTokenAuth.verify_magic_link(token_key, conn) do
      {:ok, session} ->
        {:ok, access_token, _} =
          Guardian.encode_and_sign(session, %{}, token_type: "access", ttl: {1, :hour})

        {:ok, refresh_token, %{"jti" => refresh_jti}} =
          Guardian.encode_and_sign(session, %{}, token_type: "refresh", ttl: {7, :day})

        TheRobotWars.Auth.TokenStore.store_refresh_jti(refresh_jti)
        user = resolve_user_from_session(session)
        orgs = Organizations.list_user_organizations(user.id)

        conn
        |> put_status(:ok)
        |> json(%{
          user: serialize_user(user),
          organizations: orgs,
          access_token: access_token,
          refresh_token: refresh_token
        })

      {:error, _reason} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid or expired magic link"})
    end
  end

  def request_otp_login(conn, %{"email" => email}) do
    case TheRobotWars.Auth.SmartTokenAuth.request_otp_login(email) do
      {:ok, %{otp_code: otp_code, user: _user}} ->
        TheRobotWars.Auth.SmartTokenEmail.send_otp_login(email, otp_code)

        response = %{message: "If an account exists with that email, a login code has been sent."}

        response =
          if Application.get_env(:the_robot_wars, :dev_routes) do
            Map.put(response, :dev_code, otp_code)
          else
            response
          end

        conn |> put_status(:ok) |> json(response)

      {:error, :not_found} ->
        conn
        |> put_status(:ok)
        |> json(%{message: "If an account exists with that email, a login code has been sent."})
    end
  end

  def verify_otp_login(conn, %{"email" => email, "code" => code}) do
    case TheRobotWars.Auth.SmartTokenAuth.verify_otp_login(email, code, conn) do
      {:ok, session} ->
        {:ok, access_token, _} =
          Guardian.encode_and_sign(session, %{}, token_type: "access", ttl: {1, :hour})

        {:ok, refresh_token, %{"jti" => refresh_jti}} =
          Guardian.encode_and_sign(session, %{}, token_type: "refresh", ttl: {7, :day})

        TheRobotWars.Auth.TokenStore.store_refresh_jti(refresh_jti)
        user = resolve_user_from_session(session)
        orgs = Organizations.list_user_organizations(user.id)

        conn
        |> put_status(:ok)
        |> json(%{
          user: serialize_user(user),
          organizations: orgs,
          access_token: access_token,
          refresh_token: refresh_token
        })

      {:error, _reason} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid or expired code"})
    end
  end

  def request_password_reset(conn, %{"email" => email}) do
    case TheRobotWars.Auth.SmartTokenAuth.request_password_reset(email) do
      {:ok, %{otp_code: otp_code, user: _user}} ->
        TheRobotWars.Auth.SmartTokenEmail.send_password_reset(email, otp_code)

        response = %{message: "If an account exists with that email, a reset code has been sent."}

        response =
          if Application.get_env(:the_robot_wars, :dev_routes) do
            Map.put(response, :dev_code, otp_code)
          else
            response
          end

        conn |> put_status(:ok) |> json(response)

      {:error, :not_found} ->
        conn
        |> put_status(:ok)
        |> json(%{message: "If an account exists with that email, a reset code has been sent."})
    end
  end

  def verify_password_reset(conn, %{"email" => email, "code" => code, "new_password" => new_password}) do
    case TheRobotWars.Auth.SmartTokenAuth.verify_password_reset(email, code, new_password, conn) do
      {:ok, _credential} ->
        conn |> put_status(:ok) |> json(%{message: "Password has been reset. You can now log in."})

      {:error, _reason} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid or expired code"})
    end
  end

  def refresh(conn, %{"refresh_token" => refresh_token}) do
    alias TheRobotWars.Auth.TokenStore

    case Guardian.decode_and_verify(refresh_token, %{"typ" => "refresh"}) do
      {:ok, claims} ->
        jti = claims["jti"]

        if jti && TokenStore.valid_refresh_jti?(jti) do
          case Guardian.resource_from_claims(claims) do
            {:ok, session} ->
              TokenStore.revoke_refresh_jti(jti)

              {:ok, access_token, _} =
                Guardian.encode_and_sign(session, %{}, token_type: "access", ttl: {1, :hour})

              {:ok, new_refresh_token, %{"jti" => new_jti}} =
                Guardian.encode_and_sign(session, %{}, token_type: "refresh", ttl: {7, :day})

              TokenStore.store_refresh_jti(new_jti)

              conn
              |> put_status(:ok)
              |> json(%{access_token: access_token, refresh_token: new_refresh_token})

            {:error, _} ->
              conn |> put_status(:unauthorized) |> json(%{error: "Invalid refresh token"})
          end
        else
          conn |> put_status(:unauthorized) |> json(%{error: "Invalid refresh token"})
        end

      {:error, _} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid refresh token"})
    end
  end

  def me(conn, _params) do
    session = Guardian.Plug.current_resource(conn)
    user = resolve_user_from_session(session)
    orgs = Organizations.list_user_organizations(user.id)

    conn
    |> put_status(:ok)
    |> json(%{user: serialize_user(user), organizations: orgs})
  end

  def send_verification(conn, _params) do
    session = Guardian.Plug.current_resource(conn)
    user = resolve_user_from_session(session)
    frontend_url = Application.get_env(:the_robot_wars, :frontend_url, "http://localhost:3000")

    case TheRobotWars.Auth.SmartTokenAuth.request_email_verification(user.email) do
      {:ok, %{encoded_key: encoded_key}} ->
        verification_link = "#{frontend_url}/auth/verify-email?token=#{encoded_key}"
        TheRobotWars.Auth.SmartTokenEmail.send_verification_email(user.email, verification_link)

        response = %{message: "Verification email sent."}

        response =
          if Application.get_env(:the_robot_wars, :dev_routes) do
            Map.put(response, :dev_link, verification_link)
          else
            response
          end

        conn |> put_status(:ok) |> json(response)

      {:error, _} ->
        conn |> put_status(:ok) |> json(%{message: "Verification email sent."})
    end
  end

  def verify_email(conn, %{"token" => token_key}) do
    case TheRobotWars.Auth.SmartTokenAuth.verify_email_token(token_key) do
      {:ok, user} ->
        TheRobotWars.Events.dispatch(:user_verified, %{user_id: user.id})
        conn |> put_status(:ok) |> json(%{message: "Email verified successfully."})

      {:error, _} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid or expired verification link"})
    end
  end

  defp create_session_for_user(user) do
    user_ref = TheRobotWars.Users.User.ref(user.id)
    session_entity = %TheRobotWars.Users.Sessions.UserSession{
      user: user_ref,
      status: :active,
      details: %{}
    }
    TheRobotWars.Users.Sessions.create(session_entity, Noizu.Context.system())
  end

  defp resolve_user_from_session(%TheRobotWars.Users.Sessions.UserSession{} = session) do
    case session.user do
      {:ref, _, id} ->
        {:ok, user} = TheRobotWars.Users.get_user(id, Noizu.Context.system())
        user
      %TheRobotWars.Users.User{} = user -> user
    end
  end

  defp serialize_user(user) do
    %{
      id: user.id,
      email: user.email,
      user_name: user.user_name,
      handle: user.handle,
      status: user.status,
      verified: user.verified
    }
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
