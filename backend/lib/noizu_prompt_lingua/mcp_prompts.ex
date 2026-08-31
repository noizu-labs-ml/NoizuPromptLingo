defmodule NoizuPromptLingua.MCPrompts do
  @moduledoc """
  CRUD + versioning for MCP prompt templates (W4). Prompts are scoped
  (global / org / project); scoped rows shadow the global row of the same slug.
  """

  import Ecto.Query
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.MCP.{McpPrompt, McpPromptVersion}

  @doc """
  List prompts visible at the given scope.

  Passing an `:organization_id` / `:project_id` key filters to rows that are
  global or bound to that scope (explicit `nil` = globals only). Omitting the
  keys lists everything (admin view).
  """
  def list(opts \\ []) do
    McpPrompt
    |> org_scope(opts)
    |> project_scope(opts)
    |> order_by([p], asc: p.slug)
    |> Repo.all()
  end

  defp org_scope(query, opts) do
    if Keyword.has_key?(opts, :organization_id) do
      case opts[:organization_id] do
        nil -> where(query, [p], is_nil(p.organization_id))
        org -> where(query, [p], is_nil(p.organization_id) or p.organization_id == ^org)
      end
    else
      query
    end
  end

  defp project_scope(query, opts) do
    if Keyword.has_key?(opts, :project_id) do
      case opts[:project_id] do
        nil -> where(query, [p], is_nil(p.project_id))
        proj -> where(query, [p], is_nil(p.project_id) or p.project_id == ^proj)
      end
    else
      query
    end
  end

  @doc """
  Resolve a slug for the given scope. Slugs are globally unique, so this is a
  lookup + visibility check: a prompt is visible when its `organization_id` /
  `project_id` are nil (global) or match the scope's.
  """
  def effective(slug, org_id, project_id) when is_binary(slug) do
    case get_by_slug(slug) do
      nil ->
        nil

      prompt ->
        org_ok = is_nil(prompt.organization_id) or prompt.organization_id == org_id
        proj_ok = is_nil(prompt.project_id) or prompt.project_id == project_id

        if org_ok and proj_ok, do: prompt
    end
  end

  def effective(_, _, _), do: nil

  def get!(id), do: Repo.get!(McpPrompt, id)
  def get(id), do: Repo.get(McpPrompt, id)

  def get_by_slug(slug) when is_binary(slug) do
    Repo.one(from p in McpPrompt, where: p.slug == ^normalize_slug(slug), limit: 1)
  end

  def create(attrs) do
    %McpPrompt{}
    |> McpPrompt.changeset(attrs)
    |> Repo.insert()
  end

  # NOTE: named update_prompt/delete_prompt (not update/delete) — `import
  # Ecto.Query` puts Ecto.Query.update/2 in scope and the import would shadow
  # a local def update/2 at call sites inside this module.

  def update_prompt(%McpPrompt{} = prompt, attrs) do
    prompt
    |> McpPrompt.changeset(attrs)
    |> Repo.update()
  end

  def update_prompt(slug, attrs) when is_binary(slug) do
    case get_by_slug(slug) do
      nil -> {:error, :not_found}
      prompt -> update_prompt(prompt, attrs)
    end
  end

  def delete_prompt(%McpPrompt{} = prompt), do: Repo.delete(prompt)

  def delete_prompt(slug) when is_binary(slug) do
    case get_by_slug(slug) do
      nil -> {:error, :not_found}
      prompt -> delete_prompt(prompt)
    end
  end

  @doc """
  Publish a new immutable version of the prompt body (max version + 1) and move
  `active_version` to it. Runs in a transaction.
  """
  def publish_version(%McpPrompt{} = prompt, template, change_note \\ nil) do
    Repo.transaction(fn ->
      next =
        case Repo.one(
               from v in McpPromptVersion,
                 where: v.prompt_id == ^prompt.id,
                 select: max(v.version)
             ) do
          nil -> 1
          n -> n + 1
        end

      %McpPromptVersion{}
      |> McpPromptVersion.changeset(%{
        prompt_id: prompt.id,
        version: next,
        template: template,
        change_note: change_note
      })
      |> Repo.insert!()

      prompt
      |> Ecto.Changeset.change(active_version: next)
      |> Repo.update!()

      next
    end)
  end

  def publish_version(slug, template, change_note) when is_binary(slug) do
    case get_by_slug(slug) do
      nil -> {:error, :not_found}
      prompt -> publish_version(prompt, template, change_note)
    end
  end

  @doc "Fetch a specific version (defaults to the active one)."
  def version(%McpPrompt{} = prompt, nil), do: version(prompt, prompt.active_version)

  def version(%McpPrompt{} = prompt, v) when is_integer(v) do
    Repo.one(
      from ver in McpPromptVersion,
        where: ver.prompt_id == ^prompt.id and ver.version == ^v,
        limit: 1
    )
  end

  def versions(%McpPrompt{} = prompt) do
    Repo.all(
      from v in McpPromptVersion, where: v.prompt_id == ^prompt.id, order_by: [desc: v.version]
    )
  end

  @doc """
  Render a prompt: resolve `version` (default active), substitute `{{arg}}`
  tokens, return `{:ok, rendered}`.
  """
  def render(prompt, args \\ %{}, version_number \\ nil)

  def render(%McpPrompt{} = prompt, args, version_number) do
    with %McpPromptVersion{} = ver <-
           version(prompt, version_number) || {:error, :version_not_found},
         :ok <- check_args(prompt, args) do
      {:ok, substitute(ver.template, args)}
    else
      {:error, _} = err -> err
    end
  end

  def render(slug, args, version_number) when is_binary(slug) do
    case get_by_slug(slug) do
      nil -> {:error, :not_found}
      prompt -> render(prompt, args || %{}, version_number)
    end
  end

  defp check_args(prompt, args) do
    args = args || %{}

    missing =
      prompt.arguments
      |> List.wrap()
      |> Enum.filter(fn
        %{"name" => n, "required" => true} ->
          blank?(Map.get(args, n) || Map.get(args, String.to_atom(n)))

        %{name: n, required: true} ->
          blank?(Map.get(args, n) || Map.get(args, String.to_atom(n)))

        _ ->
          false
      end)
      |> Enum.map(&arg_name/1)

    if missing == [], do: :ok, else: {:error, {:missing_arguments, missing}}
  end

  defp arg_name(%{"name" => n}), do: n
  defp arg_name(%{name: n}), do: n
  defp arg_name(n) when is_binary(n), do: n

  defp blank?(nil), do: true
  defp blank?(""), do: true
  defp blank?(_), do: false

  defp substitute(template, args) when is_map(args) do
    Regex.replace(~r/\{\{(\w+)\}\}/, template, fn _whole, key ->
      case Map.get(args, key) || Map.get(args, String.to_atom(key)) do
        nil -> "{{#{key}}}"
        value -> to_string(value)
      end
    end)
  end

  defp substitute(template, _), do: template

  defp normalize_slug(slug), do: slug |> String.trim() |> String.downcase()

  @doc "JSON shape for admin endpoints."
  def prompt_json(%McpPrompt{} = prompt) do
    %{
      id: prompt.id,
      slug: prompt.slug,
      name: prompt.name,
      description: prompt.description,
      arguments: prompt.arguments,
      active_version: prompt.active_version,
      organization_id: prompt.organization_id,
      project_id: prompt.project_id,
      inserted_at: prompt.inserted_at
    }
  end
end
