defmodule ExLiteLLM.Config.Secret do
  @moduledoc """
  Lazy secret resolution, mirroring litellm's `get_secret`
  (`litellm/secret_managers/main.py`).

  A config value of the form `os.environ/VAR_NAME` is resolved to the value of
  the `VAR_NAME` environment variable at read time (not YAML parse time). Any
  other string is returned unchanged. This is what lets the same `config.yaml`
  carry `api_key: os.environ/ANTHROPIC_API_KEY` across environments.

  Future backends (`oidc/...`, Google Secret Manager, Azure Key Vault) hook in
  here; for now only the `os.environ/` prefix is honored.
  """

  @env_prefix "os.environ/"

  @doc """
  Resolve a single value. Non-strings pass through untouched; strings are
  scanned for the `os.environ/` prefix.
  """
  @spec resolve(term()) :: term()
  def resolve(@env_prefix <> var), do: System.get_env(var)
  def resolve(value) when is_binary(value), do: value
  def resolve(value), do: value

  @doc """
  Recursively resolve every string leaf in a map/list structure. Used to
  hydrate a parsed config tree in one pass.
  """
  @spec resolve_deep(term()) :: term()
  def resolve_deep(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {k, resolve_deep(v)} end)
  end

  def resolve_deep(list) when is_list(list), do: Enum.map(list, &resolve_deep/1)
  def resolve_deep(value), do: resolve(value)
end
