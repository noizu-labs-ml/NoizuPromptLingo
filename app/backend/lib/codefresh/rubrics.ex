defmodule Codefresh.Rubrics do
  @moduledoc """
  Context for rubric authoring: head entities, immutable versions, and the
  version resolver used by `expectations` rows with `scoring_method='rubric'`.

  Follows the same head/version pattern as `Codefresh.Prompts`. See
  `docs/arch/data-model.md` §5.1 for the canonical version protocol.
  """

  import Ecto.Query, only: [from: 2]
  alias Ecto.Multi
  alias Codefresh.Repo
  alias Codefresh.Rubrics.{Rubric, RubricVersion}
  alias Codefresh.Prompts

  # ──────────────────────────────────────────────────────────────────────────
  # Head CRUD (US-033)
  # ──────────────────────────────────────────────────────────────────────────

  def create_rubric(attrs) do
    %Rubric{}
    |> Rubric.create_changeset(attrs)
    |> Repo.insert()
  end

  def update_rubric(%Rubric{} = r, attrs) do
    r
    |> Rubric.update_changeset(attrs)
    |> Repo.update()
  end

  def archive_rubric(%Rubric{} = r), do: r |> Rubric.archive_changeset() |> Repo.update()
  def unarchive_rubric(%Rubric{} = r), do: r |> Rubric.unarchive_changeset() |> Repo.update()

  def get_rubric(organization_id, id) do
    Repo.one(
      from r in Rubric,
        where: r.organization_id == ^organization_id and r.id == ^id
    )
  end

  def get_rubric!(organization_id, id) do
    case get_rubric(organization_id, id) do
      nil -> raise Ecto.NoResultsError, queryable: Rubric
      r -> r
    end
  end

  def get_rubric_by_slug(organization_id, slug) when is_binary(slug) do
    Repo.get_by(Rubric, organization_id: organization_id, slug: slug)
  end

  def list_rubrics(organization_id, opts \\ []) do
    include_archived = Keyword.get(opts, :include_archived, false)
    search = Keyword.get(opts, :search)
    only_published = Keyword.get(opts, :only_published, false)

    q =
      from r in Rubric,
        where: r.organization_id == ^organization_id,
        order_by: [asc: r.name]

    q
    |> maybe_hide_archived(include_archived)
    |> maybe_only_published(only_published)
    |> maybe_search(search)
    |> Repo.all()
  end

  defp maybe_hide_archived(q, true), do: q
  defp maybe_hide_archived(q, false), do: from(r in q, where: is_nil(r.archived_at))

  defp maybe_only_published(q, false), do: q
  defp maybe_only_published(q, true), do: from(r in q, where: not is_nil(r.current_version_id))

  defp maybe_search(q, nil), do: q
  defp maybe_search(q, ""), do: q

  defp maybe_search(q, s) do
    like = "%#{String.downcase(s)}%"

    from r in q,
      where:
        fragment("lower(?) LIKE ?", r.name, ^like) or
          fragment("lower(coalesce(?, '')) LIKE ?", r.description, ^like)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Publish (US-033) — creates immutable rubric_versions row
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Publish a new rubric version.

  Required attrs:
    * `:judge_prompt_version_id` — must resolve to a PromptVersion in the same org
    * `:judge_model` — e.g. "anthropic:claude-sonnet-4-5"

  Optional:
    * `:scale` — defaults to `%{"min" => 0, "max" => 1, "type" => "continuous"}`
    * `:criteria` — defaults to `%{}`
    * `:published_by_user_id`

  Returns `{:ok, :published, v}` | `{:ok, :noop, v}` | `{:error, reason}`.
  """
  def publish_version(%Rubric{} = rubric, attrs) do
    attrs = normalize(attrs)
    judge_prompt_version_id = Map.get(attrs, :judge_prompt_version_id)
    judge_model = Map.get(attrs, :judge_model)
    scale = Map.get(attrs, :scale) || %{"min" => 0, "max" => 1, "type" => "continuous"}
    criteria = Map.get(attrs, :criteria, %{})
    n_samples = Map.get(attrs, :n_samples, 1)
    published_by = Map.get(attrs, :published_by_user_id)

    with :ok <- require_present(judge_prompt_version_id, :judge_prompt_version_id),
         :ok <- require_present(judge_model, :judge_model),
         true <-
           Prompts.pinnable?(rubric.organization_id, judge_prompt_version_id) ||
             {:error, :judge_prompt_not_pinnable} do
      checksum =
        RubricVersion.compute_checksum(
          judge_prompt_version_id,
          judge_model,
          scale,
          criteria,
          n_samples
        )

      case Repo.get_by(RubricVersion, rubric_id: rubric.id, checksum: checksum) do
        %RubricVersion{} = existing ->
          {:ok, :noop, existing}

        nil ->
          do_publish(
            rubric,
            judge_prompt_version_id,
            judge_model,
            scale,
            criteria,
            n_samples,
            checksum,
            published_by
          )
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp do_publish(
         rubric,
         judge_pvid,
         judge_model,
         scale,
         criteria,
         n_samples,
         checksum,
         published_by
       ) do
    next_version = next_version_number(rubric.id)

    Multi.new()
    |> Multi.insert(
      :version,
      RubricVersion.create_changeset(%RubricVersion{}, %{
        rubric_id: rubric.id,
        organization_id: rubric.organization_id,
        version_number: next_version,
        judge_prompt_version_id: judge_pvid,
        judge_model: judge_model,
        scale: scale,
        criteria: criteria,
        n_samples: n_samples,
        checksum: checksum,
        published_by_user_id: published_by
      })
    )
    |> Multi.update(:advance_head, fn %{version: v} ->
      Rubric.advance_current_version_changeset(rubric, v.id)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{version: v}} -> {:ok, :published, v}
      {:error, :version, cs, _} -> {:error, cs}
      {:error, _step, reason, _} -> {:error, reason}
    end
  end

  defp next_version_number(rubric_id) do
    q =
      from rv in RubricVersion,
        where: rv.rubric_id == ^rubric_id,
        select: max(rv.version_number)

    (Repo.one(q) || 0) + 1
  end

  def list_versions(%Rubric{id: rubric_id}) do
    Repo.all(
      from rv in RubricVersion,
        where: rv.rubric_id == ^rubric_id,
        order_by: [desc: rv.version_number]
    )
  end

  def get_version!(id), do: Repo.get!(RubricVersion, id)

  # ──────────────────────────────────────────────────────────────────────────
  # Resolver for expectations (US-034)
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Resolve the current (pinned-candidate) version of a rubric. Rejects
  unpublished rubrics.
  """
  def resolve_current_version(organization_id, rubric_id) do
    case get_rubric(organization_id, rubric_id) do
      nil ->
        {:error, :not_found}

      %Rubric{current_version_id: nil} ->
        {:error, :not_published}

      %Rubric{current_version_id: vid} ->
        {:ok, Repo.get!(RubricVersion, vid)}
    end
  end

  @doc """
  Is this rubric_version pinnable for an expectation in the given org? Used by
  Stage 3 to validate `expectations.rubric_version_id` during script publish.

  Called by Stage 3 `Expectations` context — keep this signature stable.
  """
  def pinnable?(organization_id, version_id) do
    case Repo.get(RubricVersion, version_id) do
      %RubricVersion{organization_id: ^organization_id} -> true
      _ -> false
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Preview (US-058) — render judge prompt for sample input/response; no LLM call
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Render the judge prompt for a rubric against a sample (sample_input +
  sample_response). Returns the rendered judge body, the rubric scale, the
  criteria list, and an estimated token count. LLM invocation is deferred to
  Stage 4 (Agents). Use `Rubrics.Scoring.weighted_average/2` +
  `Rubrics.Scoring.confidence_band/1` on the returned judge outputs when the
  adapter eventually returns them.
  """
  def preview_render(organization_id, rubric_id, sample_attrs) do
    with {:ok, rv} <- resolve_current_version(organization_id, rubric_id),
         %Codefresh.Prompts.PromptVersion{} = judge_pv <-
           Codefresh.Prompts.get_version!(rv.judge_prompt_version_id) do
      # Convention: judge prompt declares vars `sample_input` and `sample_response`.
      bindings = %{
        "sample_input" => to_string(Map.get(sample_attrs, "sample_input", "")),
        "sample_response" => to_string(Map.get(sample_attrs, "sample_response", ""))
      }

      case Codefresh.Prompts.Template.render(judge_pv.body, judge_pv.template_vars, bindings) do
        {:ok, rendered} ->
          {:ok,
           %{
             judge_model: rv.judge_model,
             scale: rv.scale,
             criteria: rv.criteria,
             n_samples: rv.n_samples,
             rendered_judge_prompt: rendered,
             estimated_tokens: estimate_tokens(rendered),
             mode: :render_only
           }}

        {:error, _} = e ->
          e
      end
    end
  end

  # Rough char/4 heuristic — good enough for "warn before invocation" UX.
  defp estimate_tokens(text) when is_binary(text), do: div(byte_size(text), 4)

  # ──────────────────────────────────────────────────────────────────────────
  # Helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp require_present(nil, field), do: {:error, {:required, field}}
  defp require_present("", field), do: {:error, {:required, field}}
  defp require_present(_, _), do: :ok

  defp normalize(attrs) do
    for {k, v} <- attrs, into: %{} do
      key = if is_atom(k), do: k, else: safe_atom(to_string(k))
      {key, v}
    end
  end

  defp safe_atom(str) do
    String.to_existing_atom(str)
  rescue
    ArgumentError -> String.to_atom(str)
  end
end
