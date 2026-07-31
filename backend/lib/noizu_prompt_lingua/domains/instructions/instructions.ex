defmodule NoizuPromptLingua.Domains.Instructions do
  @moduledoc """
  Reusable, versioned instruction documents. An instruction is a prompt saved
  once (under an org-scoped `slug` handle) and handed to many parallel sub-agents
  by reference plus per-task params, so the full prompt text never has to be
  threaded through a caller's context.

  Editing creates a new `InstructionVersion`; `active_version` selects the served
  body. `render/2` substitutes declared params into the active (or a specific)
  version's body via `{{param}}` placeholders.
  """
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{Instruction, InstructionVersion}

  # ── CRUD ──────────────────────────────────────────────────────

  @doc "Create an instruction with its first body version (v1)."
  def create(attrs, opts \\ []) do
    body = opts[:body] || attrs[:body] || attrs["body"] || ""

    Repo.transaction(fn ->
      case %Instruction{}
           |> Instruction.changeset(Map.put(attrs, :active_version, 1))
           |> Repo.insert() do
        {:ok, instruction} ->
          {:ok, _v} =
            %InstructionVersion{}
            |> InstructionVersion.changeset(%{
              instruction_id: instruction.id,
              version: 1,
              body: body,
              change_note: "Initial version"
            })
            |> Repo.insert()

          instruction

        {:error, cs} ->
          Repo.rollback(cs)
      end
    end)
  end

  def get(id), do: Repo.get(Instruction, id)

  @doc "Resolve an id or (org-scoped) slug handle to an instruction."
  def resolve(org_id, id_or_slug) do
    case NoizuPromptLingua.UUID.cast(id_or_slug) do
      {:ok, uuid} ->
        Repo.get(Instruction, uuid) ||
          Repo.get_by(Instruction, organization_id: org_id, slug: id_or_slug)

      :error ->
        Repo.get_by(Instruction, organization_id: org_id, slug: id_or_slug)
    end
  end

  @doc "Fetch a specific (or the active) body version of an instruction."
  def get_version(instruction_id, version \\ nil) do
    target =
      case version do
        nil ->
          case get(instruction_id) do
            nil -> nil
            i -> i.active_version
          end

        v ->
          v
      end

    case target do
      nil -> nil
      v -> Repo.get_by(InstructionVersion, instruction_id: instruction_id, version: v)
    end
  end

  def list_versions(instruction_id) do
    InstructionVersion
    |> where([v], v.instruction_id == ^instruction_id)
    |> order_by([v], desc: v.version)
    |> Repo.all()
  end

  @doc """
  Update an instruction. Metadata (`title`, `description`, `tags`, `parameters`,
  `status`) updates in place. Supplying `body` creates a new version
  (active_version + 1) which becomes active; `change_note` documents it.
  """
  def update(id, attrs, opts \\ []) do
    body = opts[:body] || attrs[:body] || attrs["body"]
    change_note = opts[:change_note] || attrs[:change_note] || attrs["change_note"]

    case get(id) do
      nil ->
        {:error, :not_found}

      instruction ->
        Repo.transaction(fn ->
          meta = Map.drop(normalize(attrs), [:body, :change_note])

          {meta, version} =
            if is_binary(body) and body != "" do
              new_version = instruction.active_version + 1

              {:ok, _v} =
                %InstructionVersion{}
                |> InstructionVersion.changeset(%{
                  instruction_id: instruction.id,
                  version: new_version,
                  body: body,
                  change_note: change_note || "Updated"
                })
                |> Repo.insert()

              {Map.put(meta, :active_version, new_version), new_version}
            else
              {meta, instruction.active_version}
            end

          case instruction |> Instruction.changeset(meta) |> Repo.update() do
            {:ok, updated} -> {updated, version}
            {:error, cs} -> Repo.rollback(cs)
          end
        end)
        |> case do
          {:ok, {updated, _version}} -> {:ok, updated}
          other -> other
        end
    end
  end

  @doc "Point active_version at an existing version (rollback / roll-forward)."
  def set_active_version(id, version) do
    with %Instruction{} = instruction <- get(id),
         %InstructionVersion{} <-
           Repo.get_by(InstructionVersion, instruction_id: id, version: version) do
      instruction |> Instruction.changeset(%{active_version: version}) |> Repo.update()
    else
      nil -> {:error, :not_found}
    end
  end

  def delete(id) do
    case get(id) do
      nil ->
        {:error, :not_found}

      instruction ->
        Repo.transaction(fn ->
          Repo.delete_all(from v in InstructionVersion, where: v.instruction_id == ^id)
          Repo.delete(instruction)
        end)
    end
  end

  def list(opts \\ []) do
    Instruction
    |> maybe_filter(:organization_id, opts[:organization_id])
    |> maybe_filter(:project_id, opts[:project_id])
    |> maybe_filter(:status, opts[:status])
    |> maybe_filter_tag(opts[:tag])
    |> maybe_search(opts[:query])
    |> order_by([i], desc: i.updated_at)
    |> limit(^(opts[:limit] || 50))
    |> offset(^(opts[:offset] || 0))
    |> Repo.all()
  end

  def count(org_id) do
    Instruction |> where([i], i.organization_id == ^org_id) |> Repo.aggregate(:count, :id)
  end

  # ── Render ────────────────────────────────────────────────────

  @doc """
  Render an instruction body for a sub-agent: substitute `params` into the
  active (or specified `version`) body's `{{name}}` placeholders. Declared
  params supply defaults; missing required params (no value, no default) yield
  `{:error, {:missing_params, [names]}}`.

  Returns `{:ok, %{slug, title, version, body, params}}`.
  """
  def render(instruction, params \\ %{}, opts \\ [])

  def render(%Instruction{} = instruction, params, opts) do
    version = opts[:version]
    params = stringify_keys(params)

    case get_version(instruction.id, version) do
      nil ->
        {:error, :version_not_found}

      ver ->
        declared = instruction.parameters || []

        merged =
          Enum.reduce(declared, params, fn p, acc ->
            name = p["name"] || p[:name]

            cond do
              name == nil -> acc
              Map.has_key?(acc, name) -> acc
              (default = p["default"] || p[:default]) != nil -> Map.put(acc, name, default)
              true -> acc
            end
          end)

        missing =
          declared
          |> Enum.filter(fn p -> (p["required"] || p[:required]) == true end)
          |> Enum.map(fn p -> p["name"] || p[:name] end)
          |> Enum.reject(fn name -> name != nil and Map.has_key?(merged, name) end)

        if missing != [] do
          {:error, {:missing_params, missing}}
        else
          {:ok,
           %{
             id: instruction.id,
             slug: instruction.slug,
             title: instruction.title,
             version: ver.version,
             params: merged,
             body: substitute(ver.body, merged)
           }}
        end
    end
  end

  def render(nil, _params, _opts), do: {:error, :not_found}

  # Replace {{name}} placeholders (optional surrounding whitespace) with values.
  defp substitute(body, params) do
    Regex.replace(~r/\{\{\s*([\w.-]+)\s*\}\}/, body, fn whole, key ->
      case Map.fetch(params, key) do
        {:ok, val} -> to_string(val)
        :error -> whole
      end
    end)
  end

  # ── Private ───────────────────────────────────────────────────

  defp normalize(attrs) do
    attrs
    |> Enum.map(fn
      {k, v} when is_binary(k) -> {String.to_existing_atom(k), v}
      {k, v} -> {k, v}
    end)
    |> Map.new()
  rescue
    ArgumentError -> atomize_known(attrs)
  end

  defp atomize_known(attrs) do
    ~w(title description tags parameters status active_version)a
    |> Enum.reduce(%{}, fn key, acc ->
      case Map.get(attrs, Atom.to_string(key), Map.get(attrs, key, :__absent__)) do
        :__absent__ -> acc
        v -> Map.put(acc, key, v)
      end
    end)
  end

  defp stringify_keys(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {to_string(k), v} end)
  end

  defp stringify_keys(_), do: %{}

  defp maybe_filter(q, _field, nil), do: q
  defp maybe_filter(q, :organization_id, v), do: where(q, [i], i.organization_id == ^v)
  defp maybe_filter(q, :project_id, v), do: where(q, [i], i.project_id == ^v)
  defp maybe_filter(q, :status, v), do: where(q, [i], i.status == ^v)

  defp maybe_filter_tag(q, nil), do: q
  defp maybe_filter_tag(q, tag), do: where(q, [i], ^tag in i.tags)

  defp maybe_search(q, nil), do: q
  defp maybe_search(q, ""), do: q

  defp maybe_search(q, query) do
    pattern = "%#{query}%"

    where(
      q,
      [i],
      ilike(i.title, ^pattern) or ilike(i.description, ^pattern) or ilike(i.slug, ^pattern)
    )
  end
end
