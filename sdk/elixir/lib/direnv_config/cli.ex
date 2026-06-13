defmodule DirenvConfig.CLI do
  @spec get(String.t(), String.t(), String.t(), String.t() | nil) :: {:ok, String.t()} | :error
  def get(dc_binary \\ "dc", store_path, config, path \\ nil) do
    args =
      ["get", config] ++
        (if path, do: [path], else: []) ++
        ["--raw", "--store", store_path]

    case System.cmd(dc_binary, args, stderr_to_stdout: true) do
      {output, 0} -> {:ok, String.trim(output)}
      _ -> :error
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

  @spec set(String.t(), String.t(), String.t(), String.t(), String.t(), String.t(), boolean()) ::
          :ok | {:error, term()}
  def set(dc_binary, store_path, config, key, value, layer \\ "local", no_bump \\ false) do
    args =
      ["set", config, key, value, "--layer", layer, "--store", store_path] ++
        if(no_bump, do: ["--no-bump"], else: [])

    case System.cmd(dc_binary, args, stderr_to_stdout: true) do
      {_output, 0} -> :ok
      {output, _} -> {:error, output}
    end
  end

  @spec unset(String.t(), String.t(), String.t(), [String.t()], String.t(), boolean()) ::
          :ok | {:error, term()}
  def unset(dc_binary, store_path, config, keys, layer \\ "local", no_bump \\ false) do
    args =
      ["unset", config | keys] ++
        ["--layer", layer, "--store", store_path] ++
        if(no_bump, do: ["--no-bump"], else: [])

    case System.cmd(dc_binary, args, stderr_to_stdout: true) do
      {_output, 0} -> :ok
      {output, _} -> {:error, output}
    end
  end

  @spec bump(String.t(), String.t()) :: {:ok, non_neg_integer()} | {:error, term()}
  def bump(dc_binary, store_path) do
    args = ["bump", "--store", store_path]

    case System.cmd(dc_binary, args, stderr_to_stdout: true) do
      {output, 0} ->
        case Integer.parse(String.trim(output)) do
          {n, _} -> {:ok, n}
          :error -> {:ok, 0}
        end

      {output, _} ->
        {:error, output}
    end
  end
end
