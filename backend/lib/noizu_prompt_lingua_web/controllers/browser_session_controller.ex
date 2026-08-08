defmodule NoizuPromptLinguaWeb.BrowserSessionController do
  use NoizuPromptLinguaWeb, :controller

  @moduledoc """
  One-liner launcher for the local browser controller.

      curl -fsSL https://tobor.locker/browser-sessions | bash

  `install/2` returns a self-contained bash script (with this deployment's host
  baked in) that downloads + builds the controller into `~/.noizu/browser-controller`
  on first run (cached thereafter) and launches it. The controller prompts for an
  MCP API key on boot (copy/paste from the web UI) and exchanges it via
  `bootstrap/2` for a short-lived MCP JWT plus the caller's organization id.
  """

  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.Organizations

  @archive_path "/api/v1/config/browser-controller/download"

  @doc "Serve the bash launcher (text/x-shellscript) for `curl … | bash`."
  def install(conn, _params) do
    host = request_host(conn)

    conn
    |> put_resp_content_type("text/x-shellscript")
    |> send_resp(200, render_script(host))
  end

  @doc """
  Exchange a raw MCP API key for a short-lived MCP JWT, the caller's primary
  organization id, and the cloud socket URL. Unauthenticated (possession of the
  raw key is the credential); rate-limited at the router.
  """
  def bootstrap(conn, %{"key" => raw_key}) when is_binary(raw_key) and raw_key != "" do
    case MCPApiKeys.verify_api_key(raw_key) do
      nil ->
        conn |> put_status(:unauthorized) |> json(%{error: "invalid or expired API key"})

      api_key ->
        user = %{id: api_key.user_id, email: api_key.user.email, name: api_key.user.user_name}
        {:ok, token, expires_at} = NoizuPromptLingua.Token.mint(user, api_key)

        case Organizations.list_user_organizations(api_key.user_id) do
          [%{id: org_id} | _] ->
            json(conn, %{
              token: token,
              org_id: org_id,
              url: "wss://#{request_host(conn)}/socket",
              expires_at: DateTime.to_iso8601(expires_at)
            })

          _ ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: "no organization is associated with this key"})
        end
    end
  end

  def bootstrap(conn, _params) do
    conn |> put_status(:bad_request) |> json(%{error: "key required"})
  end

  # ── helpers ──────────────────────────────────────────────────────────────

  defp request_host(conn) do
    case conn.host do
      h when is_binary(h) and h != "" ->
        h

      _ ->
        Application.get_env(:noizu_prompt_lingua, :frontend_url)
        |> host_from_url()
        |> Kernel.||("tobor.locker")
    end
  end

  defp host_from_url(nil), do: nil

  defp host_from_url(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{host: h} when is_binary(h) and h != "" -> h
      _ -> nil
    end
  end

  defp render_script(host) do
    api = "https://#{host}"
    socket = "wss://#{host}/socket"

    """
    #!/usr/bin/env bash
    # Noizu browser-controller launcher. Installs + builds on first run (cached in
    # ~/.noizu/browser-controller), then launches. The controller prompts for your
    # MCP API key on boot — copy it from the web UI and paste when asked.
    set -euo pipefail

    API="#{api}"
    BASE="${NOIZU_BROWSER_HOME:-$HOME/.noizu}"
    DIR="$BASE/browser-controller"

    if [ ! -f "$DIR/dist/index.js" ]; then
      echo "[noizu] installing browser controller into $DIR ..." >&2
      mkdir -p "$BASE"
      tmp="$(mktemp 2>/dev/null || echo /tmp/noizu-browser.tar.gz)"
      curl -fsSL "$API#{@archive_path}" -o "$tmp"
      tar -xzf "$tmp" -C "$BASE"
      rm -f "$tmp"
      ( cd "$DIR" && npm install && npm run build )
    fi

    export BROWSER_CONTROLLER_API="$API"
    export BROWSER_CONTROLLER_URL="${BROWSER_CONTROLLER_URL:-#{socket}}"
    cd "$DIR"
    # Read the API-key prompt from the terminal even when this script is piped
    # in via `curl … | bash` (stdin is the pipe, so reattach /dev/tty).
    if [ -r /dev/tty ]; then
      exec node dist/index.js "$@" < /dev/tty
    else
      exec node dist/index.js "$@"
    fi
    """
  end
end
