defmodule DropboxMCP.Resources.Path do
  @moduledoc """
  Resource template for reading Dropbox files via `dropbox://{path}`.
  """

  use Noizu.MCP.Server.ResourceTemplate,
    uri_template: "dropbox://{path}",
    name: "Dropbox path",
    description: "Read a file from Dropbox. Example URI: dropbox:///Documents/notes.md",
    mime_type: "application/octet-stream"

  alias DropboxMCP.Access
  alias DropboxMCP.Client
  alias DropboxMCP.Format
  alias Noizu.Dropbox.Api.Files
  alias Noizu.MCP.Types.ResourceContents

  @impl true
  def read(uri, vars, _ctx) do
    path =
      (Map.get(vars, :path) || Map.get(vars, "path") || "")
      |> normalize_resource_path()

    case Access.jail_path(path) do
      {:ok, path} ->
        download_resource(uri, path)

      {:error, msg} ->
        Format.error(msg)
    end
  end

  defp download_resource(uri, path) do
    case Files.download(path, client: Client.get()) do
      {:ok, %{metadata: meta, body: body}} ->
        name = meta[:name] || meta["name"] || Path.basename(path)
        mime = guess_mime(name)

        contents =
          if text_mime?(mime) do
            ResourceContents.text(uri, safe_text(body), mime_type: mime)
          else
            ResourceContents.blob(uri, body, mime_type: mime)
          end

        {:ok, contents}

      {:error, err} ->
        Format.error(err)
    end
  end

  defp normalize_resource_path(path) when is_binary(path) do
    path
    |> String.trim()
    |> String.trim_leading("/")
    |> then(fn
      "" -> ""
      p -> "/" <> p
    end)
  end

  defp guess_mime(name) do
    case Path.extname(name) |> String.downcase() do
      ".md" -> "text/markdown"
      ".txt" -> "text/plain"
      ".json" -> "application/json"
      ".html" -> "text/html"
      ".csv" -> "text/csv"
      ".ex" -> "text/plain"
      ".exs" -> "text/plain"
      ".yml" -> "text/yaml"
      ".yaml" -> "text/yaml"
      _ -> "application/octet-stream"
    end
  end

  defp text_mime?("text/" <> _), do: true
  defp text_mime?("application/json"), do: true
  defp text_mime?("application/xml"), do: true
  defp text_mime?(_), do: false

  defp safe_text(body) do
    case :unicode.characters_to_binary(body, :utf8, :utf8) do
      out when is_binary(out) -> out
      _ -> Base.encode64(body)
    end
  end
end
