#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 Noizu Labs, Inc.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.Helpers do
  alias Noizu.ElixirCore.CallingContext
  #-------------------------
  # banner_text
  #-------------------------
  def banner_text(header, msg, len \\ 120, pad \\ 0) do
    header_len = String.length(header)
    h_len = div(len, 2)

    sub_len = div(header_len, 2)
    rem = rem(header_len, 2)

    l_len = h_len - sub_len
    r_len = h_len - sub_len - rem

    char = "*"

    lines = String.split(msg, "\n", trim: true)

    pad_str = cond do
      pad == 0 -> ""
      :else -> String.duplicate(" ", pad)
    end

    top = "\n#{pad_str}#{String.duplicate(char, l_len)} #{header} #{String.duplicate(char, r_len)}"
    bottom = pad_str <> String.duplicate(char, len) <> "\n"
    middle = for line <- lines do
      "#{pad_str}#{char} " <> line
    end
    Enum.join([top] ++ middle ++ [bottom], "\n")
  end

  #-------------------------
  # request_pagination
  #-------------------------
  def request_pagination(params, default_page, default_results_per_page) do
    page = case params["pg"] || default_page do
      v when is_integer(v) -> v
      v when is_bitstring(v) ->
        case Integer.parse(v) do
          {v, ""} -> v
          _ -> default_page
        end
      _ -> default_page
    end

    results_per_page = case params["rpp"] || default_results_per_page do
      v when is_integer(v) -> v
      v when is_bitstring(v) ->
        case Integer.parse(v) do
          {v, ""} -> v
          _ -> default_results_per_page
        end
      _ -> default_results_per_page
    end

    {page, results_per_page}
  end

  #-------------------------
  # page
  #-------------------------
  def page(page, query) do
    cond do
      page == 0 -> query
      true ->
        Enum.reduce(1 .. page, query, fn(_, acc) ->
          Amnesia.Selection.next(acc)
        end)
    end |> Amnesia.Selection.values()
  end

  #-------------------------
  # update_options
  #-------------------------
  @doc """
    Update Poison Format/Expansion options.
  """
  def update_options(entity, options) when is_atom(entity) do
    json_format = options[:json_formats][entity] || options[:json_formats][entity.poly_base()] || options[:json_format] || :mobile
    {json_format, update_expand_options(entity, options)}
  end

  def update_options(%{__struct__: m} = entity, options) do
    json_format = options[:json_formats][m] || options[:json_formats][m.poly_base()] || options[:json_format] || :mobile
    {json_format, update_expand_options(entity, options)}
  end

  def update_options(entity, options) do
    json_format = options[:json_format] || :mobile
    {json_format, update_expand_options(entity, options)}
  end

  #-------------------------
  # update_expand_options
  #-------------------------
  @doc """
    Update Entity.expand! option depth and path.
  """
  def update_expand_options(entity, options) when is_atom(entity) do
    sm = try do
      entity.sref_module()
    rescue _e -> "[error]"
    end
    (options || %{})
    |> update_in([:depth], &((&1 || 1) + 1))
    |> update_in([:path], &(sm <> (&1 && ("." <> &1) || "")))
  end
  def update_expand_options(%{__struct__: m} = _entity, options) do
    sm = try do
      m.sref_module()
    rescue _e -> "[error]"
    end
    (options || %{})
    |> update_in([:depth], &((&1 || 1) + 1))
    |> update_in([:path], &(sm <> (&1 && ("." <> &1) || "")))
  end
  def update_expand_options(_entity, options) do
    sm = "[error]"
    (options || %{})
    |> update_in([:depth], &((&1 || 1) + 1))
    |> update_in([:path], &(sm <> (&1 && ("." <> &1) || "")))
  end


  #-------------------------
  # expand_concurrency
  #-------------------------
  def expand_concurrency(options) do
    {max_concurrency, next_concurrency} = case options[:max_concurrency] do
      [] -> {1, [1]}
      [h] -> {h, [max(h-1, 1)]}
      [h|t] -> {h, t}
      _ ->
        h = System.schedulers_online()
        {h, [max(h-1, 1)]}
    end
    {max_concurrency, put_in(options, [:max_concurrency], next_concurrency)}
  end

  #-------------------------
  # expand_ref?
  #-------------------------
  @doc """
    Should entity be expanded for poison/entity expand.
  """
  def expand_ref?(options = %{path: path, depth: depth}) do
    expand_ref?(path, depth, options)
  end
  def expand_ref?(path, depth, options \\ nil) do
    cond do
      options == nil -> false
      options[:expand_all_refs] == :infinity -> true
      is_integer(options[:expand_all_refs]) && options[:expand_all_refs] <= depth -> true
      expand = options[:expand_refs] ->
        Enum.reduce_while(expand, false, fn({p, d}, acc) ->
          cond do
            is_integer(d) && d > depth -> {:cont, acc}
            Regex.match?(p, path) -> {:halt, true}
            :else -> {:cont, acc}
          end
        end)
      :else -> false
    end
  end

  #-------------------------
  # api_response
  #-------------------------
  def api_response(%Plug.Conn{} = conn, response,  %CallingContext{} = context, options \\ []) do
    options = options
              |> update_in([:pretty], &( &1 == nil && true || &1))
              |> update_in([:expand_refs], &(&1 == nil && context.options[:expand_refs] || &1))
              |> update_in([:expand_all_refs], &(&1 == nil && context.options[:expand_all_refs] || &1))
              |> update_in([:json_format], &(&1 == nil && context.options[:json_format] || &1))
              |> update_in([:json_formats], &(&1 == nil && context.options[:json_formats] || &1))
              |> update_in([:context], &(&1 == nil && context || &1))
              |> update_in([:depth], &(&1 || 1))
              |> Enum.map(&(&1))

    # Preprocess response data.
    response = cond do
      options[:expand] && options[:restricted] -> Noizu.RestrictedProtocol.restricted_view(Noizu.EntityProtocol.expand!(response, options), context, options[:restrict_options])
      options[:expand] -> Noizu.EntityProtocol.expand!(response, options)
      options[:restricted] -> Noizu.RestrictedProtocol.restricted_view(response, context, options[:restrict_options])
      :else -> response
    end

    # Injecting Useful content from calling context into headers for api client's consumption.
    case Plug.Conn.get_resp_header(conn, "x-request-id") do
      [request|_] ->
        if request != context.token do
          conn
          |> Plug.Conn.put_resp_header("x-request-id", context.token)
          |> Plug.Conn.put_resp_header("x-orig-request-id", request)
        else
          conn
        end
      [] ->
        conn
        |> Plug.Conn.put_resp_header("x-request-id", context.token)
    end |> send_resp(200, "application/json", Poison.encode_to_iodata!(response, options))
  end

  #-------------------------
  # send_resp
  #-------------------------
  def send_resp(conn, default_status, default_content_type, body) do
    conn
    |> ensure_resp_content_type(default_content_type)
    |> Plug.Conn.send_resp(conn.status || default_status, body)
  end

  #-------------------------
  # ensure_resp_content_type
  #-------------------------
  def ensure_resp_content_type(%{resp_headers: resp_headers} = conn, content_type) do
    if List.keyfind(resp_headers, "content-type", 0) do
      conn
    else
      content_type = content_type <> "; charset=utf-8"
      %{conn | resp_headers: [{"content-type", content_type}|resp_headers]}
    end
  end

  #-------------------------
  # format_to_atom
  #-------------------------
  def format_to_atom(v, default) do
    case v do
      "standard" -> :standard
      "admin" -> :admin
      "verbose" -> :verbose
      "compact" -> :compact
      "mobile" -> :mobile
      "verbose_mobile" -> :verbose_mobile
      _ -> default
    end
  end

  #-------------------------
  # default_get_context__json_format
  #-------------------------
  def default_get_context__json_format(conn, params, get_context_provider, _options) do
    (params["default-json-format"] || List.first(Plug.Conn.get_resp_header(conn, "x-default-json-format")))
    |> get_context_provider.format_to_atom(:mobile)
  end

  #-------------------------
  # default_get_context__json_formats
  #-------------------------
  def default_get_context__json_formats(conn, params, get_context_provider, _options) do
    format_overrides = params["json-formats"] || List.first(Plug.Conn.get_resp_header(conn, "x-json-formats"))
    case format_overrides do
      v when is_bitstring(v) ->
        String.split(v, ",")
        |> Enum.map(fn(e) ->
          get_context_provider.format_to_tuple(String.split(e, ":"))
        end)
        |> Enum.filter(&(&1))
        |> Map.new()
      _ -> %{}
    end
  end

  #-------------------------
  # default_get_context__expand_all_refs
  #-------------------------
  def default_get_context__expand_all_refs(conn, params, _get_context_provider, _options) do
    case (params["expand-all-refs"] || List.first(Plug.Conn.get_resp_header(conn, "x-expand-all-refs"))) do
      true -> :infinity
      "true" -> :infinity
      false -> false
      "false" -> false
      v when is_bitstring(v) ->
        case Integer.parse(v) do
          {v, ""} -> v
          _ -> false
        end
      v when is_integer(v) -> v
      nil -> false
    end
  end

  #-------------------------
  # default_get_context__expand_refs
  #-------------------------
  @doc """
     Prepares a list of paths to expand keyed to a root, plus options depth.
     Example  expand-refs=*.posts.entity-image.image,*.user:5

     Internally paths are converted to regex strings + max depth constraints and compared to input in json methods.
     Regex.match?(~"^image\.entity-image\.user.*$", path)
  """
  def default_get_context__expand_refs(conn, params, get_context_provider, _options) do
    case (params["expand-refs"] || List.first(Plug.Conn.get_resp_header(conn, "x-expand-refs"))) do
      v when is_bitstring(v) ->
        Enum.map(String.split(v, ","),
          fn(r) ->
            {path, depth} =  case String.split(r, ":") do
              [path,"infinity"] -> {path, :infinity}
              [path,depth] ->
                case Integer.parse(depth) do
                  {v, ""} -> {path, v}
                  _ -> {nil, nil}
                end
              [path] -> {path, :infinity}
            end
            if path do
              extended = case String.split(path, ".") do
                [v] ->
                  e = get_context_provider.sref_module(String.trim(v))
                  e && [e, "*"]
                v when is_list(v) ->
                  Enum.reduce_while(v, [],
                    fn(e, acc)->
                      cond do
                        e == "**" -> {:cont, acc ++ [e]}
                        e == "*" -> {:cont, acc ++ [e]}
                        e == "++" -> {:cont, acc ++ [e]}
                        e == "+" -> {:cont, acc ++ [e]}
                        Regex.match?(~r/^\{[0-9,]+\}$/, e) -> {:cont, acc ++ [e]}
                        e = get_context_provider.sref_module(String.trim(e)) -> {:cont, acc ++ [e]}
                        :else -> {:halt, nil}
                      end
                    end
                  )
              end
              if extended do
                [h|t] = extended
                head = cond do
                  is_atom(h) -> "^#{h.sref_module()}"
                  h == "**" -> "^([a-z_\\-0-9\\.])*"
                  h == "++" -> "^([a-z_\\-0-9\\.])+"
                  :else -> "^([a-z_\\-0-9])#{h}"
                end
                reg = Enum.reduce(t, head, fn(x, acc) ->
                  cond do
                    is_atom(x) -> acc <> "\.#{x.sref_module()}"
                    x == "**" -> acc <> "([a-z_\\-0-9\\.])*"
                    x == "++" -> acc <> "([a-z_\\-0-9\\.])+"
                    Regex.match?(~r/^\{[0-9,]+\}$/, x) -> acc <> "([a-z_\\-0-9]*\.)#{x}"
                    :else -> acc <> "([a-z_\\-0-9])#{x}"
                  end
                end) <> "$"
                reg = case Regex.compile(reg) do
                  {:ok, v} -> v
                  _ -> nil
                end
                reg && {reg, depth}
              end
            end
          end
        )
        |> Enum.filter(&(&1))
      nil -> nil
    end
  end

  def default_get_context__token_reason_options(conn, params, get_context_provider, opts) do
    token = CallingContext.get_token(conn)
    reason = CallingContext.get_reason(conn)
    json_format = default_get_context__json_format(conn, params, get_context_provider, opts)
    json_formats = default_get_context__json_formats(conn, params, get_context_provider, opts)
    expand_all_refs = default_get_context__expand_all_refs(conn, params, get_context_provider, opts)
    expand_refs = default_get_context__expand_refs(conn, params, get_context_provider, opts)

    context_options = %{
      expand_refs: expand_refs,
      expand_all_refs: expand_all_refs,
      json_format: json_format,
      json_formats: json_formats,
    }
    {token, reason, context_options}
  end

  #-------------------------
  # get_ip
  #-------------------------
  def get_ip(conn) do
    case Plug.Conn.get_req_header(conn, "x-forwarded-for") do
      [h|_] ->
        ip_list = case h do
          v when is_bitstring(v) -> v
          v when is_tuple(v) -> v |> Tuple.to_list |> Enum.join(".")
          v when is_list(h) -> v |> to_charlist() |> to_string()
          v -> "#{v}"
        end
        [f|_] = String.split(ip_list, ",")
        String.trim(f)
      [] -> conn.remote_ip |> Tuple.to_list |> Enum.join(".")
      nil ->  conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    end
  end # end get_ip/1

  #-------------------------
  # force_put/3
  #-------------------------
  def force_put(nil, [h], v), do: %{h => v}
  def force_put(nil, [h|_] = p, v), do: force_put(%{h => %{}}, p, v)
  def force_put(entity, [h], v), do: put_in(entity, [h], v)
  def force_put(entity, path, v) when is_list(path) do
    try do
      put_in(entity, path, v)
    rescue
      _exception ->
        [entity, _] = Enum.slice(path, 0..-2)
                      |> Enum.reduce([entity, []],
                           fn(x, [e, p]) ->
                             a = p ++ [x]
                             cond do
                               get_in(e, a) -> [e, a]
                               true -> [put_in(e, a, %{}), a]
                             end
                           end)
        put_in(entity, path, v)
    end
  end
end
