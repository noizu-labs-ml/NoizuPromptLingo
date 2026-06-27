defmodule NoizuPromptLingua.Domains.Notifications.Tools.Watch do
  use Noizu.MCP.Server.Tool,
    name: "Notifications.Watch",
    description:
      "Watch or unwatch an entity for notifications, optionally with a filter " <>
        "(substring or {\"type\":\"regex\",\"pattern\":...}) so only matching updates notify.",
    hidden: true,
    category: "Notifications"

  input do
    field :organization, :string, description: "Organization slug or UUID (context)"
    field :persona, :string, required: true, description: "Persona slug doing the watching"
    field :entity_type, :string, required: true, description: "Entity type, e.g. chat_room, ticket, artifact"
    field :entity_id, :string, required: true, description: "Entity UUID"
    field :action, :string, description: "watch (default) or unwatch"
    field :filter, :string, description: "Optional substring, or a JSON object {\"type\":\"regex\",\"pattern\":...}"
  end

  alias NoizuPromptLingua.Services.Watch
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    persona = Args.get(args, :persona)
    entity_type = Args.get(args, :entity_type)
    entity_id = Args.get(args, :entity_id)
    action = Args.get(args, :action) || "watch"
    filter = Args.get(args, :filter)

    # Organization is contextual only — watches are keyed by entity, not org.
    _org_id = Resolve.organization_id(Args.get(args, :organization))

    cond do
      is_nil(persona) ->
        {:error, "persona is required"}

      is_nil(entity_type) or is_nil(entity_id) ->
        {:error, "entity_type and entity_id are required"}

      action == "unwatch" ->
        case Watch.unwatch(entity_type, entity_id, persona) do
          {:ok, _} ->
            {:ok, %{action: "unwatch", entity_type: entity_type, entity_id: entity_id, persona: persona}}

          {:error, :not_found} ->
            {:error, "Not currently watching that entity"}
        end

      true ->
        case Watch.watch(entity_type, entity_id, persona, normalize_filter(filter)) do
          {:ok, watch} ->
            {:ok,
             %{
               action: "watch",
               id: watch.id,
               entity_type: entity_type,
               entity_id: entity_id,
               persona: persona,
               filter: watch.filter
             }}

          {:error, changeset} ->
            {:error, "Failed: #{inspect(changeset.errors)}"}
        end
    end
  end

  # A filter that arrives as a JSON string is decoded to a map so a regex filter
  # passed as text still works; a plain string stays a substring filter.
  defp normalize_filter(nil), do: nil
  defp normalize_filter(filter) when is_map(filter), do: filter

  defp normalize_filter(filter) when is_binary(filter) do
    trimmed = String.trim(filter)

    if String.starts_with?(trimmed, "{") do
      case Jason.decode(trimmed) do
        {:ok, %{} = map} -> map
        _ -> filter
      end
    else
      filter
    end
  end

  defp normalize_filter(other), do: other
end
