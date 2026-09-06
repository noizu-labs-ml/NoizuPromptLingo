defmodule NoizuPromptLingua.Domains.MockMCP.WeaviateStoreTest do
  @moduledoc """
  WeaviateStore — per-mock vector collections over `Noizu.Weaviate.api_call/5`.

  Stubbing strategy: `Noizu.Weaviate.api_base/0` bakes its endpoint in at
  COMPILE time (`Application.compile_env`), so there is no runtime seam to
  repoint the transport. Tests instead purge `Noizu.Weaviate` and recompile its
  original source file IN MEMORY with `:noizu_weaviate, :endpoint` pointed at a
  local Bandit stub — the on-disk beam is untouched, and `on_exit` purges again
  so the original module reloads from disk for every other suite. No test ever
  reaches the real Weaviate host.

  Embeddings use the deterministic feature-hashing provider (no network).
  """

  use ExUnit.Case, async: false

  alias NoizuPromptLingua.Domains.MockMCP.WeaviateStore
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
    original_embeddings = Application.get_env(:noizu_prompt_lingua, :embeddings)

    # Recompile Noizu.Weaviate in memory against the stub endpoint.
    Application.put_env(:noizu_weaviate, :endpoint, "http://127.0.0.1:#{stub.port}/")
    :code.purge(Noizu.Weaviate)
    :code.delete(Noizu.Weaviate)

    # The dep's source carries pre-existing compiler warnings that only show
    # when it is compiled outside the (cached) dep build — keep them out of the
    # suite output.
    ExUnit.CaptureIO.capture_io(:stdio, fn ->
      ExUnit.CaptureIO.capture_io(:stderr, fn ->
        Code.compile_file(@deps_weaviate_source, Path.dirname(@deps_weaviate_source))
      end)
    end)

    # Deterministic, offline embeddings for every add/query test.
    Application.put_env(:noizu_prompt_lingua, :embeddings,
      provider: :deterministic,
      dimensions: 32
    )

    on_exit(fn ->
      :code.purge(Noizu.Weaviate)
      :code.delete(Noizu.Weaviate)

      if original_endpoint,
        do: Application.put_env(:noizu_weaviate, :endpoint, original_endpoint),
        else: Application.delete_env(:noizu_weaviate, :endpoint)

      if original_embeddings,
        do: Application.put_env(:noizu_prompt_lingua, :embeddings, original_embeddings),
        else: Application.delete_env(:noizu_prompt_lingua, :embeddings)
    end)

    {:ok, stub: stub}
  end

  defp slug, do: "wvs-#{System.unique_integer([:positive])}"

  defp def_(slug, classes) when is_list(classes) do
    %{slug: slug, schema_json: %{"weaviate" => classes}}
  end

  defp facts_class(props \\ [%{"name" => "body", "dataType" => "text"}]) do
    %{"name" => "Facts", "description" => "fact store", "properties" => props}
  end

  # ── naming ────────────────────────────────────────────────────────────────

  test "class_name/2 pascal-cases and prefixes" do
    s = slug()
    assert WeaviateStore.class_name(s, "Facts") == "MockmcpWvs#{slug_tail(s)}Facts"

    assert WeaviateStore.class_name("team-one alpha", "old_notes") ==
             "MockmcpTeamOneAlphaOldNotes"
  end

  defp slug_tail(s), do: s |> String.split("-") |> List.last() |> String.capitalize()

  # ── ensure_classes/2 ──────────────────────────────────────────────────────

  describe "ensure_classes/2" do
    test "non-list or malformed designs short-circuit to {:ok, []}" do
      assert WeaviateStore.ensure_classes(%{slug: "x"}, :nope) == {:ok, []}
      assert WeaviateStore.ensure_classes(%{}, [%{"name" => "Facts"}]) == {:ok, []}
    end

    test "nameless class entries are skipped without an API call" do
      assert WeaviateStore.ensure_classes(%{slug: "x"}, [%{"description" => "no name"}]) ==
               {:ok, []}
    end

    test "creates missing classes (adds the text property, dedupes designs), keeps existing", %{
      stub: stub
    } do
      s = slug()
      cls = WeaviateStore.class_name(s, "Facts")
      other_cls = WeaviateStore.class_name(s, "Notes")

      MockMCPStub.seq(stub, cls, [{:status, 404, ""}])

      MockMCPStub.seq(stub, "schema", [
        {:raw, Jason.encode!(%{"class" => cls})},
        {:raw, Jason.encode!(%{"class" => other_cls})}
      ])

      MockMCPStub.seq(stub, other_cls, [
        {:raw, Jason.encode!(%{"class" => other_cls, "properties" => []})}
      ])

      classes = [
        facts_class([
          %{"name" => "body", "dataType" => "text"},
          %{"name" => "count", "dataType" => "integer"},
          %{"name" => "score", "dataType" => "double"},
          %{"name" => "live", "dataType" => "boolean"},
          %{"name" => "mystery", "dataType" => "who-knows"},
          %{"name" => "text", "dataType" => "string"}
        ]),
        %{"name" => "Notes"},
        %{"name" => ""}
      ]

      assert {:ok, [^cls, ^other_cls]} = WeaviateStore.ensure_classes(%{slug: s}, classes)

      # The creation POST carries the text property first, then the designed
      # properties (dataType-normalized, "text" design deduped away).
      {_, body} = MockMCPStub.last_request(stub, "schema")
      created = Jason.decode!(body)
      assert created["class"] == cls
      assert created["vectorizer"] == "none"

      names = Enum.map(created["properties"], & &1["name"])
      assert names == ["text", "body", "count", "score", "live", "mystery"]

      types = Map.new(created["properties"], &{&1["name"], hd(&1["dataType"])})
      assert types["count"] == "int"
      assert types["score"] == "number"
      assert types["live"] == "boolean"
      assert types["mystery"] == "text"

      # The second (existing) class only GETs — if it had been POSTed too, the
      # captured creation body would name Notes instead of Facts.
    end

    test "a failed creation surfaces {:error, inspect}", %{stub: stub} do
      s = slug()
      cls = WeaviateStore.class_name(s, "Facts")

      MockMCPStub.seq(stub, cls, [{:status, 404, ""}])
      MockMCPStub.seq(stub, "schema", [{:status, 500, "kaboom"}])

      assert {:error, err} = WeaviateStore.ensure_classes(%{slug: s}, [facts_class()])
      assert err =~ "{:http_error, 500}"
    end
  end

  # ── delete_classes/1 ──────────────────────────────────────────────────────

  describe "delete_classes/1" do
    test "drops each named collection; nameless entries are skipped", %{stub: stub} do
      s = slug()
      cls = WeaviateStore.class_name(s, "Facts")

      MockMCPStub.seq(stub, cls, [{:status, 204, ""}])

      assert :ok =
               WeaviateStore.delete_classes(%{
                 slug: s,
                 schema_json: %{"weaviate" => [facts_class(), %{}]}
               })

      assert MockMCPStub.last_method(stub, cls) == "DELETE"
    end

    test "definitions without a weaviate design are a no-op" do
      assert WeaviateStore.delete_classes(%{slug: "x", schema_json: nil}) == :ok
      assert WeaviateStore.delete_classes(%{slug: "x"}) == :ok
    end
  end

  # ── add/4 ─────────────────────────────────────────────────────────────────

  describe "add/4" do
    test "embeds and stores an object, returning its id", %{stub: stub} do
      s = slug()
      MockMCPStub.seq(stub, "objects", [{:raw, Jason.encode!(%{"id" => "obj-1"})}])

      assert {:ok, %{id: "obj-1"}} =
               WeaviateStore.add(def_(s, [facts_class()]), "Facts", "hello world", %{
                 "body" => "hi"
               })

      {_, body} = MockMCPStub.last_request(stub, "objects")
      stored = Jason.decode!(body)
      assert stored["properties"] == %{"body" => "hi", "text" => "hello world"}
      assert is_list(stored["vector"]) and length(stored["vector"]) == 32
    end

    test "atom-keyed extra props are stringified into the object", %{stub: stub} do
      s = slug()
      MockMCPStub.seq(stub, "objects", [{:raw, Jason.encode!(%{"id" => "obj-2"})}])

      assert {:ok, _} =
               WeaviateStore.add(def_(s, [facts_class()]), "Facts", "t", %{origin: :agent})

      {_, body} = MockMCPStub.last_request(stub, "objects")
      assert Jason.decode!(body)["properties"]["origin"] == "agent"
    end

    test "a 200 without an id yields %{id: nil}", %{stub: stub} do
      s = slug()
      MockMCPStub.seq(stub, "objects", [{:raw, Jason.encode!(%{"wononnce" => true})}])

      assert {:ok, %{id: nil}} = WeaviateStore.add(def_(s, [facts_class()]), "Facts", "t")
    end

    test "a failed store call surfaces {:error, inspect}", %{stub: stub} do
      s = slug()
      MockMCPStub.seq(stub, "objects", [{:status, 500, "kaboom"}])

      assert {:error, err} = WeaviateStore.add(def_(s, [facts_class()]), "Facts", "t")
      assert err =~ "{:http_error, 500}"
    end

    test "collections the mock never designed are rejected before any call" do
      assert {:error, err} = WeaviateStore.add(def_("x", [facts_class()]), "Nope", "t")
      assert err =~ "unknown collection 'Nope'"
      assert err =~ "Facts"
    end

    test "embedding failures surface as {:error, message}", %{stub: _stub} do
      Application.put_env(:noizu_prompt_lingua, :embeddings,
        provider: :openai,
        api_key: nil
      )

      s = slug()

      assert {:error, "embedding failed: :not_configured"} =
               WeaviateStore.add(def_(s, [facts_class()]), "Facts", "t")
    end
  end

  # ── query/4 ───────────────────────────────────────────────────────────────

  describe "query/4" do
    test "embeds, shapes the GraphQL query, and maps rows to matches", %{stub: stub} do
      s = slug()
      cls = WeaviateStore.class_name(s, "Facts")

      MockMCPStub.seq(stub, "graphql", [
        {:raw,
         Jason.encode!(%{
           "data" => %{
             "Get" => %{
               # noizu_weaviate decodes with atom keys, incl. the class name
               String.to_atom(cls) => [
                 %{
                   "_additional" => %{"id" => "id-1", "distance" => 0.25},
                   "body" => "hello",
                   "text" => "hello"
                 },
                 %{"text" => "far away"}
               ]
             }
           }
         })}
      ])

      assert {:ok, matches} =
               WeaviateStore.query(def_(s, [facts_class()]), "Facts", "hello", limit: 3)

      assert [
               %{id: "id-1", score: score_1, properties: %{"body" => "hello", "text" => "hello"}},
               %{id: nil, score: score_2, properties: %{"text" => "far away"}}
             ] = matches

      assert score_1 == 0.75
      assert score_2 == 0.0

      {_, body} = MockMCPStub.last_request(stub, "graphql")
      gql = Jason.decode!(body)["query"]
      assert gql =~ "limit: 3"
      assert gql =~ "nearVector"
      # designed property names + text are the selected fields
      assert gql =~ "body text"
    end

    test "an empty Get map yields no rows", %{stub: stub} do
      s = slug()

      MockMCPStub.seq(stub, "graphql", [
        {:raw, Jason.encode!(%{"data" => %{"Get" => %{}}})}
      ])

      assert {:ok, []} = WeaviateStore.query(def_(s, [facts_class()]), "Facts", "hello")
    end

    test "GraphQL error payloads surface as {:error, inspect}", %{stub: stub} do
      s = slug()

      MockMCPStub.seq(stub, "graphql", [
        {:raw, Jason.encode!(%{"errors" => [%{"message" => "exploded"}]})}
      ])

      assert {:error, err} = WeaviateStore.query(def_(s, [facts_class()]), "Facts", "hello")
      assert err =~ "exploded"
    end

    test "unknown collections are rejected before any call" do
      assert {:error, err} = WeaviateStore.query(def_("x", [facts_class()]), "Nope", "q")
      assert err =~ "unknown collection 'Nope'"
    end
  end
end
