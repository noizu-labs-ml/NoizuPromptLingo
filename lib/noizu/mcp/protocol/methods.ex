defmodule Noizu.MCP.Protocol.Methods do
  @moduledoc """
  Compile-time registry of MCP methods: kind (request/notification) and
  direction (client→server, server→client, or both).
  """

  @type direction :: :client_to_server | :server_to_client | :both
  @type kind :: :request | :notification

  @methods %{
    # lifecycle
    "initialize" => {:request, :client_to_server},
    "notifications/initialized" => {:notification, :client_to_server},
    "ping" => {:request, :both},
    # tools
    "tools/list" => {:request, :client_to_server},
    "tools/call" => {:request, :client_to_server},
    "notifications/tools/list_changed" => {:notification, :server_to_client},
    # resources
    "resources/list" => {:request, :client_to_server},
    "resources/templates/list" => {:request, :client_to_server},
    "resources/read" => {:request, :client_to_server},
    "resources/subscribe" => {:request, :client_to_server},
    "resources/unsubscribe" => {:request, :client_to_server},
    "notifications/resources/list_changed" => {:notification, :server_to_client},
    "notifications/resources/updated" => {:notification, :server_to_client},
    # prompts
    "prompts/list" => {:request, :client_to_server},
    "prompts/get" => {:request, :client_to_server},
    "notifications/prompts/list_changed" => {:notification, :server_to_client},
    # completion
    "completion/complete" => {:request, :client_to_server},
    # logging
    "logging/setLevel" => {:request, :client_to_server},
    "notifications/message" => {:notification, :server_to_client},
    # sampling / elicitation / roots (server-initiated)
    "sampling/createMessage" => {:request, :server_to_client},
    "elicitation/create" => {:request, :server_to_client},
    "roots/list" => {:request, :server_to_client},
    "notifications/roots/list_changed" => {:notification, :client_to_server},
    # utility notifications
    "notifications/cancelled" => {:notification, :both},
    "notifications/progress" => {:notification, :both}
  }

  @spec lookup(String.t()) :: {:ok, {kind(), direction()}} | :error
  def lookup(method), do: Map.fetch(@methods, method)

  @doc "True when `method` may be *received* by a peer in `role`."
  @spec receivable?(String.t(), :server | :client) :: boolean()
  def receivable?(method, role) do
    case Map.fetch(@methods, method) do
      {:ok, {_kind, :both}} -> true
      {:ok, {_kind, :client_to_server}} -> role == :server
      {:ok, {_kind, :server_to_client}} -> role == :client
      :error -> false
    end
  end
end
