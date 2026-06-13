defmodule Noizu.MCP.Test do
  @moduledoc """
  Test helpers for exercising `Noizu.MCP.Server` modules over an in-memory
  transport — no sockets, `async: true` safe.

      defmodule MyApp.MCPTest do
        use ExUnit.Case, async: true
        import Noizu.MCP.Test

        setup do
          %{client: connect(MyApp.MCP)}
        end

        test "weather tool", %{client: client} do
          assert {:ok, result} = call_tool(client, "get_weather", %{"location" => "NYC"})
          assert [%{type: :text}] = result.content
          assert_progress(client)
        end
      end

  The returned client handle is bound to the calling process: server output is
  delivered to your mailbox and consumed by these helpers. Notifications that
  arrive while awaiting a response are buffered and visible to
  `assert_notification/3` / `assert_progress/2`.
  """

  alias Noizu.MCP.JsonRpc
  alias Noizu.MCP.JsonRpc.{ErrorResponse, Notification, Request, Response}
  alias Noizu.MCP.Server.{Session, Supervisor}
  alias Noizu.MCP.Types.{Tool, ToolResult}

  defmodule Client do
    @moduledoc false
    defstruct [:server, :session, :ref, :counter, :server_info, :capabilities, :instructions]
  end

  @default_timeout 1_000

  @doc """
  Start a session against `server` (a `use Noizu.MCP.Server` module) and run
  the initialize handshake. Starts the server's supervision tree if it is not
  already running.

  Options: `:client_info` (map), `:client_capabilities` (wire-format map),
  `:protocol_version`.
  """
  @spec connect(module(), keyword()) :: %Client{}
  def connect(server, opts \\ []) do
    ensure_server_started(server)

    # Tag this connection's traffic so several clients can share one test
    # process mailbox without crosstalk.
    ref = make_ref()

    {:ok, session} =
      Supervisor.start_session(server,
        sink: {Noizu.MCP.Transport.Test, {self(), ref}},
        transport: :test
      )

    client = %Client{server: server, session: session, ref: ref, counter: :counters.new(1, [])}

    params = %{
      "protocolVersion" =>
        Keyword.get(opts, :protocol_version, Noizu.MCP.Protocol.Version.latest()),
      "capabilities" => Keyword.get(opts, :client_capabilities, %{}),
      "clientInfo" =>
        Keyword.get(opts, :client_info, %{"name" => "noizu_mcp_test", "version" => "0.0.0"})
    }

    {:ok, result} = request(client, "initialize", params)
    notify(client, "notifications/initialized")

    %{
      client
      | server_info: result["serverInfo"],
        capabilities: result["capabilities"],
        instructions: result["instructions"]
    }
  end

  @doc """
  Ensure `server`'s supervision tree is running (shared across tests),
  detached from the calling process. Safe under concurrent `async: true`
  callers — waits until the tree is fully started before returning.
  """
  @spec ensure_server_started(module()) :: :ok
  def ensure_server_started(server) do
    case Process.whereis(server) do
      nil ->
        # Detach from the calling test process so the shared server tree
        # outlives the individual test that happened to start it first.
        case Supervisor.start_link(server, []) do
          {:ok, pid} ->
            Process.unlink(pid)
            :ok

          {:error, {:already_started, _}} ->
            # The name registers before children finish starting — wait for
            # the last child so concurrent connects don't race startup.
            await_tree(server, 100)
        end

      _pid ->
        await_tree(server, 100)
    end
  end

  defp await_tree(server, attempts) do
    cond do
      Process.whereis(Module.concat(server, EventStore)) != nil ->
        :ok

      attempts == 0 ->
        raise "MCP server #{inspect(server)} did not finish starting"

      true ->
        Process.sleep(10)
        await_tree(server, attempts - 1)
    end
  end

  # ── raw protocol ──────────────────────────────────────────────────────────

  @doc "Send a request and await its result. Returns `{:ok, result} | {:error, error_map}`."
  @spec request(%Client{}, String.t(), map() | nil, keyword()) ::
          {:ok, map()} | {:error, map()}
  def request(%Client{} = client, method, params \\ nil, opts \\ []) do
    id = send_request(client, method, params)
    await(client, id, opts)
  end

  @doc "Send a request and return its id without awaiting the response."
  @spec send_request(%Client{}, String.t(), map() | nil) :: integer()
  def send_request(%Client{} = client, method, params \\ nil) do
    :counters.add(client.counter, 1, 1)
    id = :counters.get(client.counter, 1)
    deliver(client, %Request{id: id, method: method, params: params})
    id
  end

  @doc "Await the response for a previously sent request id."
  @spec await(%Client{}, integer(), keyword()) :: {:ok, map()} | {:error, map()}
  def await(%Client{} = client, id, opts \\ []) do
    timeout = Keyword.get(opts, :timeout, @default_timeout)
    deadline = System.monotonic_time(:millisecond) + timeout
    await_response(client, id, deadline)
  end

  @doc "Send a notification to the server."
  @spec notify(%Client{}, String.t(), map() | nil) :: :ok
  def notify(%Client{} = client, method, params \\ nil) do
    deliver(client, %Notification{method: method, params: params})
  end

  @doc "Send `notifications/cancelled` for an in-flight request id."
  @spec cancel(%Client{}, integer(), String.t() | nil) :: :ok
  def cancel(%Client{} = client, id, reason \\ nil) do
    params = %{"requestId" => id}
    params = if reason, do: Map.put(params, "reason", reason), else: params
    notify(client, "notifications/cancelled", params)
  end

  @doc "Send a raw wire binary (escape hatch for malformed-input tests)."
  @spec deliver_raw(%Client{}, binary()) :: :ok
  def deliver_raw(%Client{} = client, binary), do: Session.deliver(client.session, binary)

  defp deliver(client, message) do
    Session.deliver(client.session, IO.iodata_to_binary(JsonRpc.encode!(message)))
  end

  # ── feature wrappers ──────────────────────────────────────────────────────

  @doc "Call a tool. Returns `{:ok, %ToolResult{}} | {:error, error_map}`. Args use string keys."
  @spec call_tool(%Client{}, String.t(), map(), keyword()) ::
          {:ok, ToolResult.t()} | {:error, map()}
  def call_tool(%Client{} = client, name, args \\ %{}, opts \\ []) do
    params = %{"name" => name, "arguments" => args}

    params =
      case Keyword.get(opts, :progress_token) do
        nil -> params
        token -> Map.put(params, "_meta", %{"progressToken" => token})
      end

    case request(client, "tools/call", params, opts) do
      {:ok, result} -> {:ok, ToolResult.from_map(result)}
      {:error, error} -> {:error, error}
    end
  end

  @doc "List all tools (auto-paginates). Returns `{:ok, [%Tool{}]} | {:error, error_map}`."
  @spec list_tools(%Client{}, keyword()) :: {:ok, [Tool.t()]} | {:error, map()}
  def list_tools(%Client{} = client, opts \\ []) do
    collect_pages(client, "tools/list", "tools", &Tool.from_map/1, nil, [], opts)
  end

  defp collect_pages(client, method, key, decoder, cursor, acc, opts) do
    params = if cursor, do: %{"cursor" => cursor}, else: nil

    case request(client, method, params, opts) do
      {:ok, result} ->
        items = Enum.map(result[key] || [], decoder)
        acc = acc ++ items

        case result["nextCursor"] do
          nil -> {:ok, acc}
          next -> collect_pages(client, method, key, decoder, next, acc, opts)
        end

      {:error, error} ->
        {:error, error}
    end
  end

  @doc "Read a resource. Returns `{:ok, [%ResourceContents{}]} | {:error, error_map}`."
  @spec read_resource(%Client{}, String.t(), keyword()) ::
          {:ok, [Noizu.MCP.Types.ResourceContents.t()]} | {:error, map()}
  def read_resource(%Client{} = client, uri, opts \\ []) do
    case request(client, "resources/read", %{"uri" => uri}, opts) do
      {:ok, result} ->
        {:ok, Enum.map(result["contents"] || [], &Noizu.MCP.Types.ResourceContents.from_map/1)}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc "List all resources (auto-paginates). Returns `{:ok, [%Resource{}]}`."
  @spec list_resources(%Client{}, keyword()) ::
          {:ok, [Noizu.MCP.Types.Resource.t()]} | {:error, map()}
  def list_resources(%Client{} = client, opts \\ []) do
    collect_pages(
      client,
      "resources/list",
      "resources",
      &Noizu.MCP.Types.Resource.from_map/1,
      nil,
      [],
      opts
    )
  end

  @doc "List all resource templates (auto-paginates)."
  @spec list_resource_templates(%Client{}, keyword()) ::
          {:ok, [Noizu.MCP.Types.ResourceTemplate.t()]} | {:error, map()}
  def list_resource_templates(%Client{} = client, opts \\ []) do
    collect_pages(
      client,
      "resources/templates/list",
      "resourceTemplates",
      &Noizu.MCP.Types.ResourceTemplate.from_map/1,
      nil,
      [],
      opts
    )
  end

  @doc "Subscribe to resource update notifications for `uri`."
  @spec subscribe(%Client{}, String.t()) :: {:ok, map()} | {:error, map()}
  def subscribe(%Client{} = client, uri) do
    request(client, "resources/subscribe", %{"uri" => uri})
  end

  @doc "Unsubscribe from resource update notifications for `uri`."
  @spec unsubscribe(%Client{}, String.t()) :: {:ok, map()} | {:error, map()}
  def unsubscribe(%Client{} = client, uri) do
    request(client, "resources/unsubscribe", %{"uri" => uri})
  end

  @doc "List all prompts (auto-paginates). Returns `{:ok, [%Prompt{}]}`."
  @spec list_prompts(%Client{}, keyword()) ::
          {:ok, [Noizu.MCP.Types.Prompt.t()]} | {:error, map()}
  def list_prompts(%Client{} = client, opts \\ []) do
    collect_pages(
      client,
      "prompts/list",
      "prompts",
      &Noizu.MCP.Types.Prompt.from_map/1,
      nil,
      [],
      opts
    )
  end

  @doc """
  Get a prompt. Returns `{:ok, %{description: _, messages: [%PromptMessage{}]}}`.
  Args use string keys.
  """
  @spec get_prompt(%Client{}, String.t(), map(), keyword()) :: {:ok, map()} | {:error, map()}
  def get_prompt(%Client{} = client, name, args \\ %{}, opts \\ []) do
    case request(client, "prompts/get", %{"name" => name, "arguments" => args}, opts) do
      {:ok, result} ->
        {:ok,
         %{
           description: result["description"],
           messages: Enum.map(result["messages"] || [], &Noizu.MCP.Types.PromptMessage.from_map/1)
         }}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Request completion values. `ref` is `{:prompt, name}` or
  `{:resource_template, uri_template}`. Returns
  `{:ok, %{values: _, total: _, has_more: _}}`.
  """
  @spec complete(%Client{}, tuple(), String.t(), String.t()) :: {:ok, map()} | {:error, map()}
  def complete(%Client{} = client, ref, arg_name, value) do
    ref_map =
      case ref do
        {:prompt, name} -> %{"type" => "ref/prompt", "name" => name}
        {:resource_template, uri} -> %{"type" => "ref/resource", "uri" => uri}
      end

    params = %{"ref" => ref_map, "argument" => %{"name" => arg_name, "value" => value}}

    case request(client, "completion/complete", params) do
      {:ok, %{"completion" => completion}} ->
        {:ok,
         %{
           values: completion["values"] || [],
           total: completion["total"],
           has_more: completion["hasMore"] == true
         }}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc "Set the MCP log level for this session."
  @spec set_log_level(%Client{}, atom() | String.t()) :: {:ok, map()} | {:error, map()}
  def set_log_level(%Client{} = client, level) do
    request(client, "logging/setLevel", %{"level" => to_string(level)})
  end

  # ── notification assertions ───────────────────────────────────────────────

  @doc """
  Assert the server emitted a notification with `method`; returns its params.
  When `match` (a map) is given, every key/value in it must be present in the
  notification params.
  """
  @spec assert_notification(%Client{}, String.t(), map() | nil, keyword()) :: map() | nil
  def assert_notification(%Client{} = client, method, match \\ nil, opts \\ []) do
    timeout = Keyword.get(opts, :timeout, @default_timeout)
    deadline = System.monotonic_time(:millisecond) + timeout

    case take_buffered(client, method, match) do
      {:ok, params} ->
        params

      :none ->
        wait_notification(client, method, match, deadline)
    end
  end

  @doc "Assert the server emitted at least one `notifications/progress`; returns its params."
  @spec assert_progress(%Client{}, keyword()) :: map()
  def assert_progress(%Client{} = client, opts \\ []) do
    assert_notification(client, "notifications/progress", nil, opts)
  end

  @doc "Assert no notification with `method` arrives within `opts[:timeout]` (default 100ms)."
  @spec refute_notification(%Client{}, String.t(), keyword()) :: :ok
  def refute_notification(%Client{} = client, method, opts \\ []) do
    timeout = Keyword.get(opts, :timeout, 100)
    deadline = System.monotonic_time(:millisecond) + timeout

    case take_buffered(client, method, nil) do
      {:ok, params} ->
        raise ExUnit.AssertionError,
          message: "Expected no #{method} notification, got: #{inspect(params)}"

      :none ->
        try do
          params = wait_notification(client, method, nil, deadline)

          raise ExUnit.AssertionError,
            message: "Expected no #{method} notification, got: #{inspect(params)}"
        rescue
          e in ExUnit.AssertionError ->
            if e.message =~ "Timed out", do: :ok, else: reraise(e, __STACKTRACE__)
        end
    end
  end

  # ── internals ─────────────────────────────────────────────────────────────

  defp await_response(client, id, deadline) do
    remaining = max(deadline - System.monotonic_time(:millisecond), 0)

    receive do
      {:mcp_out, tag, binary, _routing} when tag == client.ref ->
        case JsonRpc.decode(binary) do
          {:ok, %Response{id: ^id, result: result}} ->
            {:ok, result}

          {:ok, %ErrorResponse{id: ^id, error: error}} ->
            {:error, Noizu.MCP.Error.to_map(error) |> Map.put("reason", error.reason)}

          {:ok, other} ->
            buffer(client, other)
            await_response(client, id, deadline)

          {:error, decode_error} ->
            raise "MCP test client could not decode server output: #{inspect(decode_error)}"
        end
    after
      remaining ->
        raise ExUnit.AssertionError,
          message: "Timed out awaiting response to request #{id}"
    end
  end

  defp wait_notification(client, method, match, deadline) do
    remaining = max(deadline - System.monotonic_time(:millisecond), 0)

    receive do
      {:mcp_out, tag, binary, _routing} when tag == client.ref ->
        case JsonRpc.decode(binary) do
          {:ok, %Notification{method: ^method, params: params}} ->
            if matches?(params, match) do
              params
            else
              buffer(client, %Notification{method: method, params: params})
              wait_notification(client, method, match, deadline)
            end

          {:ok, other} ->
            buffer(client, other)
            wait_notification(client, method, match, deadline)

          {:error, decode_error} ->
            raise "MCP test client could not decode server output: #{inspect(decode_error)}"
        end
    after
      remaining ->
        raise ExUnit.AssertionError,
          message: "Timed out awaiting #{method} notification"
    end
  end

  defp buffer_key(client), do: {__MODULE__, :buffer, client.session}

  defp buffer(client, message) do
    key = buffer_key(client)
    Process.put(key, (Process.get(key) || []) ++ [message])
  end

  defp take_buffered(client, method, match) do
    key = buffer_key(client)
    buffered = Process.get(key) || []

    case Enum.split_while(buffered, fn
           %Notification{method: ^method, params: params} -> not matches?(params, match)
           _ -> true
         end) do
      {_, []} ->
        :none

      {before, [%Notification{params: params} | rest]} ->
        Process.put(key, before ++ rest)
        {:ok, params}
    end
  end

  defp matches?(_params, nil), do: true

  defp matches?(params, match) when is_map(params) do
    Enum.all?(match, fn {key, value} -> Map.get(params, key) == value end)
  end

  defp matches?(_params, _match), do: false
end
