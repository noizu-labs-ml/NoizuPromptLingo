defmodule AgentClient.Handler do
  @moduledoc """
  Answers server-initiated MCP traffic. Implementing `handle_elicitation/2`
  advertises the `elicitation` capability to the server, so server tools may
  call `Noizu.MCP.Ctx.elicit/4` against us mid-call.

  This demo auto-accepts: it prints the question to stderr and answers `true`
  for every requested boolean field (swap in `IO.gets/1` for a real
  terminal prompt). Notifications from the server are mirrored to stderr.
  """

  @behaviour Noizu.MCP.Client.Handler

  @impl true
  def handle_elicitation(params, _state) do
    message = params["message"] || "(no message)"
    properties = get_in(params, ["requestedSchema", "properties"]) || %{}

    IO.puts(:stderr, "[elicitation] server asks: #{message} -> auto-accepting")

    content =
      Map.new(properties, fn {key, schema} ->
        {key, default_answer(schema["type"])}
      end)

    {:ok, :accept, content}
  end

  @impl true
  def handle_notification(method, params, _state) do
    IO.puts(:stderr, "[notification] #{method} #{inspect(params)}")
    :ok
  end

  defp default_answer("boolean"), do: true
  defp default_answer("number"), do: 0
  defp default_answer("integer"), do: 0
  defp default_answer(_other), do: "ok"
end
