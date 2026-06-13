defmodule Noizu.MCP.Server.Features.Prompts do
  @moduledoc false
  # Feature glue for prompts/list and prompts/get.

  alias Noizu.MCP.Error
  alias Noizu.MCP.Server.Features.Pagination
  alias Noizu.MCP.Types.{Prompt, PromptMessage}

  def list(server, params, ctx) do
    cursor = (params || %{})["cursor"]

    case server.handle_list_prompts(cursor, ctx) do
      {:ok, prompts, next_cursor} ->
        result = %{"prompts" => Enum.map(prompts, &Prompt.to_map/1)}
        result = if next_cursor, do: Map.put(result, "nextCursor", next_cursor), else: result
        {:ok, result}

      {:error, %Error{} = error} ->
        {:error, error}
    end
  end

  @doc "Default `handle_list_prompts` over registered prompt modules."
  def list_registered(registered, cursor) do
    definitions = Enum.map(registered, fn {module, opts} -> definition(module, opts) end)
    Pagination.paginate(definitions, cursor)
  end

  def get(server, params, ctx) do
    name = (params || %{})["name"]
    args = (params || %{})["arguments"] || %{}

    if is_binary(name) do
      case server.handle_get_prompt(name, args, ctx) do
        {:ok, messages} -> {:ok, render(messages, nil)}
        {:ok, messages, opts} -> {:ok, render(messages, opts[:description])}
        {:error, %Error{} = error} -> {:error, error}
      end
    else
      {:error, Error.invalid_params("prompts/get requires a prompt name")}
    end
  end

  @doc "Default `handle_get_prompt`: dispatch to a registered prompt module."
  def dispatch_get(registered, name, args, ctx) do
    case find(registered, name) do
      nil ->
        {:error, Error.invalid_params("Unknown prompt: #{name}")}

      {module, opts} ->
        definition = definition(module, opts)

        missing =
          for argument <- definition.arguments,
              argument.required,
              not Map.has_key?(args, argument.name),
              do: argument.name

        case missing do
          [] ->
            case module.get(args, ctx) do
              {:ok, messages} -> {:ok, messages, description: definition.description}
              other -> other
            end

          missing ->
            {:error,
             Error.invalid_params("Missing required arguments: #{Enum.join(missing, ", ")}")}
        end
    end
  end

  @doc "Find a registered prompt module by wire name."
  def find(registered, name) do
    Enum.find(registered, fn {module, opts} -> definition(module, opts).name == name end)
  end

  def definition(module, opts) do
    definition = module.definition()

    Enum.reduce(opts, definition, fn
      {:name, name}, acc -> %{acc | name: name}
      {:description, description}, acc -> %{acc | description: description}
      {_other, _}, acc -> acc
    end)
  end

  defp render(messages, description) do
    %{"messages" => Enum.map(messages, &PromptMessage.to_map/1)}
    |> then(fn map ->
      if description, do: Map.put(map, "description", description), else: map
    end)
  end
end
