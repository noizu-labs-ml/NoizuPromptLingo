defmodule NoizuPromptLinguaWeb.Plugs.McpHostRedirect do
  @moduledoc """
  Browser hits on MCP subdomains (wiki.tobor.locker, tickets.*, …) used to
  serve the Next SPA. Cookies are origin-scoped, so the user appeared logged
  out and /login on that host could not finish OIDC.

  MCP paths stay on the subdomain; everything else goes to the apex app.
  """
  import Plug.Conn

  @skip_prefixes [
    "/mcp",
    "/sse",
    "/.well-known",
    "/assets",
    "/health",
    "/socket",
    "/oauth",
    "/custom",
    "/api",
    "/browser-sessions"
  ]

  def init(opts), do: opts

  def call(conn, _opts) do
    host = conn.host || ""

    if mcp_subdomain?(host) and not skip?(conn.request_path) do
      target = "https://#{apex_host()}#{conn.request_path}"
      target = if conn.query_string in [nil, ""], do: target, else: target <> "?" <> conn.query_string

      conn
      |> put_resp_header("cache-control", "private, no-store, max-age=0")
      |> Phoenix.Controller.redirect(external: target)
      |> halt()
    else
      conn
    end
  end

  defp skip?(path) do
    Enum.any?(@skip_prefixes, fn prefix -> path == prefix or String.starts_with?(path, prefix <> "/") end)
  end

  defp mcp_subdomain?(host) do
    Enum.any?(NoizuPromptLingua.MCPServers.customizable(), fn %{id: id} ->
      String.starts_with?(host, id <> ".")
    end)
  end

  defp apex_host do
    System.get_env("PHX_HOST") ||
      case Application.get_env(:noizu_prompt_lingua, NoizuPromptLinguaWeb.Endpoint) do
        url when is_list(url) -> get_in(url, [:url, :host])
        %{url: %{host: host}} when is_binary(host) -> host
        _ -> nil
      end || "tobor.locker"
  end
end
