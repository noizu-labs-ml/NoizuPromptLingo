defmodule Noizu.MCP.Server.Features.Resources do
  @moduledoc false
  # Feature glue for resources/list, resources/templates/list, resources/read,
  # and subscribe checks. Direct resources match by exact URI; templates match
  # via Noizu.MCP.UriTemplate.

  alias Noizu.MCP.{Error, UriTemplate}
  alias Noizu.MCP.Server.Features.Pagination
  alias Noizu.MCP.Types.{Resource, ResourceContents, ResourceTemplate}

  # ── resources/list ────────────────────────────────────────────────────────

  def list(server, params, ctx) do
    cursor = (params || %{})["cursor"]

    case server.handle_list_resources(cursor, ctx) do
      {:ok, resources, next_cursor} ->
        result = %{"resources" => Enum.map(resources, &Resource.to_map/1)}
        result = if next_cursor, do: Map.put(result, "nextCursor", next_cursor), else: result
        {:ok, result}

      {:error, %Error{} = error} ->
        {:error, error}
    end
  end

  @doc "Default `handle_list_resources`: registered resources + enumerable templates."
  def list_registered(resources, templates, cursor, ctx) do
    direct = Enum.map(resources, fn {module, opts} -> definition(module, opts) end)

    from_templates =
      Enum.flat_map(templates, fn {module, _opts} ->
        if function_exported?(module, :list, 1) do
          case module.list(ctx) do
            {:ok, items} -> items
            {:error, _} -> []
          end
        else
          []
        end
      end)

    Pagination.paginate(direct ++ from_templates, cursor)
  end

  # ── resources/templates/list ──────────────────────────────────────────────

  def list_templates(server, params, ctx) do
    cursor = (params || %{})["cursor"]

    case server.handle_list_resource_templates(cursor, ctx) do
      {:ok, templates, next_cursor} ->
        result = %{"resourceTemplates" => Enum.map(templates, &ResourceTemplate.to_map/1)}
        result = if next_cursor, do: Map.put(result, "nextCursor", next_cursor), else: result
        {:ok, result}

      {:error, %Error{} = error} ->
        {:error, error}
    end
  end

  @doc "Default `handle_list_resource_templates` over registered template modules."
  def list_registered_templates(templates, cursor) do
    definitions = Enum.map(templates, fn {module, _opts} -> module.definition() end)
    Pagination.paginate(definitions, cursor)
  end

  # ── resources/read ────────────────────────────────────────────────────────

  def read(server, params, ctx) do
    case (params || %{})["uri"] do
      uri when is_binary(uri) ->
        case server.handle_read_resource(uri, ctx) do
          {:error, %Error{} = error} ->
            {:error, error}

          result ->
            case normalize_contents(result, uri, nil) do
              {:error, %Error{} = error} -> {:error, error}
              contents -> {:ok, %{"contents" => Enum.map(contents, &ResourceContents.to_map/1)}}
            end
        end

      _ ->
        {:error, Error.invalid_params("resources/read requires a uri")}
    end
  end

  @doc "Default `handle_read_resource`: exact URI match, then template match."
  def dispatch_read(resources, templates, uri, ctx) do
    case find(resources, templates, uri) do
      {:resource, module, _opts} ->
        module.read(uri, ctx) |> normalize_contents(uri, module.__mcp_resource__(:mime_type))

      {:template, module, vars} ->
        module.read(uri, vars, ctx)
        |> normalize_contents(uri, module.__mcp_resource_template__(:mime_type))

      nil ->
        {:error, Error.resource_not_found(uri)}
    end
  end

  @doc "Subscribe check for the default `handle_subscribe`: the URI must exist and be subscribable."
  def check_subscribe(resources, templates, uri) do
    case find(resources, templates, uri) do
      {:resource, module, _opts} ->
        if module.__mcp_resource__(:subscribable),
          do: :ok,
          else: {:error, Error.invalid_request("Resource is not subscribable: #{uri}")}

      {:template, module, _vars} ->
        if module.__mcp_resource_template__(:subscribable),
          do: :ok,
          else: {:error, Error.invalid_request("Resource is not subscribable: #{uri}")}

      nil ->
        {:error, Error.resource_not_found(uri)}
    end
  end

  defp find(resources, templates, uri) do
    direct =
      Enum.find_value(resources, fn {module, opts} ->
        if definition(module, opts).uri == uri, do: {:resource, module, opts}
      end)

    direct ||
      Enum.find_value(templates, fn {module, _opts} ->
        case UriTemplate.match(module.definition().uri_template, uri) do
          {:ok, vars} -> {:template, module, vars}
          :nomatch -> nil
        end
      end)
  end

  defp definition(module, opts) do
    definition = module.definition()

    Enum.reduce(opts, definition, fn
      {:name, name}, acc -> %{acc | name: name}
      {:description, description}, acc -> %{acc | description: description}
      {_other, _}, acc -> acc
    end)
  end

  # ── contents normalization ────────────────────────────────────────────────

  defp normalize_contents({:ok, text}, uri, mime_type) when is_binary(text),
    do: [ResourceContents.text(uri, text, mime_type: mime_type)]

  defp normalize_contents({:ok, {:blob, blob}}, uri, mime_type) when is_binary(blob),
    do: [ResourceContents.blob(uri, blob, mime_type: mime_type)]

  defp normalize_contents({:ok, %ResourceContents{} = contents}, _uri, _mime), do: [contents]

  defp normalize_contents({:ok, [%ResourceContents{} | _] = contents}, _uri, _mime),
    do: contents

  defp normalize_contents({:error, %Error{} = error}, _uri, _mime), do: {:error, error}

  defp normalize_contents([%ResourceContents{} | _] = contents, _uri, _mime), do: contents

  defp normalize_contents(other, uri, _mime) do
    raise ArgumentError,
          "invalid resource read return for #{uri}: #{inspect(other)} — expected " <>
            "{:ok, text | {:blob, binary} | ResourceContents | [ResourceContents]} | {:error, Error}"
  end
end
