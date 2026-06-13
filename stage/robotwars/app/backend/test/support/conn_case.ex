defmodule TheRobotWarsWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest
      import TheRobotWarsWeb.ConnCase

      @endpoint TheRobotWarsWeb.Endpoint
    end
  end

  setup tags do
    TheRobotWars.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Creates a test user with login credential and returns access/refresh tokens.

  Inserts directly via Ecto schemas (bypasses Noizu entity layer) for speed and
  simplicity. The auth_providers seed must have run (login provider must exist).
  """
  def setup_user_and_token(_context \\ %{}) do
    login_provider_id = UUID.uuid5(:oid, "TheRobotWars.Schema.Auth.Providers.Provider@Login")

    # Ensure the login auth provider exists (idempotent)
    TheRobotWars.Repo.insert!(
      %TheRobotWars.Schema.Auth.Providers.Provider{
        id: login_provider_id,
        title: "Login",
        description: "Email and password authentication"
      },
      on_conflict: :nothing,
      conflict_target: :id
    )

    uniq = System.unique_integer([:positive])
    email = "test-#{uniq}@example.com"
    password = "password123"
    hashed = Bcrypt.hash_pwd_salt(password)

    user = %TheRobotWars.Schema.Users.User{
      id: Ecto.UUID.generate(),
      email: email,
      user_name: "testuser#{uniq}",
      handle: "test#{uniq}",
      hashed_password: hashed,
      status: :active,
      verified: false,
      flagged: false
    }

    {:ok, user} = TheRobotWars.Repo.insert(user)

    credential = %TheRobotWars.Schema.Users.Credentials.UserCredential{
      id: Ecto.UUID.generate(),
      user_id: user.id,
      auth_provider_id: login_provider_id,
      status: :active,
      settings: %{"email" => email, "password" => hashed},
      state: %{},
      fingerprint: "#{email}:#{hashed}"
    }

    {:ok, _credential} = TheRobotWars.Repo.insert(credential)

    session = %TheRobotWars.Schema.Users.Sessions.UserSession{
      id: Ecto.UUID.generate(),
      user_id: user.id,
      status: :active,
      details: %{}
    }

    {:ok, session} = TheRobotWars.Repo.insert(session)

    # Build entity-layer session struct for Guardian signing
    session_entity = %TheRobotWars.Users.Sessions.UserSession{
      id: session.id,
      user: {:ref, TheRobotWars.Users.User, user.id},
      status: :active,
      details: %{}
    }

    {:ok, access_token, _claims} =
      TheRobotWars.Guardian.encode_and_sign(session_entity, %{}, token_type: "access", ttl: {1, :hour})

    {:ok, refresh_token, %{"jti" => jti}} =
      TheRobotWars.Guardian.encode_and_sign(session_entity, %{}, token_type: "refresh", ttl: {7, :day})

    TheRobotWars.Auth.TokenStore.store_refresh_jti(jti)

    %{
      user: user,
      password: password,
      access_token: access_token,
      refresh_token: refresh_token,
      session: session
    }
  end

  @doc """
  Adds a Bearer authorization header to the connection.
  """
  def authenticated_conn(conn, access_token) do
    Plug.Conn.put_req_header(conn, "authorization", "Bearer #{access_token}")
  end
end
