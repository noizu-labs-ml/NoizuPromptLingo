defmodule NoizuPromptLingua.TRP.Shapes do
  @moduledoc """
  TRP JSON (atom keys, per docs/api/shared-key-api.md §4) → NPL legacy shapes.

  Every mapping is defensive: fields NPL callers historically read stay present
  (with nil/[] defaults) even when TRP's `*_to_json` omits them, so downstream
  `Map.get`/dot-access never crashes on a shape gap.
  """

  @doc """
  TRP item JSON → the ticket-shaped map `Domains.Tickets.PMBridge` used to emit
  (old `Noizu.PM.Schema.Items.Item` struct fields + `ticket_type` alias).
  """
  def item(json) when is_map(json) do
    type = json[:item_type] || json["item_type"]

    %{
      id: json[:id],
      key: json[:key],
      number: json[:number],
      organization_id: json[:organization_id],
      project_id: json[:project_id],
      title: json[:title],
      description: json[:description],
      item_type: type,
      ticket_type: type,
      status: json[:status],
      priority: json[:priority],
      assignee: json[:assignee],
      reporter: json[:reporter],
      custom_fields: json[:custom_fields] || %{},
      owner_user_id: Map.get(json, :owner_user_id),
      tags: Map.get(json, :tags) || [],
      rank: json[:rank],
      start_date: json[:start_date],
      due_date: json[:due_date],
      estimate: json[:estimate],
      queue_id: json[:queue_id],
      parent_id: json[:parent_id],
      stage_id: json[:stage_id],
      iteration_id: json[:iteration_id],
      lock_version: Map.get(json, :lock_version),
      inserted_at: json[:inserted_at],
      updated_at: json[:updated_at],
      queue: Map.get(json, :queue),
      parent: Map.get(json, :parent)
    }
  end

  @doc "TRP org JSON → `%{id, slug, name}` (spec §4.1)."
  def organization(json) when is_map(json) do
    %{
      id: json[:id],
      slug: json[:slug],
      name: json[:name],
      role: Map.get(json, :role),
      owner: Map.get(json, :owner)
    }
  end

  @doc "TRP project JSON → atom-keyed project map (Resolve/controllers)."
  def project(json) when is_map(json) do
    %{
      id: json[:id],
      organization_id: json[:organization_id],
      name: json[:name],
      slug: json[:slug],
      description: json[:description],
      status: json[:status],
      settings: Map.get(json, :settings) || %{},
      default_methodology: Map.get(json, :default_methodology),
      key_prefix: Map.get(json, :key_prefix),
      archived_at: Map.get(json, :archived_at),
      inserted_at: json[:inserted_at] || json[:created_at],
      updated_at: json[:updated_at]
    }
  end

  @doc """
  TRP project JSON → the STRING-keyed map legacy `Projects.list_for_user/2`
  returned (raw-SQL shape). `role_name`/`inherited_from_org`/`default_methodology`
  have no TRP shared-key equivalent (identity gap) → nil.
  """
  def project_for_user(json) when is_map(json) do
    %{
      "id" => json[:id],
      "organization_id" => json[:organization_id],
      "name" => json[:name],
      "slug" => json[:slug],
      "description" => json[:description],
      "status" => json[:status],
      "created_at" => json[:inserted_at] || json[:created_at],
      "role_name" => nil,
      "inherited_from_org" => nil,
      "default_methodology" => Map.get(json, :default_methodology),
      "key_prefix" => Map.get(json, :key_prefix)
    }
  end

  @doc "TRP field-definition JSON → atom-keyed map in `TicketFieldDefinition` struct shape."
  def field_definition(json) when is_map(json) do
    %{
      id: json[:id],
      organization_id: json[:organization_id],
      project_id: json[:project_id],
      slug: json[:slug],
      label: json[:label],
      field_type: json[:field_type],
      options: json[:options] || %{},
      default_value: json[:default_value],
      description: json[:description],
      disabled: Map.get(json, :disabled) || false,
      inserted_at: json[:inserted_at],
      updated_at: json[:updated_at]
    }
  end

  @doc """
  TRP type-definition JSON → atom-keyed map in `TicketTypeDefinition` struct
  shape, with `type_fields` preloaded in `{ticket_field_definition, required,
  position}` join shape so `Definitions.type_field_list/1` keeps working.
  """
  def type_definition(json) when is_map(json) do
    %{
      id: json[:id],
      organization_id: json[:organization_id],
      project_id: json[:project_id],
      slug: json[:slug],
      name: json[:name],
      description: json[:description],
      icon: json[:icon],
      color: Map.get(json, :color),
      status_workflow: json[:status_workflow],
      disabled: Map.get(json, :disabled) || false,
      deleted_at: Map.get(json, :deleted_at),
      inserted_at: json[:inserted_at],
      updated_at: json[:updated_at],
      type_fields: type_fields(json[:fields] || [])
    }
  end

  defp type_fields(fields) do
    Enum.map(fields, fn f ->
      %{
        position: f[:position] || 0,
        required: Map.get(f, :required) || false,
        ticket_field_definition: field_definition(f)
      }
    end)
  end
end
