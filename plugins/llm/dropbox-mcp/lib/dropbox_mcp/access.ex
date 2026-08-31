defmodule DropboxMCP.Access do
  @moduledoc """
  Least-privilege gates for Dropbox MCP tools.

  * Writes are off unless `DROPBOX_MCP_WRITES=1` (or `:dropbox_mcp, :writes`).
  * When `DROPBOX_MCP_ROOT` or `:default_root` is set, tool paths must stay
    under that prefix (`..` segments are collapsed first).
  """

  alias DropboxMCP.Client

  @truthy ~w(1 true yes on)
  @falsy ~w(0 false no off)

  @doc "True when mutating tools are allowed."
  @spec writes_enabled?() :: boolean()
  def writes_enabled? do
    case env_flag(System.get_env("DROPBOX_MCP_WRITES")) do
      {:ok, enabled?} -> enabled?
      :unset -> app_writes()
    end
  end

  @doc "`:ok` or `{:error, reason}` when writes are disabled."
  @spec require_writes() :: :ok | {:error, String.t()}
  def require_writes do
    if writes_enabled?() do
      :ok
    else
      {:error,
       "writes disabled: set DROPBOX_MCP_WRITES=1 to enable dropbox_write_file, dropbox_move, dropbox_delete, and other mutations"}
    end
  end

  @doc """
  Normalize `path` and, when a default root is configured, reject anything
  outside that prefix.
  """
  @spec jail_path(String.t() | nil) :: {:ok, String.t()} | {:error, String.t()}
  def jail_path(path) do
    normalized = Client.normalize_path(path)
    root = Client.default_root()

    if under_root?(normalized, root) do
      {:ok, normalized}
    else
      {:error, "path #{inspect(normalized)} is outside default_root #{inspect(root)}"}
    end
  end

  defp app_writes do
    case Application.get_env(:dropbox_mcp, :writes, false) do
      true -> true
      1 -> true
      "1" -> true
      "true" -> true
      "TRUE" -> true
      _ -> false
    end
  end

  defp env_flag(nil), do: :unset
  defp env_flag(""), do: :unset

  defp env_flag(value) when is_binary(value) do
    case String.downcase(String.trim(value)) do
      v when v in @truthy -> {:ok, true}
      v when v in @falsy -> {:ok, false}
      _ -> {:ok, false}
    end
  end

  defp under_root?(_path, root) when root in ["", "/"], do: true
  defp under_root?(path, root), do: path == root or String.starts_with?(path, root <> "/")
end
