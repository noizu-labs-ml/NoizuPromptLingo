defmodule DropboxMCP.Format do
  @moduledoc false

  alias Noizu.Dropbox.Error
  alias Noizu.Dropbox.Struct.ListFolderResult
  alias Noizu.Dropbox.Struct.Metadata

  @doc "JSON-encode term for tool text responses."
  def json(term) do
    term
    |> encode_safe()
    |> Jason.encode!(pretty: true)
  end

  def ok_json(term), do: {:ok, json(term)}

  def error(msg) when is_binary(msg), do: {:error, msg}

  def error(%Error{} = err) do
    msg =
      cond do
        is_binary(err.summary) and err.summary != "" -> err.summary
        is_binary(err.message) -> err.message
        true -> inspect(err)
      end

    status = if err.status, do: " (HTTP #{err.status})", else: ""
    {:error, "Dropbox error#{status}: #{msg}"}
  end

  def error(other), do: {:error, "Dropbox error: #{inspect(other)}"}

  def metadata(%Metadata{} = m) do
    %{
      "tag" => m.tag,
      "name" => m.name,
      "path" => m.path_display || m.path_lower,
      "id" => m.id,
      "size" => m.size,
      "rev" => m.rev,
      "client_modified" => m.client_modified,
      "server_modified" => m.server_modified,
      "content_hash" => m.content_hash,
      "is_downloadable" => m.is_downloadable
    }
    |> reject_nils()
  end

  def metadata(%{} = m) do
    %{
      "tag" => m[:".tag"] || m[".tag"] || m[:tag] || m["tag"],
      "name" => m[:name] || m["name"],
      "path" => m[:path_display] || m["path_display"] || m[:path_lower] || m["path_lower"],
      "id" => m[:id] || m["id"],
      "size" => m[:size] || m["size"],
      "rev" => m[:rev] || m["rev"],
      "client_modified" => m[:client_modified] || m["client_modified"],
      "server_modified" => m[:server_modified] || m["server_modified"],
      "content_hash" => m[:content_hash] || m["content_hash"]
    }
    |> reject_nils()
  end

  def metadata(_), do: %{}

  def list_folder(%ListFolderResult{} = r) do
    %{
      "entries" => Enum.map(r.entries, &metadata/1),
      "cursor" => r.cursor,
      "has_more" => r.has_more
    }
  end

  def list_folder(%{} = r) do
    entries = r[:entries] || r["entries"] || []

    %{
      "entries" => Enum.map(entries, &metadata/1),
      "cursor" => r[:cursor] || r["cursor"],
      "has_more" => r[:has_more] || r["has_more"] || false
    }
  end

  defp reject_nils(map) do
    map
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  defp encode_safe(term)
       when is_binary(term) or is_number(term) or is_boolean(term) or is_nil(term),
       do: term

  defp encode_safe(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp encode_safe(%Metadata{} = m), do: metadata(m)
  defp encode_safe(%ListFolderResult{} = r), do: list_folder(r)
  defp encode_safe(%_{} = struct), do: struct |> Map.from_struct() |> encode_safe()
  defp encode_safe(list) when is_list(list), do: Enum.map(list, &encode_safe/1)

  defp encode_safe(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {to_string(k), encode_safe(v)} end)
  end

  defp encode_safe(other), do: inspect(other)
end
