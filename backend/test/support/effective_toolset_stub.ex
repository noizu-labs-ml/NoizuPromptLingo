defmodule NoizuPromptLingua.MCP.EffectiveToolsetStub do
  @moduledoc """
  Test double for the EffectiveToolset seam (TOBOR-CONTRACTS.md §2) — W5 builds
  against the behaviour while feat/effective-toolset lands in parallel.

  Backed by process-local state so tests script per-client variance:

      EffectiveToolsetStub.set(%{
        "Session_Create" => %{enabled: false},
        "Ticket_List" => %{visible: false, expires_at: ~U[2030-01-01 00:00:00Z]}
      })
  """

  @behaviour NoizuPromptLingua.MCP.EffectiveToolset.Behaviour

  @impl true
  def resolve(scope, client, user_ref, _at) do
    Process.put(:effective_toolset_stub_last_scope, scope)
    Process.put(:effective_toolset_stub_last_client, client)
    Process.put(:effective_toolset_stub_last_user, user_ref)
    Process.get(:effective_toolset_stub_states, %{})
  end

  def set(states) when is_map(states), do: Process.put(:effective_toolset_stub_states, states)
  def reset, do: Process.delete(:effective_toolset_stub_states)

  def last_client, do: Process.get(:effective_toolset_stub_last_client)
  def last_scope, do: Process.get(:effective_toolset_stub_last_scope)
  def last_user, do: Process.get(:effective_toolset_stub_last_user)
end
