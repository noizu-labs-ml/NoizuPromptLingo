defmodule NoizuPromptLingua.MemoryCase do
  @moduledoc """
  Test case for the memory engine. Provides the Ecto Sandbox, scope/org/persona/agent builders,
  and an `eventually/2` retry helper for Weaviate's near-real-time consistency.

  Note: memory writes go to Weaviate (committed, not sandboxed) while PG rows are sandboxed
  (rolled back). Inter-test isolation comes from each test's randomly-generated organization_id,
  which scopes every Weaviate query.
  """
  use ExUnit.CaseTemplate

  using do
    quote do
      import Ecto.Query
      import NoizuPromptLingua.MemoryCase

      alias NoizuPromptLingua.Repo
      alias NoizuPromptLingua.Domains.Memory
      alias NoizuPromptLingua.Domains.Memory.{Agents, VectorStore}
      alias NoizuPromptLingua.Schema.Memory.Memory, as: MemSchema
      alias NoizuPromptLingua.Schema.Memory.AssociationEdge
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(NoizuPromptLingua.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    :ok
  end

  @doc "Insert an organization, returning its UUID."
  def insert_org(prefix \\ "memorg") do
    %{rows: [[raw]]} =
      NoizuPromptLingua.Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["#{prefix}-#{System.unique_integer([:positive])}", "Memory Test Org"]
      )

    Ecto.UUID.load!(raw)
  end

  @doc "Insert a persona under an org, returning its UUID."
  def insert_persona(org_id, slug \\ nil) do
    slug = slug || "persona-#{System.unique_integer([:positive])}"

    %{rows: [[raw]]} =
      NoizuPromptLingua.Repo.query!(
        "INSERT INTO personas (id, organization_id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, $3, now(), now()) RETURNING id",
        [Ecto.UUID.dump!(org_id), slug, "Persona #{slug}"]
      )

    Ecto.UUID.load!(raw)
  end

  @doc "A context map for a persona scope."
  def persona_scope(org_id, persona_id),
    do: %{organization_id: org_id, scope_type: :persona, scope_id: persona_id, requester_id: persona_id, source_agent: "test"}

  @doc "Register a team_member call sign and return its scope context."
  def team_member_scope(org_id, call_sign \\ nil) do
    {:ok, cs} = NoizuPromptLingua.Domains.Memory.Agents.register(org_id, :team_member, call_sign: call_sign)
    %{organization_id: org_id, scope_type: :team_member, scope_id: cs.id, requester_id: cs.id, source_agent: "test", call_sign: cs.call_sign}
  end

  @doc "Register a weego call sign and return its scope context."
  def weego_scope(org_id, call_sign \\ "weego") do
    {:ok, cs} = NoizuPromptLingua.Domains.Memory.Agents.register(org_id, :weego, call_sign: call_sign)
    %{organization_id: org_id, scope_type: :weego, scope_id: cs.id, requester_id: cs.id, source_agent: "test"}
  end

  @doc "Retry `fun` until it returns a truthy, non-empty value (Weaviate is eventually consistent)."
  def eventually(fun, tries \\ 40)
  def eventually(_fun, 0), do: nil

  def eventually(fun, tries) do
    case fun.() do
      nil -> Process.sleep(200) && eventually(fun, tries - 1)
      false -> Process.sleep(200) && eventually(fun, tries - 1)
      [] -> Process.sleep(200) && eventually(fun, tries - 1)
      val -> val
    end
  end
end
