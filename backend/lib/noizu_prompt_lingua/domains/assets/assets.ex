defmodule NoizuPromptLingua.Domains.Assets do
  @moduledoc """
  Media-prompt asset management. An asset entry stores a `.media.prompt` (YAML)
  and its type; generating an entry produces an `AssetOutput` backed by an
  artifact (the generated item, fetchable via the Artifacts domain). Entries are
  org-scoped (required) with an optional project.

  Generation currently materializes the prompt as the artifact content (a
  placeholder). To wire real LLM/media generation, route `generate_content/2`
  through a content generator before inserting the artifact.
  """
  import Ecto.Query, except: [update: 2]
  require Logger
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{AssetEntry, AssetOutput, AssetEntryHistory}
  alias NoizuPromptLingua.Domains.Artifacts

  # ── Entry CRUD ────────────────────────────────────────────────

  def create(attrs, opts \\ []) do
    case %AssetEntry{} |> AssetEntry.changeset(attrs) |> Repo.insert() do
      {:ok, entry} ->
        log_history(entry.id, "created", opts[:actor])
        {:ok, entry}

      error ->
        error
    end
  end

  def get(id), do: Repo.get(AssetEntry, id)

  # Resolve an id or (org-scoped) slug to an entry.
  def resolve(org_id, id_or_slug) do
    case Ecto.UUID.cast(id_or_slug) do
      {:ok, uuid} ->
        Repo.get(AssetEntry, uuid) || Repo.get_by(AssetEntry, organization_id: org_id, slug: id_or_slug)

      :error ->
        Repo.get_by(AssetEntry, organization_id: org_id, slug: id_or_slug)
    end
  end

  def update(id, attrs, opts \\ []) do
    case get(id) do
      nil ->
        {:error, :not_found}

      entry ->
        case entry |> AssetEntry.changeset(attrs) |> Repo.update() do
          {:ok, updated} ->
            log_history(updated.id, "prompt_updated", opts[:actor], %{changed_fields: Map.keys(attrs)})
            {:ok, updated}

          error ->
            error
        end
    end
  end

  def delete(id) do
    case get(id) do
      nil -> {:error, :not_found}
      entry -> Repo.delete(entry)
    end
  end

  def set_status(id, status, action, opts \\ []) do
    case get(id) do
      nil ->
        {:error, :not_found}

      entry ->
        case entry |> AssetEntry.changeset(%{status: status}) |> Repo.update() do
          {:ok, updated} ->
            log_history(updated.id, action, opts[:actor])
            {:ok, updated}

          error ->
            error
        end
    end
  end

  def publish(id, opts \\ []), do: set_status(id, "published", "published", opts)
  def archive(id, opts \\ []), do: set_status(id, "archived", "archived", opts)

  def list(opts \\ []) do
    AssetEntry
    |> maybe_filter(:organization_id, opts[:organization_id])
    |> maybe_filter(:project_id, opts[:project_id])
    |> maybe_filter(:asset_type, opts[:asset_type])
    |> maybe_filter(:status, opts[:status])
    |> maybe_filter_tag(opts[:tag])
    |> order_by([e], desc: e.inserted_at)
    |> limit(^(opts[:limit] || 50))
    |> offset(^(opts[:offset] || 0))
    |> Repo.all()
  end

  def count_by_type(org_id) do
    AssetEntry |> where([e], e.organization_id == ^org_id) |> group_by([e], e.asset_type) |> select([e], {e.asset_type, count(e.id)}) |> Repo.all() |> Map.new()
  end

  def count_by_status(org_id) do
    AssetEntry |> where([e], e.organization_id == ^org_id) |> group_by([e], e.status) |> select([e], {e.status, count(e.id)}) |> Repo.all() |> Map.new()
  end

  # ── Outputs (generation) ──────────────────────────────────────

  @doc """
  Generate an output for an entry: produce content for the asset, store it as an
  artifact, and record an `AssetOutput`. Content generation is a placeholder
  (the prompt itself) unless `opts[:content]` is supplied.
  """
  def generate(entry_id, opts \\ []) do
    case get(entry_id) do
      nil ->
        {:error, :not_found}

      entry ->
        with {:ok, content} <- resolve_content(entry, opts) do
          mime = opts[:mime_type] || type_to_mime(entry.asset_type)
          persist_generation(entry, entry_id, content, mime, opts)
        end
    end
  end

  # Persist the generated artifact + output in one transaction. No hard {:ok,_}=
  # matches: a changeset/insert error rolls the txn back to a clean {:error, _}
  # instead of raising a MatchError -> 500 (ticket 2989d130).
  defp persist_generation(entry, entry_id, content, mime, opts) do
    Repo.transaction(fn ->
      with {:ok, artifact} <-
             Artifacts.create(%{
               organization_id: entry.organization_id,
               project_id: entry.project_id,
               kind: type_to_artifact_kind(entry.asset_type),
               title: "#{entry.title} (generated)",
               content: content,
               mime_type: mime
             }),
           next_variant = next_variant_number(entry_id),
           {:ok, output} <-
             %AssetOutput{}
             |> AssetOutput.changeset(%{
               entry_id: entry_id,
               artifact_id: artifact.id,
               provider: opts[:provider],
               model: opts[:model],
               variant_number: next_variant
             })
             |> Repo.insert() do
        entry |> AssetEntry.changeset(%{status: "generating"}) |> Repo.update()
        log_history(entry_id, "generated", opts[:actor], %{output_id: output.id, variant: next_variant})
        output
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  # Resolve the content to materialize: an explicit override, the prompt itself
  # (explicit placeholder via llm_generate: false), or an LLM generation. Returns
  # {:ok, content} | {:error, :generation_unavailable}.
  defp resolve_content(entry, opts) do
    cond do
      is_binary(opts[:content]) -> {:ok, opts[:content]}
      opts[:llm_generate] == false -> {:ok, entry.prompt_yaml}
      true -> generate_content(entry, opts)
    end
  end

  # Generate content from the prompt YAML via the LLM-backed ContentGenerator
  # (loads format-specific FIM references from priv/skills/content-generator).
  # A failed/raising generation (no provider key, network error, bad response)
  # surfaces as {:error, :generation_unavailable} — a clean 503/422 upstream,
  # never a 500 and never a silent prompt-as-content artifact. For a deliberate
  # placeholder use llm_generate: false (handled in resolve_content/2).
  defp generate_content(entry, opts) do
    case NoizuPromptLingua.Domains.Assets.ContentGenerator.generate(entry.prompt_yaml, opts) do
      {:ok, generated} -> {:ok, generated}
      {:error, _reason} -> {:error, :generation_unavailable}
    end
  rescue
    e ->
      Logger.warning("asset generation failed: #{Exception.message(e)}")
      {:error, :generation_unavailable}
  end

  def list_outputs(entry_id) do
    AssetOutput
    |> where([o], o.entry_id == ^entry_id)
    |> order_by([o], desc: o.variant_number)
    |> Repo.all()
  end

  def accept_output(output_id), do: update_output_status(output_id, "accepted")
  def reject_output(output_id), do: update_output_status(output_id, "rejected")

  def set_active(entry_id, output_id, opts \\ []) do
    case get(entry_id) do
      nil ->
        {:error, :not_found}

      entry ->
        case entry |> AssetEntry.changeset(%{active_output_id: output_id}) |> Repo.update() do
          {:ok, updated} ->
            log_history(entry_id, "output_activated", opts[:actor], %{output_id: output_id})
            {:ok, updated}

          error ->
            error
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

  defp type_to_mime("image"), do: "image/png"
  defp type_to_mime("svg"), do: "image/svg+xml"
  defp type_to_mime("diagram"), do: "image/svg+xml"
  defp type_to_mime("html"), do: "text/html"
  defp type_to_mime("component"), do: "text/html"
  defp type_to_mime("style_guide"), do: "text/html"
  defp type_to_mime("document"), do: "text/markdown"
  defp type_to_mime("video"), do: "video/mp4"
  defp type_to_mime("music"), do: "audio/mpeg"
  defp type_to_mime("voice"), do: "audio/mpeg"
  defp type_to_mime(_), do: "application/octet-stream"

  defp type_to_artifact_kind(type) when type in ~w(image svg), do: "image"
  defp type_to_artifact_kind(type) when type in ~w(video music voice), do: "binary"
  defp type_to_artifact_kind(type) when type in ~w(component html style_guide diagram), do: "code"
  defp type_to_artifact_kind("document"), do: "document"
  defp type_to_artifact_kind(_), do: "binary"

  defp maybe_filter(q, _field, nil), do: q
  defp maybe_filter(q, :organization_id, v), do: where(q, [e], e.organization_id == ^v)
  defp maybe_filter(q, :project_id, v), do: where(q, [e], e.project_id == ^v)
  defp maybe_filter(q, :asset_type, v), do: where(q, [e], e.asset_type == ^v)
  defp maybe_filter(q, :status, v), do: where(q, [e], e.status == ^v)

  defp maybe_filter_tag(q, nil), do: q
  defp maybe_filter_tag(q, tag), do: where(q, [e], ^tag in e.tags)
end
