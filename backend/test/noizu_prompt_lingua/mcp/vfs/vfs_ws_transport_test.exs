defmodule NoizuPromptLingua.MCP.VFS.VFSWSTransportTest do
  @moduledoc """
  Wire-level conformance for NPL's `/vfs` mount (Wave 0): the
  `Noizu.MCP.Transport.VFSWS` plug hosting `NoizuPromptLingua.MCP.VFSServer`
  through a real Bandit listener, driven by the same Mint.WebSocket client
  pattern as the lib's transport suite.

  Covers the substrate contract an in-process test can't see: bearer
  enforcement on the upgrade (401 without/with-bad token), the `vfs/auth`
  handshake binding the verified claims to the connection identity, and
  per-operation gating enforced end-to-end (`vfs/write` on the read-only
  Wave 0 backend, `:enoent` for excluded subtrees).

  Note the double bind on this transport: the Bearer token authenticates the
  UPGRADE, then the first frame (`vfs/auth` carrying the same token) binds the
  claims — operations before `vfs/auth` close the connection.
  """

  use NoizuPromptLingua.DataCase, async: false

  # Explicit alias: the nested client is defined at the bottom of this file,
  # after the test blocks expand — the auto-alias from nested defmodule is not
  # in scope yet at expansion time.
  alias __MODULE__.WSClient

  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.Token
  alias NoizuPromptLingua.TRP.Cache
  alias NoizuPromptLingua.TRP.TestStub

  @path "/vfs"

  setup do
    Cache.clear()
    TestStub.reset()

    slug = "vfs-ws-#{System.unique_integer([:positive])}"
    TestStub.seed_org(Ecto.UUID.generate(), slug, "VFS WS Org")

    # Lib pubsub hub: started by the app supervision tree (application.ex lists
    # Noizu.MCP.Server.VFSPubSub); assert it so the subscribe test fails loud
    # if that wiring is ever dropped.
    assert Process.whereis(Noizu.MCP.Server.VFSPubSub.Hub)

    port = start_bandit!()
    {:ok, token, _caller} = minted_caller()

    %{
      port: port,
      slug: slug,
      token: token
    }
  end

  defp start_bandit! do
    # Same opts the Phoenix router mounts with, except :path — this listener is
    # NOT behind a Phoenix forward, so the prefix is not stripped.
    plug_opts = NoizuPromptLinguaWeb.MCPConfig.vfs_plug_opts() |> Keyword.put(:path, "/vfs")

    pid =
      start_supervised!(
        {Bandit,
         plug: {Noizu.MCP.Transport.VFSWS, plug_opts},
         port: 0,
         ip: :loopback,
         startup_log: false,
         thousand_island_options: [shutdown_timeout: 10]},
        id: :vfs_ws_bandit
      )

    {:ok, {_ip, port}} = ThousandIsland.listener_info(pid)
    port
  end

  defp minted_caller do
    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "vfsws-#{uniq}@example.com",
        user_name: "vfsws#{uniq}",
        handle: "vfsws#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _raw} =
      MCPApiKeys.generate_api_key(user.id, "vfs-ws",
        toolset_config: %{"groups" => %{"wiki" => %{}}}
      )

    {:ok, token, _exp} =
      Token.mint(%{id: user.id, email: user.email, name: user.user_name}, %{id: key.id},
        alg: :hs256
      )

    {:ok, token, %{user: user, key: key}}
  end

  defp auth_header(nil), do: []
  defp auth_header(token), do: [{"authorization", "Bearer " <> token}]

  # ── upgrade-time auth ─────────────────────────────────────────────────────

  test "upgrade without a bearer token is rejected 401", %{port: port} do
    assert {:error, :not_upgraded, 401} = WSClient.connect(port, @path, [])
  end

  test "upgrade with a bad token is rejected 401", %{port: port} do
    assert {:error, :not_upgraded, 401} =
             WSClient.connect(port, @path, auth_header("not-a-real-token"))
  end

  # ── handshake + ops ───────────────────────────────────────────────────────

  test "vfs/auth binds the connection; ops serve the principal's tree", %{
    port: port,
    slug: slug,
    token: token
  } do
    assert {:ok, client} = WSClient.connect(port, @path, auth_header(token))

    # First frame MUST be vfs/auth; the handshake response carries the
    # connection's session id.
    assert {:ok, client, %{"result" => %{"authenticated" => true, "session_id" => sid}}} =
             WSClient.request(client, "vfs/auth", %{"token" => token}, 1)

    assert is_binary(sid)

    # vfs/stat on the meta plane.
    assert {:ok, client, %{"result" => %{"type" => "file", "size" => size}}} =
             WSClient.request(
               client,
               "vfs/stat",
               %{"path" => "/tobor/#{slug}/_meta/whoami.json"},
               2
             )

    assert size > 0

    # vfs/list of the org root shows only the gated entries.
    assert {:ok, client, %{"result" => %{"entries" => entries}}} =
             WSClient.request(client, "vfs/list", %{"path" => "/tobor/#{slug}"}, 3)

    names = Enum.map(entries, & &1["name"])
    assert "_meta" in names
    assert "wiki" in names
    refute "chat" in names

    # vfs/read round-trips JSON content.
    assert {:ok, client, %{"result" => %{"content" => content, "version" => version}}} =
             WSClient.read(client, "/tobor/#{slug}/_meta/whoami.json", 4)

    assert {:ok, whoami} = Jason.decode(content)
    assert whoami["orgs"] == [slug]
    assert is_integer(version) and version > 0

    # vfs/write: read-only Wave 0 backend — the wire maps :enosys to -32046.
    assert {:ok, client, %{"error" => %{"code" => -32046, "data" => %{"errno_atom" => "enosys"}}}} =
             WSClient.request(
               client,
               "vfs/write",
               %{"path" => "/tobor/#{slug}/_meta/whoami.json", "data" => "hax"},
               5
             )

    # Excluded group subtree: :enoent → resource_not_found -32002.
    assert {:ok, _client,
            %{"error" => %{"code" => -32002, "data" => %{"errno_atom" => "enoent"}}}} =
             WSClient.request(client, "vfs/stat", %{"path" => "/tobor/#{slug}/chat"}, 6)

    # /etc/dev is composed in on the wire too.
    assert {:ok, _client, %{"result" => %{"entries" => etc}}} =
             WSClient.request(client, "vfs/list", %{"path" => "/etc/dev"}, 7)

    assert Enum.map(etc, & &1["name"]) == ["cache", "config", "runtime", "tools"]
  end

  test "operations before vfs/auth close the connection", %{port: port, token: token} do
    assert {:ok, client} = WSClient.connect(port, @path, auth_header(token))

    # The close is preceded by the -32001 error frame.
    assert {:ok, client, %{"error" => %{"code" => -32001}}} =
             WSClient.request(client, "vfs/stat", %{"path" => "/"}, 1)

    assert {:closed, _client, _code} = WSClient.recv(client)
  end

  test "vfs/subscribe registers against the pubsub hub", %{port: port, slug: slug, token: token} do
    assert {:ok, client} = WSClient.connect(port, @path, auth_header(token))

    {:ok, client, %{"id" => 1}} =
      WSClient.request(client, "vfs/auth", %{"token" => token}, 1)

    assert {:ok, _client, %{"result" => %{"subscribed" => true}}} =
             WSClient.request(client, "vfs/subscribe", %{"paths" => ["/tobor/#{slug}"]}, 2)

    assert {:ok, _client, %{"result" => %{"unsubscribed" => true}}} =
             WSClient.request(client, "vfs/unsubscribe", %{"paths" => ["/tobor/#{slug}"]}, 3)
  end

  # ── Mint.WebSocket test client (lib test-suite pattern) ───────────────────

  defmodule WSClient do
    defstruct [:conn, :ref, :ws, :queue, :close]

    def connect(port, path, headers) do
      with {:ok, conn} <-
             Mint.HTTP.connect(:http, "127.0.0.1", port, protocols: [:http1], mode: :passive),
           {:ok, conn, ref} <- Mint.WebSocket.upgrade(:ws, conn, path, headers),
           {:ok, conn, responses} <- Mint.HTTP.recv(conn, 0, 2000) do
        with {:ok, 101, resp_headers} <- upgrade_response(responses, ref),
             {:ok, conn, ws} <- Mint.WebSocket.new(conn, ref, 101, resp_headers) do
          {:ok, %__MODULE__{conn: conn, ref: ref, ws: ws, queue: []}}
        else
          {:ok, status, _headers} -> {:error, :not_upgraded, status}
          error -> error
        end
      else
        {:error, conn, reason} -> {:error, conn, reason}
        error -> error
      end
    end

    defp upgrade_response(responses, ref) do
      status =
        Enum.find_value(responses, fn
          {:status, ^ref, status} -> status
          _ -> nil
        end)

      headers =
        Enum.find_value(responses, fn
          {:headers, ^ref, headers} -> headers
          _ -> nil
        end)

      if status && headers, do: {:ok, status, headers}, else: {:error, :incomplete_upgrade}
    end

    def request(client, method, params, id, timeout \\ 2000) do
      {:ok, ws, data} =
        Mint.WebSocket.encode(
          client.ws,
          {:text, Jason.encode!(%{"v" => 2, "id" => id, "method" => method, "params" => params})}
        )

      {:ok, conn} = Mint.WebSocket.stream_request_body(client.conn, client.ref, data)
      wait_response(%{client | ws: ws, conn: conn}, id, timeout)
    end

    def read(client, path, id, timeout \\ 2000) do
      request(client, "vfs/read", %{"path" => path}, id, timeout)
    end

    defp wait_response(client, id, timeout) do
      case recv(client, timeout) do
        {:ok, client, %{"id" => ^id} = frame} -> {:ok, client, frame}
        {:ok, client, _other} -> wait_response(client, id, timeout)
        error -> error
      end
    end

    def recv(client, timeout \\ 2000)

    def recv(%__MODULE__{close: close} = client, _timeout) when close != nil do
      {:closed, client, close}
    end

    def recv(%__MODULE__{queue: [text | rest]} = client, _timeout) do
      {:ok, %{client | queue: rest}, Jason.decode!(text)}
    end

    def recv(client, timeout) do
      case Mint.WebSocket.recv(client.conn, 0, timeout) do
        {:ok, conn, responses} ->
          datas = for {:data, _, data} <- responses, do: data

          decode(%{client | conn: conn}, IO.iodata_to_binary(datas), timeout)

        {:error, conn, %Mint.TransportError{reason: :closed}, _} ->
          {:closed, %{client | conn: conn}, :closed}

        {:error, conn, reason, _} ->
          {:error, %{client | conn: conn}, reason}
      end
    end

    defp decode(client, data, timeout) do
      case Mint.WebSocket.decode(client.ws, data) do
        {:ok, ws, frames} ->
          client = %{client | ws: ws}

          {texts, rest} = Enum.split_with(frames, &match?({:text, _}, &1))
          texts = Enum.map(texts, fn {:text, t} -> t end)

          close =
            Enum.find(rest, &match?({:close, _, _}, &1)) ||
              Enum.find(rest, &match?({:close, _}, &1))

          cond do
            texts != [] ->
              [text | queued] = texts
              {:ok, %{client | queue: queued, close: close || client.close}, Jason.decode!(text)}

            close != nil ->
              {:closed, %{client | close: close}, close}

            true ->
              recv(client, timeout)
          end

        {:error, ws, reason} ->
          {:error, %{client | ws: ws}, reason}
      end
    end
  end
end
