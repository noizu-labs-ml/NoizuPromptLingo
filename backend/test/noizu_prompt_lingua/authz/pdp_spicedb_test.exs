defmodule NoizuPromptLingua.Authz.PdpSpiceDBTest do
  # Application env mutation + a shared Bandit stub — never async.
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Authz.Pdp.SpiceDB
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User

  # Minimal SpiceDB REST gateway stand-in. The requested tool's id chooses the
  # response: "stub-ok*" ⇒ has permission, "stub-no*" ⇒ no tuples, otherwise 500.
  defmodule Stub do
    def init(opts), do: opts

    def call(conn, _opts) do
      {:ok, body, conn} = Plug.Conn.read_body(conn)

      case Jason.decode(body || "") do
        {:ok, %{"resource" => %{"object_id" => "stub-ok" <> _}}} ->
          Plug.Conn.resp(
            conn,
            200,
            ~s({"permissionship": "PERMISSIONSHIP_HAS_PERMISSION"})
          )

        {:ok, %{"resource" => %{"object_id" => "stub-no" <> _}}} ->
          Plug.Conn.resp(conn, 200, ~s({"permissionship": "PERMISSIONSHIP_NO_PERMISSION"}))

        _ ->
          Plug.Conn.resp(conn, 500, "{}")
      end
    end
  end

  setup do
    NoizuPromptLingua.OAuthTestSchema.ensure!()

    # Random high port; retry the unlikely collision.
    port =
      Enum.find_value(1..10, fn _ ->
        candidate = 40_000 + rem(System.unique_integer([:positive]), 20_000)

        case start_stub(candidate) do
          {:ok, pid} -> {candidate, pid}
          _ -> nil
        end
      end)

    {port, _pid} = port

    original = Application.get_env(:noizu_prompt_lingua, :mcp_pdp)

    Application.put_env(:noizu_prompt_lingua, :mcp_pdp,
      mode: :spicedb,
      spicedb_http_endpoint: "http://127.0.0.1:#{port}/",
      spicedb_preshared_key: "preshared-test-key"
    )

    on_exit(fn ->
      if original do
        Application.put_env(:noizu_prompt_lingua, :mcp_pdp, original)
      else
        Application.delete_env(:noizu_prompt_lingua, :mcp_pdp)
      end
    end)

    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "spicedb-#{uniq}@example.com",
        user_name: "spicedb#{uniq}",
        handle: "spicedb#{uniq}",
        status: :active,
        verified: true,
        flagged: false
      }
      |> Repo.insert!()

    %{user: user, port: port}
  end

  defp start_stub(port) do
    {:ok, pid} = Bandit.start_link(plug: Stub, port: port)
    {:ok, pid}
  rescue
    _ -> :error
  catch
    _, _ -> :error
  end

  test "endpoint present, SpiceDB grants permission → :ok", %{user: user} do
    assert :ok =
             SpiceDB.check(%{user_id: user.id, tool: "stub-ok-tool", action: "project:read"})
  end

  test "endpoint present, no tuples → falls back to the local check", %{user: user} do
    assert :ok =
             SpiceDB.check(%{user_id: user.id, tool: "stub-no-tool", action: "project:read"})
  end

  test "remote failure on a read-class action fails open", %{user: user} do
    # Stub serves 500s for ordinary tool ids; a list action fails open.
    assert :ok = SpiceDB.check(%{user_id: user.id, tool: "boom", action: "project:list"})
  end

  test "remote failure on a write-class action fails closed", %{user: user} do
    assert {:error, :pdp_unavailable} =
             SpiceDB.check(%{user_id: user.id, tool: "boom", action: "project:delete"})
  end

  test "remote failure without a binary action fails closed", %{user: user} do
    assert {:error, :pdp_unavailable} =
             SpiceDB.check(%{user_id: user.id, tool: "boom", action: :delete})
  end

  test "connection-refused endpoint fails closed for write actions", %{user: user, port: port} do
    Application.put_env(:noizu_prompt_lingua, :mcp_pdp,
      mode: :spicedb,
      spicedb_http_endpoint: "http://127.0.0.1:#{port - 1}",
      spicedb_preshared_key: nil
    )

    assert {:error, :pdp_unavailable} =
             SpiceDB.check(%{user_id: user.id, tool: "anything", action: "project:delete"})
  end

  test "local axis failure on a read-class action fails open (documented quirk)", %{user: user} do
    # The stub would grant "stub-ok-tool", so an :ok result proves the local
    # pairing-grant axis failed the request and the read-class fail-open let it
    # through anyway. NOTE: this means a revoked grant does not block reads in
    # :spicedb mode — flagged to the campaign as a security finding.
    assert :ok =
             SpiceDB.check(%{
               user_id: user.id,
               grant_id: "pg_missing",
               tool: "stub-ok-tool",
               action: "project:read"
             })
  end

  test "local axis failure on a write-class action fails closed", %{user: user} do
    assert {:error, :pdp_unavailable} =
             SpiceDB.check(%{
               user_id: user.id,
               grant_id: "pg_missing",
               tool: "stub-ok-tool",
               action: "project:delete"
             })
  end
end
