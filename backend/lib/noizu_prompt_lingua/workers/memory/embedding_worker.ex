defmodule NoizuPromptLingua.Workers.Memory.EmbeddingWorker do
  @moduledoc """
  Async tail of ingest: embed the present text facets (content/context/reflection/tangent) with
  OpenAI and compute the 7-d emotional vector, then upsert ALL of them to Weaviate as named
  vectors (content/context/reflection/tangent/emotional) and flip the memory to `active`.

  The emotional vector is always computable (pure math), so it is upserted even when text
  embeddings are unavailable; text recall is then unavailable until embeddings land, but
  emotional-resonance recall works.
  """
  use Oban.Worker, queue: :memory, max_attempts: 3
  require Logger

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Memory.Memory
  alias NoizuPromptLingua.Domains.Memory.{Emotion, Embeddings, VectorStore, Jobs}
  alias NoizuPromptLingua.Workers.Memory.LinkJob

  @text_facets ~w(content context reflection tangent)a

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"memory_id" => id}}) do
    case Repo.get(Memory, id) do
      nil ->
        :ok

      mem ->
        vectors = build_vectors(mem)

        if VectorStore.configured?() and map_size(vectors) > 0 do
          sync_vectors(mem, vectors)
        else
          activate(mem, synced: false, model: nil)
        end

        enqueue_link(id)
        :ok
    end
  end

  # Emotional vector (always) + the text vectors (when embeddings configured).
  defp build_vectors(mem) do
    {mood, hormones} = Emotion.from_row(mem)
    emotional = %{"emotional" => Emotion.build_vector(mood, hormones)}

    texts =
      for f <- @text_facets,
          t = Map.get(mem, f),
          is_binary(t) and String.trim(t) != "",
          do: {f, t}

    case texts do
      [] ->
        emotional

      _ ->
        if Embeddings.configured?() do
          {names, values} = Enum.unzip(texts)

          case Embeddings.embed(values) do
            {:ok, vecs} ->
              text_map = names |> Enum.map(&Atom.to_string/1) |> Enum.zip(vecs) |> Map.new()
              Map.merge(emotional, text_map)

            {:error, reason} ->
              Logger.warning(
                "[Memory.EmbeddingWorker] embed failed for #{mem.id}: #{inspect(reason)}"
              )

              emotional
          end
        else
          emotional
        end
    end
  end

  defp sync_vectors(mem, vectors) do
    VectorStore.ensure_class()

    props = %{
      "organization_id" => to_string(mem.organization_id),
      "scope_type" => to_string(mem.scope_type),
      "scope_id" => to_string(mem.scope_id),
      "compartment" => mem.compartment,
      "classification" => to_string(mem.classification),
      "content_type" => to_string(mem.content_type)
    }

    has_text = Enum.any?(Map.keys(vectors), &(&1 != "emotional"))

    case VectorStore.upsert(mem.id, vectors, props) do
      :ok ->
        activate(mem, synced: has_text, model: if(has_text, do: Embeddings.model(), else: nil))

      other ->
        Logger.warning(
          "[Memory.EmbeddingWorker] weaviate upsert failed for #{mem.id}: #{inspect(other)}"
        )

        activate(mem, synced: false, model: nil)
    end
  end

  defp activate(mem, opts) do
    mem
    |> Ecto.Changeset.change(%{
      state: :active,
      vectors_synced: Keyword.get(opts, :synced, false),
      embedding_model: Keyword.get(opts, :model)
    })
    |> Repo.update()

    :ok
  end

  defp enqueue_link(memory_id) do
    Jobs.enqueue(LinkJob, %{memory_id: memory_id})
    :ok
  rescue
    e ->
      Logger.warning("[Memory.EmbeddingWorker] could not enqueue link: #{inspect(e)}")
      :ok
  catch
    :exit, _ -> :ok
  end
end
