# W8 definitions import — JSON export → prod TRP via the shared-key plane.
#
# Usage (from backend/):
#   TRP_API_BASE_URL=https://app.therobotplans.com \
#   TRP_SHARED_KEY=trp_sk_... \
#   mix run priv/w8_import_definitions.exs w8_definitions_export.json
#
# Idempotent, keyed by org+slug: existing TRP definitions are skipped, missing
# rows are created. UUIDs are NOT forced — TRP items reference types/fields BY
# SLUG (W0), so slug fidelity is the invariant; the export UUIDs ride the
# create body as a hint (TRP is free to ignore them). Global rows (org-NULL on
# NPL) are replicated into every org in key scope — v1 divergence, documented
# in docs/pm-core-cutover.md.
#
# NOTE: project-scoped NPL rows cannot be mapped 1:1 yet (NPL project UUIDs
# differ from TRP project ids); they are SKIPPED and reported, never guessed.

alias NoizuPromptLingua.TRP.Client

[path] = System.argv()
export = path |> File.read!() |> Jason.decode!()

{:ok, %{"organizations" => trp_orgs}} = Client.request(:get, "/api/v1/organizations")
org_id_by_slug = Map.new(trp_orgs, fn o -> {o["slug"], o["id"]} end)
IO.puts("TRP orgs in key scope: #{Enum.map_join(trp_orgs, ", ", & &1["slug"])}")

stats = %{created: 0, skipped: 0, failed: 0, unmapped_project_rows: 0}

add = fn stats, key -> Map.update!(stats, key, &(&1 + 1)) end

list_existing = fn org_id, kind ->
  case Client.request(:get, "/api/v1/organizations/#{org_id}/definitions/#{kind}") do
    {:ok, json} when is_map(json) ->
      (json[kind] || json |> Map.values() |> Enum.find(&is_list/1) || [])
      |> Map.new(&{&1["slug"], &1})

    {:error, e} ->
      IO.puts("  !! list #{kind} failed for org #{org_id}: #{inspect(e)}")
      %{}
  end
end

import_group = fn slug, group, org_id, stats ->
  IO.puts("== #{slug} -> TRP org #{org_id}")

  {field_id_by_slug, stats} =
    Enum.reduce(group["fields"], {list_existing.(org_id, "fields"), stats}, fn f, {acc, st} ->
      if Map.has_key?(acc, f["slug"]) do
        {acc, add.(st, :skipped)}
      else
        body = %{
          "slug" => f["slug"],
          "label" => f["label"],
          "field_type" => f["field_type"],
          "options" => f["options"] || %{},
          "default_value" => f["default_value"],
          "description" => f["description"],
          "disabled" => f["disabled"],
          "id" => f["id"]
        }

        case Client.request(:post, "/api/v1/organizations/#{org_id}/definitions/fields", json: body) do
          {:ok, %{"field" => created}} ->
            st = if f["project_id"], do: add.(st, :unmapped_project_rows), else: st
            {Map.put(acc, f["slug"], created), add.(st, :created)}

          {:error, e} ->
            IO.puts("  !! field #{f["slug"]}: #{inspect(e)}")
            {acc, add.(st, :failed)}
        end
      end
    end)

  existing_types = list_existing.(org_id, "types")

  stats =
    Enum.reduce(group["types"], stats, fn t, st ->
      if Map.has_key?(existing_types, t["slug"]) do
        add.(st, :skipped)
      else
        if t["project_id"], do: IO.puts("  ?? type #{t["slug"]} is project-scoped — SKIPPED (no project mapping)")

        fields =
          if t["project_id"] do
            []
          else
            Enum.map(t["fields"] || [], fn tf ->
              case Map.get(field_id_by_slug, tf["slug"]) do
                %{"id" => id} when is_binary(id) ->
                  %{"id" => id, "required" => tf["required"], "position" => tf["position"]}

                _ ->
                  IO.puts("  ?? type #{t["slug"]}: field slug #{tf["slug"]} unresolved; skipping assoc")
                  nil
              end
            end)
            |> Enum.reject(&is_nil/1)
          end

        body = %{
          "slug" => t["slug"],
          "name" => t["name"],
          "description" => t["description"],
          "icon" => t["icon"],
          "status_workflow" => t["status_workflow"],
          "disabled" => t["disabled"],
          "fields" => fields,
          "id" => t["id"]
        }

        case Client.request(:post, "/api/v1/organizations/#{org_id}/definitions/types", json: body) do
          {:ok, _} -> add.(st, :created)
          {:error, e} ->
            IO.puts("  !! type #{t["slug"]}: #{inspect(e)}")
            add.(st, :failed)
        end
      end
    end)

  stats
end

org_targets =
  Enum.flat_map(export["orgs"] || %{}, fn {slug, group} ->
    case Map.get(org_id_by_slug, slug) do
      nil ->
        IO.puts("!! org slug #{slug} not in TRP key scope — SKIPPED")
        []

      org_id ->
        [{slug, group, org_id}]
    end
  end)

# Global rows replicate into every org in key scope (v1 divergence).
global = export["global"]
global_targets = Enum.map(trp_orgs, fn o -> {"global(#{o["slug"]})", global, o["id"]} end)

final =
  Enum.reduce(global_targets ++ org_targets, stats, fn {slug, group, org_id}, st ->
    import_group.(slug, group, org_id, st)
  end)

IO.puts("DONE " <> Jason.encode!(final))
System.halt(if(final.failed > 0, do: 1, else: 0))
