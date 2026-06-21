defmodule NoizuPromptLingua.Domains.Browser do
  @moduledoc """
  Cloud-side helpers for the browser-control domain. Resolves the org ref and
  dispatches an action to the user's connected local controller via the
  `Relay`, translating relay errors into tool-friendly `{:error, message}`.
  """

  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.Domains.Browser.Relay

  @no_controller "no local browser controller connected for this organization"

  @doc "True when a controller is connected for the resolved org (or false)."
  def connected?(org_ref) do
    case Resolve.organization_id(org_ref) do
      nil -> false
      org_id -> Relay.connected?(org_id)
    end
  end

  @doc """
  Resolve `org_ref`, then dispatch `{action, params}` to its controller and
  return the controller's `{:ok, data}` / `{:error, message}`.
  """
  def run(org_ref, action, params \\ %{}, timeout \\ 30_000) do
    case Resolve.organization_id(org_ref) do
      nil ->
        {:error, "Organization '#{org_ref}' not found"}

      org_id ->
        command = %{action: action, params: params}

        case Relay.dispatch(org_id, command, timeout) do
          {:ok, data} -> {:ok, data}
          {:error, :no_controller} -> {:error, @no_controller}
          {:error, :timeout} -> {:error, "browser controller timed out after #{timeout}ms"}
          {:error, message} when is_binary(message) -> {:error, message}
          {:error, other} -> {:error, "browser controller error: #{inspect(other)}"}
        end
    end
  end
end
