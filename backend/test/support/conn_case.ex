defmodule NoizuPromptLinguaWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest
      import NoizuPromptLinguaWeb.ConnCase

      @endpoint NoizuPromptLinguaWeb.Endpoint
    end
  end

  setup tags do
    NoizuPromptLingua.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Creates a test user + active session and returns access/refresh tokens.

  Inserts directly via Ecto schemas (bypasses Noizu entity layer) for speed and
  simplicity. Auth in production is SSO/Authentik-only (no password login), so
  this helper mints tokens directly from a session — no credential plumbing.
  """
  def setup_user_and_token(_context \\ %{}) do
    uniq = System.unique_integer([:positive])
    email = "test-#{uniq}@example.com"

    user = %NoizuPromptLingua.Schema.Users.User{
      id: Ecto.UUID.generate(),
      email: email,
      user_name: "testuser#{uniq}",
      handle: "test#{uniq}",
      status: :active,
      verified: false,
      flagged: false
    }

    {:ok, user} = NoizuPromptLingua.Repo.insert(user)

    session = %NoizuPromptLingua.Schema.Users.Sessions.UserSession{
      id: Ecto.UUID.generate(),
      user_id: user.id,
      status: :active,
      details: %{}
    }

    {:ok, session} = NoizuPromptLingua.Repo.insert(session)

    # Build entity-layer session struct for Guardian signing
    session_entity = %NoizuPromptLingua.Users.Sessions.UserSession{
      id: session.id,
      user: {:ref, NoizuPromptLingua.Users.User, user.id},
      status: :active,
      details: %{}
    }

    {:ok, access_token, _claims} =
      NoizuPromptLingua.Guardian.encode_and_sign(session_entity, %{}, token_type: "access", ttl: {1, :hour})

    {:ok, refresh_token, %{"jti" => jti}} =
      NoizuPromptLingua.Guardian.encode_and_sign(session_entity, %{}, token_type: "refresh", ttl: {7, :day})

    NoizuPromptLingua.Auth.TokenStore.store_refresh_jti(jti)

    %{
      user: user,
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
