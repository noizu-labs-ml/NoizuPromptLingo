defmodule Noizu.MCP.Client.Handler do
  @moduledoc """
  Callbacks for server-initiated MCP traffic on the client side.

      defmodule MyApp.MCPHandler do
        @behaviour Noizu.MCP.Client.Handler

        @impl true
        def handle_sampling(params, _state) do
          messages = params["messages"]
          {:ok, text} = MyApp.LLM.complete(messages, max_tokens: params["maxTokens"])

          {:ok,
           %{
             "role" => "assistant",
             "content" => %{"type" => "text", "text" => text},
             "model" => "my-model"
           }}
        end

        @impl true
        def handle_elicitation(%{"message" => _msg}, _state), do: {:ok, :decline}
      end

  Pass it to the client as `handler: MyApp.MCPHandler` (or `{module, arg}`).
  Implementing a callback is what advertises the corresponding client
  capability (`sampling`, `elicitation`); `roots` is advertised when the
  client is started with a `:roots` option or `c:list_roots/1` is implemented.

  Sampling/elicitation callbacks run in supervised tasks — a slow
  human-in-the-loop elicitation never blocks pings or concurrent responses.
  """

  alias Noizu.MCP.Types

  @typedoc "The handler argument given at client start (`handler: {mod, arg}`)."
  @type state :: term()

  @doc """
  Answer a `sampling/createMessage` request. `params` is the raw wire map
  (`messages`, `maxTokens`, `modelPreferences`, and on 2025-11-25 optionally
  `tools`/`toolChoice`). Return `{:ok, result_map}` with `role`, `content`,
  and `model`, or `{:error, reason}` to reject.
  """
  @callback handle_sampling(params :: map(), state()) ::
              {:ok, map()} | {:error, Noizu.MCP.Error.t() | String.t()}

  @doc """
  Answer an `elicitation/create` request. Return `{:ok, :accept, content_map}`
  (matching the requested schema), `{:ok, :decline}`, or `{:ok, :cancel}`.
  """
  @callback handle_elicitation(params :: map(), state()) ::
              {:ok, :accept, map()}
              | {:ok, :decline}
              | {:ok, :cancel}
              | {:error, Noizu.MCP.Error.t() | String.t()}

  @doc "Provide the roots list dynamically (otherwise the client's `:roots` option is used)."
  @callback list_roots(state()) :: {:ok, [Types.Root.t()]}

  @doc "Observe server notifications (log messages, resource updates, list changes…)."
  @callback handle_notification(method :: String.t(), params :: map() | nil, state()) :: :ok

  @optional_callbacks handle_sampling: 2,
                      handle_elicitation: 2,
                      list_roots: 1,
                      handle_notification: 3
end
