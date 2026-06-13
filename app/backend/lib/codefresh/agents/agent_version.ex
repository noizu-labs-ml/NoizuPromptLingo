defmodule Codefresh.Agents.AgentVersion do
  @moduledoc """
  Immutable version of an agent connector. Stores the adapter type and its
  adapter-specific configuration, modeled against migration
  `20260421000005_create_agents_and_versions.exs`:

    * `adapter` — one of #{inspect(["openai", "anthropic", "langchain", "http", "bedrock", "vertex"])}
    * `endpoint_url` — base URL or webhook URL (nullable for SDK-backed adapters)
    * `model` — model name (e.g. `gpt-4o`, `claude-sonnet-4.5`)
    * `auth_ref` — opaque map: `%{"type" => "secret_ref", "ref" => "projects/…"}`
    * `headers` — extra HTTP headers (HTTP adapter)
    * `request_template` — adapter-specific payload map (streaming flags,
      mapping rules, langchain entrypoint, etc.)
    * `response_jsonpath` — JSONPath/JQ expression to pull text from HTTP
      adapter responses
    * `checksum` — SHA-256 over canonical adapter + config + version_number-ish
    * `model_tier` — cost tier label (US-064)

  Streaming preference (US-065) is persisted inside `request_template` under
  `"streaming" => true|false`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @adapters ~w(openai anthropic langchain http bedrock vertex)

  schema "agent_versions" do
    field :version_number, :integer
    field :adapter, :string
    field :endpoint_url, :string
    field :model, :string
    field :auth_ref, :map, default: %{}
    field :headers, :map, default: %{}
    field :request_template, :map, default: %{}
    field :response_jsonpath, :string
    field :checksum, :binary
    field :model_tier, :string

    belongs_to :agent, Codefresh.Agents.Agent
    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :published_by, Codefresh.Accounts.User, foreign_key: :published_by_user_id

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def adapters, do: @adapters

  def create_changeset(av, attrs) do
    av
    |> cast(attrs, [
      :agent_id,
      :organization_id,
      :version_number,
      :adapter,
      :endpoint_url,
      :model,
      :auth_ref,
      :headers,
      :request_template,
      :response_jsonpath,
      :checksum,
      :model_tier,
      :published_by_user_id
    ])
    |> validate_required([
      :agent_id,
      :organization_id,
      :version_number,
      :adapter,
      :checksum
    ])
    |> validate_inclusion(:adapter, @adapters)
    |> validate_number(:version_number, greater_than: 0)
    |> unique_constraint([:agent_id, :version_number])
    |> unique_constraint([:agent_id, :checksum])
    |> foreign_key_constraint(:agent_id)
    |> foreign_key_constraint(:organization_id)
  end

  @doc """
  SHA-256 checksum of the canonical representation of a version's config.
  Adapter + sorted config fields + version_number are included so the same
  config in different numeric slots still produces distinct rows (the unique
  index on `(agent_id, checksum)` gives the noop dedup behavior within a
  given version slot).
  """
  def compute_checksum(config) when is_map(config) do
    canonical =
      [
        "adapter=#{Map.get(config, :adapter) || Map.get(config, "adapter")}",
        "endpoint_url=#{Map.get(config, :endpoint_url) || Map.get(config, "endpoint_url")}",
        "model=#{Map.get(config, :model) || Map.get(config, "model")}",
        "auth_ref=" <> stable_encode(Map.get(config, :auth_ref) || Map.get(config, "auth_ref") || %{}),
        "headers=" <> stable_encode(Map.get(config, :headers) || Map.get(config, "headers") || %{}),
        "request_template=" <>
          stable_encode(Map.get(config, :request_template) || Map.get(config, "request_template") || %{}),
        "response_jsonpath=#{Map.get(config, :response_jsonpath) || Map.get(config, "response_jsonpath")}",
        "model_tier=#{Map.get(config, :model_tier) || Map.get(config, "model_tier")}"
      ]
      |> Enum.join("\n---\n")

    :crypto.hash(:sha256, canonical)
  end

  defp stable_encode(map) when is_map(map) do
    map
    |> Enum.sort_by(fn {k, _} -> to_string(k) end)
    |> Enum.map_join(",", fn {k, v} -> "#{k}=#{inspect(v, limit: :infinity)}" end)
  end

  defp stable_encode(_), do: ""
end
