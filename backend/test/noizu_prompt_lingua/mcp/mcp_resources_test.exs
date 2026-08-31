defmodule NoizuPromptLingua.MCPResourcesTest do
  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.MCPResources

  @org Ecto.UUID.generate()
  @proj Ecto.UUID.generate()

  defp resource_attrs(overrides \\ %{}) do
    Map.merge(
      %{
        "uri" => "notes://tobor/handbook",
        "name" => "Tobor Handbook",
        "description" => "How tobor works",
        "content" => "The handbook body"
      },
      overrides
    )
  end

  defp template_attrs(overrides \\ %{}) do
    Map.merge(
      %{
        "uri_template" => "notes://tobor/pages/{page}",
        "name" => "Tobor Page",
        "description" => "Page lookup"
      },
      overrides
    )
  end

  test "resource changeset requires uri/name/content and defaults mime_type" do
    {:ok, resource} = MCPResources.create_resource(resource_attrs())
    assert resource.mime_type == "text/plain"

    assert {:error, %Ecto.Changeset{}} =
             MCPResources.create_resource(resource_attrs(%{"content" => nil}))

    assert {:error, %Ecto.Changeset{}} =
             MCPResources.create_resource(resource_attrs(%{"uri" => nil}))
  end

  test "resource CRUD by id + scoping" do
    {:ok, resource} = MCPResources.create_resource(resource_attrs())

    assert {:ok, updated} =
             MCPResources.update_resource(resource.id, %{"content" => "v2"})

    assert updated.content == "v2"
    assert {:error, :not_found} = MCPResources.update_resource(Ecto.UUID.generate(), %{})
    assert {:ok, _} = MCPResources.delete_resource(resource.id)
    assert {:error, :not_found} = MCPResources.delete_resource(resource.id)
  end

  test "find_resource_by_uri resolves project → org → global with specificity" do
    {:ok, global} = MCPResources.create_resource(resource_attrs())

    {:ok, org_r} =
      MCPResources.create_resource(resource_attrs(%{"organization_id" => @org}))

    {:ok, proj_r} =
      MCPResources.create_resource(
        resource_attrs(%{"organization_id" => @org, "project_id" => @proj})
      )

    assert proj_r.id == MCPResources.find_resource_by_uri(global.uri, @org, @proj).id
    assert org_r.id == MCPResources.find_resource_by_uri(global.uri, @org, nil).id
    assert global.id == MCPResources.find_resource_by_uri(global.uri, nil, nil).id
    assert nil == MCPResources.find_resource_by_uri("notes://missing", nil, nil)
  end

  test "list_resources scopes by org and includes globals" do
    {:ok, _global} = MCPResources.create_resource(resource_attrs())
    {:ok, _scoped} = MCPResources.create_resource(resource_attrs(%{"organization_id" => @org}))

    assert length(MCPResources.list_resources(organization_id: @org)) == 2
    assert length(MCPResources.list_resources([])) == 2
    assert length(MCPResources.list_resources(organization_id: Ecto.UUID.generate())) == 1
  end

  test "template changeset requires a {param} placeholder" do
    {:ok, template} = MCPResources.create_template(template_attrs())
    assert template.mime_type == "text/plain"

    assert {:error, %Ecto.Changeset{}} =
             MCPResources.create_template(template_attrs(%{"uri_template" => "notes://plain"}))

    assert {:error, %Ecto.Changeset{}} =
             MCPResources.create_template(template_attrs(%{"name" => nil}))
  end

  test "template CRUD by id" do
    {:ok, template} = MCPResources.create_template(template_attrs())

    assert {:ok, updated} = MCPResources.update_template(template.id, %{"name" => "Renamed"})
    assert updated.name == "Renamed"

    assert {:error, :not_found} = MCPResources.update_template(Ecto.UUID.generate(), %{})
    assert {:ok, _} = MCPResources.delete_template(template.id)
    assert {:error, :not_found} = MCPResources.delete_template(template.id)
    assert [] == MCPResources.list_templates([])
  end
end
