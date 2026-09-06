defmodule NoizuPromptLingua.Domains.Memory.VectorStoreStubTest do
  @moduledoc """
  Enabled-mode coverage for `Memory.VectorStore` + the OpenAI response arms of
  `Memory.Embeddings`, with no external network.

  Stubbing strategy (mirrors `MockMCP.WeaviateStoreTest`): `Noizu.Weaviate.api_base/0`
  bakes its endpoint in at COMPILE time, so the tests purge `Noizu.Weaviate` and
  recompile its source IN MEMORY against a local Bandit stub (`MockMCPStub`);
  `on_exit` purges again so the on-disk beam is untouched for other suites.
  Embedding calls point `:api_base` at the same stub.
  """
  use ExUnit.Case, async: false

  alias NoizuPromptLingua.Domains.Memory.{Embeddings, VectorStore}
  alias NoizuPromptLingua.MockMCPStub

  @deps_weaviate_source Path.join([
                          __DIR__,
                          "../../../..",
                          "deps/noizu_weaviate/lib/noizu_weaviate.ex"
                        ])

  setup do
    stub = MockMCPStub.start()
    on_exit(fn -> MockMCPStub.stop(stub) end)

    original_endpoint = Application.get_env(:noizu_weaviate, :endpoint)
    original_weaviate = Application.get_env(:noizu_prompt_lingua, :memory_weaviate)
    original_embeddings = Application.get_env(:noizu_prompt_lingua, :embeddings)

    # Recompile Noizu.Weaviate in memory against the stub endpoint.
    Application.put_env(:noizu_weaviate, :endpoint, "http://127.0.0.1:#{stub.port}/")
    :code.purge(Noizu.Weaviate)
    :code.delete(Noizu.Weaviate)

    ExUnit.CaptureIO.capture_io(:stdio, fn ->
      ExUnit.CaptureIO.capture_io(:stderr, fn ->
        Code.compile_file(@deps_weaviate_source, Path.dirname(@deps_weaviate_source))
      end)
    end)

    Application.put_env(:noizu_prompt_lingua, :memory_weaviate, enabled: true, class: "NplMemory")

    on_exit(fn ->
      :code.purge(Noizu.Weaviate)
      :code.delete(Noizu.Weaviate)

      if original_endpoint,
        do: Application.put_env(:noizu_weaviate, :endpoint, original_endpoint),
        else: Application.delete_env(:noizu_weaviate, :endpoint)

      if original_weaviate,
        do: Application.put_env(:noizu_prompt_lingua, :memory_weaviate, original_weaviate),
        else: Application.delete_env(:noizu_prompt_lingua, :memory_weaviate)

      if original_embeddings,
        do: Application.put_env(:noizu_prompt_lingua, :embeddings, original_embeddings),
        else: Application.delete_env(:noizu_prompt_lingua, :embeddings)
    end)

    {:ok, stub: stub}
  end

  defp vec(dims \\ 4), do: Enum.map(1..dims, &(&1 * 1.0))

  # The endpoint is compile-time baked into Noizu.Weaviate — repointing it means
  # another purge + in-memory recompile (on_exit in setup restores everything).
  defp recompile_weaviate(endpoint) do
    Application.put_env(:noizu_weaviate, :endpoint, endpoint)
    :code.purge(Noizu.Weaviate)
    :code.delete(Noizu.Weaviate)

    ExUnit.CaptureIO.capture_io(:stdio, fn ->
      ExUnit.CaptureIO.capture_io(:stderr, fn ->
        Code.compile_file(@deps_weaviate_source, Path.dirname(@deps_weaviate_source))
      end)
    end)
  end

  # ── VectorStore (enabled) ──────────────────────────────────────────

  test "ensure_class creates the class when the schema probe misses", %{stub: stub} do
    MockMCPStub.seq(stub, "NplMemory", [{:status, 404, "{}"}])
    MockMCPStub.seq(stub, "schema", [{:raw, ~s({"class": "NplMemory"})}])

    assert :ok = VectorStore.ensure_class()
    assert MockMCPStub.last_method(stub, "schema") == "POST"
  end

  test "ensure_class is a no-op when the class exists", %{stub: stub} do
    MockMCPStub.seq(stub, "NplMemory", [{:raw, ~s({"class": "NplMemory", "objects": []})}])

    assert :ok = VectorStore.ensure_class()
    assert MockMCPStub.last_method(stub, "NplMemory") == "GET"
  end

  test "transport failures surface {:error, _} through the log_err arms", %{stub: _stub} do
    recompile_weaviate("http://127.0.0.1:1/")

    assert {:error, _} = VectorStore.ensure_class()
    assert {:error, _} = VectorStore.search("content", vec())
  end

  test "HTTP error statuses still count as success at the transport layer", %{stub: stub} do
    # Noizu.Weaviate.api_call surfaces 4xx/5xx as {:ok, %Finch.Response{}} — so an
    # upsert against a 500-ing store still reports :ok; only transport failures
    # (covered below) reach the log_err arms.
    MockMCPStub.seq(stub, "objects", [{:status, 500, ~s({"error": "boom"})}])
    vectors = Map.new(VectorStore.named_vectors(), &{to_string(&1), vec()})

    assert :ok = VectorStore.upsert("m-1", vectors, %{"organization_id" => "org-1"})
  end

  test "upsert posts five named vectors and reports failures", %{stub: stub} do
    vectors = Map.new(VectorStore.named_vectors(), &{to_string(&1), vec()})
    props = %{"organization_id" => "org-1", "scope_type" => "persona"}

    MockMCPStub.seq(stub, "objects", [{:raw, ~s({"id": "m-1"})}])
    assert :ok = VectorStore.upsert("m-1", vectors, props)

    {headers, body} = MockMCPStub.last_request(stub, "objects")
    assert body =~ "memory_id"
    decoded = Jason.decode!(body)
    assert map_size(decoded["vectors"]) == 5
    content_type = headers |> Enum.into(%{}) |> Map.get("content-type")
    assert content_type =~ "json"

    # Transport-level failure: repoint the compiled endpoint at a dead port.
    recompile_weaviate("http://127.0.0.1:1/")
    assert {:error, _} = VectorStore.upsert("m-1", vectors, props)
  end

  test "search parses GraphQL nearVector hits and degrades on errors", %{stub: stub} do
    hits = [
      %{"memory_id" => "m-1", "_additional" => %{"distance" => 0.25}},
      %{"memory_id" => "m-2", "_additional" => %{"distance" => 0.5}}
    ]

    body =
      Jason.encode!(%{
        "data" => %{"Get" => %{"NplMemory" => hits}}
      })

    MockMCPStub.seq(stub, "graphql", [{:raw, body}])

    assert {:ok, [%{memory_id: "m-1", score: s1}, %{memory_id: "m-2", score: s2}]} =
             VectorStore.search("content", vec(),
               limit: 2,
               filters: %{"organization_id" => "org-1", "scope_type" => "persona"}
             )

    assert_in_delta s1, 0.75, 0.0001
    assert_in_delta s2, 0.5, 0.0001

    {_, req_body} = MockMCPStub.last_request(stub, "graphql")
    assert req_body =~ "nearVector"
    assert req_body =~ "where"

    # Error response → {:error, _} (log_err arm).
    MockMCPStub.seq(stub, "graphql", [{:raw, ~s({"errors": [{"message": "bad query"}]})}])
    assert {:error, _} = VectorStore.search("content", vec())

    # Rows missing distance default to score 0.
    sparse = Jason.encode!(%{"data" => %{"Get" => %{"NplMemory" => [%{"memory_id" => "m-3"}]}}})
    MockMCPStub.seq(stub, "graphql", [{:raw, sparse}])
    assert {:ok, [%{memory_id: "m-3", score: 0.0}]} = VectorStore.search("emotional", vec())
  end

  test "delete and delete_class issue DELETEs and always return :ok", %{stub: stub} do
    MockMCPStub.seq(stub, "m-9", [{:raw, "{}"}])
    assert :ok = VectorStore.delete("m-9")
    assert MockMCPStub.last_method(stub, "m-9") == "DELETE"

    MockMCPStub.seq(stub, "NplMemory", [{:raw, "{}"}])
    assert :ok = VectorStore.delete_class()
  end

  test "count aggregates and tolerates malformed responses", %{stub: stub} do
    body =
      Jason.encode!(%{
        "data" => %{"Aggregate" => %{"NplMemory" => [%{"meta" => %{"count" => 7}}]}}
      })

    MockMCPStub.seq(stub, "graphql", [{:raw, body}])
    assert {:ok, 7} = VectorStore.count()

    empty = Jason.encode!(%{"data" => %{"Aggregate" => %{"NplMemory" => []}}})
    MockMCPStub.seq(stub, "graphql", [{:raw, empty}])
    assert {:ok, 0} = VectorStore.count()

    # A 500 aggregates response is returned verbatim ({:ok, response}) by the stack.
    MockMCPStub.seq(stub, "graphql", [{:status, 500, "{}"}])
    assert {:ok, %Finch.Response{status: 500}} = VectorStore.count()

    # Transport failure reaches the passthrough error arm.
    recompile_weaviate("http://127.0.0.1:1/")
    assert {:error, _} = VectorStore.count()
  end

  # ── Embeddings (OpenAI response arms over the same stub) ──────────

  test "openai embeddings decode 200 payloads and surface http errors", %{stub: stub} do
    Application.put_env(:noizu_prompt_lingua, :embeddings,
      provider: :openai,
      api_key: "stub-key",
      api_base: "http://127.0.0.1:#{stub.port}",
      model: "text-embedding-3-small",
      dimensions: 8
    )

    payload =
      Jason.encode!(%{
        "data" => [
          %{"index" => 1, "embedding" => [0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4]},
          %{"index" => 0, "embedding" => [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]}
        ]
      })

    MockMCPStub.seq(stub, "embeddings", [{:raw, payload}])

    assert {:ok, [first, second]} = Embeddings.embed(["a", "b"])
    assert hd(first) == 0.1
    assert hd(second) == 0.4

    MockMCPStub.seq(stub, "embeddings", [{:status, 429, ~s({"error": "slow down"})}])
    assert {:error, {:http, 429}} = Embeddings.embed(["a"])
  end
end
