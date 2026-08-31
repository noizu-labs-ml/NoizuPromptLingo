defmodule NoizuPromptLingua.MCP.EffectiveToolset.Behaviour do
  @moduledoc """
  Contract for effective-toolset resolution (TOBOR-CONTRACTS.md §2).

  The live implementation lives on `NoizuPromptLingua.MCP.EffectiveToolset`
  (branch feat/effective-toolset). Consumers that must build before that branch
  lands — `Session_Manifest` (W5) and tests — resolve the implementation through
  the `:effective_toolset_impl` application env and this behaviour, so the
  module can be swapped for a test double.

  ```elixir
  Application.get_env(
    :noizu_prompt_lingua,
    :effective_toolset_impl,
    NoizuPromptLingua.MCP.EffectiveToolset
  )
  ```
  """

  @type tool_state :: %{
          optional(:enabled) => boolean,
          optional(:visible) => boolean,
          optional(:name_override) => String.t() | nil,
          optional(:description_override) => String.t() | nil,
          optional(:expires_at) => DateTime.t() | nil
        }

  @type scope :: NoizuPromptLingua.Schema.MCPCustomScope.t() | nil
  @type client :: %{id: term, kind: :api_key | :oauth_client, toolset_config: map() | nil}

  @callback resolve(scope, client, user_ref_or_nil :: String.t() | nil, at :: DateTime.t()) ::
              %{String.t() => tool_state()}
end
