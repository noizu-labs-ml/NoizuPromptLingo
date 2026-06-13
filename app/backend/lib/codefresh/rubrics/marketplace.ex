defmodule Codefresh.Rubrics.Marketplace do
  @moduledoc """
  Cross-org rubric catalog (US-119). Browse is not tenant-scoped (everyone sees
  curated entries); import deep-copies the rubric_version into the caller's org,
  retaining provenance in the new rubric's `description` and incrementing the
  marketplace entry's `download_count`.

  Marketplace publishing (author side) is Wave 3+ and not exposed here.
  """

  import Ecto.Query, only: [from: 2]
  alias Ecto.Multi
  alias Codefresh.Repo
  alias Codefresh.Rubrics
  alias Codefresh.Rubrics.{MarketplaceRubric, RubricVersion}

  @doc """
  List marketplace entries with optional `:domain` and `:status` filters.
  Returns `%{entry: MarketplaceRubric, rubric_version: RubricVersion}` maps.
  """
  def list_entries(opts \\ []) do
    domain = Keyword.get(opts, :domain)
    status = Keyword.get(opts, :status, "curated")

    q =
      from e in MarketplaceRubric,
        join: rv in RubricVersion,
        on: rv.id == e.rubric_version_id,
        where: e.curation_status == ^status,
        order_by: [desc: e.published_at],
        select: %{entry: e, rubric_version: rv}

    q
    |> maybe_domain(domain)
    |> Repo.all()
  end

  defp maybe_domain(q, nil), do: q
  defp maybe_domain(q, ""), do: q
  defp maybe_domain(q, domain), do: from([e, _] in q, where: e.domain == ^domain)

  def get_entry!(id), do: Repo.get!(MarketplaceRubric, id)

  @doc """
  Import a marketplace rubric into `organization_id`. Deep-copies the source
  rubric_version into a fresh rubric head owned by the importer. The new rubric
  carries `description = "Imported from marketplace: <title>"` (provenance).

  Returns `{:ok, %{rubric: r, version: v}}` on success.
  """
  def import(organization_id, entry_id, opts \\ []) do
    importing_user_id = Keyword.get(opts, :imported_by_user_id)

    Multi.new()
    |> Multi.run(:entry, fn _repo, _ ->
      case Repo.get(MarketplaceRubric, entry_id) do
        nil -> {:error, :entry_not_found}
        entry -> {:ok, entry}
      end
    end)
    |> Multi.run(:source_version, fn _repo, %{entry: e} ->
      case Repo.get(RubricVersion, e.rubric_version_id) do
        nil -> {:error, :source_version_missing}
        v -> {:ok, v}
      end
    end)
    |> Multi.run(:new_rubric, fn _repo, %{entry: e} ->
      slug_base =
        e.title
        |> String.downcase()
        |> String.replace(~r/[^a-z0-9]+/, "-")
        |> String.trim("-")

      slug = "#{slug_base}-#{short_id()}"

      Rubrics.create_rubric(%{
        "organization_id" => organization_id,
        "created_by_user_id" => importing_user_id,
        "name" => e.title,
        "slug" => slug,
        "description" => "Imported from marketplace: #{e.title}"
      })
    end)
    |> Multi.run(:new_version, fn _repo, %{new_rubric: r, source_version: sv} ->
      case Rubrics.publish_version(r, %{
             judge_prompt_version_id: sv.judge_prompt_version_id,
             judge_model: sv.judge_model,
             scale: sv.scale,
             criteria: sv.criteria,
             n_samples: sv.n_samples,
             published_by_user_id: importing_user_id
           }) do
        {:ok, :published, v} ->
          {:ok, v}

        {:ok, :noop, v} ->
          {:ok, v}

        # Cross-org judge_prompt can't be pinned — surface clearly.
        {:error, :judge_prompt_not_pinnable} ->
          {:error, :judge_prompt_requires_local_copy}

        {:error, reason} ->
          {:error, reason}
      end
    end)
    |> Multi.update(:bump_downloads, fn %{entry: e} ->
      MarketplaceRubric.increment_download_changeset(e)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{new_rubric: r, new_version: v}} -> {:ok, %{rubric: r, version: v}}
      {:error, _step, reason, _} -> {:error, reason}
    end
  end

  defp short_id do
    :crypto.strong_rand_bytes(4) |> Base.url_encode64(padding: false) |> String.downcase()
  end
end
