defmodule NoizuPromptLinguaWeb.ToolsController do
  @moduledoc """
  REST tool endpoints for trusted backend callers (API-key authenticated).

  * `POST /api/v1/tools/web-search` — `{query, limit?}` → `{results: [...]}`
  * `POST /api/v1/tools/site-to-md`  — `{source}` → `{markdown, source, char_count}`
  """
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Tools.WebSearch
  alias NoizuPromptLingua.Domains.Markdown

  # ── POST /api/v1/tools/web-search ────────────────────────────────

  def web_search(conn, params) do
    query = params["query"]
    limit = params["limit"]

    cond do
      not is_binary(query) or String.trim(query) == "" ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "query is required"})

      true ->
        opts = if is_integer(limit), do: [limit: limit], else: []

        case WebSearch.search(query, opts) do
          {:ok, results} ->
            json(conn, %{results: results})

          {:error, :not_configured} ->
            conn
            |> put_status(:service_unavailable)
            |> json(%{error: :not_configured})

          {:error, :invalid_query} ->
            conn
            |> put_status(:bad_request)
            |> json(%{error: "query is required"})

          {:error, reason} ->
            conn
            |> put_status(:bad_gateway)
            |> json(%{error: to_string(reason)})
        end
    end
  end

  # ── POST /api/v1/tools/site-to-md ────────────────────────────────

  def site_to_md(conn, params) do
    source = params["source"]

    cond do
      not is_binary(source) or String.trim(source) == "" ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "source is required"})

      true ->
        # Delegate to the existing Markdown domain converter — do NOT reimplement.
        case Markdown.convert(source, []) do
          {:ok, %{markdown: markdown}} ->
            json(conn, %{
              markdown: markdown,
              source: source,
              char_count: String.length(markdown)
            })

          {:error, reason} ->
            conn
            |> put_status(:bad_gateway)
            |> json(%{error: to_string(reason)})
        end
    end
  end
end
