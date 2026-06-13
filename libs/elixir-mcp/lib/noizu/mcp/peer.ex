defmodule Noizu.MCP.Peer do
  @moduledoc """
  Sans-IO MCP session core, shared by server sessions and client connections.

  Both ends of MCP are symmetric JSON-RPC peers; this module models one end as a
  pure state machine. The owning process feeds decoded `Noizu.MCP.JsonRpc`
  messages through `ingest/2` and interprets the returned **effects** — `Peer`
  itself never touches a socket or process.

  Effects:

    * `{:send, message}` — encode and write `message` to the transport
    * `{:dispatch, method, id, params}` — an inbound request for the feature layer
    * `{:notice, method, params}` — an inbound notification for the feature layer
    * `{:resolve, tag, id, result}` — an outbound request completed
      (`result :: {:ok, map} | {:error, Noizu.MCP.Error.t()}`)
    * `{:cancel_in, id, reason}` — the remote cancelled a request we are processing
    * `{:progress, tag, id, params}` — progress for one of our outbound requests
    * `{:ready, remote_info}` — handshake complete, normal traffic may flow
    * `{:initialize_result, result}` — (client) the initialize response arrived;
      follow with `initialized/1`
    * `{:initialize_failed, reason}` — (client) the server negotiated an
      unsupported version
  """

  alias Noizu.MCP.{Error, JsonRpc}
  alias Noizu.MCP.JsonRpc.{ErrorResponse, Notification, Request, Response}
  alias Noizu.MCP.Protocol.{Methods, Version}
  alias Noizu.MCP.Types.Implementation

  @type role :: :server | :client
  @type phase :: :handshake | :initializing | :ready | :closing
  @type tag :: term()
  @type effect :: tuple()

  @type t :: %__MODULE__{
          role: role(),
          phase: phase(),
          protocol_version: String.t() | nil,
          local_info: Implementation.t(),
          local_capabilities: map(),
          instructions: String.t() | nil,
          remote_info: Implementation.t() | nil,
          remote_capabilities: map() | nil,
          next_id: pos_integer(),
          pending_out: %{optional(JsonRpc.id()) => map()},
          pending_in: %{optional(JsonRpc.id()) => String.t()},
          cancelled_in: MapSet.t(),
          progress_index: %{optional(term()) => JsonRpc.id()}
        }

  @enforce_keys [:role, :local_info]
  defstruct role: :server,
            phase: :handshake,
            protocol_version: nil,
            local_info: nil,
            local_capabilities: %{},
            instructions: nil,
            remote_info: nil,
            remote_capabilities: nil,
            next_id: 1,
            pending_out: %{},
            pending_in: %{},
            cancelled_in: MapSet.new(),
            progress_index: %{}

  @doc """
  Build a new peer.

  Options: `:role` (`:server` | `:client`, required), `:info`
  (`Noizu.MCP.Types.Implementation`, required), `:capabilities` (wire-format
  map), `:instructions` (server only).
  """
  @spec new(keyword()) :: t()
  def new(opts) do
    %__MODULE__{
      role: Keyword.fetch!(opts, :role),
      local_info: Keyword.fetch!(opts, :info),
      local_capabilities: Keyword.get(opts, :capabilities, %{}),
      instructions: Keyword.get(opts, :instructions)
    }
  end

  # ── Outbound ──────────────────────────────────────────────────────────────

  @doc """
  Issue an outbound request. Returns the assigned id and the request struct to
  send. `opts`: `:tag` (returned in the `:resolve` effect), `:progress_token`
  (adds `_meta.progressToken` and routes inbound progress notifications).
  """
  @spec request(t(), String.t(), map() | nil, keyword()) :: {t(), JsonRpc.id(), Request.t()}
  def request(%__MODULE__{} = peer, method, params, opts \\ []) do
    id = peer.next_id
    tag = Keyword.get(opts, :tag, id)
    progress_token = Keyword.get(opts, :progress_token)

    params =
      if progress_token do
        Map.update(params || %{}, "_meta", %{"progressToken" => progress_token}, fn meta ->
          Map.put(meta, "progressToken", progress_token)
        end)
      else
        params
      end

    pending = %{tag: tag, method: method, progress_token: progress_token}

    peer = %{
      peer
      | next_id: id + 1,
        pending_out: Map.put(peer.pending_out, id, pending),
        progress_index:
          if(progress_token,
            do: Map.put(peer.progress_index, progress_token, id),
            else: peer.progress_index
          )
    }

    {peer, id, %Request{id: id, method: method, params: params}}
  end

  @doc "Build a notification struct (stateless helper)."
  @spec notification(String.t(), map() | nil) :: Notification.t()
  def notification(method, params \\ nil), do: %Notification{method: method, params: params}

  @doc """
  Respond to an inbound request. Returns `:drop` when the request was cancelled
  by the remote (the spec forbids responding after cancellation).
  """
  @spec respond(t(), JsonRpc.id(), map()) :: {t(), {:ok, Response.t()} | :drop}
  def respond(%__MODULE__{} = peer, id, result) when is_map(result) do
    finish_inbound(peer, id, fn -> %Response{id: id, result: result} end)
  end

  @doc "Respond to an inbound request with a protocol error. See `respond/3`."
  @spec respond_error(t(), JsonRpc.id(), Error.t()) :: {t(), {:ok, ErrorResponse.t()} | :drop}
  def respond_error(%__MODULE__{} = peer, id, %Error{} = error) do
    finish_inbound(peer, id, fn -> %ErrorResponse{id: id, error: error} end)
  end

  defp finish_inbound(peer, id, build) do
    cond do
      MapSet.member?(peer.cancelled_in, id) ->
        {%{peer | cancelled_in: MapSet.delete(peer.cancelled_in, id)}, :drop}

      Map.has_key?(peer.pending_in, id) ->
        {%{peer | pending_in: Map.delete(peer.pending_in, id)}, {:ok, build.()}}

      true ->
        # Already answered (or never tracked) — don't answer twice.
        {peer, :drop}
    end
  end

  @doc """
  Abandon an outbound request and build the `notifications/cancelled` to send.
  Any late response for it is silently ignored. Returns the abandoned
  request's tag (or `nil` if the id was unknown).
  """
  @spec cancel_out(t(), JsonRpc.id(), String.t() | nil) ::
          {t(), Notification.t() | nil, tag() | nil}
  def cancel_out(%__MODULE__{} = peer, id, reason \\ nil) do
    case Map.pop(peer.pending_out, id) do
      {nil, _} ->
        {peer, nil, nil}

      {entry, pending_out} ->
        params =
          %{"requestId" => id}
          |> then(&if reason, do: Map.put(&1, "reason", reason), else: &1)

        peer = %{
          peer
          | pending_out: pending_out,
            progress_index: Map.delete(peer.progress_index, entry.progress_token)
        }

        {peer, %Notification{method: "notifications/cancelled", params: params}, entry.tag}
    end
  end

  # ── Client handshake ──────────────────────────────────────────────────────

  @doc "(client) Build the `initialize` request."
  @spec init_request(t()) :: {t(), Request.t()}
  def init_request(%__MODULE__{role: :client, phase: :handshake} = peer) do
    params = %{
      "protocolVersion" => Version.latest(),
      "capabilities" => peer.local_capabilities,
      "clientInfo" => Implementation.to_map(peer.local_info)
    }

    {peer, _id, request} = request(peer, "initialize", params, tag: :__initialize__)
    {%{peer | phase: :initializing}, request}
  end

  @doc "(client) Complete the handshake: build `notifications/initialized`."
  @spec initialized(t()) :: {t(), Notification.t(), [effect()]}
  def initialized(%__MODULE__{role: :client, phase: :initializing} = peer) do
    peer = %{peer | phase: :ready}

    {peer, %Notification{method: "notifications/initialized"}, [{:ready, peer.remote_info}]}
  end

  # ── Ingest ────────────────────────────────────────────────────────────────

  @doc "Process one decoded inbound message; returns `{peer, effects}`."
  @spec ingest(t(), JsonRpc.message()) :: {t(), [effect()]}
  def ingest(peer, message)

  # initialize (server)
  def ingest(%__MODULE__{role: :server} = peer, %Request{method: "initialize"} = req) do
    case peer.phase do
      :handshake ->
        params = req.params || %{}
        negotiated = Version.negotiate(params["protocolVersion"])

        result =
          %{
            "protocolVersion" => negotiated,
            "capabilities" => peer.local_capabilities,
            "serverInfo" => Implementation.to_map(peer.local_info)
          }
          |> then(fn map ->
            if peer.instructions, do: Map.put(map, "instructions", peer.instructions), else: map
          end)

        peer = %{
          peer
          | phase: :initializing,
            protocol_version: negotiated,
            remote_info: Implementation.from_map(params["clientInfo"] || %{}),
            remote_capabilities: params["capabilities"] || %{}
        }

        {peer, [{:send, %Response{id: req.id, result: result}}]}

      _ ->
        {peer,
         [
           {:send,
            %ErrorResponse{id: req.id, error: Error.invalid_request("Already initialized")}}
         ]}
    end
  end

  def ingest(%__MODULE__{role: :server, phase: :initializing} = peer, %Notification{
        method: "notifications/initialized"
      }) do
    peer = %{peer | phase: :ready}
    {peer, [{:ready, peer.remote_info}]}
  end

  # ping — auto-answered in any phase, either role
  def ingest(%__MODULE__{} = peer, %Request{method: "ping", id: id}) do
    {peer, [{:send, %Response{id: id, result: %{}}}]}
  end

  def ingest(%__MODULE__{} = peer, %Notification{method: "notifications/cancelled"} = note) do
    id = (note.params || %{})["requestId"]
    reason = (note.params || %{})["reason"]

    if Map.has_key?(peer.pending_in, id) do
      peer = %{
        peer
        | pending_in: Map.delete(peer.pending_in, id),
          cancelled_in: MapSet.put(peer.cancelled_in, id)
      }

      {peer, [{:cancel_in, id, reason}]}
    else
      {peer, []}
    end
  end

  def ingest(%__MODULE__{} = peer, %Notification{method: "notifications/progress"} = note) do
    token = (note.params || %{})["progressToken"]

    case Map.fetch(peer.progress_index, token) do
      {:ok, id} ->
        case Map.fetch(peer.pending_out, id) do
          {:ok, entry} -> {peer, [{:progress, entry.tag, id, note.params}]}
          :error -> {peer, []}
        end

      :error ->
        {peer, []}
    end
  end

  def ingest(%__MODULE__{} = peer, %Notification{method: method, params: params}) do
    # Unknown or wrong-direction notifications are ignored per spec.
    if Methods.receivable?(method, peer.role) do
      {peer, [{:notice, method, params}]}
    else
      {peer, []}
    end
  end

  def ingest(%__MODULE__{} = peer, %Request{} = req) do
    cond do
      peer.phase != :ready ->
        {peer,
         [
           {:send,
            %ErrorResponse{
              id: req.id,
              error: Error.invalid_request("Session not initialized")
            }}
         ]}

      not Methods.receivable?(req.method, peer.role) ->
        {peer, [{:send, %ErrorResponse{id: req.id, error: Error.method_not_found(req.method)}}]}

      Map.has_key?(peer.pending_in, req.id) ->
        {peer,
         [
           {:send,
            %ErrorResponse{
              id: req.id,
              error: Error.invalid_request("Duplicate in-flight request id")
            }}
         ]}

      true ->
        peer = %{peer | pending_in: Map.put(peer.pending_in, req.id, req.method)}
        {peer, [{:dispatch, req.method, req.id, req.params}]}
    end
  end

  def ingest(%__MODULE__{} = peer, %Response{id: id, result: result}) do
    resolve_out(peer, id, {:ok, result})
  end

  def ingest(%__MODULE__{} = peer, %ErrorResponse{id: id, error: error}) do
    resolve_out(peer, id, {:error, error})
  end

  defp resolve_out(peer, id, outcome) do
    case Map.pop(peer.pending_out, id) do
      {nil, _} ->
        # Late response to a cancelled/timed-out request — ignore.
        {peer, []}

      {%{tag: :__initialize__}, pending_out} ->
        peer = %{peer | pending_out: pending_out}
        client_initialize_outcome(peer, outcome)

      {entry, pending_out} ->
        peer = %{
          peer
          | pending_out: pending_out,
            progress_index: Map.delete(peer.progress_index, entry.progress_token)
        }

        {peer, [{:resolve, entry.tag, id, outcome}]}
    end
  end

  defp client_initialize_outcome(peer, {:ok, result}) do
    version = result["protocolVersion"]

    if Version.supported?(version) do
      peer = %{
        peer
        | protocol_version: version,
          remote_info: Implementation.from_map(result["serverInfo"] || %{}),
          remote_capabilities: result["capabilities"] || %{}
      }

      {peer, [{:initialize_result, result}]}
    else
      {%{peer | phase: :closing}, [{:initialize_failed, {:unsupported_version, version}}]}
    end
  end

  defp client_initialize_outcome(peer, {:error, error}) do
    {%{peer | phase: :closing}, [{:initialize_failed, {:error, error}}]}
  end
end
