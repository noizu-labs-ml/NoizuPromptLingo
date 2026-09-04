defmodule NoizuPromptLinguaWeb.BrowserChannel do
  @moduledoc """
  Relay channel for the user's local browser controller.

  A local controller (Node + Playwright) connects to `UserSocket` with an MCP
  JWT and joins `browser:<org_id>`. The cloud `Browser.*` MCP tools dispatch
  commands through `NoizuPromptLingua.Domains.Browser.Relay`, which pushes a
  `command` event to this channel; the controller executes it and replies with
  `command_result`, which we hand back to the blocked tool via `Relay.reply/2`.

  Authorization: the socket has already verified the controller's MCP JWT and
  assigned `:user_id`; joining additionally requires the user to be an
  `editor` of the target organization.

  v1 supports a single controller per org topic. If two controllers join the
  same org, the later registration wins (commands route to the newest); a
  future revision could fan out to per-session topics.
  """

  use Phoenix.Channel

  alias NoizuPromptLingua.Domains.Browser.Relay

  @impl true
  def join("browser:" <> org_id, _params, socket) do
    user_id = socket.assigns.user_id

    # Same floor as the tunnel CRUD gate: the scoped-membership ladder has no
    # "editor" rung, so "editor" cleared ANY membership (ticket 1bd065df).
    # Browser-relay operators are ≥ member.
    case NoizuPromptLingua.Organizations.authorize(user_id, org_id, "member") do
      {:ok, _membership} ->
        :ok = Relay.register(org_id, self())
        {:ok, assign(socket, :org_id, org_id)}

      {:error, _} ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  # Relay → controller: forward a queued command over the wire.
  @impl true
  def handle_info({:browser_command, command}, socket) do
    push(socket, "command", command)
    {:noreply, socket}
  end

  # controller → Relay: a finished command result, correlated by request_id.
  @impl true
  def handle_in("command_result", %{"request_id" => request_id} = payload, socket) do
    result =
      case payload do
        %{"ok" => true, "data" => data} -> {:ok, data}
        %{"ok" => false, "error" => error} -> {:error, error}
        _ -> {:error, "malformed command_result"}
      end

    Relay.reply(request_id, result)
    {:reply, :ok, socket}
  end

  def handle_in("ping", _payload, socket) do
    {:reply, {:ok, %{message: "pong"}}, socket}
  end
end
