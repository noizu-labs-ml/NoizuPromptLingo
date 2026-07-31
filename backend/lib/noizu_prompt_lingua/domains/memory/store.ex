defmodule NoizuPromptLingua.Domains.Memory.Store do
  @moduledoc """
  Synchronous ingest hot path: resolve the scope, run the Guardian gate, stamp the raw emotional
  components (agent VAD ++ Monitor hormone snapshot), and store the four texts. The OpenAI
  embeddings + the 7-d emotional vector + the Weaviate upsert happen asynchronously in
  `Workers.Memory.EmbeddingWorker`.
  """
  require Logger
  import Ecto.Query

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Memory.{Memory, Quarantine}
  alias NoizuPromptLingua.Domains.Memory.{Emotion, Embeddings, Guardian, Monitor, Sentinel, Jobs}
  alias NoizuPromptLingua.Workers.Memory.EmbeddingWorker

  @type context :: %{
          required(:organization_id) => Ecto.UUID.t(),
          required(:scope_type) => atom() | String.t(),
          required(:scope_id) => Ecto.UUID.t(),
          optional(:source_agent) => String.t()
        }

  @spec remember(map(), context()) ::
          {:ok, %{id: Ecto.UUID.t() | nil, status: atom(), confidence: String.t()}}
          | {:error, term()}
  def remember(attrs, context \\ %{}) do
    attrs = normalize_keys(attrs)

    case Sentinel.scope(context) do
      nil ->
        {:error, :scope_required}

      scope ->
        case Guardian.gate(attrs) do
          {:quarantine, reason} ->
            quarantine(scope, attrs, reason)
            {:ok, %{id: nil, status: :quarantined, confidence: "low"}}

          :ok ->
            do_store(scope, attrs, context)
        end
    end
  end

  @doc "Archive a memory (drops out of recall; reachable later for restore/audit)."
  def archive(memory_id, context \\ %{}),
    do: set_state(memory_id, context, :archived, prune: true)

  @doc "Restore an archived memory to active."
  def restore(memory_id, context \\ %{}), do: set_state(memory_id, context, :active, prune: false)

  defp set_state(memory_id, context, state, opts) do
    pruned_at = if opts[:prune], do: DateTime.utc_now(), else: nil

    query =
      from(m in Memory, where: m.id == ^memory_id)
      |> Sentinel.scope_filter(Sentinel.scope(context))

    case Repo.update_all(query,
           set: [state: state, pruned_at: pruned_at, updated_at: DateTime.utc_now()]
         ) do
      {n, _} when n > 0 -> :ok
      _ -> {:error, :not_found}
    end
  end

  defp do_store(scope, attrs, context) do
    mood = resolve_mood(attrs)
    confidence = if mood, do: "medium", else: "low"
    # Explicit per-memory hormones (e.g. simulation fixtures) override the Monitor's snapshot.
    hormones = attrs[:hormones] || Monitor.current_hormones(scope)
    comps = Emotion.components(mood, hormones)

    now = DateTime.utc_now()
    occurred = parse_dt(attrs[:occurred_at]) || now

    row =
      %{
        organization_id: scope.organization_id,
        scope_type: scope.scope_type,
        scope_id: scope.scope_id,
        project_id: attrs[:project_id],
        source_agent: context[:source_agent] || attrs[:source_agent] || "external",
        content: attrs[:content],
        context: attrs[:context],
        reflection: attrs[:reflection],
        tangent: attrs[:tangent],
        summary: attrs[:summary],
        content_type: attrs[:content_type] || :episodic,
        confidence: confidence,
        occurred_at: occurred,
        time_of_day: time_of_day(occurred),
        day_of_week: Date.day_of_week(DateTime.to_date(occurred)),
        season: season(occurred),
        domain: attrs[:domain],
        topic: attrs[:topic],
        session_id: attrs[:session_id],
        modality: attrs[:modality],
        collaborators: attrs[:collaborators] || [],
        environment: attrs[:environment] || %{},
        compartment: attrs[:compartment] || "default",
        classification: attrs[:classification] || :open,
        state: :consolidating,
        last_reinforced_at: now
      }
      |> Map.merge(comps)

    case %Memory{} |> Memory.changeset(row) |> Repo.insert() do
      {:ok, mem} ->
        enqueue_embedding(mem.id)
        status = if Embeddings.configured?(), do: :embedding_pending, else: :stored
        {:ok, %{id: mem.id, status: status, confidence: confidence}}

      {:error, changeset} ->
        Logger.warning("[Memory.Store] insert failed: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  end

  defp resolve_mood(attrs) do
    case attrs[:mood] do
      m when is_map(m) ->
        m

      _ ->
        flat = Map.take(attrs, [:valence, :arousal, :dominance])
        if map_size(flat) > 0, do: flat, else: nil
    end
  end

  defp enqueue_embedding(memory_id) do
    Jobs.enqueue(EmbeddingWorker, %{memory_id: memory_id})
    :ok
  rescue
    e ->
      Logger.warning("[Memory.Store] could not enqueue embedding: #{inspect(e)}")
      :ok
  catch
    :exit, reason ->
      Logger.warning("[Memory.Store] embedding enqueue exit: #{inspect(reason)}")
      :ok
  end

  defp quarantine(scope, attrs, reason) do
    %Quarantine{}
    |> Quarantine.changeset(%{
      organization_id: scope.organization_id,
      scope_type: scope.scope_type,
      scope_id: scope.scope_id,
      reason: reason,
      payload: %{"content" => attrs[:content], "domain" => attrs[:domain]}
    })
    |> Repo.insert()
  end

  defp time_of_day(%DateTime{hour: h}) do
    cond do
      h < 6 -> "night"
      h < 12 -> "morning"
      h < 18 -> "afternoon"
      true -> "evening"
    end
  end

  defp season(%DateTime{month: m}) do
    cond do
      m in [12, 1, 2] -> "winter"
      m in [3, 4, 5] -> "spring"
      m in [6, 7, 8] -> "summer"
      true -> "autumn"
    end
  end

  defp parse_dt(%DateTime{} = dt), do: dt

  defp parse_dt(s) when is_binary(s) do
    case DateTime.from_iso8601(s) do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end

  defp parse_dt(_), do: nil

  defp normalize_keys(attrs) when is_map(attrs) do
    Map.new(attrs, fn
      {k, v} when is_binary(k) -> {safe_atom(k), v}
      {k, v} -> {k, v}
    end)
  end

  defp safe_atom(k) do
    String.to_existing_atom(k)
  rescue
    ArgumentError -> k
  end
end
