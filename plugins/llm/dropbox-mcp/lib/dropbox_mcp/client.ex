defmodule DropboxMCP.Client do
  @moduledoc """
  Resolves a `%Noizu.Dropbox.Client{}` for tool handlers.

  Preference order:
  1. `:dropbox_mcp` app env `:client` (tests / explicit override)
  2. Process dictionary `:dropbox_mcp_client`
  3. Application config / env via `Noizu.Dropbox.client/0`
  """

  alias Noizu.Dropbox.Client, as: DropboxClient

  @spec get() :: DropboxClient.t()
  def get do
    cond do
      match?(%DropboxClient{}, Application.get_env(:dropbox_mcp, :client)) ->
        Application.get_env(:dropbox_mcp, :client)

      match?(%DropboxClient{}, Process.get(:dropbox_mcp_client)) ->
        Process.get(:dropbox_mcp_client)

      true ->
        Noizu.Dropbox.client()
    end
  end

  @doc "Set a client override visible to all processes (tests / single-tenant servers)."
  @spec put(DropboxClient.t()) :: :ok
  def put(%DropboxClient{} = client) do
    Application.put_env(:dropbox_mcp, :client, client)
    Process.put(:dropbox_mcp_client, client)
    :ok
  end

  @doc "Clear overrides."
  @spec clear() :: :ok
  def clear do
    Application.delete_env(:dropbox_mcp, :client)
    Process.delete(:dropbox_mcp_client)
    :ok
  end

  @doc """
  Jail root for tools: `DROPBOX_MCP_ROOT` if set, else `:default_root`.
  Empty / `/` means the Dropbox account root (no prefix jail).
  """
  @spec default_root() :: String.t()
  def default_root do
    case present_env("DROPBOX_MCP_ROOT") do
      {:ok, value} ->
        collapse(value)

      :unset ->
        case Application.get_env(:dropbox_mcp, :default_root, "") do
          value when is_binary(value) -> collapse(value)
          _ -> ""
        end
    end
  end

  @doc "Normalize a user-supplied path for Dropbox (\"\" root, collapse `.` / `..`)."
  @spec normalize_path(String.t() | nil) :: String.t()
  def normalize_path(nil), do: default_root()
  def normalize_path(""), do: default_root()

  def normalize_path(path) when is_binary(path) do
    collapsed = path |> String.trim() |> collapse()
    if collapsed == "", do: default_root(), else: collapsed
  end

  defp present_env(name) do
    case System.get_env(name) do
      value when is_binary(value) ->
        if String.trim(value) == "", do: :unset, else: {:ok, value}

      _ ->
        :unset
    end
  end

  defp collapse(path) when is_binary(path) do
    path
    |> String.replace("\\", "/")
    |> String.split("/")
    |> Enum.reduce([], fn
      "", acc -> acc
      ".", acc -> acc
      "..", [] -> []
      "..", [_ | rest] -> rest
      seg, acc -> [seg | acc]
    end)
    |> Enum.reverse()
    |> case do
      [] -> ""
      segs -> "/" <> Enum.join(segs, "/")
    end
  end
end
