defmodule NoizuPromptLingua.MCP.VFS.MemoryTest do
  @moduledoc """
  Wave 3 battery for the `memory` VFS backend (design §2.12), through `Root` +
  `Features.VFS`.

  Covers: the call-sign registry (AgentRegister as create, AgentList as
  readdir, :eexist collisions, weego resolution), the journal (Remember as
  create — plain text or JSON body —, doc reads, listing windows),
  Reinforce/Denforce as weight-field writes, `.links.json` association reads,
  and the `_query` write-request/read-result control node — including the
  Weaviate-backed semantic branch (stubbed per the vector_store_stub_test
  pattern) and the lexical fallback, with one-shot consume semantics.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias NoizuPromptLingua.MockMCPStub
  alias NoizuPromptLingua.MCP.VFS.Root
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Memory.AssociationEdge
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    TrpCache.clear()
    TestStub.reset()

    suffix = Ecto.UUID.generate() |> binary_part(0, 8)

    org =
      Repo.insert!(%Organization{name: "VFS Memory Org #{suffix}", slug: "vfs-memory-#{suffix}"})

    TestStub.seed_org(org.id, org.slug, org.name)

    on_exit(fn -> Cache.purge(Root) end)

    %{org: org, ctx: key_ctx(%{"groups" => %{"memory" => %{}}})}
  end

  defp key_ctx(config) do
    uniq = System.unique_integer([:positive])
    handle = "w3bmem#{uniq}"

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "#{handle}@example.com",
        user_name: handle,
        handle: handle,
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _} = MCPApiKeys.generate_api_key(user.id, "vfs-memory", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "mem-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id, "handle" => handle}}
    }
  end

  defp base(org), do: "/tobor/#{org.slug}/memory"

  defp register!(org, ctx, call_sign, kind) do
    assert {:ok, _} =
             VFS.create(
               Root,
               "#{base(org)}/agents/#{call_sign}.json",
               ~s({"kind": "#{kind}"}),
               ctx
             )
  end

  defp remember!(org, ctx, agent, body) do
    assert {:ok, node} = VFS.create(Root, "#{base(org)}/#{agent}/journal/m.json", body, ctx)
    node.xattrs["id"]
  end

  # ── call-sign registry (AgentRegister / AgentList) ────────────────────────

  test "agent registry: create, read, list, duplicate collision", %{org: org, ctx: ctx} do
    register!(org, ctx, "kilo", "weego")

    {:ok, doc, _} = VFS.read(Root, "#{base(org)}/agents/kilo.json", ctx)
    assert {:ok, %{"call_sign" => "kilo", "kind" => "weego"}} = Jason.decode(doc)

    assert {:ok, entries, nil} = VFS.list(Root, "#{base(org)}/agents", nil, ctx)
    assert Enum.map(entries, & &1.name) == ["kilo.json"]

    # Duplicate call sign → :eexist; plain-text body defaults to team_member.
    assert {:error, :eexist} =
             VFS.create(Root, "#{base(org)}/agents/kilo.json", ~s({"kind": "team_member"}), ctx)

    assert {:ok, _} = VFS.create(Root, "#{base(org)}/agents/echo.json", "plain text", ctx)

    {:ok, doc, _} = VFS.read(Root, "#{base(org)}/agents/echo.json", ctx)
    assert {:ok, %{"kind" => "team_member"}} = Jason.decode(doc)

    # Bad kind refused.
    assert {:error, :eio} =
             VFS.create(Root, "#{base(org)}/agents/bad.json", ~s({"kind": "overlord"}), ctx)

    assert {:error, :enosys} = VFS.remove(Root, "#{base(org)}/agents/kilo.json", ctx)
  end

  # ── journal (Remember) ────────────────────────────────────────────────────

  test "journal: plain-text and JSON creates read back; listing shows the window", %{
    org: org,
    ctx: ctx
  } do
    register!(org, ctx, "raven", "team_member")

    id1 = remember!(org, ctx, "raven", "a plain thought")
    assert is_binary(id1)

    id2 =
      remember!(org, ctx, "raven", """
      {"content": "structured thought", "context": "testing", "reflection": "calm",
       "domain": "ops", "mood": {"valence": 0.5, "arousal": 0.3}}
      """)

    assert id2 != id1

    {:ok, doc1, _} = VFS.read(Root, "#{base(org)}/raven/journal/#{id1}.json", ctx)
    assert {:ok, %{"content" => "a plain thought"}} = Jason.decode(doc1)

    {:ok, doc2, _} = VFS.read(Root, "#{base(org)}/raven/journal/#{id2}.json", ctx)
    {:ok, doc} = Jason.decode(doc2)
    assert doc["content"] == "structured thought"
    assert doc["context"] == "testing"
    assert doc["domain"] == "ops"
    assert doc["mood"]["valence"] == 0.5

    assert {:ok, entries, nil} = VFS.list(Root, "#{base(org)}/raven/journal", nil, ctx)
    # Sort BOTH sides — UUID ids have no ordering relationship to create order,
    # and a one-sided sort flips this 50% of the time (full-suite flake 09-05).
    assert Enum.sort(Enum.map(entries, & &1.name)) ==
             Enum.sort(["#{id1}.json", "#{id2}.json"])

    # The literal weego resolves to the org's registered weego identity.
    register!(org, ctx, "kilo", "weego")
    id3 = remember!(org, ctx, "weego", "weego's memory")
    assert {:ok, _, _} = VFS.read(Root, "#{base(org)}/weego/journal/#{id3}.json", ctx)
  end

  # ── Reinforce / Denforce ──────────────────────────────────────────────────

  test "reinforce and denforce adjust the decay weight through file writes", %{
    org: org,
    ctx: ctx
  } do
    register!(org, ctx, "viper", "team_member")
    id = remember!(org, ctx, "viper", "reinforce me")

    path = "#{base(org)}/viper/journal/#{id}.json"
    {:ok, doc, _} = VFS.read(Root, path, ctx)
    {:ok, %{"decay_weight" => w0}} = Jason.decode(doc)

    assert {:ok, _} = VFS.write(Root, path, "denforce", ctx)
    {:ok, %{"decay_weight" => w1}} = read_weight(path)

    assert {:ok, _} = VFS.write(Root, path, ~s({"reinforce": true}), ctx)
    {:ok, %{"decay_weight" => w2}} = read_weight(path)

    assert w1 < w0
    assert w2 > w1

    # Malformed weight writes are :eio.
    assert {:error, :eio} = VFS.write(Root, path, "shout at it", ctx)
  end

  defp read_weight(path) do
    {:ok, doc, _} = VFS.read(Root, path, key_ctx(%{"groups" => %{"memory" => %{}}}))
    {:ok, map} = Jason.decode(doc)
    {:ok, map}
  end

  # ── associations (.links.json) ────────────────────────────────────────────

  test "links file renders association edges", %{org: org, ctx: ctx} do
    register!(org, ctx, "ghost", "team_member")
    id1 = remember!(org, ctx, "ghost", "source memory")
    id2 = remember!(org, ctx, "ghost", "target memory")

    Repo.insert!(%AssociationEdge{
      source_memory_id: id1,
      target_memory_id: id2,
      edge_type: :semantic,
      weight: 0.7,
      reason: "written together"
    })

    {:ok, links, _} = VFS.read(Root, "#{base(org)}/ghost/journal/#{id1}.links.json", ctx)
    assert {:ok, edges} = Jason.decode(links)

    mine = Enum.find(edges, &(&1["reason"] == "written together"))
    assert mine["type"] == "semantic"
    assert_in_delta mine["weight"], 0.7, 0.001
    assert mine["source_memory_id"] == id1
    assert mine["target_memory_id"] == id2

    # The reverse direction resolves the same edge set; unknown ids are :enoent.
    assert {:ok, _, _} = VFS.read(Root, "#{base(org)}/ghost/journal/#{id2}.links.json", ctx)

    assert {:error, :enoent} =
             VFS.stat(
               Root,
               "#{base(org)}/ghost/journal/00000000-0000-0000-0000-000000000000.links.json",
               ctx
             )
  end

  # ── _query control node (write-request / read-result) ─────────────────────

  test "_query lexical recall ranks results and consumes on read", %{org: org, ctx: ctx} do
    register!(org, ctx, "sage", "team_member")
    id = remember!(org, ctx, "sage", "the blueberry pancake recipe needs buttermilk")
    remember!(org, ctx, "sage", "unrelated note about kubernetes ingress controllers")

    query = "#{base(org)}/sage/_query"

    # Read with nothing buffered → :enoent.
    assert {:error, :enoent} = VFS.read(Root, query, ctx)

    assert {:ok, _} = VFS.write(Root, query, ~s({"query": "blueberry pancake"}), ctx)

    {:ok, results, _} = VFS.read(Root, query, ctx)
    {:ok, %{"mode" => "active", "results" => rows}} = Jason.decode(results)
    assert id in Enum.map(rows, & &1["id"])

    # One-shot: the buffer is consumed.
    assert {:error, :enoent} = VFS.read(Root, query, ctx)

    # Bare-text shorthand is a query; per-session buffers don't collide.
    assert {:ok, _} = VFS.write(Root, query, "blueberry", ctx)
    assert {:ok, _, _} = VFS.read(Root, query, ctx)

    other = key_ctx(%{"groups" => %{"memory" => %{}}})
    assert {:error, :enoent} = VFS.read(Root, query, other)
  end

  test "_query emotional mode answers by_emotion; malformed requests are :eio", %{
    org: org,
    ctx: ctx
  } do
    register!(org, ctx, "ember", "team_member")
    remember!(org, ctx, "ember", "a calm evening walk by the lake")

    query = "#{base(org)}/ember/_query"

    assert {:ok, _} =
             VFS.write(Root, query, ~s({"mood": {"valence": 0.6, "arousal": 0.2}}), ctx)

    {:ok, results, _} = VFS.read(Root, query, ctx)
    assert {:ok, %{"mode" => "by_emotion", "results" => rows}} = Jason.decode(results)
    assert is_list(rows)

    assert {:error, :eio} = VFS.write(Root, query, "{}", ctx)
  end

  test "_query semantic path rides a stubbed Weaviate and ranks stubbed hits", %{
    org: org,
    ctx: ctx
  } do
    register!(org, ctx, "nova", "team_member")
    id = remember!(org, ctx, "nova", "weaviate should surface this exact memory")

    stub = MockMCPStub.start()
    on_exit(fn -> MockMCPStub.stop(stub) end)

    original_endpoint = Application.get_env(:noizu_weaviate, :endpoint)
    original_weaviate = Application.get_env(:noizu_prompt_lingua, :memory_weaviate)
    original_embeddings = Application.get_env(:noizu_prompt_lingua, :embeddings)

    hits = [%{"memory_id" => id, "_additional" => %{"distance" => 0.1}}]

    graphql =
      Jason.encode!(%{"data" => %{"Get" => %{"NplMemory" => hits}}})

    MockMCPStub.seq(stub, "graphql", [{:raw, graphql}])

    embeddings =
      Jason.encode!(%{
        "data" => [%{"index" => 0, "embedding" => [0.1, 0.2, 0.3, 0.4]}]
      })

    MockMCPStub.seq(stub, "embeddings", [{:raw, embeddings}])

    # Noizu.Weaviate bakes the endpoint in at compile time — purge and
    # recompile in memory against the stub (vector_store_stub_test pattern).
    Application.put_env(:noizu_weaviate, :endpoint, "http://127.0.0.1:#{stub.port}/")
    :code.purge(Noizu.Weaviate)
    :code.delete(Noizu.Weaviate)

    weaviate_source =
      Path.join([__DIR__, "../../../..", "deps/noizu_weaviate/lib/noizu_weaviate.ex"])

    ExUnit.CaptureIO.capture_io(:stdio, fn ->
      ExUnit.CaptureIO.capture_io(:stderr, fn ->
        Code.compile_file(weaviate_source, Path.dirname(weaviate_source))
      end)
    end)

    Application.put_env(:noizu_prompt_lingua, :memory_weaviate, enabled: true, class: "NplMemory")

    Application.put_env(:noizu_prompt_lingua, :embeddings,
      provider: :openai,
      api_key: "stub-key",
      api_base: "http://127.0.0.1:#{stub.port}",
      model: "text-embedding-3-small",
      dimensions: 4
    )

    query = "#{base(org)}/nova/_query"
    assert {:ok, _} = VFS.write(Root, query, ~s({"query": "exact memory"}), ctx)

    {:ok, results, _} = VFS.read(Root, query, ctx)
    {:ok, %{"mode" => "active", "results" => rows}} = Jason.decode(results)

    assert rows != []
    assert id in Enum.map(rows, & &1["id"])
  after
    :code.purge(Noizu.Weaviate)
    :code.delete(Noizu.Weaviate)

    Application.delete_env(:noizu_weaviate, :endpoint)
    Application.delete_env(:noizu_prompt_lingua, :memory_weaviate)
    Application.delete_env(:noizu_prompt_lingua, :embeddings)
  end

  # ── listing + errnos ──────────────────────────────────────────────────────

  test "memory root lists registered agents; unknown agents are :enoent", %{org: org, ctx: ctx} do
    register!(org, ctx, "talon", "team_member")

    assert {:ok, entries, nil} = VFS.list(Root, base(org), nil, ctx)
    names = Enum.map(entries, & &1.name)
    assert "overview.md" in names
    assert "agents" in names
    assert "talon" in names

    assert {:error, :enoent} = VFS.stat(Root, "#{base(org)}/no-such-agent", ctx)
    assert {:error, :eisdir} = VFS.read(Root, "#{base(org)}/talon", ctx)
    assert {:error, :enosys} = VFS.remove(Root, "#{base(org)}/talon/journal/x.json", ctx)
    assert {:error, :enosys} = VFS.create(Root, "#{base(org)}/talon/journal/m", "x", ctx)
  end
end
