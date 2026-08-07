defmodule NoizuPromptLingua.Authz.Pdp do
  @moduledoc """
  Policy Decision Point for MCP OAuth (Phase 3).

  Effective permission = axis1 (user entitlements) ∩ axis2 (client capability)
  ∩ axis3 (pairing grant).

  Backends:
  - `:local` (default) — Ecto + existing `Authz.authorize/4` (no SpiceDB required)
  - `:spicedb` — HTTP checks against SpiceDB when `SPICEDB_ENDPOINT` is set
  - `:disabled` — always allow (JWT crypto only; ToolGuard still applies)

  Configure: `config :noizu_prompt_lingua, :mcp_pdp, mode: :local`
  """

  @type check_request :: %{
          optional(:user_id) => String.t(),
          optional(:client_id) => String.t(),
          optional(:grant_id) => String.t() | nil,
          optional(:resource) => String.t() | nil,
          optional(:tool) => String.t() | nil,
          optional(:server) => String.t() | nil,
          optional(:action) => String.t() | nil,
          optional(:resource_type) => atom() | String.t() | nil,
          optional(:resource_id) => String.t() | nil,
          optional(:required_role) => atom() | String.t() | nil
        }

  @callback check(check_request()) :: :ok | {:error, atom() | map()}

  def check(req) when is_map(req) do
    case mode() do
      :disabled -> :ok
      :spicedb -> NoizuPromptLingua.Authz.Pdp.SpiceDB.check(req)
      _ -> NoizuPromptLingua.Authz.Pdp.Local.check(req)
    end
  end

  def mode do
    Application.get_env(:noizu_prompt_lingua, :mcp_pdp, [])
    |> Keyword.get(:mode, :local)
  end

  def enabled?, do: mode() != :disabled
end
