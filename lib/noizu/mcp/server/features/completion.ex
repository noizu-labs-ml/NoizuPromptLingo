defmodule Noizu.MCP.Server.Features.Completion do
  @moduledoc false
  # Feature glue for completion/complete: parses the ref, routes to the owning
  # prompt/resource-template module, and caps values at 100 per spec.

  alias Noizu.MCP.Error
  alias Noizu.MCP.Server.Features.Prompts
  alias Noizu.MCP.UriTemplate

  @max_values 100

  def complete(server, params, ctx) do
    params = params || %{}

    with {:ok, ref} <- parse_ref(params["ref"]),
         {:ok, argument} <- parse_argument(params["argument"]) do
      case server.handle_complete(ref, argument, ctx) do
        {:ok, values} -> {:ok, render(values, [])}
        {:ok, values, opts} -> {:ok, render(values, opts)}
        {:error, %Error{} = error} -> {:error, error}
      end
    end
  end

  defp parse_ref(%{"type" => "ref/prompt", "name" => name}) when is_binary(name),
    do: {:ok, {:prompt, name}}

  defp parse_ref(%{"type" => "ref/resource", "uri" => uri}) when is_binary(uri),
    do: {:ok, {:resource_template, uri}}

  defp parse_ref(_),
    do: {:error, Error.invalid_params("completion/complete requires a valid ref")}

  defp parse_argument(%{"name" => name, "value" => value})
       when is_binary(name) and is_binary(value),
       do: {:ok, {name, value}}

  defp parse_argument(_),
    do: {:error, Error.invalid_params("completion/complete requires argument name and value")}

  defp render(values, opts) do
    values = Enum.map(values, &to_string/1)
    capped = Enum.take(values, @max_values)

    completion =
      %{"values" => capped}
      |> then(fn map ->
        case Keyword.fetch(opts, :total) do
          {:ok, total} when is_integer(total) -> Map.put(map, "total", total)
          _ -> map
        end
      end)
      |> then(fn map ->
        has_more = Keyword.get(opts, :has_more, length(values) > @max_values)
        if has_more, do: Map.put(map, "hasMore", true), else: map
      end)

    %{"completion" => completion}
  end

  @doc "Default `handle_complete`: route to registered prompt / template modules."
  def dispatch(prompts, templates, ref, {arg_name, value}, ctx) do
    case ref do
      {:prompt, name} ->
        case Prompts.find(prompts, name) do
          nil -> {:error, Error.invalid_params("Unknown prompt: #{name}")}
          {module, _opts} -> complete_prompt(module, arg_name, value, ctx)
        end

      {:resource_template, uri_template} ->
        template =
          Enum.find(templates, fn {module, _opts} ->
            module.definition().uri_template == uri_template
          end)

        case template do
          nil ->
            {:error, Error.invalid_params("Unknown resource template: #{uri_template}")}

          {module, _opts} ->
            complete_template(module, uri_template, arg_name, value, ctx)
        end
    end
  end

  defp complete_prompt(module, arg_name, value, ctx) do
    statics = module.__mcp_prompt__(:static_completions)

    cond do
      function_exported?(module, :complete, 3) ->
        module.complete(safe_arg_atom(module, arg_name), value, ctx)

      Map.has_key?(statics, arg_name) ->
        {:ok, statics[arg_name] |> Enum.filter(&String.starts_with?(&1, value))}

      true ->
        {:ok, []}
    end
  end

  defp complete_template(module, uri_template, arg_name, value, ctx) do
    variables = UriTemplate.variables(uri_template)
    variable = Enum.find(variables, fn atom -> Atom.to_string(atom) == arg_name end)

    cond do
      is_nil(variable) ->
        {:error, Error.invalid_params("Unknown template variable: #{arg_name}")}

      function_exported?(module, :complete, 3) ->
        module.complete(variable, value, ctx)

      true ->
        {:ok, []}
    end
  end

  # Prompt argument names were declared as atoms at compile time, so this
  # cannot mint new atoms for well-formed requests.
  defp safe_arg_atom(module, arg_name) do
    declared = module.definition().arguments |> Enum.map(& &1.name)

    if arg_name in declared do
      String.to_atom(arg_name)
    else
      :__unknown_argument__
    end
  end
end
