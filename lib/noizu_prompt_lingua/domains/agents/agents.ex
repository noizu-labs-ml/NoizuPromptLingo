defmodule NoizuPromptLingua.Domains.Agents do
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{AgentPipeMessage, AgentInstruction, AgentOrchestration}

  # ── Pipes ─────────────────────────────────────────────────────

  def pipe_in(agent, opts \\ []) do
    limit = Keyword.get(opts, :limit, 10)

    messages =
      AgentPipeMessage
      |> where([m], m.target == ^agent and m.consumed == false)
      |> order_by([m], asc: m.inserted_at)
      |> limit(^limit)
      |> Repo.all()

    ids = Enum.map(messages, & &1.id)
    if ids != [] do
      AgentPipeMessage
      |> where([m], m.id in ^ids)
      |> Repo.update_all(set: [consumed: true])
    end

    messages
  end

  def pipe_out(targets, content, sender, opts \\ []) do
    priority = Keyword.get(opts, :priority, "normal")

    results =
      Enum.map(targets, fn target ->
        %AgentPipeMessage{}
        |> AgentPipeMessage.changeset(%{target: target, sender: sender, content: content, priority: priority})
        |> Repo.insert()
      end)

    errors = Enum.filter(results, &match?({:error, _}, &1))
    if errors == [], do: {:ok, length(results)}, else: {:error, errors}
  end

  # ── Instructions ──────────────────────────────────────────────

  def create_instruction(attrs) do
    %AgentInstruction{} |> AgentInstruction.changeset(attrs) |> Repo.insert()
  end

  def get_instruction(id) do
    Repo.get(AgentInstruction, id)
  end

  def list_instructions(opts \\ []) do
    AgentInstruction
    |> maybe_search_instructions(opts[:search])
    |> maybe_filter_tags(opts[:tags])
    |> maybe_filter_session(opts[:session_id])
    |> order_by([i], desc: i.inserted_at)
    |> limit(^(opts[:limit] || 50))
    |> Repo.all()
  end

  # ── Orchestration ─────────────────────────────────────────────

  def trigger_pipeline(attrs) do
    %AgentOrchestration{}
    |> AgentOrchestration.changeset(Map.put(attrs, :status, "pending"))
    |> Repo.insert()
  end

  def get_orchestration(id) do
    Repo.get(AgentOrchestration, id)
  end

  def update_orchestration(id, attrs) do
    case Repo.get(AgentOrchestration, id) do
      nil -> {:error, :not_found}
      orch -> orch |> AgentOrchestration.changeset(attrs) |> Repo.update()
    end
  end

  # ── Private ───────────────────────────────────────────────────

  defp maybe_search_instructions(q, nil), do: q
  defp maybe_search_instructions(q, s), do: where(q, [i], ilike(i.title, ^"%#{s}%") or ilike(i.content, ^"%#{s}%"))

  defp maybe_filter_tags(q, nil), do: q
  defp maybe_filter_tags(q, tags) when is_list(tags) do
    Enum.reduce(tags, q, fn tag, acc -> where(acc, [i], ^tag in i.tags) end)
  end

  defp maybe_filter_session(q, nil), do: q
  defp maybe_filter_session(q, sid), do: where(q, [i], i.session_id == ^sid)
end
