defmodule HttpKitchenSink.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # MCP server runtime (registry, sessions, event store) — no transport
      # child here; the HTTP plug below drives sessions per connection.
      HttpKitchenSink.MCP,
      {Bandit, plug: HttpKitchenSink.Router, port: 4040}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: HttpKitchenSink.Supervisor)
  end
end
