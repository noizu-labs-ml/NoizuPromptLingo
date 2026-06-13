# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.CallingContext do
  @moduledoc """

  CallingContext
  -----------------------------------------------------------------------------
  Context object used to track a caller's state and permissions along
  with unique request identifier for tracking requests as they travel through
  the layers in your application. Useful for log collation, permission checks,
  access auditing.

  ### Application Config Options and Defaults

  - Include Default IO.inspect formatter defimpl for CallingContext
  `config :noizu_core, inspect_calling_context: true`

  - Request ID Extraction Strategy.
  {m,f}  or function\2 that accepts (conn, default) and pulls request id (CallingContext.token) from Plug.Conn.
  `config :noizu_core, token_strategy: {Noizu.ElixirCore.CallingContext, :extract_token}

  - Request Reason Extraction Strategy.
  {m,f}  or function\2 that accepts (conn, default) and pulls request reason (CallingContext.reason) from Plug.Conn.
  `config :noizu_core, token_strategy: {Noizu.ElixirCore.CallingContext, :extract_reason}

  - Request Caller Extraction Strategy.
  {m,f}  or function\2 that accepts (conn, default) and pulls request Caller (CallingContext.caller) from Plug.Conn
  `config :noizu_core, get_plug_caller: {Noizu.ElixirCore.CallingContext, :extract_caller}

  - Request Caller's Auth Map Extraction Strategy.
  {m,f}  or function\2 that accepts (conn, default) and returns effective permission map ContextCaller.auth.
  `config :noizu_core, acl_strategy: {Noizu.ElixirCore.CallingContext, :default_auth}

  - Default Blank/Empty Request Reason
  `config :noizu_core, default_request_reason: :none`

  - Default Restricted User Reference or Object
  `config :noizu_core, default_internal_user: {:ref, Noizu.ElixirCore.CallerEntity, :restricted}`

  - Default Internal User Reference or Object
  `config :noizu_core, default_internal_user: {:ref, Noizu.ElixirCore.CallerEntity, :internal}`

  - Default System User Reference or Object
  `config :noizu_core, default_system_user: {:ref, Noizu.ElixirCore.CallerEntity, :system}`

  - Default Admin User Reference or Object
  `config :noizu_core, default_admin_user: {:ref, Noizu.ElixirCore.CallerEntity, :admin}`

  - Default Restricted User Auth Map
  `config :noizu_core, default_internal_auth: %{permissions: %{restricted: true}}`

  - Default Internal User Auth Map
  `config :noizu_core, default_internal_auth: %{permissions: %{internal: true}}`

  - Default Ssy User Auth Map
  `config :noizu_core, default_system_auth: %{permissions: %{system: true, internal: true}}`

  - Default Admin User Auth Map
  `config :noizu_core, default_admin_auth: %{permissions: %{admin: true, system: true, internal: true}}`







  """

  alias Noizu.ElixirCore.CallingContext
  require Logger

  # ====================================================================================================================
  # Struct
  # ====================================================================================================================
  @vsn 1.0
  @type t :: %CallingContext{
          caller: tuple,
          token: String.t(),
          reason: String.t(),
          auth: Any,
          options: Map.t(),
          time: DateTime.t() | nil,
          outer_context: CalingContext.t(),
          vsn: float
        }

  defstruct caller: nil,
            token: nil,
            reason: nil,
            auth: nil,
            options: nil,
            time: nil,
            outer_context: nil,
            vsn: @vsn

  # ====================================================================================================================
  # Public Methods
  # ====================================================================================================================

  @doc """
  Default logic for grabbing conn's request id. Using either config noizu_core, token_strategy: {m,f} or included extract_token method.
  """
  def default_token(conn, default) do
    case Application.get_env(:noizu_core, :token_strategy, {__MODULE__, :extract_token}) do
      {m, f} -> apply(m, f, [conn, default])
      v when is_function(v) -> v.(conn, default)
      _ -> extract_token(conn, default)
    end
  end

  @doc """
    Extract Request Id Token from Plug.Conn or Generate UUID if non found.
    Attached to CallingContext to include in log output for log collation.
  """
  def extract_token(nil, :generate), do: apply(UUID, :uuid4, [:hex])
  def extract_token(nil, default), do: default

  def extract_token(conn, default) do
    case conn.body_params["request-id"] ||
           apply(Plug.Conn, :get_resp_header, [conn, "x-request-id"]) do
      v when is_bitstring(v) -> v
      [] -> (default == :generate && apply(UUID, :uuid4, [:hex])) || default
      [h | _] -> h
    end
  end

  # end extract_token/0

  @doc """
  Default logic for grabbing conn's request reason. Using either config noizu_core, extract_reason: {m,f} or included extract_token method.
  """
  def default_reason(conn, default) do
    case Application.get_env(:noizu_core, :token_strategy, {__MODULE__, :extract_reason}) do
      {m, f} -> apply(m, f, [conn, default])
      v when is_function(v) -> v.(conn, default)
      _ -> extract_reason(conn, default)
    end
  end

  @doc """
    Extract Request Reason from Plug.Conn.
    Useful for logging purposes/exception handling messaging/tracing on backend.
  """
  def extract_reason(conn, default) do
    case conn.body_params["call-reason"] ||
           apply(Plug.Conn, :get_resp_header, [conn, "x-call-reason"]) do
      v when is_bitstring(v) -> v
      [] -> default || empty_reason()
      [h | _] -> h
    end
  end

  @doc """
    Extract caller permission level from Plug.Conn. (Currently only depends on default value)
  """
  def extract_caller(%{__struct__: Plug.Conn} = conn, default) do
    case default do
      :restricted -> default_restricted_user()
      :internal -> default_internal_user()
      :system -> default_system_user()
      :user -> default_restricted_user()
      :unauthenticated -> {:ref, Noizu.ElixirCore.UnauthenticatedCallerEntity, get_ip(conn)}
      _ -> {:ref, Noizu.ElixirCore.UnauthenticatedCallerEntity, get_ip(conn)}
    end
  end

  @doc """
    Default effective auth permissions. Nested key value pairs of ContextCaller has been granted.
  """
  defp default_auth(caller, _auth) do
    case caller do
      {:ref, Noizu.ElixirCore.CallerEntity, :restricted} ->
        default_restricted_auth()

      {:ref, Noizu.ElixirCore.CallerEntity, :internal} ->
        default_internal_auth()

      {:ref, Noizu.ElixirCore.CallerEntity, :system} ->
        default_system_auth()

      {:ref, Noizu.ElixirCore.CallerEntity, :admin} ->
        default_admin_auth()

      {:ref, Noizu.ElixirCore.UnauthenticatedCallerEntity, _ip} ->
        %{permissions: %{unauthenticated: true}}
    end
  end

  @doc """
  Get call request id from Plug.Conn
  """
  def get_token(conn, default \\ :generate) do
    default_token(conn, default)
  end

  @doc """
  Get call reason from Plug.Conn
  """
  def get_reason(conn, default \\ nil) do
    default_reason(conn, default)
  end

  @doc """
  Get caller from Plug.Conn
  """
  def get_caller(%{__struct__: Plug.Conn} = conn, default \\ :unauthenticated) do
    case Application.get_env(:noizu_core, :get_plug_caller, {__MODULE__, :extract_caller}) do
      v when is_function(v) -> v.(conn, default)
      {m, f} -> apply(m, f, [conn, default])
      _ -> extract_caller(conn, default)
    end
  end

  @doc """
  Get caller effective authentication map.
  """
  def get_auth(caller, options) do
    case Application.get_env(:noizu_core, :acl_strategy, {__MODULE__, :default_auth}) do
      v when is_function(v) -> v.(caller, options)
      {m, f} -> apply(m, f, [caller, options])
      _ -> default_auth(caller, options)
    end
  end

  @doc """
  Prepare Context object with given caller/auth and conn request details. Sets Process meta data by default.
  """
  def new_conn(caller, auth, %{__struct__: Plug.Conn} = conn, options \\ %{logger_init: true}) do
    reason = get_reason(conn, options[:default][:reason])
    token = get_token(conn, options[:default][:token] || :generate)
    time = options[:time] || DateTime.utc_now()
    outer_context = options[:outer_context]

    context = %__MODULE__{
      caller: caller,
      auth: auth,
      time: time,
      outer_context: outer_context,
      token: token,
      reason: reason
    }

    if Map.get(options, :logger_init, true) do
      meta_update(context)
    end

    context
  end

  @doc """
  Prepare Context object with for given conn. Sets Process meta data by default.
  """
  def new_conn(%{__struct__: Plug.Conn} = conn, options \\ %{logger_init: true}) do
    caller = get_caller(conn, options)
    auth = get_auth(caller, options)
    reason = get_reason(conn, options[:default][:reason])
    token = get_token(conn, options[:default][:token] || :generate)
    time = options[:time] || DateTime.utc_now()
    outer_context = options[:outer_context]

    context = %__MODULE__{
      caller: caller,
      auth: auth,
      time: time,
      outer_context: outer_context,
      token: token,
      reason: reason
    }

    if Map.get(options, :logger_init, true) do
      meta_update(context)
    end

    context
  end

  @doc """
  Generate new Context.Caller by passing in Caller, Auth and options.
  """
  def new(caller, auth, options) do
    time = options[:time] || DateTime.utc_now()

    token =
      (options[:token] && options[:token] != :generate && options[:token]) ||
        default_token(nil, :generate)

    reason = options[:reason] || empty_reason()
    outer_context = options[:outer_context]

    %__MODULE__{
      caller: caller,
      auth: auth,
      time: time,
      outer_context: outer_context,
      token: token,
      reason: reason
    }
  end

  # -----------------------------------------------------------------------------
  # Internal CallingContext
  # -----------------------------------------------------------------------------
  @doc """
    Create new calling context with default internal user caller and permissions.
  """
  def internal(), do: new(default_internal_user(), default_internal_auth(), %{})
  def internal(nil), do: new(default_internal_user(), default_internal_auth(), %{})

  def internal(%__MODULE__{} = this),
    do: %__MODULE__{this | auth: default_internal_auth(), outer_context: this}

  def internal(%{} = options), do: new(default_internal_user(), default_internal_auth(), options)

  def internal(%{__struct__: Plug.Conn} = conn, options),
    do: new_conn(default_internal_user(), default_internal_auth(), conn, options)

  # -----------------------------------------------------------------------------
  # System CallingContext
  # -----------------------------------------------------------------------------
  @doc """
    Create new calling context with default system user caller and permissions.
  """
  def system(), do: new(default_system_user(), default_system_auth(), %{})
  def system(nil), do: new(default_system_user(), default_system_auth(), %{})

  def system(%__MODULE__{} = this),
    do: %__MODULE__{this | auth: default_system_auth(), outer_context: this}

  def system(%{} = options), do: new(default_system_user(), default_system_auth(), options)

  def system(%{__struct__: Plug.Conn} = conn, options),
    do: new_conn(default_system_user(), default_system_auth(), conn, options)

  # -----------------------------------------------------------------------------
  # Restricted CallingContext
  # -----------------------------------------------------------------------------
  @doc """
    Create new calling context with default restricted user caller and permissions.
  """
  def restricted(), do: new(default_restricted_user(), default_restricted_auth(), %{})
  def restricted(nil), do: new(default_restricted_user(), default_restricted_auth(), %{})

  def restricted(%__MODULE__{} = this),
    do: %__MODULE__{this | auth: default_restricted_auth(), outer_context: this}

  def restricted(%{} = options),
    do: new(default_restricted_user(), default_restricted_auth(), options)

  def restricted(%{__struct__: Plug.Conn} = conn, options),
    do: new_conn(default_restricted_user(), default_restricted_auth(), conn, options)

  # -----------------------------------------------------------------------------
  # Admin CallingContext
  # -----------------------------------------------------------------------------
  @doc """
    Create new calling context with default admin user caller and permissions.
  """
  def admin(), do: new(default_admin_user(), default_admin_auth(), %{})
  def admin(nil), do: new(default_admin_user(), default_admin_auth(), %{})

  def admin(%__MODULE__{} = this),
    do: %__MODULE__{this | auth: default_admin_auth(), outer_context: this}

  def admin(%{} = options), do: new(default_admin_user(), default_admin_auth(), options)

  def admin(%{__struct__: Plug.Conn} = conn, options),
    do: new_conn(default_admin_user(), default_admin_auth(), conn, options)

  @doc """
  Extract CallingContext meta data for Logger
  """
  def metadata(%__MODULE__{} = context) do
    filter =
      case context.options[:log_filter] do
        v when is_list(v) -> v
        _ -> []
      end

    [context_token: context.token, context_time: context.time, context_caller: context.caller] ++
      filter
  end

  def metadata(_) do
    [context_token: :none, context_time: 0, context_caller: :none]
  end

  @doc """
  Strip CallingContext meta data from Logger.
  """
  def meta_strip(context) do
    m = Keyword.delete(Logger.metadata() || [], Keyword.keys(metadata(context)))
    Logger.metadata(m)
  end

  @doc """
  Update Logger with CallingContext meta data.
  """
  def meta_update(context) do
    (Logger.metadata() || [])
    |> Keyword.merge(metadata(context))
    |> Logger.metadata()
  end

  # ====================================================================================================================
  # Private Methods
  # ====================================================================================================================
  defp empty_reason() do
    Application.get_env(:noizu_core, :default_request_reason, :none)
  end

  defp default_restricted_user() do
    Application.get_env(
      :noizu_core,
      :default_internal_user,
      {:ref, Noizu.ElixirCore.CallerEntity, :restricted}
    )
  end

  defp default_internal_user() do
    Application.get_env(
      :noizu_core,
      :default_internal_user,
      {:ref, Noizu.ElixirCore.CallerEntity, :internal}
    )
  end

  defp default_system_user() do
    Application.get_env(
      :noizu_core,
      :default_system_user,
      {:ref, Noizu.ElixirCore.CallerEntity, :system}
    )
  end

  defp default_admin_user() do
    Application.get_env(
      :noizu_core,
      :default_admin_user,
      {:ref, Noizu.ElixirCore.CallerEntity, :admin}
    )
  end

  defp default_restricted_auth() do
    Application.get_env(:noizu_core, :default_internal_auth, %{permissions: %{restricted: true}})
  end

  defp default_internal_auth() do
    Application.get_env(:noizu_core, :default_internal_auth, %{permissions: %{internal: true}})
  end

  defp default_system_auth() do
    Application.get_env(:noizu_core, :default_system_auth, %{
      permissions: %{system: true, internal: true}
    })
  end

  defp default_admin_auth() do
    Application.get_env(:noizu_core, :default_admin_auth, %{
      permissions: %{admin: true, system: true, internal: true}
    })
  end

  defp get_ip(conn) do
    case apply(Plug.Conn, :get_req_header, [conn, "x-forwarded-for"]) do
      [h | _] -> h
      [] -> conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
      nil -> conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
    end
  end

  # end get_ip/1
end

# end defmodule Noizu.Scaffolding.CallingContext

if Application.get_env(:noizu_core, :inspect_calling_context, true) do
  # -----------------------------------------------------------------------------
  # Inspect Protocol
  # -----------------------------------------------------------------------------
  defimpl Inspect, for: Noizu.ElixirCore.CallingContext do
    import Inspect.Algebra

    def inspect(entity, opts) do
      heading = "#CallingContext(#{entity.token})"
      {seperator, end_seperator} = if opts.pretty, do: {"\n   ", "\n"}, else: {" ", " "}

      inner =
        cond do
          opts.limit == :infinity ->
            concat(["<#{seperator}", to_doc(Map.from_struct(entity), opts), "#{seperator}>"])

          opts.limit >= 200 ->
            concat([
              "<",
              "#{seperator}caller: #{inspect(entity.caller)},",
              "#{seperator}reason: #{inspect(entity.reason)},",
              "#{seperator}permissions: #{inspect(entity.auth[:permissions])}",
              "#{end_seperator}>"
            ])

          opts.limit >= 150 ->
            concat([
              "<",
              "#{seperator}caller: #{inspect(entity.caller)},",
              "#{seperator}reason: #{inspect(entity.reason)}",
              "#{end_seperator}>"
            ])

          opts.limit >= 100 ->
            concat(["<", "#{seperator}caller: #{inspect(entity.caller)}", "#{end_seperator}>"])

          true ->
            "<>"
        end

      concat([heading, inner])
    end

    # end inspect/2
  end

  # end defimpl
end
