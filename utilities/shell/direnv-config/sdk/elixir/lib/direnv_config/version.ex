defmodule DirenvConfig.Version do
  @spec read(String.t()) :: non_neg_integer()
  def read(store_path) do
    path = Path.join(store_path, ".version")

    case File.read(path) do
      {:ok, content} ->
        case Integer.parse(String.trim(content)) do
          {n, _} when n >= 0 -> n
          _ -> 0
        end

      {:error, _} ->
        0
    end
  end

  @spec bump(String.t()) :: {:ok, non_neg_integer()}
  def bump(store_path) do
    current = read(store_path)
    new_version = current + 1
    version_path = Path.join(store_path, ".version")
    tmp_path = Path.join(store_path, ".version.tmp")
    File.write!(tmp_path, Integer.to_string(new_version))
    File.rename!(tmp_path, version_path)
    {:ok, new_version}
  end
end
