defmodule Noizu.MCP.Inspector.Handler do
  @moduledoc """
  `Noizu.MCP.Client.Handler` for the inspector: server-initiated sampling and
  elicitation requests are parked in the inspector session and surfaced in the
  browser (Pending tab), blocking until a human answers. Roots come from the
  session's editable roots list.
  """

  @behaviour Noizu.MCP.Client.Handler

  alias Noizu.MCP.Inspector.Session

  @impl true
  def handle_sampling(params, session) do
    Session.park_pending(session, :sampling, params)
  end

  @impl true
  def handle_elicitation(params, session) do
    Session.park_pending(session, :elicitation, params)
  end

  @impl true
  def list_roots(session) do
    {:ok, Session.get_roots(session)}
  end
end
