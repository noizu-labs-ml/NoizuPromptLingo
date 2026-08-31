defmodule NoizuPromptLingua.TRP.Client do
  @moduledoc """
  Low-level TRP shared-key HTTP client (docs/api/shared-key-api.md §1).

  - `Authorization: Bearer <raw key>` — raw key, no JWT dance.
  - Bounded timeouts; retries 5xx (and honors 429 `retry_after` once).
  - Typed errors: `{:error, %NoizuPromptLingua.TRP.Error{}}` for every spec
    status; `{:error, :trp_not_configured}` when base URL / key are missing;
    `{:error, {:transport, reason}}` when TRP is unreachable.
  """

  require Logger

  @retries 2
  @backoff_ms 250

  alias NoizuPromptLingua.TRP.{Config, Error}

  @doc """
  Perform a request. `path` is spec-relative, e.g. `"/api/v1/organizations"`.

  Opts: `query` (keyword/string map), `json` (request body), `timeout_ms`.

  Returns `{:ok, decoded_body | nil}` — status is folded into the shape of the
  result (204 → `{:ok, nil}`) — or `{:error, term()}`.
  """
  def request(method, path, opts \\ []) do
    if Config.configured?() do
      headers = [
        {"authorization", "Bearer " <> Config.shared_key()},
        {"accept", "application/json"}
      ]

      url = build_url(path, opts[:query])
      transport = transport()

      do_request(transport, method, url, headers, opts[:json], attempts_left: @retries + 1)
    else
      # Activation-gated: missing TRP_API_BASE_URL / TRP_SHARED_KEY fails at
      # call time, never at boot.
      {:error, :trp_not_configured}
    end
  end

  # --- internals ----------------------------------------------------------

  defp do_request(transport, method, url, headers, body, attempts_left: 0) do
    # Exhausted retries — surface the last raw failure path.
    raw(transport, method, url, headers, body)
  end

  defp do_request(transport, method, url, headers, body, attempts_left: n) do
    case raw(transport, method, url, headers, body) do
      {:error, %Error{status: 429, retry_after: after_s}} = err ->
        if is_integer(after_s) and after_s >= 0 and after_s <= 30 do
          if after_s > 0, do: Process.sleep(after_s * 1000)

          Logger.warning("TRP rate-limited; retrying once after #{after_s}s")
          do_request(transport, method, url, headers, body, attempts_left: n - 1)
        else
          err
        end

      {:error, %Error{status: status}} when status >= 500 and n > 1 ->
        jitter = :rand.uniform(@backoff_ms)
        Process.sleep(@backoff_ms * (@retries + 1 - n) + jitter)
        do_request(transport, method, url, headers, body, attempts_left: n - 1)

      other ->
        other
    end
  end

  defp raw(transport, method, url, headers, body) do
    case transport.request(method, Config.base_url(), url, headers, body, []) do
      {:ok, status, raw_body} ->
        handle_status(status, raw_body)

      {:error, reason} ->
        Logger.error("TRP transport error: #{inspect(reason)}")
        {:error, {:transport, reason}}
    end
  end

  defp handle_status(status, raw_body) when status in 200..299 do
    case decode(raw_body) do
      nil -> {:ok, nil}
      decoded -> {:ok, decoded}
    end
  end

  defp handle_status(status, raw_body) do
    {:error, Error.from_response(status, decode(raw_body))}
  end

  defp decode(nil), do: nil
  defp decode(""), do: nil
  defp decode(" "), do: nil

  defp decode(body) when is_binary(body) do
    case Jason.decode(body, keys: :atoms!) do
      {:ok, decoded} -> decoded
      _ -> nil
    end
  end

  defp decode(decoded) when is_map(decoded) or is_list(decoded), do: decoded

  defp build_url(path, nil), do: path

  defp build_url(path, query) do
    query
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> case do
      [] -> path
      pairs -> path <> "?" <> URI.encode_query(normalize_query(pairs))
    end
  end

  defp normalize_query(pairs) do
    Enum.map(pairs, fn {k, v} ->
      {to_string(k), if(is_binary(v), do: v, else: to_string(v))}
    end)
  end

  defp transport do
    Application.get_env(
      :noizu_prompt_lingua,
      :trp_transport,
      NoizuPromptLingua.TRP.Transport.Req
    )
  end
end
