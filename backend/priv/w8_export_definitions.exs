# W8 definitions export — NPL app DB → JSON (read-only).
#
# Usage (from backend/):
#   DATABASE_URL=<prod npl ecto url via port-forward> mix run priv/w8_export_definitions.exs [out.json]
#
# Exports ticket_field_definitions / ticket_type_definitions /
# ticket_type_fields grouped by owning org (slug-resolved); org-NULL rows are
# grouped under "global". Output feeds priv/w8_import_definitions.exs.

alias Ecto.Adapters.SQL

out_path = Enum.at(System.argv(), 0) || "w8_definitions_export.json"

orgs =
  SQL.query!(NoizuPromptLingua.Repo, "SELECT id, slug FROM organizations", [])
  |> Map.get(:rows)
  |> Map.new(fn [id, slug] -> {id, slug} end)

fields =
  SQL.query!(
    NoizuPromptLingua.Repo,
    "SELECT id, organization_id, project_id, slug, label, field_type, options, default_value, description, disabled, inserted_at FROM ticket_field_definitions",
    []
  )
  |> Map.get(:rows)
  |> Enum.map(fn [id, org_id, proj_id, slug, label, ftype, options, default_value, description, disabled, inserted_at] ->
    %{
      "id" => id,
      "org_slug" => Map.get(orgs, org_id),
      "project_id" => proj_id,
      "slug" => slug,
      "label" => label,
      "field_type" => ftype,
      "options" => options,
      "default_value" => default_value,
      "description" => description,
      "disabled" => disabled,
      "inserted_at" => DateTime.to_iso8601(inserted_at)
    }
  end)

types =
  SQL.query!(
    NoizuPromptLingua.Repo,
    "SELECT id, organization_id, project_id, slug, name, description, icon, status_workflow, disabled, deleted_at, inserted_at FROM ticket_type_definitions",
    []
  )
  |> Map.get(:rows)
  |> Enum.map(fn [id, org_id, proj_id, slug, name, description, icon, workflow, disabled, deleted_at, inserted_at] ->
    %{
      "id" => id,
      "org_slug" => Map.get(orgs, org_id),
      "project_id" => proj_id,
      "slug" => slug,
      "name" => name,
      "description" => description,
      "icon" => icon,
      "status_workflow" => workflow,
      "disabled" => disabled,
      "deleted_at" => (deleted_at && DateTime.to_iso8601(deleted_at)) || nil,
      "inserted_at" => DateTime.to_iso8601(inserted_at)
    }
  end)

type_fields =
  SQL.query!(
    NoizuPromptLingua.Repo,
    "SELECT ticket_type_definition_id, ticket_field_definition_id, required, position FROM ticket_type_fields",
    []
  )
  |> Map.get(:rows)
  |> Enum.map(fn [tid, fid, required, position] ->
    %{"type_id" => tid, "field_id" => fid, "required" => required, "position" => position}
  end)

field_by_id = Map.new(fields, fn f -> {f["id"], f} end)

types_with_fields =
  Enum.map(types, fn t ->
    tfs =
      type_fields
      |> Enum.filter(&(&1["type_id"] == t["id"]))
      |> Enum.sort_by(& &1["position"])

    Map.put(t, "fields", Enum.map(tfs, fn tf ->
      f = Map.fetch!(field_by_id, tf["field_id"])
      %{"slug" => f["slug"], "required" => tf["required"], "position" => tf["position"]}
    end))
  end)

export = %{
  "exported_at" => DateTime.utc_now() |> DateTime.to_iso8601(),
  "source" => "npl app db (ticket_*_definitions)",
  "global" => %{
    "fields" => Enum.filter(fields, &is_nil(&1["org_slug"])),
    "types" => Enum.filter(types_with_fields, &is_nil(&1["org_slug"]))
  },
  "orgs" =>
    fields
    |> Enum.map(& &1["org_slug"])
    |> Enum.concat(Enum.map(types_with_fields, & &1["org_slug"]))
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Map.new(fn slug ->
      {slug,
       %{
         "fields" => Enum.filter(fields, &(&1["org_slug"] == slug)),
         "types" => Enum.filter(types_with_fields, &(&1["org_slug"] == slug))
       }}
    end)
}

File.write!(out_path, Jason.encode!(export, pretty: true))

counts =
  export["orgs"]
  |> Map.new(fn {slug, g} -> {slug, %{fields: length(g["fields"]), types: length(g["types"])}} end)
  |> Map.put("global", %{fields: length(export["global"]["fields"]), types: length(export["global"]["types"])})

IO.puts("WROTE #{out_path}")
IO.puts("census: " <> Jason.encode!(counts))
