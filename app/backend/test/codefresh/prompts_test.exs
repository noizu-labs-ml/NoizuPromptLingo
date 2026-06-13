defmodule Codefresh.PromptsTest do
  use Codefresh.DataCase, async: true

  import Codefresh.Fixtures
  alias Codefresh.Prompts

  defp with_org do
    %{user: user, organization: org} = org_with_owner()
    %{user: user, org: org}
  end

  defp create!(org, user, attrs \\ %{}) do
    defaults = %{
      "name" => "Greeter #{System.unique_integer([:positive])}",
      "organization_id" => org.id,
      "created_by_user_id" => user.id
    }

    {:ok, p} = Prompts.create_prompt(Map.merge(defaults, stringify(attrs)))
    p
  end

  defp stringify(m), do: for({k, v} <- m, into: %{}, do: {to_string(k), v})

  describe "create_prompt/1 (US-009)" do
    test "auto-derives slug from name" do
      %{org: org, user: u} = with_org()

      assert {:ok, p} =
               Prompts.create_prompt(%{
                 "name" => "Hello World!",
                 "organization_id" => org.id,
                 "created_by_user_id" => u.id
               })

      assert p.slug == "hello-world"
      assert p.current_version_id == nil
    end

    test "slug unique per org" do
      %{org: org, user: u} = with_org()
      _ = create!(org, u, %{slug: "dup", name: "First"})

      assert {:error, cs} =
               Prompts.create_prompt(%{
                 "name" => "Second",
                 "slug" => "dup",
                 "organization_id" => org.id
               })

      assert "has already been taken" in errors_on(cs).slug
    end

    test "cross-org slug collision allowed" do
      %{org: org1, user: u1} = with_org()
      %{org: org2, user: u2} = with_org()
      _ = create!(org1, u1, %{slug: "same", name: "One"})

      assert {:ok, _} =
               Prompts.create_prompt(%{
                 "name" => "Two",
                 "slug" => "same",
                 "organization_id" => org2.id,
                 "created_by_user_id" => u2.id
               })
    end
  end

  describe "publish_version/2 (US-010)" do
    test "inserts v1 and advances current_version_id" do
      %{org: org, user: u} = with_org()
      prompt = create!(org, u)

      assert {:ok, :published, v} =
               Prompts.publish_version(prompt, %{body: "Hello!", published_by_user_id: u.id})

      assert v.version_number == 1

      reloaded = Prompts.get_prompt!(org.id, prompt.id)
      assert reloaded.current_version_id == v.id
    end

    test "monotonic version numbers" do
      %{org: org, user: u} = with_org()
      prompt = create!(org, u)

      {:ok, :published, v1} = Prompts.publish_version(prompt, %{body: "one"})
      {:ok, :published, v2} = Prompts.publish_version(prompt, %{body: "two"})
      {:ok, :published, v3} = Prompts.publish_version(prompt, %{body: "three"})
      assert [v1.version_number, v2.version_number, v3.version_number] == [1, 2, 3]
    end

    test "identical body → noop returning existing version" do
      %{org: org, user: u} = with_org()
      prompt = create!(org, u)

      {:ok, :published, v1} = Prompts.publish_version(prompt, %{body: "same"})
      assert {:ok, :noop, v_same} = Prompts.publish_version(prompt, %{body: "same"})
      assert v_same.id == v1.id
    end

    test "rejects body with undeclared template vars" do
      %{org: org, user: u} = with_org()
      prompt = create!(org, u)

      assert {:error, :undeclared_vars, ["city", "name"]} =
               Prompts.publish_version(prompt, %{body: "Hi {{name}} from {{city}}"})
    end

    test "accepts body with fully-declared vars (US-048)" do
      %{org: org, user: u} = with_org()
      prompt = create!(org, u)

      assert {:ok, :published, v} =
               Prompts.publish_version(prompt, %{
                 body: "Hi {{name}}",
                 template_vars: %{"name" => %{"required" => true, "description" => "user name"}}
               })

      assert v.template_vars == %{"name" => %{"required" => true, "description" => "user name"}}
    end
  end

  describe "resolve_current_version/2 (US-011)" do
    test ":not_published when head has no version" do
      %{org: org, user: u} = with_org()
      prompt = create!(org, u)
      assert {:error, :not_published} = Prompts.resolve_current_version(org.id, prompt.id)
    end

    test "returns the pinned version after publish" do
      %{org: org, user: u} = with_org()
      prompt = create!(org, u)
      {:ok, :published, v} = Prompts.publish_version(prompt, %{body: "hi"})
      assert {:ok, resolved} = Prompts.resolve_current_version(org.id, prompt.id)
      assert resolved.id == v.id
    end

    test "cross-org prompt lookup returns :not_found" do
      %{org: org1, user: u1} = with_org()
      %{org: org2} = with_org()
      prompt = create!(org1, u1)
      assert {:error, :not_found} = Prompts.resolve_current_version(org2.id, prompt.id)
    end

    test "pinnable?/2 enforces org ownership" do
      %{org: org1, user: u1} = with_org()
      %{org: org2} = with_org()
      prompt = create!(org1, u1)
      {:ok, :published, v} = Prompts.publish_version(prompt, %{body: "x"})
      assert Prompts.pinnable?(org1.id, v.id)
      refute Prompts.pinnable?(org2.id, v.id)
    end
  end

  describe "list_prompts/2 (US-050)" do
    test "hides archived by default" do
      %{org: org, user: u} = with_org()
      keep = create!(org, u, %{name: "Keep"})
      hide = create!(org, u, %{name: "Hide"})
      {:ok, _} = Prompts.archive_prompt(hide)

      names = Prompts.list_prompts(org.id) |> Enum.map(& &1.prompt.name)
      assert names == [keep.name]
    end

    test "substring search over name" do
      %{org: org, user: u} = with_org()
      _ = create!(org, u, %{name: "Greeter", slug: "greeter"})
      _ = create!(org, u, %{name: "Summarizer", slug: "summarizer"})

      names = Prompts.list_prompts(org.id, search: "sum") |> Enum.map(& &1.prompt.name)
      assert names == ["Summarizer"]
    end

    test "only_published filter" do
      %{org: org, user: u} = with_org()
      published = create!(org, u, %{name: "Published", slug: "published"})
      _draft = create!(org, u, %{name: "Draft", slug: "draft"})
      {:ok, :published, _} = Prompts.publish_version(published, %{body: "body"})

      names = Prompts.list_prompts(org.id, only_published: true) |> Enum.map(& &1.prompt.name)
      assert names == ["Published"]
    end

    test "usage_count is 0 when no script_nodes pin any version" do
      %{org: org, user: u} = with_org()
      _ = create!(org, u)
      [%{usage_count: uc}] = Prompts.list_prompts(org.id)
      assert uc == 0
    end
  end

  defp errors_on(%Ecto.Changeset{} = cs) do
    Ecto.Changeset.traverse_errors(cs, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
