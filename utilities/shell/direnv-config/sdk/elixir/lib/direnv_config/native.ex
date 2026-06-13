defmodule DirenvConfig.Native do
  @spec get(String.t(), String.t(), String.t() | nil) :: {:ok, term()} | :error
  def get(store_path, config, path \\ nil) do
    active_file = Path.join([store_path, config, ".active"])

    case YamlElixir.read_from_file(active_file) do
      {:ok, data} ->
        resolve(data, path)

      {:error, _} ->
        :error
    end
  end

  @spec list_configs(String.t()) :: {:ok, [String.t()]} | :error
  def list_configs(store_path) do
    meta_file = Path.join(store_path, ".meta")

    case YamlElixir.read_from_file(meta_file) do
      {:ok, %{"configs" => configs}} when is_list(configs) ->
        {:ok, configs}

      _ ->
        :error
    end
  end

  @spec set(String.t(), String.t(), String.t(), term(), String.t(), boolean()) ::
          :ok | {:error, term()}
  def set(store_path, config, key, value, layer \\ "local", no_bump \\ false) do
    ensure_store_and_config(store_path, config)
    layer_file = DirenvConfig.Store.layer_path(store_path, config, layer)

    doc =
      case YamlElixir.read_from_file(layer_file) do
        {:ok, data} when is_map(data) -> data
        _ -> %{}
      end

    parsed = parse_value(value)

    case DirenvConfig.Path.set(doc, key, parsed) do
      {:ok, updated} ->
        File.write!(layer_file, Ymlr.document!(updated))
        DirenvConfig.Resolve.resolve_active(store_path, config)
        unless no_bump, do: DirenvConfig.Version.bump(store_path)
        :ok

      {:error, _} = err ->
        err
    end
  end

  @spec unset(String.t(), String.t(), [String.t()], String.t(), boolean()) ::
          :ok | {:error, term()}
  def unset(store_path, config, keys, layer \\ "local", no_bump \\ false) do
    layer_file = DirenvConfig.Store.layer_path(store_path, config, layer)

    unless File.exists?(layer_file) do
      :ok
    else
      doc =
        case YamlElixir.read_from_file(layer_file) do
          {:ok, data} when is_map(data) -> data
          _ -> %{}
        end

      result =
        Enum.reduce_while(keys, {:ok, doc}, fn key, {:ok, acc} ->
          case DirenvConfig.Path.delete(acc, key) do
            {:ok, updated} -> {:cont, {:ok, updated}}
            :error -> {:halt, {:error, {:delete_failed, key}}}
          end
        end)

      case result do
        {:ok, updated} ->
          File.write!(layer_file, Ymlr.document!(updated))
          DirenvConfig.Resolve.resolve_active(store_path, config)
          unless no_bump, do: DirenvConfig.Version.bump(store_path)
          :ok

        {:error, _} = err ->
          err
      end
    end
  end

  @spec bump(String.t()) :: {:ok, non_neg_integer()}
  def bump(store_path) do
    DirenvConfig.Version.bump(store_path)
  end

  defp resolve(data, nil), do: {:ok, data}
  defp resolve(data, path), do: DirenvConfig.Path.get(data, path)

  defp ensure_store_and_config(store_path, config) do
    File.mkdir_p!(store_path)
    meta_path = Path.join(store_path, ".meta")

    unless File.exists?(meta_path) do
      meta = %{
        "source" => store_path,
        "created" => DateTime.utc_now() |> DateTime.to_iso8601(),
        "configs" => []
      }

      File.write!(meta_path, Ymlr.document!(meta))
    end

    DirenvConfig.Store.ensure_config(store_path, config)
  end

  defp parse_value(value) when is_binary(value) do
    case YamlElixir.read_from_string(value) do
      {:ok, parsed} -> parsed
      {:error, _} -> value
    end
  end

  defp parse_value(value), do: value
end
