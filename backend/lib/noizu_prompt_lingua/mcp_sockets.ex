defmodule NoizuPromptLingua.MCPSockets do
  @moduledoc """
  Catalog of websocket channels (Phoenix `UserSocket` topics) advertised to MCP
  clients. Single source of truth shared by the auth/mcp config endpoint
  (`/api/v1/auth/mcp/config`) and per-domain `*_Overview` tool responses, so a
  client can discover which live sockets a domain exposes.

  All channels are served by `NoizuPromptLinguaWeb.UserSocket` at the single
  endpoint `wss://<host>/socket`; each entry's `topic_pattern` selects the
  channel within that socket (e.g. `org:<org_id>`).

  No channels are advertised yet — `@sockets` is empty. A websocket alternative
  to `Notifications.Get` will be the first entry, e.g.:

      %{
        id: "notifications",
        domain: "notifications",
        topic_pattern: "notifications:<org_id>",
        description: "Live push alternative to Notifications.Get",
        events: ["notification"]
      }

  Keep `:domain` aligned with the public server ids in
  `NoizuPromptLingua.MCPServers` so `for_domain/1`/`overview_section/1` match the
  domain whose `*_Overview` tool should surface the socket.
  """

  # %{id, domain, topic_pattern, description, events}. Empty until the first
  # channel is added (see @moduledoc for the planned notifications entry shape).
  @sockets []

  @doc "All configured sockets (without host-resolved URLs)."
  def all, do: @sockets

  @doc """
  Returns the configured sockets with the full `wss://<host>/socket` URL attached,
  derived from `host` (or the configured `PHX_HOST` when nil). Suitable for JSON
  serialization to clients.
  """
  def for_host(host \\ nil)
  def for_host(nil), do: for_host(default_host())

  def for_host(host) when is_binary(host) do
    url = "wss://#{host}/socket"
    Enum.map(@sockets, &Map.put(&1, :url, url))
  end

  @doc "Host-resolved sockets filtered to a single domain id (e.g. \"notifications\")."
  def for_domain(domain, host \\ nil) when is_binary(domain) do
    host |> for_host() |> Enum.filter(&(&1.domain == domain))
  end

  @doc """
  Convenience for `*_Overview` tools: returns `%{sockets: [...]}` when the domain
  has advertised channels, otherwise `%{}` so the key is omitted from the overview
  response entirely.
  """
  def overview_section(domain, host \\ nil) when is_binary(domain) do
    case for_domain(domain, host) do
      [] -> %{}
      sockets -> %{sockets: sockets}
    end
  end

  # Mirrors NoizuPromptLingua.MCPServers host resolution.
  defp default_host do
    Application.get_env(:noizu_prompt_lingua, NoizuPromptLinguaWeb.Endpoint)
    |> case do
      %{url: %{host: host}} when is_binary(host) and host != "" -> host
      kw when is_list(kw) -> kw |> Keyword.get(:url, []) |> Keyword.get(:host, "localhost")
      _ -> System.get_env("PHX_HOST") || "localhost"
    end
  end
end
