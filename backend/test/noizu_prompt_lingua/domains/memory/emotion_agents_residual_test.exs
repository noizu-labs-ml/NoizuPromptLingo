defmodule NoizuPromptLingua.Domains.Memory.EmotionAgentsResidualTest do
  @moduledoc """
  Wave-5B residuals for the memory domain's pure/support layers beyond the
  engine flows in `MemoryTest`:

    * `Emotion` — vector/component math, bucket boundaries, resonance, and the
      defensive atomize/clamp arms.
    * `Agents` — call-sign registry: explicit + auto handles, dup rejection,
      resolve (uuid / call sign / miss), `resolve_scope/3` + `resolve_agent/2`
      bridges, list filters, archive.
    * `Embeddings` — deterministic provider, blank input, `not_configured`,
      provider-error arms (transport refused), hash-embed non-binary arm.
    * `Sentinel` — scope extraction (atom + string types), scope filters,
      weaviate filter shapes, authorize backstop (incl. restricted + string
      classification).
    * `Jobs` — `:sync` dispatch, worker failure → `{:error, _}` rescue arm.
    * `VectorStore` — disabled-mode arms + accessors (enabled arms live in the
      Bandit-stubbed suite).
  """
  use NoizuPromptLingua.MemoryCase, async: false

  alias NoizuPromptLingua.Domains.Memory.{
    Agents,
    Emotion,
    Embeddings,
    Jobs,
    Sentinel,
    VectorStore
  }

  alias NoizuPromptLingua.Schema.Memory.AgentCallSign

  # ── Emotion ────────────────────────────────────────────────────────

  test "build_vector shapes 7 pre-weighted dims; missing hormones fall back to baseline" do
    vec = Emotion.build_vector(%{valence: 1.0, arousal: 1.0, dominance: 1.0}, %{})
    assert length(vec) == 7
    assert hd(vec) == Emotion.vad_weight() * 1.0

    baseline = Emotion.hormone_baseline()

    assert Enum.slice(vec, 3, 4) ==
             Enum.map(
               [baseline.cortisol, baseline.dopamine, baseline.oxytocin, baseline.serotonin],
               &(&1 * Emotion.hormone_weight())
             )
  end

  test "build_vector accepts string-keyed maps and unknown keys (atomize arms)" do
    vec = Emotion.build_vector(%{"valence" => 0.5}, %{"cortisol" => 0.9})
    assert length(vec) == 7

    # An uncastable string key trips the atomize rescue and degrades to neutral.
    vec2 = Emotion.build_vector(%{"nope-not-an-atom" => 1}, %{})
    assert length(vec2) == 7
  end

  test "components keeps raw valence and merges hormones over the baseline" do
    comps = Emotion.components(%{valence: -0.5, arousal: 0.1}, %{dopamine: 0.9})
    assert comps.valence == -0.5
    assert comps.dopamine == 0.9
    assert comps.cortisol == Emotion.hormone_baseline().cortisol
  end

  test "from_row reconstructs mood + hormones from raw columns" do
    row = %{
      valence: 0.1,
      arousal: 0.2,
      dominance: 0.3,
      cortisol: 0.4,
      dopamine: 0.5,
      oxytocin: 0.6,
      serotonin: 0.7
    }

    {mood, hormones} = Emotion.from_row(row)
    assert mood == %{valence: 0.1, arousal: 0.2, dominance: 0.3}
    assert hormones.serotonin == 0.7
  end

  test "bucket places VAD into the 36-bucket grid (boundaries)" do
    assert Emotion.bucket(-0.9, 0.0, 0.0) == "000"
    assert Emotion.bucket(-0.2, 0.5, 0.5) == "111"
    assert Emotion.bucket(0.2, 0.9, 0.4) == "221"
    assert Emotion.bucket(0.9, 0.34, 1.0) == "312"
  end

  test "resonance is 1 for identical vectors and bounded in [0,1]" do
    vec = Emotion.build_vector(Emotion.neutral_mood(), %{})
    assert Emotion.resonance(vec, vec) == 1.0
    res = Emotion.resonance(vec, Emotion.build_vector(%{valence: -1.0}, %{}))
    assert res >= 0.0 and res < 1.0
  end

  test "normalize clamps out-of-range and non-numeric mood values" do
    vec = Emotion.build_vector(%{valence: 9.0, arousal: -3.0, dominance: "hot"}, %{})
    [v, a, d | _] = Enum.map(vec, &(&1 / Emotion.vad_weight()))
    assert v == 1.0
    assert a == 0.0
    # A non-numeric component falls through clampf to the upper bound.
    assert d == 1.0
  end

  # ── Agents ─────────────────────────────────────────────────────────

  test "register stores explicit + auto call signs; duplicate handle is rejected" do
    org = insert_org()

    {:ok, cs} = Agents.register(org, :weego, call_sign: "  Ghost  ", display_name: "Orchestrator")
    assert cs.call_sign == "ghost"

    {:ok, auto} = Agents.register(org, :team_member)
    assert is_binary(auto.call_sign) and auto.call_sign != ""

    assert {:error, _} = Agents.register(org, :team_member, call_sign: "ghost")
  end

  test "generated call signs suffix when the base handle is taken" do
    org = insert_org()

    # Occupy every base handle so the generator must fall into the -NN attempts path.
    for handle <- ~w(maverick viper ghost raven falcon cobra nomad echo nova phoenix talon zephyr
                     specter saber comet drift ranger vortex onyx ember halo jet kilo lynx orca
                     rogue sage tundra wraith zenith aria atlas bishop cinder) do
      %AgentCallSign{}
      |> AgentCallSign.changeset(%{
        organization_id: org,
        kind: :team_member,
        call_sign: handle,
        metadata: %{}
      })
      |> Repo.insert!()
    end

    {:ok, cs} = Agents.register(org, :team_member)

    assert Regex.match?(~r/-\d+$/, cs.call_sign),
           "expected a suffixed handle, got #{cs.call_sign}"
  end

  test "resolve finds by uuid, by call sign, and misses cleanly" do
    org = insert_org()
    {:ok, cs} = Agents.register(org, :weego, call_sign: "seek-me")

    assert Agents.resolve(org, cs.id).id == cs.id
    assert Agents.resolve(org, "seek-me").id == cs.id
    # An unknown uuid falls through to the call-sign lookup → nil.
    assert Agents.resolve(org, Ecto.UUID.generate()) |> is_nil()
    assert Agents.resolve(org, "not-a-handle-xyz") |> is_nil()
  end

  test "resolve_scope bridges personas, weego, team_member, and rejects junk" do
    org = insert_org()
    persona_id = insert_persona(org)

    assert {:ok, %{scope_type: :persona, scope_id: ^persona_id}} =
             Agents.resolve_scope(org, :persona, to_string(persona_id))

    assert {:error, :persona_not_found} = Agents.resolve_scope(org, :persona, "ghost")

    assert {:error, :agent_not_found} = Agents.resolve_scope(org, :weego, nil)

    {:ok, weego} = Agents.register(org, :weego, call_sign: "org-weego")

    assert {:ok, %{scope_type: :weego, scope_id: scope_id}} =
             Agents.resolve_scope(org, :weego, nil)

    assert scope_id == weego.id

    {:ok, tm} = Agents.register(org, :team_member, call_sign: "tm-1")

    assert {:ok, %{scope_type: :team_member, scope_id: tm_scope_id}} =
             Agents.resolve_scope(org, :team_member, "tm-1")

    assert tm_scope_id == tm.id

    assert {:error, {:bad_scope_type, :boss}} = Agents.resolve_scope(org, :boss, "x")
  end

  test "resolve_agent prefers the registry then personas; weego literal resolves the org weego" do
    org = insert_org()
    {:ok, _} = Agents.register(org, :weego, call_sign: "weego")

    assert {:ok, %{scope_type: :weego}} = Agents.resolve_agent(org, "weego")
    assert {:error, :agent_not_found} = Agents.resolve_agent(insert_org(), nil)

    # A persona slug falls through the registry to the personas domain.
    slug = "persona-#{System.unique_integer([:positive])}"
    persona_id = insert_persona(org, slug)

    assert {:ok, %{scope_type: :persona, scope_id: ^persona_id}} = Agents.resolve_agent(org, slug)
  end

  test "list filters by kind/status and archive flips status" do
    org = insert_org()
    {:ok, weego} = Agents.register(org, :weego, call_sign: "list-weego")
    {:ok, _} = Agents.register(org, :team_member, call_sign: "list-tm")

    assert Enum.any?(Agents.list(org), &(&1.id == weego.id))
    assert Enum.any?(Agents.list(org, kind: :weego), &(&1.id == weego.id))
    assert Agents.list(org, kind: :weego, status: "archived") == []
    assert length(Agents.list(org, limit: 1)) == 1

    {:ok, archived} = Agents.archive(weego.id)
    assert archived.status == "archived"
    assert {:error, :not_found} = Agents.archive(Ecto.UUID.generate())
  end

  # ── Embeddings ─────────────────────────────────────────────────────

  test "deterministic provider embeds offline; blank input passes through" do
    original = Application.get_env(:noizu_prompt_lingua, :embeddings)

    Application.put_env(:noizu_prompt_lingua, :embeddings,
      provider: :deterministic,
      dimensions: 16
    )

    try do
      assert Embeddings.configured?()
      assert {:ok, []} = Embeddings.embed([])
      {:ok, [v1, v2]} = Embeddings.embed(["shared words here", "shared words here too"])
      assert length(v1) == 16
      # Shared tokens → positively correlated vectors.
      dot = Enum.zip(v1, v2) |> Enum.reduce(0.0, fn {a, b}, acc -> acc + a * b end)
      assert dot > 0.0

      assert {:ok, vec} = Embeddings.embed_one("hello")
      assert length(vec) == 16
      # Non-binary input → the all-zeros hash arm.
      assert {:ok, [zeros]} = Embeddings.embed([42])
      assert Enum.all?(zeros, &(&1 == 0.0))
    after
      Application.put_env(:noizu_prompt_lingua, :embeddings, original)
    end
  end

  test "unconfigured openai provider returns :not_configured" do
    original = Application.get_env(:noizu_prompt_lingua, :embeddings)

    Application.put_env(:noizu_prompt_lingua, :embeddings, provider: :openai, api_key: nil)

    try do
      refute Embeddings.configured?()
      assert {:error, :not_configured} = Embeddings.embed(["x"])
    after
      Application.put_env(:noizu_prompt_lingua, :embeddings, original)
    end
  end

  test "openai transport failure surfaces as {:error, _}" do
    original = Application.get_env(:noizu_prompt_lingua, :embeddings)

    Application.put_env(:noizu_prompt_lingua, :embeddings,
      provider: :openai,
      api_key: "test-key",
      api_base: "http://127.0.0.1:1",
      timeout_ms: 500
    )

    try do
      assert {:error, _} = Embeddings.embed(["x"])
    after
      Application.put_env(:noizu_prompt_lingua, :embeddings, original)
    end
  end

  # ── Sentinel ───────────────────────────────────────────────────────

  test "scope extraction handles atoms and strings, and rejects partial contexts" do
    ctx = %{organization_id: "org", scope_type: "persona", scope_id: "p1"}
    assert Sentinel.scope(ctx) == %{organization_id: "org", scope_type: :persona, scope_id: "p1"}

    assert Sentinel.scope(%{organization_id: "org", scope_type: :weego, scope_id: nil})
           |> is_nil()

    assert Sentinel.scope(%{}) |> is_nil()
  end

  test "authorize backstop filters by classification and scope match" do
    org = Ecto.UUID.generate()
    sid = Ecto.UUID.generate()

    scope = %{organization_id: org, scope_type: :persona, scope_id: sid}

    mine_open = %{
      organization_id: org,
      scope_type: "persona",
      scope_id: sid,
      classification: :open
    }

    mine_string = %{
      organization_id: org,
      scope_type: :persona,
      scope_id: sid,
      classification: "open"
    }

    restricted = %{
      organization_id: org,
      scope_type: :persona,
      scope_id: sid,
      classification: :restricted
    }

    theirs = %{
      organization_id: Ecto.UUID.generate(),
      scope_type: :persona,
      scope_id: sid,
      classification: :open
    }

    # No scope context: only the classification gate applies.
    assert Sentinel.authorize([mine_open, mine_string, restricted, theirs], %{}) ==
             [mine_open, mine_string, theirs]

    assert Sentinel.authorize([mine_open, theirs], scope) == [mine_open]

    weego_ctx = %{organization_id: org, scope_type: :weego, scope_id: "w"}
    assert Sentinel.authorize([mine_open, theirs], weego_ctx) == [mine_open]
  end

  # ── Jobs ───────────────────────────────────────────────────────────

  test "sync mode runs the worker inline and rescues failures into {:error, _}" do
    assert Jobs.mode() == :sync

    assert {:ok, :ok} =
             Jobs.enqueue(NoizuPromptLingua.Workers.Memory.ReinforcementWorker, %{
               "memory_ids" => []
             })

    assert {:error, _} = Jobs.enqueue(NoSuchWorker.Whatever, %{})
  end

  # ── VectorStore (disabled mode) ────────────────────────────────────

  test "vector store accessors and disabled-mode arms" do
    original = Application.get_env(:noizu_prompt_lingua, :memory_weaviate)

    Application.put_env(:noizu_prompt_lingua, :memory_weaviate,
      enabled: false,
      class: "NplMemory"
    )

    try do
      assert VectorStore.text_vectors() == ~w(content context reflection tangent)
      assert VectorStore.named_vectors() == ~w(content context reflection tangent emotional)

      assert VectorStore.enabled?() == false
      assert VectorStore.configured?() == false

      assert {:error, :disabled} = VectorStore.ensure_class()
      assert {:error, :disabled} = VectorStore.upsert("m1", %{"content" => [0.0]}, %{})
      assert {:error, :disabled} = VectorStore.search("content", [0.0])
      assert :ok = VectorStore.delete("m1")
      assert :ok = VectorStore.delete_class()
      assert {:error, :disabled} = VectorStore.count()
    after
      Application.put_env(:noizu_prompt_lingua, :memory_weaviate, original)
    end
  end
end
