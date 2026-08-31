defmodule ExLiteLLM.HTTP do
  @moduledoc """
  Shared outbound-HTTP configuration for every upstream call (provider
  adapters, gateway forwarding).

  Centralizes two reliability concerns that showed up in production:

    * **Stale keep-alive connections** — upstreams (notably api.anthropic.com)
      close idle pooled connections server-side; reusing one fails with
      `%Req.TransportError{reason: :closed}`. The dedicated Finch pool caps
      `conn_max_idle_time` well below typical server idle timeouts so stale
      sockets are culled before reuse.
    * **The remaining race window** — a connection can still die between the
      idle check and the write. For **buffered** requests that's safe to retry
      immediately (the request never reached the upstream); streams don't
      retry (a mid-stream duplicate would corrupt client SSE state).
  """

  @finch ExLiteLLM.Finch

  @doc "The Finch child spec for the supervision tree."
  def finch_spec do
    {Finch,
     name: @finch,
     pools: %{
       :default => [
         size: 200,
         count: 1,
         # Cull idle connections after 30s — under any upstream's server-side
         # keep-alive timeout, so we never reuse a socket the server closed.
         conn_max_idle_time: 30_000
       ]
     }}
  end

  @doc "The Finch pool name to pass to Req."
  def finch, do: @finch

  @doc """
  Req options for buffered (non-streaming) upstream calls: shared pool plus an
  immediate retry when the transport was closed under us.

  `compressed: false` on both paths: Req's default step advertises
  accept-encoding (zstd/br/gzip) on outgoing requests, but the gateway relays
  bodies verbatim while stripping `content-encoding` — a compressed upstream
  reply would reach the client as undecodable binary. Plain answers only.
  """
  @spec buffered_opts() :: keyword()
  def buffered_opts do
    [
      finch: @finch,
      compressed: false,
      retry: &retry_closed?/2,
      retry_delay: 0,
      max_retries: 2,
      retry_log_level: :warning
    ]
  end

  @doc "Req options for streaming upstream calls: shared pool, no retry."
  @spec stream_opts() :: keyword()
  def stream_opts do
    [finch: @finch, compressed: false, retry: false]
  end

  # Retry only the stale-connection signature — never response-status errors
  # (those are the caller's to map) and never other transport failures.
  defp retry_closed?(_request, %Req.TransportError{reason: :closed}), do: true
  defp retry_closed?(_request, _response_or_exception), do: false
end
