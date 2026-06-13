defmodule Codefresh.Personas do
  @moduledoc """
  Context for persona authoring: head + immutable versions, starter-library
  imports (US-055), run attachment (US-036), system-preamble pinning (US-053),
  and node-level persona expectations (US-051).

  Mirrors the head/version pattern of `Codefresh.Prompts` / `Codefresh.Rubrics`.
  See `docs/arch/data-model.md` §5.4.
  """

  import Ecto.Query, only: [from: 2]
  alias Ecto.Multi
  alias Codefresh.Repo
  alias Codefresh.Personas.{Persona, PersonaVersion, PersonaExpectation, StarterLibrary}
  alias Codefresh.Prompts

  # ──────────────────────────────────────────────────────────────────────────
  # Head CRUD (US-035)
  # ──────────────────────────────────────────────────────────────────────────

  def create_persona(attrs) do
    %Persona{}
    |> Persona.create_changeset(attrs)
    |> Repo.insert()
  end

  def update_persona(%Persona{} = p, attrs) do
    p |> Persona.update_changeset(attrs) |> Repo.update()
  end

  def archive_persona(%Persona{} = p), do: p |> Persona.archive_changeset() |> Repo.update()
  def unarchive_persona(%Persona{} = p), do: p |> Persona.unarchive_changeset() |> Repo.update()

  def get_persona(organization_id, id) do
    Repo.one(from p in Persona, where: p.organization_id == ^organization_id and p.id == ^id)
  end

  def get_persona!(organization_id, id) do
    case get_persona(organization_id, id) do
      nil -> raise Ecto.NoResultsError, queryable: Persona
      p -> p
    end
  end

  def get_persona_by_slug(organization_id, slug) when is_binary(slug) do
    Repo.get_by(Persona, organization_id: organization_id, slug: slug)
  end

  def list_personas(organization_id, opts \\ []) do
    include_archived = Keyword.get(opts, :include_archived, false)
    search = Keyword.get(opts, :search)
    tone = Keyword.get(opts, :tone)

    q = from p in Persona, where: p.organization_id == ^organization_id, order_by: [asc: p.name]

    q
    |> maybe_hide_archived(include_archived)
    |> maybe_tone_filter(tone)
    |> maybe_search(search)
    |> Repo.all()
  end

  defp maybe_hide_archived(q, true), do: q
  defp maybe_hide_archived(q, false), do: from(p in q, where: is_nil(p.archived_at))

  defp maybe_tone_filter(q, nil), do: q
  defp maybe_tone_filter(q, ""), do: q

  defp maybe_tone_filter(q, tone) do
    # Tone lives on persona_versions; filter by any version matching.
    from p in q,
      join: pv in PersonaVersion,
      on: pv.persona_id == p.id,
      where: pv.tone == ^tone,
      distinct: p.id
  end

  defp maybe_search(q, nil), do: q
  defp maybe_search(q, ""), do: q

  defp maybe_search(q, s) do
    like = "%#{String.downcase(s)}%"

    from p in q,
      where:
        fragment("lower(?) LIKE ?", p.name, ^like) or
          fragment("lower(coalesce(?, '')) LIKE ?", p.description, ^like)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Publish (US-035 + US-053)
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Publish a new persona version. Optional `:system_prompt_version_id` pins a
  published prompt version as the persona's system preamble (US-053). The pinned
  prompt must resolve within the same organization.

  Returns `{:ok, :published, v}` | `{:ok, :noop, v}` | `{:error, reason}`.
  """
  def publish_version(%Persona{} = persona, attrs) do
    attrs = normalize(attrs)
    tone = Map.get(attrs, :tone)
    description = Map.get(attrs, :description)
    metadata = Map.get(attrs, :metadata, %{})
    preamble_id = Map.get(attrs, :system_prompt_version_id)
    published_by = Map.get(attrs, :published_by_user_id)

    with :ok <- validate_preamble(persona.organization_id, preamble_id) do
      checksum = PersonaVersion.compute_checksum(tone, description, metadata, preamble_id)

      case Repo.get_by(PersonaVersion, persona_id: persona.id, checksum: checksum) do
        %PersonaVersion{} = existing ->
          {:ok, :noop, existing}

        nil ->
          do_publish(persona, tone, description, metadata, preamble_id, checksum, published_by)
      end
    end
  end

  defp validate_preamble(_org_id, nil), do: :ok

  defp validate_preamble(org_id, pvid) do
    if Prompts.pinnable?(org_id, pvid), do: :ok, else: {:error, :preamble_not_pinnable}
  end

  defp do_publish(persona, tone, description, metadata, preamble_id, checksum, published_by) do
    next = next_version_number(persona.id)

    Multi.new()
    |> Multi.insert(
      :version,
      PersonaVersion.create_changeset(%PersonaVersion{}, %{
        persona_id: persona.id,
        organization_id: persona.organization_id,
        version_number: next,
        tone: tone,
        description: description,
        metadata: metadata,
        system_prompt_version_id: preamble_id,
        checksum: checksum,
        published_by_user_id: published_by
      })
    )
    |> Multi.update(:advance_head, fn %{version: v} ->
      Persona.advance_current_version_changeset(persona, v.id)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{version: v}} -> {:ok, :published, v}
      {:error, :version, cs, _} -> {:error, cs}
      {:error, _, reason, _} -> {:error, reason}
    end
  end

  defp next_version_number(persona_id) do
    q =
      from pv in PersonaVersion,
        where: pv.persona_id == ^persona_id,
        select: max(pv.version_number)

    (Repo.one(q) || 0) + 1
  end

  def list_versions(%Persona{id: pid}) do
    Repo.all(
      from pv in PersonaVersion,
        where: pv.persona_id == ^pid,
        order_by: [desc: pv.version_number]
    )
  end

  def get_version!(id), do: Repo.get!(PersonaVersion, id)

  def resolve_current_version(organization_id, persona_id) do
    case get_persona(organization_id, persona_id) do
      nil -> {:error, :not_found}
      %Persona{current_version_id: nil} -> {:error, :not_published}
      %Persona{current_version_id: vid} -> {:ok, Repo.get!(PersonaVersion, vid)}
    end
  end

  @doc "Is this persona_version pinnable (same org)? Used by runs + expectations."
  def pinnable?(organization_id, version_id) do
    case Repo.get(PersonaVersion, version_id) do
      %PersonaVersion{organization_id: ^organization_id} -> true
      _ -> false
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Starter library import (US-055)
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Deep-copy a starter persona into `organization_id`. Does NOT copy the sample
  system preamble as a prompt — the sample text is embedded in the persona
  version's description so the importer can wire a real prompt later via
  `publish_version/2` with `system_prompt_version_id`.
  """
  def import_from_starter(organization_id, starter_slug, opts \\ []) do
    importing_user_id = Keyword.get(opts, :imported_by_user_id)

    with {:ok, starter} <- StarterLibrary.get(starter_slug) do
      desc =
        "#{starter.description}\n\n--- Sample system preamble ---\n#{starter.sample_preamble}"

      Multi.new()
      |> Multi.run(:persona, fn _repo, _ ->
        slug = "#{starter.slug}-#{short_id()}"

        create_persona(%{
          "organization_id" => organization_id,
          "created_by_user_id" => importing_user_id,
          "name" => starter.name,
          "slug" => slug,
          "description" => "Imported from starter library: #{starter.name}"
        })
      end)
      |> Multi.run(:version, fn _repo, %{persona: p} ->
        case publish_version(p, %{
               tone: starter.tone,
               description: desc,
               metadata: %{"imported_from_starter" => starter.slug},
               published_by_user_id: importing_user_id
             }) do
          {:ok, :published, v} -> {:ok, v}
          {:ok, :noop, v} -> {:ok, v}
          {:error, reason} -> {:error, reason}
        end
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{persona: p, version: v}} -> {:ok, %{persona: p, version: v}}
        {:error, _step, reason, _} -> {:error, reason}
      end
    end
  end

  defp short_id do
    :crypto.strong_rand_bytes(4) |> Base.url_encode64(padding: false) |> String.downcase()
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Run attachment (US-036)
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Attach a persona version to a run. Inserts a `run_personas` row pinning the
  version. The runner (Stage 5) reads this at execution time to compose
  persona preamble + script system node (persona preamble is "outer"; see
  US-053 notes).

  Returns `{:ok, run_persona}` | `{:error, reason}`.
  """
  def attach_to_run(run_id, persona_version_id, organization_id)
      when is_binary(run_id) and is_binary(persona_version_id) and is_binary(organization_id) do
    cond do
      not pinnable?(organization_id, persona_version_id) ->
        {:error, :persona_not_pinnable}

      true ->
        now = DateTime.utc_now() |> DateTime.truncate(:second)

        row = %{
          run_id: run_id,
          persona_version_id: persona_version_id,
          organization_id: organization_id,
          inserted_at: now
        }

        case Repo.insert_all(Codefresh.Runs.RunPersona, [row],
               returning: [:id, :run_id, :persona_version_id]
             ) do
          {1, [inserted]} -> {:ok, inserted}
          other -> {:error, {:insert_failed, other}}
        end
    end
  rescue
    e in Postgrex.Error -> {:error, e}
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Persona expectations (US-051)
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Create a persona-layered expectation on a script node. Validates cross-org
  consistency: persona_version + script_node must share `organization_id`.
  Rubric-backed expectations require a pinnable rubric_version in the same org.
  """
  def create_persona_expectation(attrs) do
    attrs = normalize(attrs)
    persona_version_id = Map.get(attrs, :persona_version_id)
    script_node_id = Map.get(attrs, :script_node_id)
    organization_id = Map.get(attrs, :organization_id)
    rubric_version_id = Map.get(attrs, :rubric_version_id)
    scoring_method = Map.get(attrs, :scoring_method)

    with :ok <- require_present(persona_version_id, :persona_version_id),
         :ok <- require_present(script_node_id, :script_node_id),
         :ok <- require_present(organization_id, :organization_id),
         :ok <- validate_persona_scope(organization_id, persona_version_id),
         :ok <- validate_node_scope(organization_id, script_node_id),
         :ok <- validate_rubric_scope(organization_id, rubric_version_id, scoring_method) do
      %PersonaExpectation{}
      |> PersonaExpectation.create_changeset(attrs)
      |> Repo.insert()
    end
  end

  def list_persona_expectations(persona_version_id) do
    Repo.all(
      from pe in PersonaExpectation,
        where: pe.persona_version_id == ^persona_version_id,
        order_by: [asc: pe.label]
    )
  end

  defp validate_persona_scope(org_id, persona_version_id) do
    if pinnable?(org_id, persona_version_id), do: :ok, else: {:error, :persona_not_in_org}
  end

  defp validate_node_scope(org_id, script_node_id) do
    q =
      from sn in "script_nodes",
        where: sn.id == ^script_node_id and sn.organization_id == ^org_id,
        select: sn.id

    case Repo.one(q) do
      nil -> {:error, :script_node_not_in_org}
      _ -> :ok
    end
  end

  defp validate_rubric_scope(_org_id, _rubric_version_id, method) when method != "rubric", do: :ok

  defp validate_rubric_scope(_org_id, nil, "rubric"), do: {:error, :rubric_required}

  defp validate_rubric_scope(org_id, rubric_version_id, "rubric") do
    if Codefresh.Rubrics.pinnable?(org_id, rubric_version_id),
      do: :ok,
      else: {:error, :rubric_not_pinnable}
  end

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
