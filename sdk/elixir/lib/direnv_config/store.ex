defmodule DirenvConfig.Store do
  @spec state_dir() :: String.t()
  def state_dir do
    case System.get_env("XDG_STATE_HOME") do
      nil -> Path.join([System.user_home!(), ".local", "state", "direnv-config"])
      xdg -> Path.join(xdg, "direnv-config")
    end
  end

  @spec path_to_hash(String.t()) :: String.t()
  def path_to_hash(dir) do
    stripped = String.trim_leading(dir, "/")
    name = String.replace(stripped, "/", "-")

    if byte_size(name) <= 200 do
      name
    else
      hash =
        :crypto.hash(:sha256, dir)
        |> Base.encode16(case: :lower)
        |> binary_part(0, 8)

      binary_part(name, 0, 200) <> "-" <> hash
    end
  end

  @spec store_path(String.t()) :: String.t()
  def store_path(dir) do
    Path.join(state_dir(), path_to_hash(dir))
  end

  @spec find_current_store(String.t() | nil) :: {:ok, String.t()} | {:error, :not_found}
  def find_current_store(start_dir \\ nil) do
    dir = start_dir || File.cwd!()
    walk_up(dir)
  end

  defp walk_up("/"), do: check_or_stop("/")

  defp walk_up(dir) do
    sp = store_path(dir)

    if File.dir?(sp) do
      {:ok, sp}
    else
      parent = Path.dirname(dir)

      if parent == dir do
        {:error, :not_found}
      else
        walk_up(parent)
      end
    end
  end

  defp check_or_stop(dir) do
    sp = store_path(dir)
    if File.dir?(sp), do: {:ok, sp}, else: {:error, :not_found}
  end

  @spec ensure_store(String.t()) :: {:ok, String.t()}
  def ensure_store(directory) do
    sp = store_path(directory)
    File.mkdir_p!(sp)
    meta_path = Path.join(sp, ".meta")

    unless File.exists?(meta_path) do
      meta = %{
        "source" => directory,
        "created" => DateTime.utc_now() |> DateTime.to_iso8601(),
        "configs" => []
      }

      File.write!(meta_path, Ymlr.document!(meta))
    end

    {:ok, sp}
  end

  @spec ensure_config(String.t(), String.t()) :: {:ok, String.t()}
  def ensure_config(store, name) do
    config_path = Path.join(store, name)
    File.mkdir_p!(config_path)
    {:ok, config_path}
  end

  @spec layer_path(String.t(), String.t(), String.t()) :: String.t()
  def layer_path(store, name, layer) do
    Path.join([store, name, "#{layer}.yaml"])
  end

  @spec active_path(String.t(), String.t()) :: String.t()
  def active_path(store, name) do
    Path.join([store, name, ".active"])
  end
end
