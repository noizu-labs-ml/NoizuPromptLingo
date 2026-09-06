defmodule NoizuPromptLinguaWeb.Plugs.ApiKeyAuthTest do
  use NoizuPromptLingua.DataCase, async: true

  import Plug.Test
  import Plug.Conn

  alias NoizuPromptLinguaWeb.Plugs.ApiKeyAuth
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema
  alias NoizuPromptLingua.Schema.Users.Sessions.UserSession, as: SessionSchema

  setup do
    # Clean env before each test.
    orig = Application.get_env(:noizu_prompt_lingua, :api_key_auth, [])
    on_exit(fn -> Application.put_env(:noizu_prompt_lingua, :api_key_auth, orig) end)
    :ok
  end

  # ── Helpers ──────────────────────────────────────────────────────

  defp seed_service_user do
    uniq = System.unique_integer([:positive])

    user = %UserSchema{
      id: Ecto.UUID.generate(),
      email: "service-#{uniq}@example.com",
      user_name: "service#{uniq}",
      handle: "svc#{uniq}",
      status: :active,
      verified: false,
      flagged: false
    }

    {:ok, user} = NoizuPromptLingua.Repo.insert(user)

    session = %SessionSchema{
      id: Ecto.UUID.generate(),
      user_id: user.id,
      status: :active,
      details: %{}
    }

    {:ok, _session} = NoizuPromptLingua.Repo.insert(session)

    user
  end

  defp configure_api_key(key, user_id) do
    Application.put_env(:noizu_prompt_lingua, :api_key_auth,
      keys: [key],
      service_user_id: user_id
    )
  end

  defp call_plug(conn) do
    ApiKeyAuth.call(conn, [])
  end

  # ── Valid key authenticates as service user ──────────────────────

  test "valid Bearer key authenticates and sets current_resource without halting" do
    user = seed_service_user()
    key = "test-service-key-12345"
    configure_api_key(key, user.id)

    conn =
      conn(:get, "/api/v1/auth/me")
      |> put_req_header("authorization", "Bearer #{key}")
      |> call_plug()

    refute conn.halted
    assert conn.assigns[:auth_method] == :api_key

    session = Guardian.Plug.current_resource(conn)
    assert %NoizuPromptLingua.Users.Sessions.UserSession{} = session
    assert session.status == :active
  end

  test "valid X-API-Key header authenticates without halting" do
    user = seed_service_user()
    key = "xkey-test-67890"
    configure_api_key(key, user.id)

    conn =
      conn(:get, "/api/v1/auth/me")
      |> put_req_header("x-api-key", key)
      |> call_plug()

    refute conn.halted
    assert conn.assigns[:auth_method] == :api_key
    assert Guardian.Plug.current_resource(conn) != nil
  end

  # ── Invalid / missing key falls through ──────────────────────────

  test "invalid key does not authenticate and does not halt" do
    user = seed_service_user()
    configure_api_key("real-key", user.id)

    conn =
      conn(:get, "/api/v1/auth/me")
      |> put_req_header("authorization", "Bearer wrong-key")
      |> call_plug()

    refute conn.halted
    refute conn.assigns[:auth_method]
    assert Guardian.Plug.current_resource(conn) == nil
  end

  test "missing key does not authenticate and does not halt" do
    user = seed_service_user()
    configure_api_key("real-key", user.id)

    conn =
      conn(:get, "/api/v1/auth/me")
      |> call_plug()

    refute conn.halted
    refute conn.assigns[:auth_method]
  end

  # ── Misconfiguration falls through gracefully ────────────────────

  test "falls through when service_user_id is not configured" do
    Application.put_env(:noizu_prompt_lingua, :api_key_auth,
      keys: ["some-key"],
      service_user_id: nil
    )

    conn =
      conn(:get, "/api/v1/auth/me")
      |> put_req_header("authorization", "Bearer some-key")
      |> call_plug()

    refute conn.halted
    refute conn.assigns[:auth_method]
  end

  test "falls through when service user does not exist" do
    # Valid key + configured UUID that doesn't exist in DB
    Application.put_env(:noizu_prompt_lingua, :api_key_auth,
      keys: ["phantom-key"],
      service_user_id: Ecto.UUID.generate()
    )

    conn =
      conn(:get, "/api/v1/auth/me")
      |> put_req_header("authorization", "Bearer phantom-key")
      |> call_plug()

    refute conn.halted
    refute conn.assigns[:auth_method]
  end

  test "falls through when no keys are configured" do
    user = seed_service_user()

    Application.put_env(:noizu_prompt_lingua, :api_key_auth,
      keys: [],
      service_user_id: user.id
    )

    conn =
      conn(:get, "/api/v1/auth/me")
      |> put_req_header("authorization", "Bearer any-key")
      |> call_plug()

    refute conn.halted
    refute conn.assigns[:auth_method]
  end
end
