defmodule Codefresh.Enterprise.SsoConfig do
  @moduledoc """
  Schema for per-organization SSO configuration (SAML stub — wave 3 assertion
  handling not implemented here). Persists IdP metadata URL, entity ID, and
  X.509 certificate for future assertion validation.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_providers ~w(saml oidc)

  schema "sso_config" do
    field :provider, :string
    field :enabled, :boolean, default: false
    field :sso_required, :boolean, default: false
    field :metadata, :map, default: %{}
    field :role_mapping, :map, default: %{}

    belongs_to :organization, Codefresh.Organizations.Organization

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating or updating SSO config.

  `metadata` expected keys for SAML:
    - `idp_metadata_url` (string)
    - `entity_id` (string)
    - `x509_cert` (string, PEM-encoded)
  """
  def changeset(sso_config, attrs) do
    sso_config
    |> cast(attrs, [:organization_id, :provider, :enabled, :sso_required, :metadata, :role_mapping])
    |> validate_required([:organization_id, :provider])
    |> validate_inclusion(:provider, @valid_providers)
    |> validate_saml_metadata()
    |> foreign_key_constraint(:organization_id)
    |> unique_constraint(:organization_id)
  end

  defp validate_saml_metadata(%{valid?: false} = cs), do: cs

  defp validate_saml_metadata(cs) do
    case get_field(cs, :provider) do
      "saml" ->
        meta = get_field(cs, :metadata) || %{}

        cs
        |> validate_meta_field(meta, "idp_metadata_url")
        |> validate_meta_field(meta, "entity_id")

      _ ->
        cs
    end
  end

  defp validate_meta_field(cs, meta, key) do
    case Map.get(meta, key) do
      v when is_binary(v) and v != "" ->
        cs

      _ ->
        add_error(cs, :metadata, "#{key} is required for SAML provider")
    end
  end
end
