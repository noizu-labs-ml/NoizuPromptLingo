defmodule Codefresh.Agents.Adapters.Behaviour do
  @moduledoc """
  Contract all agent adapter modules implement.

  * `validate_config/1` — shape/field validation; no network.
  * `health_check/1` — credentials-presence check; no network.
  * `invoke/2` — issue a single generation turn. Stage 5 stubs this out for
    every adapter (returns a deterministic `{:ok, "<stubbed response>", %{input_tokens: 0, output_tokens: 0}}`).
    Real HTTP/gRPC calls land in the Stage-4 expansion batch.

  `invoke/2` contract:
    * `config` — the merged agent version config (map; same shape as for
      `validate_config/1`).
    * `request` — `%{prompt: binary, system: binary | nil, history: [map], metadata: map}`

  Return:
    * `{:ok, response_binary, usage_map}` — `usage_map` MUST include at least
      `:input_tokens` and `:output_tokens` (may be 0 for stubs).
    * `{:error, reason}` — reason is a map; canonical keys:
      `%{type: "timeout|rate_limit|network|provider_5xx|auth|config|other",
         message: binary, retryable: boolean}`.
  """

  @type invoke_usage :: %{
          required(:input_tokens) => non_neg_integer(),
          required(:output_tokens) => non_neg_integer(),
          optional(atom()) => any()
        }

  @type invoke_request :: %{
          required(:prompt) => binary(),
          optional(:system) => binary() | nil,
          optional(:history) => [map()],
          optional(:metadata) => map()
        }

  @type invoke_error :: %{
          required(:type) => binary(),
          required(:message) => binary(),
          required(:retryable) => boolean()
        }

  @callback validate_config(map()) :: :ok | {:error, String.t()}
  @callback health_check(map()) ::
              {:ok, :config_valid} | {:ok, :not_implemented} | {:error, String.t()}
  @callback invoke(map(), invoke_request()) ::
              {:ok, binary(), invoke_usage()} | {:error, invoke_error()}
end
