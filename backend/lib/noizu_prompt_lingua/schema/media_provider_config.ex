defmodule NoizuPromptLingua.Schema.MediaProviderConfig do
  @moduledoc """
  Per-org media-generation provider config (ADR-016). Overrides a registered
  genai media provider's per-request api_key / model / settings (and toggles it)
  for asset generation. `provider` is a registry slug (see
  `Domains.Assets.MediaProviders`). `api_key` is stored verbatim (masked on output),
  matching the `mock_mcp_llms` / `github_tokens` convention.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "media_provider_configs" do
    field :organization_id, :binary_id
    field :provider, :string
    field :modality, :string
    field :enabled, :boolean, default: true
    field :api_key, :string
    field :endpoint, :string
    field :default_model, :string
    field :settings, :map, default: %{}

    timestamps(type: :utc_datetime)
  end

  def changeset(cfg, attrs) do
    cfg
    |> cast(attrs, [
      :organization_id,
      :provider,
      :modality,
      :enabled,
      :api_key,
      :endpoint,
      :default_model,
      :settings
    ])
    |> validate_required([:organization_id, :provider, :modality])
    |> unique_constraint(:provider, name: :uq_media_provider_configs_org_provider)
    |> foreign_key_constraint(:organization_id)
  end
end
