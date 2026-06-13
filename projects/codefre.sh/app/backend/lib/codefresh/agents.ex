defmodule Codefresh.Agents do
  @moduledoc """
  Context for agent connectors (Stage 4): head entities, immutable published
  versions with per-adapter config validation, cost-governance on the head,
  and a health-check dispatcher that only validates config (no network).

  User stories: US-012, US-013, US-014, US-061, US-062, US-063, US-064, US-065.
  """

  import Ecto.Query, only: [from: 2]
  alias Ecto.Multi
  alias Codefresh.Repo
  alias Codefresh.Agents.{Agent, AgentVersion}

  alias Codefresh.Agents.Adapters.{
    OpenAI,
    Anthropic,
    LangChain,
    HTTP,
    Bedrock,
    Vertex
  }

  @adapter_modules %{
    "openai" => OpenAI,
    "anthropic" => Anthropic,
    "langchain" => LangChain,
    "http" => HTTP,
    "bedrock" => Bedrock,
    "vertex" => Vertex
  }

  def adapter_modules, do: @adapter_modules

  # ──────────────────────────────────────────────────────────────────────────
  # Head CRUD (US-012 shape, applicable to all adapters; US-064 governance)
  # ──────────────────────────────────────────────────────────────────────────

  def create_agent(attrs) do
    %Agent{}
    |> Agent.create_changeset(attrs)
    |> Repo.insert()
  end

  def update_agent(%Agent{} = agent, attrs) do
    agent
    |> Agent.update_changeset(attrs)
    |> Repo.update()
  end

  def archive_agent(%Agent{} = agent) do
    agent |> Agent.archive_changeset() |> Repo.update()
  end

  def unarchive_agent(%Agent{} = agent) do
    agent |> Agent.unarchive_changeset() |> Repo.update()
  end

  def get_agent(organization_id, id) do
    Repo.one(
      from a in Agent,
        where: a.organization_id == ^organization_id and a.id == ^id
    )
  end

  def get_agent!(organization_id, id) do
    case get_agent(organization_id, id) do
      nil -> raise Ecto.NoResultsError, queryable: Agent
      agent -> agent
    end
  end

  def get_agent_by_slug(organization_id, slug) when is_binary(slug) do
    Repo.get_by(Agent, organization_id: organization_id, slug: slug)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Library listing
  # ──────────────────────────────────────────────────────────────────────────

  def list_agents(organization_id, opts \\ []) do
    include_archived = Keyword.get(opts, :include_archived, false)
    search = Keyword.get(opts, :search)
    only_published = Keyword.get(opts, :only_published, false)

    q = from a in Agent, where: a.organization_id == ^organization_id, order_by: [asc: a.name]

    q
    |> maybe_filter_archived(include_archived)
    |> maybe_filter_published(only_published)
    |> maybe_filter_search(search)
    |> Repo.all()
  end

  defp maybe_filter_archived(q, true), do: q
  defp maybe_filter_archived(q, false), do: from(a in q, where: is_nil(a.archived_at))

  defp maybe_filter_published(q, false), do: q
  defp maybe_filter_published(q, true), do: from(a in q, where: not is_nil(a.current_version_id))

  defp maybe_filter_search(q, nil), do: q
  defp maybe_filter_search(q, ""), do: q

  defp maybe_filter_search(q, search) do
    like = "%#{String.downcase(search)}%"

    from a in q,
      where:
        fragment("lower(?) LIKE ?", a.name, ^like) or
          fragment("lower(coalesce(?, '')) LIKE ?", a.description, ^like)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Publish version (US-014) — adapter validation + checksum dedup
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Publish a new agent version. The caller supplies a map with `:adapter` plus
  adapter-specific fields. The corresponding `Codefresh.Agents.Adapters.*`
  module validates the shape before the version is inserted. If the checksum
  already exists for this agent, returns `{:ok, :noop, existing}`.

  ## Errors
    * `{:error, :unknown_adapter, adapter}` — not in the whitelist
    * `{:error, :invalid_config, reason_string}` — adapter-level shape error
    * `{:error, changeset}` — DB/changeset error
  """
  def publish_version(%Agent{} = agent, attrs) do
    attrs = normalize(attrs)
    adapter = to_string(Map.get(attrs, :adapter) || "")

    with {:ok, mod} <- resolve_adapter(adapter),
         :ok <- mod.validate_config(attrs) do
      config = %{
        adapter: adapter,
        endpoint_url: Map.get(attrs, :endpoint_url),
        model: Map.get(attrs, :model),
        auth_ref: Map.get(attrs, :auth_ref) || %{},
        headers: Map.get(attrs, :headers) || %{},
        request_template: Map.get(attrs, :request_template) || %{},
        response_jsonpath: Map.get(attrs, :response_jsonpath),
        model_tier: Map.get(attrs, :model_tier)
      }

      checksum = AgentVersion.compute_checksum(config)

      case Repo.get_by(AgentVersion, agent_id: agent.id, checksum: checksum) do
        %AgentVersion{} = existing ->
          {:ok, :noop, existing}

        nil ->
          do_publish(agent, config, checksum, Map.get(attrs, :published_by_user_id))
      end
    end
  end

  defp resolve_adapter(adapter) do
    case Map.fetch(@adapter_modules, adapter) do
      {:ok, mod} -> {:ok, mod}
      :error -> {:error, :unknown_adapter, adapter}
    end
  end

  defp do_publish(agent, config, checksum, published_by) do
    next_version = next_version_number(agent.id)

    attrs =
      config
      |> Map.merge(%{
        agent_id: agent.id,
        organization_id: agent.organization_id,
        version_number: next_version,
        checksum: checksum,
        published_by_user_id: published_by
      })

    Multi.new()
    |> Multi.insert(:version, AgentVersion.create_changeset(%AgentVersion{}, attrs))
    |> Multi.update(:advance_head, fn %{version: v} ->
      Agent.advance_current_version_changeset(agent, v.id)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{version: v}} -> {:ok, :published, v}
      {:error, :version, cs, _} -> {:error, cs}
      {:error, _, reason, _} -> {:error, reason}
    end
  end

  defp next_version_number(agent_id) do
    q =
      from v in AgentVersion,
        where: v.agent_id == ^agent_id,
        select: max(v.version_number)

    (Repo.one(q) || 0) + 1
  end

  def list_versions(%Agent{id: agent_id}) do
    Repo.all(
      from v in AgentVersion,
        where: v.agent_id == ^agent_id,
        order_by: [desc: v.version_number]
    )
  end

  def get_version!(id), do: Repo.get!(AgentVersion, id)

  # ──────────────────────────────────────────────────────────────────────────
  # Resolver (used by script nodes that reference an agent version)
  # ──────────────────────────────────────────────────────────────────────────

  def resolve_current_version(organization_id, agent_id) do
    case get_agent(organization_id, agent_id) do
      nil -> {:error, :not_found}
      %Agent{current_version_id: nil} -> {:error, :not_published}
      %Agent{current_version_id: vid} -> {:ok, Repo.get!(AgentVersion, vid)}
    end
  end

  def pinnable?(organization_id, version_id) do
    case Repo.get(AgentVersion, version_id) do
      %AgentVersion{organization_id: ^organization_id} -> true
      _ -> false
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Health check (US-013) — config-validation only, never hits the network
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Runs the adapter's `health_check/1`. Accepts either a version struct, a
  head whose `current_version_id` is set, or a raw config map (for draft
  previews).

  Returns one of:
    * `{:ok, :config_valid}` — real adapter, config looks good
    * `{:ok, :not_implemented}` — stubbed adapter (langchain/bedrock/vertex)
    * `{:error, :not_published}` — head with no published version
    * `{:error, :unknown_adapter, adapter}`
    * `{:error, reason_string}` — shape error from the adapter
  """
  def health_check(%AgentVersion{} = v) do
    dispatch_health(v.adapter, version_to_config(v))
  end

  def health_check(%Agent{current_version_id: nil}), do: {:error, :not_published}

  def health_check(%Agent{current_version_id: vid}) do
    case Repo.get(AgentVersion, vid) do
      nil -> {:error, :not_published}
      %AgentVersion{} = v -> health_check(v)
    end
  end

  def health_check(config) when is_map(config) do
    adapter = to_string(Map.get(config, :adapter) || Map.get(config, "adapter") || "")
    dispatch_health(adapter, config)
  end

  defp dispatch_health(adapter, config) do
    case Map.fetch(@adapter_modules, adapter) do
      {:ok, mod} -> mod.health_check(config)
      :error -> {:error, :unknown_adapter, adapter}
    end
  end

  defp version_to_config(%AgentVersion{} = v) do
    %{
      adapter: v.adapter,
      endpoint_url: v.endpoint_url,
      model: v.model,
      auth_ref: v.auth_ref || %{},
      headers: v.headers || %{},
      request_template: v.request_template || %{},
      response_jsonpath: v.response_jsonpath,
      model_tier: v.model_tier
    }
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

  defp safe_atom(str) do
    String.to_existing_atom(str)
  rescue
    ArgumentError -> String.to_atom(str)
  end
end
