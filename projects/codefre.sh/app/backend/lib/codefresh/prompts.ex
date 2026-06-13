defmodule Codefresh.Prompts do
  @moduledoc """
  Context for prompt authoring: head entities, immutable published versions,
  library queries, and the version resolver used by script nodes at pin time.
  """

  import Ecto.Query, only: [from: 2]
  alias Ecto.Multi
  alias Codefresh.Repo
  alias Codefresh.Prompts.{Prompt, PromptVersion, Template, ToolDefs}

  # ──────────────────────────────────────────────────────────────────────────
  # Prompt head CRUD (US-009)
  # ──────────────────────────────────────────────────────────────────────────

  def create_prompt(attrs) do
    %Prompt{}
    |> Prompt.create_changeset(attrs)
    |> Repo.insert()
  end

  def update_prompt(%Prompt{} = prompt, attrs) do
    prompt
    |> Prompt.update_changeset(attrs)
    |> Repo.update()
  end

  def archive_prompt(%Prompt{} = prompt) do
    prompt |> Prompt.archive_changeset() |> Repo.update()
  end

  def unarchive_prompt(%Prompt{} = prompt) do
    prompt |> Prompt.unarchive_changeset() |> Repo.update()
  end

  def get_prompt(organization_id, id) do
    Repo.one(
      from p in Prompt,
        where: p.organization_id == ^organization_id and p.id == ^id
    )
  end

  def get_prompt!(organization_id, id) do
    case get_prompt(organization_id, id) do
      nil -> raise Ecto.NoResultsError, queryable: Prompt
      prompt -> prompt
    end
  end

  def get_prompt_by_slug(organization_id, slug) when is_binary(slug) do
    Repo.get_by(Prompt, organization_id: organization_id, slug: slug)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Library listing / search (US-050)
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Lists prompts in the org with usage count (number of `script_nodes` pinning
  any version of each prompt). Archived prompts hidden by default.

  Options:
    * `:include_archived` (default false)
    * `:search` — substring match on name or description (case-insensitive)
    * `:only_published` (default false) — exclude prompts that have no version
  """
  def list_prompts(organization_id, opts \\ []) do
    include_archived = Keyword.get(opts, :include_archived, false)
    search = Keyword.get(opts, :search)
    only_published = Keyword.get(opts, :only_published, false)

    base =
      from p in Prompt,
        left_join: pv in PromptVersion,
        on: pv.prompt_id == p.id,
        left_join: sn in "script_nodes",
        on: sn.prompt_version_id == pv.id,
        where: p.organization_id == ^organization_id,
        group_by: p.id,
        select: %{prompt: p, usage_count: count(sn.id, :distinct)}

    base
    |> maybe_filter_archived(include_archived)
    |> maybe_filter_published(only_published)
    |> maybe_filter_search(search)
    |> order_by_name()
    |> Repo.all()
  end

  defp maybe_filter_archived(q, true), do: q
  defp maybe_filter_archived(q, false), do: from([p, _pv, _sn] in q, where: is_nil(p.archived_at))

  defp maybe_filter_published(q, false), do: q

  defp maybe_filter_published(q, true),
    do: from([p, _pv, _sn] in q, where: not is_nil(p.current_version_id))

  defp maybe_filter_search(q, nil), do: q
  defp maybe_filter_search(q, ""), do: q

  defp maybe_filter_search(q, search) do
    like = "%#{String.downcase(search)}%"

    from [p, _pv, _sn] in q,
      where:
        fragment("lower(?) LIKE ?", p.name, ^like) or
          fragment("lower(coalesce(?, '')) LIKE ?", p.description, ^like)
  end

  defp order_by_name(q), do: from([p, _pv, _sn] in q, order_by: [asc: p.name])

  # ──────────────────────────────────────────────────────────────────────────
  # Versions + publish (US-010, US-048)
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Publish a new version of a prompt.

  Validates that every `{{var}}` in `:body` has a matching declaration in
  `:template_vars`. Computes a checksum; if an existing version with the same
  checksum exists, returns `{:ok, :noop, existing_version}`. Otherwise
  inserts a new version, advances `current_version_id`, and returns
  `{:ok, :published, version}`.

  ## Attrs
    * `:body` (required)
    * `:template_vars` (optional, default %{})
    * `:tool_defs` (optional, default %{})
    * `:metadata` (optional, default %{})
    * `:published_by_user_id` (optional)
  """
  def publish_version(%Prompt{} = prompt, attrs) do
    attrs = normalize(attrs)
    body = Map.get(attrs, :body) || ""
    template_vars = Map.get(attrs, :template_vars, %{}) |> stringify_outer_keys()
    tool_defs = Map.get(attrs, :tool_defs, %{})
    metadata = Map.get(attrs, :metadata, %{})
    published_by = Map.get(attrs, :published_by_user_id)

    with :ok <- Template.validate(body, template_vars),
         :ok <- ToolDefs.validate(tool_defs) do
      checksum = PromptVersion.compute_checksum(body, template_vars, tool_defs)

      case Repo.get_by(PromptVersion, prompt_id: prompt.id, checksum: checksum) do
        %PromptVersion{} = existing ->
          {:ok, :noop, existing}

        nil ->
          do_publish(prompt, body, template_vars, tool_defs, metadata, checksum, published_by)
      end
    else
      {:error, {:undeclared_vars, vars}} ->
        {:error, :undeclared_vars, vars}

      {:error, reason} ->
        {:error, :invalid_tool_defs, reason}
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Sandbox render (US-114) — render-only; LLM execution deferred to Stage 4
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Render a prompt for sandbox preview. Accepts either a draft body (+
  template_vars / tool_defs) OR a reference to an existing published version.

  Returns `{:ok, %{rendered: string, tool_names: [...], mode: :render_only}}`
  or an error tuple matching `Template.render/3` shape.

  LLM execution is deferred until Stage 4 (Agents) lands. Until then this
  gives editors a deterministic preview of the substituted body.
  """
  def sandbox_render(attrs) when is_map(attrs) do
    attrs = normalize(attrs)
    body = Map.get(attrs, :body) || ""
    declared = Map.get(attrs, :template_vars, %{}) |> stringify_outer_keys()
    tool_defs = Map.get(attrs, :tool_defs, %{})
    bindings = Map.get(attrs, :bindings, %{}) |> stringify_outer_keys()

    with :ok <- Template.validate(body, declared),
         :ok <- ToolDefs.validate(tool_defs),
         {:ok, rendered} <- Template.render(body, declared, bindings) do
      {:ok,
       %{
         rendered: rendered,
         tool_names: ToolDefs.tool_names(tool_defs),
         mode: :render_only
       }}
    end
  end

  defp do_publish(prompt, body, template_vars, tool_defs, metadata, checksum, published_by) do
    next_version = next_version_number(prompt.id)

    Multi.new()
    |> Multi.insert(
      :version,
      PromptVersion.create_changeset(%PromptVersion{}, %{
        prompt_id: prompt.id,
        organization_id: prompt.organization_id,
        version_number: next_version,
        body: body,
        template_vars: template_vars,
        tool_defs: tool_defs,
        metadata: metadata,
        checksum: checksum,
        published_by_user_id: published_by
      })
    )
    |> Multi.update(:advance_head, fn %{version: v} ->
      Prompt.advance_current_version_changeset(prompt, v.id)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{version: v}} -> {:ok, :published, v}
      {:error, :version, cs, _} -> {:error, cs}
      {:error, _, reason, _} -> {:error, reason}
    end
  end

  defp next_version_number(prompt_id) do
    q =
      from pv in PromptVersion,
        where: pv.prompt_id == ^prompt_id,
        select: max(pv.version_number)

    (Repo.one(q) || 0) + 1
  end

  def list_versions(%Prompt{id: prompt_id}) do
    Repo.all(
      from pv in PromptVersion,
        where: pv.prompt_id == ^prompt_id,
        order_by: [desc: pv.version_number]
    )
  end

  def get_version!(id), do: Repo.get!(PromptVersion, id)

  def get_version_for_prompt(organization_id, prompt_id, version_number) do
    Repo.one(
      from pv in PromptVersion,
        where:
          pv.organization_id == ^organization_id and
            pv.prompt_id == ^prompt_id and
            pv.version_number == ^version_number
    )
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Resolver used by script nodes (US-011)
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Resolve the current (pinned-candidate) version of a prompt. Rejects
  unpublished prompts — a prompt with no `current_version_id` is not pinnable.

  Returns `{:ok, version}` or `{:error, :not_published}` or
  `{:error, :not_found}`.
  """
  def resolve_current_version(organization_id, prompt_id) do
    case get_prompt(organization_id, prompt_id) do
      nil ->
        {:error, :not_found}

      %Prompt{current_version_id: nil} ->
        {:error, :not_published}

      %Prompt{current_version_id: vid} ->
        {:ok, Repo.get!(PromptVersion, vid)}
    end
  end

  @doc """
  Assert a prompt version is pinnable: it must exist and belong to the given
  org. Used by `script_nodes` inserts to validate `prompt_version_id`.
  """
  def pinnable?(organization_id, version_id) do
    case Repo.get(PromptVersion, version_id) do
      %PromptVersion{organization_id: ^organization_id} -> true
      _ -> false
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp normalize(attrs) do
    for {k, v} <- attrs, into: %{} do
      key = if is_atom(k), do: k, else: safe_atom(to_string(k))
      {key, v}
    end
  end

  defp stringify_outer_keys(%{} = m) do
    for {k, v} <- m, into: %{}, do: {to_string(k), v}
  end

  defp safe_atom(str) do
    String.to_existing_atom(str)
  rescue
    ArgumentError -> String.to_atom(str)
  end
end
