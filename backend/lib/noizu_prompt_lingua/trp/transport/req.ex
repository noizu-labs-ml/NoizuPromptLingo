defmodule NoizuPromptLingua.TRP.Transport.Req do
  @moduledoc """
  Default TRP transport: `Req` over the `#{inspect(NoizuPromptLingua.TRP.Finch)}` pool.

  Bounded timeouts (connect 5s / receive 15s); retry policy lives in
  `NoizuPromptLingua.TRP.Client`, not here.
  """

  @behaviour NoizuPromptLingua.TRP.Transport

  @impl true
  def request(method, base_url, path, headers, body, opts) do
    req =
      Req.new(
        method: method,
        url: base_url <> path,
        headers: headers,
        finch: NoizuPromptLingua.TRP.Finch,
        connect_options: [timeout: opts[:connect_timeout] || 5_000],
        retry: false
      )

    req =
      case body do
        nil -> req
        b when is_map(b) -> Req.merge(req, json: b)
        b when is_binary(b) -> Req.merge(req, body: b)
      end

    case Req.request(req, receive_timeout: opts[:receive_timeout] || 15_000) do
      {:ok, resp} -> {:ok, resp.status, resp.body}
      {:error, exception} -> {:error, exception}
    end
  end
end
