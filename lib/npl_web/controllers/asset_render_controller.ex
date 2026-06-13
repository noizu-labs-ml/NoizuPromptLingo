defmodule NPLWeb.AssetRenderController do
  use NPLWeb, :controller

  alias NoizuPromptLingua.Domains.Assets

  @type_to_mime %{
    "image" => "image/png",
    "svg" => "image/svg+xml",
    "video" => "video/mp4",
    "music" => "audio/mpeg",
    "voice" => "audio/mpeg",
    "component" => "text/html",
    "html" => "text/html",
    "diagram" => "image/svg+xml",
    "document" => "text/plain",
    "style_guide" => "text/html"
  }

  def show(conn, %{"project_slug" => project_slug, "asset_slug" => asset_slug}) do
    case Assets.get_by_project_slug(project_slug, asset_slug) do
      nil ->
        send_placeholder(conn, "not_found")
      entry ->
        serve_active_output(conn, entry)
    end
  end

  defp serve_active_output(conn, %{active_output_id: nil} = entry) do
    send_placeholder(conn, entry.status)
  end

  defp serve_active_output(conn, entry) do
    case NoizuPromptLingua.Repo.get(NoizuPromptLingua.Schema.AssetOutput, entry.active_output_id) do
      nil -> send_placeholder(conn, "not_generated")
      output -> serve_artifact_content(conn, entry, output)
    end
  end

  defp serve_artifact_content(conn, entry, output) do
    case NoizuPromptLingua.Domains.Artifacts.get(output.artifact_id) do
      {_artifact, nil} -> send_placeholder(conn, "not_generated")
      nil -> send_placeholder(conn, "not_found")
      {artifact, revision} ->
        mime = artifact.mime_type || Map.get(@type_to_mime, entry.asset_type, "application/octet-stream")
        conn
        |> put_resp_content_type(mime)
        |> put_resp_header("x-asset-slug", entry.slug)
        |> put_resp_header("x-asset-variant", to_string(output.variant_number))
        |> put_resp_header("x-asset-status", entry.status)
        |> send_resp(200, revision.content || "")
    end
  end

  defp send_placeholder(conn, status) do
    body = placeholder_svg(status)
    conn
    |> put_resp_content_type("image/svg+xml")
    |> put_resp_header("x-asset-status", status)
    |> put_resp_header("cache-control", "no-cache")
    |> send_resp(placeholder_http_status(status), body)
  end

  defp placeholder_http_status("not_found"), do: 404
  defp placeholder_http_status(_), do: 202

  defp placeholder_svg(status) do
    label = status_label(status)
    ~s(<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="400" height="300" viewBox="0 0 400 300">
  <rect width="400" height="300" fill="#18181b" rx="8"/>
  <text x="200" y="140" text-anchor="middle" font-family="system-ui,sans-serif" font-size="16" fill="#71717a">#{label}</text>
  <text x="200" y="170" text-anchor="middle" font-family="system-ui,sans-serif" font-size="12" fill="#52525b">#{status}</text>
</svg>)
  end

  defp status_label("not_found"), do: "Asset Not Found"
  defp status_label("draft"), do: "Not Yet Generated"
  defp status_label("generating"), do: "Generating..."
  defp status_label("not_generated"), do: "No Active Output"
  defp status_label(_), do: "Unavailable"
end
