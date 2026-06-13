defmodule Codefresh.PersonasTest do
  use Codefresh.DataCase, async: true

  alias Codefresh.Personas
  alias Codefresh.Personas.{Persona, PersonaVersion, StarterLibrary}

  import Codefresh.Fixtures

  describe "create_persona/1 + publish_version/2 (US-035)" do
    test "creates head + publishes v1 with tone tag" do
      %{organization: org} = org_with_owner()

      {:ok, persona} =
        Personas.create_persona(%{
          "organization_id" => org.id,
          "name" => "Hostile Hank",
          "slug" => "hostile-hank"
        })

      assert %Persona{current_version_id: nil} = persona

      {:ok, :published, v} =
        Personas.publish_version(persona, %{tone: "hostile", description: "Angry user"})

      assert %PersonaVersion{version_number: 1, tone: "hostile"} = v

      reloaded = Personas.get_persona!(org.id, persona.id)
      assert reloaded.current_version_id == v.id
    end

    test "republishing identical body is a noop" do
      %{organization: org} = org_with_owner()
      {:ok, p} = Personas.create_persona(%{"organization_id" => org.id, "name" => "Hank"})

      {:ok, :published, v1} = Personas.publish_version(p, %{tone: "hostile"})
      {:ok, :noop, v2} = Personas.publish_version(p, %{tone: "hostile"})
      assert v1.id == v2.id
    end
  end

  describe "publish_version/2 with system preamble (US-053)" do
    test "pins a same-org prompt_version as preamble" do
      %{organization: org, user: user} = org_with_owner()

      {:ok, prompt} =
        Codefresh.Prompts.create_prompt(%{
          "organization_id" => org.id,
          "created_by_user_id" => user.id,
          "name" => "Persona Preamble"
        })

      {:ok, :published, prompt_v} =
        Codefresh.Prompts.publish_version(prompt, %{
          body: "You are roleplaying a hostile user.",
          published_by_user_id: user.id
        })

      {:ok, persona} = Personas.create_persona(%{"organization_id" => org.id, "name" => "Hank"})

      {:ok, :published, pv} =
        Personas.publish_version(persona, %{
          tone: "hostile",
          system_prompt_version_id: prompt_v.id
        })

      assert pv.system_prompt_version_id == prompt_v.id
    end

    test "rejects cross-org prompt_version as preamble" do
      %{organization: org_a} = org_with_owner()
      %{organization: org_b, user: user_b} = org_with_owner()

      {:ok, prompt_b} =
        Codefresh.Prompts.create_prompt(%{
          "organization_id" => org_b.id,
          "created_by_user_id" => user_b.id,
          "name" => "Other Org"
        })

      {:ok, :published, prompt_bv} =
        Codefresh.Prompts.publish_version(prompt_b, %{
          body: "hello",
          published_by_user_id: user_b.id
        })

      {:ok, persona} = Personas.create_persona(%{"organization_id" => org_a.id, "name" => "Hank"})

      assert {:error, :preamble_not_pinnable} =
               Personas.publish_version(persona, %{
                 tone: "hostile",
                 system_prompt_version_id: prompt_bv.id
               })
    end
  end

  describe "import_from_starter/3 (US-055)" do
    test "deep-copies a starter into caller's org" do
      %{organization: org} = org_with_owner()

      {:ok, %{persona: p, version: v}} = Personas.import_from_starter(org.id, "hostile")

      assert p.organization_id == org.id
      assert String.starts_with?(p.slug, "hostile-")
      assert v.tone == "hostile"
      assert v.metadata == %{"imported_from_starter" => "hostile"}
    end

    test "rejects unknown starter slug" do
      %{organization: org} = org_with_owner()
      assert {:error, :not_found} = Personas.import_from_starter(org.id, "no-such-starter")
    end

    test "StarterLibrary ships 6 default tones" do
      slugs = Enum.map(StarterLibrary.list(), & &1.slug)

      assert Enum.sort(slugs) ==
               Enum.sort([
                 "broken-english",
                 "hostile",
                 "confused-novice",
                 "adversarial",
                 "over-specific",
                 "context-switch"
               ])
    end
  end

  describe "pinnable?/2" do
    test "true for same-org versions, false for cross-org" do
      %{organization: org_a} = org_with_owner()
      %{organization: org_b} = org_with_owner()

      {:ok, p} = Personas.create_persona(%{"organization_id" => org_a.id, "name" => "A"})
      {:ok, :published, v} = Personas.publish_version(p, %{tone: "hostile"})

      assert Personas.pinnable?(org_a.id, v.id)
      refute Personas.pinnable?(org_b.id, v.id)
    end
  end
end
