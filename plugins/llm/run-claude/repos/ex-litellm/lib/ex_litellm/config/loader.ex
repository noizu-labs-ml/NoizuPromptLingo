defmodule ExLiteLLM.Config.Loader do
  @moduledoc """
  Loads and normalizes a litellm-style `config.yaml`.

  Recognizes the same top-level keys the Python proxy reads
  (`model_list`, `litellm_settings`, `router_settings`, `general_settings`)
  plus an ex-litellm extension block (`front_proxy`) for the folded-in front
  tier. Values are hydrated through `ExLiteLLM.Config.Secret` so
  `os.environ/VAR` interpolation works exactly as in litellm.

  Returns an `%ExLiteLLM.Config{}` struct. Deep validation of individual
  provider params lands with the provider layer (Phase 2); Phase 1 parses,
  interpolates, and shape-checks the top level.
  """

  alias ExLiteLLM.Config
  alias ExLiteLLM.Config.Secret

  @known_keys ~w(model_list litellm_settings router_settings general_settings
                 environment_variables finetune_settings files_settings front_proxy)

  @doc """
  Load config from a YAML file path. Returns `{:ok, %Config{}}` or
  `{:error, reason}`.
  """
  @spec load_file(String.t()) :: {:ok, Config.t()} | {:error, term()}
  def load_file(path) when is_binary(path) do
    with {:ok, raw} <- read(path),
         {:ok, parsed} <- parse(raw) do
      from_map(parsed)
    end
  end

  @doc "Load from an already-parsed map (used in tests and by the DB config path)."
  @spec from_map(map()) :: {:ok, Config.t()} | {:error, term()}
  def from_map(parsed) when is_map(parsed) do
    # Inject any `environment_variables` block into the process env before
    # resolving os.environ/ refs elsewhere — mirrors litellm behavior.
    apply_environment_variables(Map.get(parsed, "environment_variables"))

    hydrated = Secret.resolve_deep(parsed)

    config = %Config{
      model_list: Map.get(hydrated, "model_list", []),
      litellm_settings: Map.get(hydrated, "litellm_settings", %{}),
      router_settings: Map.get(hydrated, "router_settings", %{}),
      general_settings: Map.get(hydrated, "general_settings", %{}),
      front_proxy: Map.get(hydrated, "front_proxy", %{}),
      raw: hydrated
    }

    {:ok, config}
  end

  def from_map(_), do: {:error, :config_not_a_map}

  defp read(path) do
    case File.read(path) do
      {:ok, contents} -> {:ok, contents}
      {:error, reason} -> {:error, {:config_read_failed, path, reason}}
    end
  end

  defp parse(raw) do
    case YamlElixir.read_from_string(raw) do
      {:ok, map} when is_map(map) ->
        {:ok, warn_unknown_keys(map)}

      {:ok, _other} ->
        {:error, :config_not_a_map}

      {:error, reason} ->
        {:error, {:config_parse_failed, reason}}
    end
  end

  defp warn_unknown_keys(map) do
    for key <- Map.keys(map), key not in @known_keys do
      require Logger
      Logger.warning("[config] ignoring unknown top-level key: #{inspect(key)}")
    end

    map
  end

  defp apply_environment_variables(nil), do: :ok

  defp apply_environment_variables(vars) when is_map(vars) do
    Enum.each(vars, fn {k, v} ->
      # Only set if not already present, matching run-claude's behavior.
      if is_binary(v) and System.get_env(to_string(k)) in [nil, ""] do
        System.put_env(to_string(k), Secret.resolve(v) || "")
      end
    end)
  end

  defp apply_environment_variables(_), do: :ok
end
