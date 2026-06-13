defmodule DirenvConfig.Resolve do
  @moduledoc """
  Resolves the `.active` configuration by merging YAML layers.

  Layer merge order: base.yaml -> {DC_ENV}.yaml -> local.yaml -> secrets.yaml
  """

  @spec resolve_active(String.t(), String.t()) :: {:ok, term()} | {:error, term()}
  def resolve_active(store_path, name) do
    config_dir = Path.join(store_path, name)
    env = System.get_env("DC_ENV") || "dev"

    layer_names = ["base", env, "local", "secrets"]

    layers =
      layer_names
      |> Enum.map(fn layer -> Path.join(config_dir, "#{layer}.yaml") end)
      |> Enum.filter(&File.exists?/1)
      |> Enum.reduce([], fn file, acc ->
        case YamlElixir.read_from_file(file) do
          {:ok, data} when is_map(data) -> acc ++ [data]
          _ -> acc
        end
      end)

    merged =
      case layers do
        [] -> %{}
        _ -> DirenvConfig.Merge.deep_merge_multi(layers) || %{}
      end

    File.mkdir_p!(config_dir)
    active_path = Path.join(config_dir, ".active")
    yaml_content = Ymlr.document!(merged)
    File.write!(active_path, yaml_content)

    {:ok, merged}
  rescue
    e -> {:error, e}
  end
end
