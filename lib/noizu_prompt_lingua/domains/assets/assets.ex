defmodule NoizuPromptLingua.Domains.Assets do
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{AssetEntry, AssetOutput, AssetEntryHistory}
  alias NoizuPromptLingua.Domains.Artifacts

  # ── Entry CRUD ────────────────────────────────────────────────

  def create(attrs, opts \\ []) do
    case %AssetEntry{} |> AssetEntry.changeset(attrs) |> Repo.insert() do
      {:ok, entry} ->
        log_history(entry.id, "created", opts[:actor])
        {:ok, entry}
      error -> error
    end
  end

  def get(slug_or_id) do
    case Ecto.UUID.cast(slug_or_id) do
      {:ok, _} ->
        AssetEntry
        |> where([e], e.id == ^slug_or_id or e.slug == ^slug_or_id)
        |> Repo.one()
      :error ->
        Repo.get_by(AssetEntry, slug: slug_or_id)
    end
  end

  def update(slug_or_id, attrs, opts \\ []) do
    case get(slug_or_id) do
      nil -> {:error, :not_found}
      entry ->
        case entry |> AssetEntry.changeset(attrs) |> Repo.update() do
          {:ok, updated} ->
            log_history(updated.id, "prompt_updated", opts[:actor], %{changed_fields: Map.keys(attrs)})
            {:ok, updated}
          error -> error
        end
    end
  end

  def publish(slug_or_id, opts \\ []) do
    case get(slug_or_id) do
      nil -> {:error, :not_found}
      entry ->
        case entry |> AssetEntry.changeset(%{status: "published"}) |> Repo.update() do
          {:ok, published} ->
            log_history(published.id, "published", opts[:actor])
            {:ok, published}
          error -> error
        end
    end
  end

  def archive(slug_or_id, opts \\ []) do
    case get(slug_or_id) do
      nil -> {:error, :not_found}
      entry ->
        case entry |> AssetEntry.changeset(%{status: "archived"}) |> Repo.update() do
          {:ok, archived} ->
            log_history(archived.id, "archived", opts[:actor])
            {:ok, archived}
          error -> error
        end
    end
  end

  def list(opts \\ []) do
    AssetEntry
    |> maybe_filter(:asset_type, opts[:asset_type])
    |> maybe_filter(:status, opts[:status])
    |> maybe_filter(:project_id, opts[:project_id])
    |> maybe_filter_tag(opts[:tag])
    |> order_by([e], desc: e.inserted_at)
    |> limit(^(opts[:limit] || 50))
    |> offset(^(opts[:offset] || 0))
    |> Repo.all()
  end

  def count_by_type do
    AssetEntry |> group_by([e], e.asset_type) |> select([e], {e.asset_type, count(e.id)}) |> Repo.all() |> Map.new()
  end

  def count_by_status do
    AssetEntry |> group_by([e], e.status) |> select([e], {e.status, count(e.id)}) |> Repo.all() |> Map.new()
  end

  # ── Outputs ───────────────────────────────────────────────────

  def generate(entry_id, opts \\ []) do
    entry = Repo.get!(AssetEntry, entry_id)
    artifact_kind = type_to_artifact_kind(entry.asset_type)

    Repo.transaction(fn ->
      {:ok, artifact} = Artifacts.create(%{
        kind: artifact_kind,
        title: "#{entry.title} (generated)",
        content: entry.prompt_yaml,
        mime_type: opts[:mime_type]
      })

      next_variant = next_variant_number(entry_id)

      {:ok, output} = %AssetOutput{}
        |> AssetOutput.changeset(%{
          entry_id: entry_id,
          artifact_id: artifact.id,
          provider: opts[:provider],
          model: opts[:model],
          variant_number: next_variant
        })
        |> Repo.insert()

      entry |> AssetEntry.changeset(%{status: "generating"}) |> Repo.update()
      log_history(entry_id, "generated", opts[:actor], %{output_id: output.id, variant: next_variant})

      output
    end)
  end

  def list_outputs(entry_id) do
    AssetOutput
    |> where([o], o.entry_id == ^entry_id)
    |> order_by([o], desc: o.variant_number)
    |> Repo.all()
  end

  def accept_output(output_id) do
    update_output_status(output_id, "accepted")
  end

  def reject_output(output_id) do
    update_output_status(output_id, "rejected")
  end

  def set_active(entry_id, output_id, opts \\ []) do
    case get_by_id(entry_id) do
      nil -> {:error, :not_found}
      entry ->
        case entry |> AssetEntry.changeset(%{active_output_id: output_id}) |> Repo.update() do
          {:ok, updated} ->
            log_history(entry_id, "output_activated", opts[:actor], %{output_id: output_id})
            {:ok, updated}
          error -> error
        end
    end
  end

  # ── History ───────────────────────────────────────────────────

  def list_history(entry_id, opts \\ []) do
    AssetEntryHistory
    |> where([h], h.entry_id == ^entry_id)
    |> order_by([h], desc: h.inserted_at)
    |> limit(^(opts[:limit] || 50))
    |> Repo.all()
  end

  # ── Private ───────────────────────────────────────────────────

  defp get_by_id(id), do: Repo.get(AssetEntry, id)

  defp log_history(entry_id, action, actor, details \\ nil) do
    %AssetEntryHistory{}
    |> AssetEntryHistory.changeset(%{entry_id: entry_id, action: action, actor: actor, details: details})
    |> Repo.insert()
  end

  defp update_output_status(output_id, status) do
    case Repo.get(AssetOutput, output_id) do
      nil -> {:error, :not_found}
      output -> output |> AssetOutput.changeset(%{status: status}) |> Repo.update()
    end
  end

  defp next_variant_number(entry_id) do
    (AssetOutput |> where([o], o.entry_id == ^entry_id) |> select([o], max(o.variant_number)) |> Repo.one() || 0) + 1
  end

  defp type_to_artifact_kind(type) when type in ~w(image svg), do: "image"
  defp type_to_artifact_kind("video"), do: "binary"
  defp type_to_artifact_kind(type) when type in ~w(music voice), do: "binary"
  defp type_to_artifact_kind(type) when type in ~w(component html style_guide), do: "code"
  defp type_to_artifact_kind("diagram"), do: "code"
  defp type_to_artifact_kind("document"), do: "document"
  defp type_to_artifact_kind(_), do: "binary"

  defp maybe_filter(q, _field, nil), do: q
  defp maybe_filter(q, :asset_type, v), do: where(q, [e], e.asset_type == ^v)
  defp maybe_filter(q, :status, v), do: where(q, [e], e.status == ^v)
  defp maybe_filter(q, :project_id, v), do: where(q, [e], e.project_id == ^v)

  defp maybe_filter_tag(q, nil), do: q
  defp maybe_filter_tag(q, tag), do: where(q, [e], ^tag in e.tags)
end
