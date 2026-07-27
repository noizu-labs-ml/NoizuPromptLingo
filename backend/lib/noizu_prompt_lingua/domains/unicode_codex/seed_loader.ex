defmodule NoizuPromptLingua.Domains.UnicodeCodex.SeedLoader do
  @moduledoc """
  Loads layered Unicode Codex seed YAML into normalized tables.
  """
  alias NoizuPromptLingua.Domains.UnicodeCodex
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Projects.Project

  def default_dir do
    Path.join(:code.priv_dir(:noizu_prompt_lingua), "unicode-codex")
  end

  def seed_all!(dir \\ default_dir()) do
    files =
      []
      |> maybe_add(Path.join(dir, "global.yaml"))
      |> Kernel.++(Path.wildcard(Path.join(dir, "organizations/*.yaml")) |> Enum.sort())
      |> Kernel.++(Path.wildcard(Path.join(dir, "projects/*/*.yaml")) |> Enum.sort())

    Enum.each(files, &seed_file!/1)
    :ok
  end

  def seed_file!(path) do
    {:ok, data} = YamlElixir.read_from_file(path)
    {scope, org_id, project_id} = resolve_scope!(Map.get(data, "scope", %{}), path)

    Enum.each(Map.get(data, "special_usages", []), fn usage ->
      usage
      |> usage_attrs(scope, org_id, project_id)
      |> UnicodeCodex.upsert_special_usage()
      |> bang!()
    end)

    elements =
      Enum.map(Map.get(data, "elements", []), fn element ->
        {:ok, row} =
          element
          |> element_attrs(scope, org_id, project_id)
          |> UnicodeCodex.upsert_element()

        {row, element}
      end)

    Enum.each(elements, fn {row, element} ->
      UnicodeCodex.replace_element_usages(
        row,
        Map.get(element, "special_usages", []),
        org_id,
        project_id
      )

      UnicodeCodex.replace_element_relations(
        row,
        Map.get(element, "relations", []),
        org_id,
        project_id
      )
    end)

    :ok
  end

  defp maybe_add(files, path), do: if(File.exists?(path), do: files ++ [path], else: files)

  defp resolve_scope!(%{"type" => "global"}, _path), do: {"global", nil, nil}

  defp resolve_scope!(%{"type" => "organization", "organization" => org_ref}, path) do
    case NoizuPromptLingua.Organizations.resolve_org_id(org_ref) do
      {:ok, org_id} -> {"organization", org_id, nil}
      _ -> raise "Unicode Codex seed #{path} references unknown organization '#{org_ref}'"
    end
  end

  defp resolve_scope!(
         %{"type" => "project", "organization" => org_ref, "project" => project_ref},
         path
       ) do
    case NoizuPromptLingua.Organizations.resolve_org_id(org_ref) do
      {:ok, org_id} ->
        case resolve_project(org_id, project_ref) do
          nil -> raise "Unicode Codex seed #{path} references unknown project '#{project_ref}'"
          project -> {"project", org_id, project.id}
        end

      _ ->
        raise "Unicode Codex seed #{path} references unknown organization '#{org_ref}'"
    end
  end

  defp resolve_scope!(scope, path),
    do: raise("Unicode Codex seed #{path} has invalid scope #{inspect(scope)}")

  defp resolve_project(org_id, ref) do
    case NoizuPromptLingua.UUID.cast(ref) do
      {:ok, uuid} -> Repo.get_by(Project, id: uuid, organization_id: org_id)
      :error -> Repo.get_by(Project, slug: ref, organization_id: org_id)
    end
  end

  defp usage_attrs(usage, scope, org_id, project_id) do
    %{
      scope: scope,
      organization_id: org_id,
      project_id: project_id,
      slug: usage["slug"],
      name: usage["name"],
      title: usage["title"],
      description: usage["description"],
      references: usage["references"] || [],
      flags: usage["flags"] || [],
      topics: usage["topics"] || []
    }
  end

  defp element_attrs(element, scope, org_id, project_id) do
    %{
      scope: scope,
      organization_id: org_id,
      project_id: project_id,
      slug: element["slug"],
      codepoint: element["codepoint"],
      char: element["char"],
      name: element["name"],
      title: element["title"],
      description: element["description"],
      meaning: element["meaning"],
      printable: Map.get(element, "printable", true),
      visibility: element["visibility"] || "glyph",
      unicode_meta: element["unicode"] || %{},
      flags: element["flags"] || [],
      topics: element["topics"] || [],
      sentiments: element["sentiments"] || [],
      aliases: element["aliases"] || [],
      search_terms: element["search_terms"] || []
    }
  end

  defp bang!({:ok, row}), do: row

  defp bang!({:error, changeset}),
    do: raise("Unicode Codex seed failed: #{inspect(changeset.errors)}")
end
