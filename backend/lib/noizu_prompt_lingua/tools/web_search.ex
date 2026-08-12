defmodule NoizuPromptLingua.Tools.WebSearch do
  @moduledoc """
  Web-search tool for trusted backend callers.

  Default provider is Jina (s.jina.ai). Returns a list of result maps with
  `:url`, `:title`, and `:snippet` keys. When `JINA_API_KEY` is unset, returns
  `{:error, :not_configured}` so the caller can surface a 503.

  # TODO: Add additional providers (Brave, Google CSE, SearXNG) behind the
  # `:web_search_provider` config key.
  """

  @default_limit 5
  @max_limit 20

  @doc """
  Search the web for `query`.

  ## Options
    * `:limit` — max results (default 5, clamped to 20)
    * `:provider` — `:jina` (default) — overrides `:web_search_provider` app env

  ## Returns
    * `{:ok, [%{url: String.t(), title: String.t(), snippet: String.t()}]}`
    * `{:error, :not_configured}` — provider key missing
    * `{:error, reason}` — upstream failure / timeout
  """
  def search(query, opts \\ [])

  def search(query, _opts) when not is_binary(query) or query == "" do
    {:error, :invalid_query}
  end

  def search(query, opts) do
    limit = opts |> Keyword.get(:limit, @default_limit) |> min(@max_limit) |> max(1)
    provider = opts[:provider] || Application.get_env(:noizu_prompt_lingua, :web_search_provider, :jina)

    do_search(provider, query, limit)
  end

  # ── Jina s.jina.ai ───────────────────────────────────────────────

  defp do_search(:jina, query, limit) do
    jina_key = System.get_env("JINA_API_KEY")

    if jina_key == nil or jina_key == "" do
      {:error, :not_configured}
    else
      jina_search(query, jina_key, limit)
    end
  end

  defp do_search(_provider, _query, _limit) do
    {:error, :unknown_provider}
  end

  defp jina_search(query, jina_key, limit) do
    url = "https://s.jina.ai/" <> URI.encode(query)

    headers = [
      {"accept", "application/json"},
      {"authorization", "Bearer #{jina_key}"},
      {"x-return-format", "text"}
    ]

    case Req.get(url, headers: headers, receive_timeout: 15_000, redirect: true) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        results = parse_jina_results(body, limit)
        {:ok, results}

      {:ok, %{status: status}} ->
        {:error, "Jina search returned HTTP #{status}"}

      {:error, %{reason: reason}} ->
        {:error, reason}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Jina s.jina.ai returns JSON with a "data" array of result objects.
  # Each result has :title, :url, and :content/description fields.
  defp parse_jina_results(body, limit) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, %{"data" => items} = _response} when is_list(items) ->
        items
        |> Enum.take(limit)
        |> Enum.map(fn item ->
          %{
            url: item["url"] || "",
            title: item["title"] || "",
            snippet: extract_snippet(item)
          }
        end)

      {:ok, _other} ->
        # Some Jina responses may not have "data" — fall back to empty.
        []

      {:error, _decode_error} ->
        []
    end
  end

  defp parse_jina_results(_body, _limit), do: []

  defp extract_snippet(item) do
    # Jina returns :content (full text) — truncate for a snippet.
    content = item["content"] || item["description"] || ""
    snippet = String.slice(content, 0, 300)
    if byte_size(content) > 300, do: snippet <> "...", else: snippet
  end
end
