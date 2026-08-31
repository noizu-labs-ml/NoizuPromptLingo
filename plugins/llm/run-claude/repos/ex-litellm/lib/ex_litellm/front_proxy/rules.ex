defmodule ExLiteLLM.FrontProxy.Rules do
  @moduledoc """
  Runtime-alterable routing rules for the front-proxy tier.

  The Python `front_proxy.py::_route` is a fixed if-ladder. Here it's an ordered
  list of `%Rule{}` held in a GenServer, replaceable at runtime (via the admin
  endpoints `GET/PUT /front/rules` and `PUT /front/mode`) with no restart.

  Each rule is `{match, target, auth}`:

    * **match** — `{:path_in, paths}` (exact or `path/…` prefix),
      `{:messages_model, prefix}` (the `/v1/messages` model-conditional rule),
      or `:any` (catch-all).
    * **target** — `:litellm` (→ the LiteLLM tier), `:anthropic` (→ Anthropic
      API), or `{:url, base}` (arbitrary upstream).
    * **auth** — `:master_key` (strip client OAuth, inject master key) or
      `:passthrough` (keep the caller's original auth headers).

  Two seed rule-sets mirror the Python modes:

    * `:standard`    — everything → LiteLLM (client already holds master key).
    * `:passthrough` — OpenAI paths → LiteLLM (auth swap); `/v1/messages` non-
      `claude-*` → LiteLLM, else Anthropic passthrough; everything else →
      Anthropic passthrough.
  """
  use GenServer

  @name __MODULE__

  @openai_paths [
    "/v1/chat/completions",
    "/v1/completions",
    "/v1/embeddings",
    "/v1/images",
    "/v1/audio",
    "/v1/responses"
  ]

  defmodule Rule do
    @moduledoc "One front-proxy routing rule."
    @enforce_keys [:match, :target, :auth]
    defstruct [:match, :target, :auth]

    @type t :: %__MODULE__{
            match:
              {:path_in, [String.t()]}
              | {:messages_model, String.t()}
              | {:messages_not_model, String.t()}
              | :any,
            target: :litellm | :anthropic | {:url, String.t()},
            auth: :master_key | :passthrough
          }
  end

  # --- client API ---

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: @name)
  end

  @doc "The current ordered rule list."
  @spec list() :: [Rule.t()]
  def list, do: :persistent_term.get(pt_key(), default_rules(:passthrough))

  @doc "The current mode (`:standard` | `:passthrough` | `:custom`)."
  @spec mode() :: atom()
  def mode, do: GenServer.call(@name, :mode)

  @doc "Replace the rule list (mode becomes `:custom`)."
  @spec put(list()) :: :ok
  def put(rules) when is_list(rules), do: GenServer.call(@name, {:put, rules})

  @doc "Switch to a seed mode (`:standard` | `:passthrough`)."
  @spec set_mode(atom()) :: :ok | {:error, :unknown_mode}
  def set_mode(mode), do: GenServer.call(@name, {:set_mode, mode})

  @doc "The default rule set for a seed mode."
  @spec default_rules(atom()) :: [Rule.t()]
  def default_rules(:standard) do
    [%Rule{match: :any, target: :litellm, auth: :master_key}]
  end

  def default_rules(:passthrough) do
    [
      # OpenAI-shaped paths → LiteLLM tier, swap to master key.
      %Rule{match: {:path_in, @openai_paths}, target: :litellm, auth: :master_key},
      # /v1/messages with a non-claude model → LiteLLM (swap auth).
      %Rule{match: {:messages_not_model, "claude-"}, target: :litellm, auth: :master_key},
      # /v1/messages with a claude-* model → Anthropic, keep caller OAuth.
      %Rule{match: {:messages_model, "claude-"}, target: :anthropic, auth: :passthrough},
      # Everything else → Anthropic passthrough.
      %Rule{match: :any, target: :anthropic, auth: :passthrough}
    ]
  end

  @doc "The OpenAI paths that route to the LiteLLM tier."
  @spec openai_paths() :: [String.t()]
  def openai_paths, do: @openai_paths

  # --- server ---

  @impl true
  def init(opts) do
    mode = Keyword.get(opts, :mode, seed_mode())
    rules = default_rules(mode)
    publish(rules)
    {:ok, %{mode: mode, rules: rules}}
  end

  @impl true
  def handle_call(:mode, _from, state), do: {:reply, state.mode, state}

  def handle_call({:put, rules}, _from, state) do
    publish(rules)
    {:reply, :ok, %{state | rules: rules, mode: :custom}}
  end

  def handle_call({:set_mode, mode}, _from, state) when mode in [:standard, :passthrough] do
    rules = default_rules(mode)
    publish(rules)
    {:reply, :ok, %{state | mode: mode, rules: rules}}
  end

  def handle_call({:set_mode, _mode}, _from, state) do
    {:reply, {:error, :unknown_mode}, state}
  end

  # --- helpers ---

  defp publish(rules), do: :persistent_term.put(pt_key(), rules)
  defp pt_key, do: {__MODULE__, :rules}

  # Seed from config's front_proxy.mode, else default to passthrough (safe:
  # preserves Anthropic OAuth for claude-* like the Python default).
  defp seed_mode do
    case ExLiteLLM.Config.get().front_proxy["mode"] do
      "standard" -> :standard
      _ -> :passthrough
    end
  end
end
