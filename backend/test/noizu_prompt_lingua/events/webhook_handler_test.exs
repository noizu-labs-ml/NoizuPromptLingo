defmodule NoizuPromptLingua.Events.WebhookHandlerTest do
  @moduledoc """
  Events.WebhookHandler — PubSub event fan-out to active webhook rows.

  Drives the REAL supervision-tree GenServer: the test grants its sandbox
  connection to the handler process (the matching query runs there), dispatches
  events through NoizuPromptLingua.Events, and captures deliveries on a local
  Bandit catcher (same ephemeral-port recipe as MockMCPStub).

  Rows are inserted via raw SQL: the webhooks table is timestamptz while the
  Ecto schema declares naive `timestamps/0`, so struct inserts fail to dump
  (schema/migration mismatch — flagged for the fix wave).

  The defensive `rescue` in list_matching_webhooks stays uncovered by design —
  it only fires when the repo itself is unreachable.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Events.WebhookHandler
  alias NoizuPromptLingua.Repo

  defmodule Catcher do
    @moduledoc false
    @behaviour Plug

    @impl true
    def init(table), do: table

    @impl true
    def call(conn, table) do
      {:ok, body, conn} = Plug.Conn.read_body(conn)

      status = if String.ends_with?(conn.request_path, "/fail"), do: 500, else: 200

      signature =
        case Enum.find(conn.req_headers, &match?({"x-webhook-signature", _}, &1)) do
          {_, sig} -> sig
          nil -> nil
        end

      :ets.insert(table, {System.unique_integer([:positive]), conn.request_path, body, signature})

      Plug.Conn.send_resp(conn, status, "ok")
    end
  end

  setup do
    {:ok, sock} = :gen_tcp.listen(0, ip: {127, 0, 0, 1})
    {:ok, port} = :inet.port(sock)
    :gen_tcp.close(sock)

    table = :"webhook_catcher_#{port}"
    :ets.new(table, [:named_table, :public, :bag])

    {:ok, pid} =
      Bandit.start_link(plug: {Catcher, table}, scheme: :http, ip: {127, 0, 0, 1}, port: port)

    Ecto.Adapters.SQL.Sandbox.allow(Repo, self(), Process.whereis(WebhookHandler))

    on_exit(fn ->
      if Process.alive?(pid), do: Process.exit(pid, :shutdown)
      if :ets.whereis(table) != :undefined, do: :ets.delete(table)
    end)

    %{port: port, table: table}
  end

  test "delivers an HMAC-signed JSON body to matching webhooks", %{port: port, table: table} do
    webhook!("http://127.0.0.1:#{port}/hook", ["user_registered"], secret: "sekrit")

    NoizuPromptLingua.Events.dispatch(:user_registered, %{org_id: nil, hello: "world"})

    req = await_request(table, "/hook")

    assert %{"event" => "user_registered", "payload" => %{"hello" => "world"}, "timestamp" => _} =
             Jason.decode!(req.body)

    expected =
      :crypto.mac(:hmac, :sha256, "sekrit", req.body) |> Base.encode16(case: :lower)

    assert req.signature == expected
  end

  test "webhooks subscribed to other events are not delivered", %{port: port, table: table} do
    webhook!("http://127.0.0.1:#{port}/filtered", ["org_created"])

    NoizuPromptLingua.Events.dispatch(:user_registered, %{org_id: nil})

    Process.sleep(300)
    assert requests(table) == []
  end

  test "org-scoped webhooks only fire for their organization", %{port: port, table: table} do
    org_id = Ecto.UUID.generate()

    webhook!("http://127.0.0.1:#{port}/global", ["all"])
    webhook!("http://127.0.0.1:#{port}/scoped", ["all"], org_id: org_id)

    # A foreign org payload reaches only the org-agnostic webhook.
    NoizuPromptLingua.Events.dispatch(:org_created, %{org_id: Ecto.UUID.generate()})
    await_request(table, "/global")
    Process.sleep(300)
    refute Enum.any?(requests(table), &(&1.path == "/scoped"))

    # The owning org's payload reaches both.
    NoizuPromptLingua.Events.dispatch(:org_created, %{org_id: org_id})
    await_request(table, "/scoped")
    assert length(requests(table)) >= 3
  end

  test "a non-2xx delivery is attempted with the empty-secret signature", %{
    port: port,
    table: table
  } do
    webhook!("http://127.0.0.1:#{port}/fail", ["user_registered"])

    NoizuPromptLingua.Events.dispatch(:user_registered, %{org_id: nil})

    req = await_request(table, "/fail")

    assert req.signature ==
             :crypto.mac(:hmac, :sha256, "", req.body) |> Base.encode16(case: :lower)

    assert Process.alive?(Process.whereis(WebhookHandler))
  end

  test "an unreachable endpoint leaves the handler alive", %{table: table} do
    {:ok, sock} = :gen_tcp.listen(0, ip: {127, 0, 0, 1})
    {:ok, dead_port} = :inet.port(sock)
    :gen_tcp.close(sock)

    webhook!("http://127.0.0.1:#{dead_port}/gone", ["user_registered"])

    NoizuPromptLingua.Events.dispatch(:user_registered, %{org_id: nil})

    Process.sleep(400)
    assert requests(table) == []
    assert Process.alive?(Process.whereis(WebhookHandler))
  end

  # The webhooks table is timestamptz; the schema's naive timestamps can't dump,
  # so seed rows directly (see moduledoc). Raw-query uuid params take 16-byte
  # binaries, hence bingenerate/dump!.
  defp webhook!(url, events, opts \\ []) do
    org_id =
      case Keyword.get(opts, :org_id) do
        nil -> nil
        ref -> Ecto.UUID.dump!(ref)
      end

    Repo.query!(
      """
      INSERT INTO webhooks (id, url, secret, events, active, organization_id, inserted_at, updated_at)
      VALUES ($1, $2, $3, $4, true, $5, now(), now())
      """,
      [Ecto.UUID.bingenerate(), url, Keyword.get(opts, :secret), events, org_id]
    )

    :ok
  end

  defp requests(table),
    do:
      table
      |> :ets.tab2list()
      |> Enum.map(fn {_id, path, body, sig} -> %{path: path, body: body, signature: sig} end)

  defp await_request(table, path, tries \\ 50)

  defp await_request(_table, path, 0) do
    flunk("no request recorded for #{path}")
  end

  defp await_request(table, path, tries) do
    case Enum.find(requests(table), &(&1.path == path)) do
      nil ->
        Process.sleep(50)
        await_request(table, path, tries - 1)

      req ->
        req
    end
  end
end
