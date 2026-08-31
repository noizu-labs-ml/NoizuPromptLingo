defmodule ExLiteLLM.Config do
  @moduledoc """
  Parsed, hydrated ex-litellm configuration.

  Mirrors litellm's `ConfigYAML` (the four canonical sections) and adds the
  ex-litellm `front_proxy` extension for the folded-in front tier. Populated by
  `ExLiteLLM.Config.Loader`. Held in `:persistent_term` so the whole node reads
  one immutable snapshot; runtime mutations (e.g. front-proxy rules,
  `store_model_in_db` model registration) live in their own GenServers, not
  here.
  """

  @pt_key {__MODULE__, :config}

  @type t :: %__MODULE__{
          model_list: [map()],
          litellm_settings: map(),
          router_settings: map(),
          general_settings: map(),
          front_proxy: map(),
          raw: map()
        }

  defstruct model_list: [],
            litellm_settings: %{},
            router_settings: %{},
            general_settings: %{},
            front_proxy: %{},
            raw: %{}

  @doc "Store the active config snapshot for the node."
  @spec put(t()) :: :ok
  def put(%__MODULE__{} = config), do: :persistent_term.put(@pt_key, config)

  @doc "Fetch the active config, or an empty default if none loaded yet."
  @spec get() :: t()
  def get, do: :persistent_term.get(@pt_key, %__MODULE__{})

  @doc "Convenience: value from `general_settings`."
  @spec general(String.t(), term()) :: term()
  def general(key, default \\ nil), do: Map.get(get().general_settings, key, default)

  @doc "Convenience: value from `litellm_settings`."
  @spec setting(String.t(), term()) :: term()
  def setting(key, default \\ nil), do: Map.get(get().litellm_settings, key, default)

  @doc "Whether `drop_params` is enabled in `litellm_settings`."
  @spec drop_params?() :: boolean()
  def drop_params?, do: setting("drop_params", false) == true
end
