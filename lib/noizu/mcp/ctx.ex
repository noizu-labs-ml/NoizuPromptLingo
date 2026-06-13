defmodule Noizu.MCP.Ctx do
  @moduledoc """
  Per-request handler context.

  Every server handler receives a `%Noizu.MCP.Ctx{}` carrying session identity,
  the negotiated protocol version, client info/capabilities, and `assigns`. Use
  it to report progress, emit MCP log messages, and check for cooperative
  cancellation.

  Handlers do not return an updated context — handler invocations run
  concurrently per session. `assign/3` is local to the current invocation; use
  `put_session/3` to persist a value into the session's assigns for subsequent
  requests.
  """

  alias Noizu.MCP.Server.Session

  @type t :: %__MODULE__{
          server: module(),
          session: pid() | nil,
          session_id: String.t() | nil,
          request_id: Noizu.MCP.JsonRpc.id() | nil,
          progress_token: term() | nil,
          protocol_version: String.t() | nil,
          client_info: Noizu.MCP.Types.Implementation.t() | nil,
          client_capabilities: map(),
          transport: atom(),
          cancel_flag: :atomics.atomics_ref() | nil,
          assigns: map()
        }

  defstruct [
    :server,
    :session,
    :session_id,
    :request_id,
    :progress_token,
    :protocol_version,
    :client_info,
    :cancel_flag,
    client_capabilities: %{},
    transport: :test,
    assigns: %{}
  ]

  @log_levels [:debug, :info, :notice, :warning, :error, :critical, :alert, :emergency]

  @doc """
  Report progress for the current request. Silently no-ops when the client did
  not send a `progressToken`. Options: `:total`, `:message`.
  """
  @spec report_progress(t(), number(), keyword()) :: :ok
  def report_progress(ctx, progress, opts \\ [])

  def report_progress(%__MODULE__{progress_token: nil}, _progress, _opts), do: :ok

  def report_progress(%__MODULE__{} = ctx, progress, opts) when is_number(progress) do
    Session.notify_progress(ctx.session, ctx.progress_token, ctx.request_id, progress, opts)
  end

  @doc """
  Emit an MCP `notifications/message` log entry to the client, filtered by the
  level the client set via `logging/setLevel`. `data` may be any
  JSON-serializable term. Options: `:logger` (a logical logger name).
  """
  @spec log(t(), atom(), term(), keyword()) :: :ok
  def log(%__MODULE__{} = ctx, level, data, opts \\ []) when level in @log_levels do
    Session.notify_log(ctx.session, level, data, opts[:logger], ctx.request_id)
  end

  for level <- [:debug, :info, :warning, :error] do
    @doc "Emit a `#{level}` MCP log message. See `log/4`."
    @spec unquote(level)(t(), term(), keyword()) :: :ok
    def unquote(level)(ctx, data, opts \\ []), do: log(ctx, unquote(level), data, opts)
  end

  @doc """
  True when the client cancelled the current request.

  By default the runtime kills the handler task on cancellation, so most
  handlers never need this; poll it from handlers that must clean up external
  state at a safe point.
  """
  @spec cancelled?(t()) :: boolean()
  def cancelled?(%__MODULE__{cancel_flag: nil}), do: false
  def cancelled?(%__MODULE__{cancel_flag: flag}), do: :atomics.get(flag, 1) == 1

  # ── server → client requests ───────────────────────────────────────────────

  @doc """
  Ask the client to sample an LLM completion (`sampling/createMessage`).

  `params` is the wire-format map: `"messages"`, `"maxTokens"`, and optionally
  `"systemPrompt"`, `"modelPreferences"`, `"tools"`/`"toolChoice"` (2025-11-25).
  Blocks the calling handler task only. Options: `:timeout` (default 60s).

      {:ok, %{"content" => %{"text" => text}}} =
        Noizu.MCP.Ctx.sample(ctx, %{
          "messages" => [
            %{"role" => "user", "content" => %{"type" => "text", "text" => "Summarize: ..."}}
          ],
          "maxTokens" => 500
        })
  """
  @spec sample(t(), map(), keyword()) :: {:ok, map()} | {:error, term()}
  def sample(%__MODULE__{} = ctx, params, opts \\ []) when is_map(params) do
    server_request(ctx, "sampling", "sampling/createMessage", params, opts)
  end

  @doc """
  Ask the user (via the client) for structured input (`elicitation/create`).

  `requested_schema` is a flat-object JSON Schema map (string keys). Returns
  `{:ok, {:accept, content}}`, `{:ok, :decline}`, or `{:ok, :cancel}`.

      {:ok, {:accept, %{"confirm" => true}}} =
        Noizu.MCP.Ctx.elicit(ctx, "Really delete 14 rows?", %{
          "type" => "object",
          "properties" => %{"confirm" => %{"type" => "boolean"}},
          "required" => ["confirm"]
        })
  """
  @spec elicit(t(), String.t(), map(), keyword()) ::
          {:ok, {:accept, map()} | :decline | :cancel} | {:error, term()}
  def elicit(%__MODULE__{} = ctx, message, requested_schema, opts \\ []) do
    params = %{"message" => message, "requestedSchema" => requested_schema}

    case server_request(ctx, "elicitation", "elicitation/create", params, opts) do
      {:ok, %{"action" => "accept"} = result} -> {:ok, {:accept, result["content"] || %{}}}
      {:ok, %{"action" => "decline"}} -> {:ok, :decline}
      {:ok, %{"action" => "cancel"}} -> {:ok, :cancel}
      {:ok, other} -> {:error, {:invalid_response, other}}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc "Ask the client for its filesystem roots (`roots/list`)."
  @spec list_roots(t(), keyword()) :: {:ok, [Noizu.MCP.Types.Root.t()]} | {:error, term()}
  def list_roots(%__MODULE__{} = ctx, opts \\ []) do
    case server_request(ctx, "roots", "roots/list", nil, opts) do
      {:ok, result} ->
        {:ok, Enum.map(result["roots"] || [], &Noizu.MCP.Types.Root.from_map/1)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp server_request(ctx, capability, method, params, opts) do
    cond do
      ctx.session == self() ->
        # Would deadlock: Ctx server→client calls are for handler tasks, not
        # code running in the session process itself (e.g. init/2).
        {:error, :not_allowed_in_session_process}

      not Map.has_key?(ctx.client_capabilities || %{}, capability) ->
        {:error, :capability_not_supported}

      true ->
        Session.server_request(
          ctx.session,
          method,
          params,
          Keyword.put(opts, :related_request_id, ctx.request_id)
        )
    end
  end

  @doc "Put a value in this invocation's local assigns."
  @spec assign(t(), atom(), term()) :: t()
  def assign(%__MODULE__{} = ctx, key, value) when is_atom(key) do
    %{ctx | assigns: Map.put(ctx.assigns, key, value)}
  end

  @doc """
  Persist a value into the session's assigns so subsequent requests in this
  session observe it. Serialized through the session process (atomic), but
  last-write-wins across concurrently running handlers.
  """
  @spec put_session(t(), atom(), term()) :: :ok
  def put_session(%__MODULE__{} = ctx, key, value) when is_atom(key) do
    Session.put_assign(ctx.session, key, value)
  end
end
