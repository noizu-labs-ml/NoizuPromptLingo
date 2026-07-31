defmodule NoizuPromptLinguaWeb.VoiceAssistantController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Authz

  def approval_script(conn, %{"org_id" => org_id} = params) do
    user_id = get_user_id(conn)

    case Authz.authorize(user_id, "organization", org_id, "viewer") do
      {:ok, _} ->
        transcript = params["transcript"] || ""
        title = normalize_title(params["title"], transcript)
        ticket_type = normalize_ticket_type(params["ticket_type"])
        description = normalize_description(params["description"], transcript)
        project_id = clean_optional(params["project_id"])

        script =
          build_ticket_create_script(%{
            "organization" => org_id,
            "project_id" => project_id,
            "title" => title,
            "ticket_type" => ticket_type,
            "description" => description
          })

        json(conn, %{
          approval_script: script,
          execution_enabled: false,
          preview: %{
            endpoint: "tobor-tickets",
            command: "Ticket.Create",
            organization: org_id,
            project_id: project_id,
            title: title,
            ticket_type: ticket_type,
            description: description
          }
        })

      {:error, :not_a_member} ->
        conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})

      {:error, _} ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  defp build_ticket_create_script(args) do
    call_args =
      args
      |> Enum.reject(fn {_key, value} -> is_nil(value) or value == "" end)
      |> Enum.map(fn {key, value} -> "#{key}=#{encode_string(value)}" end)
      |> Enum.join(", ")

    """
    {{#endpoint "tobor-tickets"}}
      transport = "local"
    {{/endpoint}}

    {{#vars}}
      ticket : object?
    {{/vars}}

    {{#step "Create ticket" confirm="review voice draft before create"}}
      {{assign ticket = call("tobor-tickets", "Ticket.Create", #{call_args})}}
    {{/step}}

    {{#outputs}}
      ticket_id = ticket.id
      ticket_title = ticket.title
      ticket_type = ticket.ticket_type
    {{/outputs}}
    """
  end

  defp normalize_title(title, transcript) do
    (clean_optional(title) || clean_optional(transcript) || "Untitled voice capture")
    |> String.replace(~r/\s+/, " ")
    |> String.slice(0, 140)
  end

  defp normalize_description(description, transcript) do
    clean_optional(description) || clean_optional(transcript)
  end

  defp normalize_ticket_type(ticket_type)
       when ticket_type in ["task", "bug", "story", "epic"],
       do: ticket_type

  defp normalize_ticket_type(_), do: "task"

  defp clean_optional(value) when is_binary(value) do
    value = String.trim(value)
    if value == "", do: nil, else: value
  end

  defp clean_optional(_), do: nil

  defp encode_string(value) when is_binary(value) do
    escaped =
      value
      |> String.replace("\\", "\\\\")
      |> String.replace("\"", "\\\"")
      |> String.replace("\n", "\\n")

    "\"#{escaped}\""
  end

  defp get_user_id(conn) do
    case NoizuPromptLingua.Guardian.Plug.current_resource(conn) do
      %NoizuPromptLingua.Users.Sessions.UserSession{user: {:ref, _, id}} -> id
      %NoizuPromptLingua.Users.Sessions.UserSession{user: %{id: id}} -> id
      _ -> nil
    end
  end
end
