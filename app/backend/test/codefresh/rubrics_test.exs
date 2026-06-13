defmodule Codefresh.RubricsTest do
  use Codefresh.DataCase, async: true

  import Codefresh.Fixtures
  alias Codefresh.{Prompts, Rubrics}

  defp published_prompt_version(org, user) do
    {:ok, prompt} =
      Prompts.create_prompt(%{
        "name" => "Judge Prompt #{System.unique_integer([:positive])}",
        "organization_id" => org.id,
        "created_by_user_id" => user.id
      })

    {:ok, :published, v} =
      Prompts.publish_version(prompt, %{body: "Score the output.", published_by_user_id: user.id})

    v
  end

  defp create_rubric!(org, user, attrs \\ %{}) do
    defaults = %{
      "name" => "Rubric #{System.unique_integer([:positive])}",
      "organization_id" => org.id,
      "created_by_user_id" => user.id
    }

    {:ok, r} = Rubrics.create_rubric(Map.merge(defaults, attrs))
    r
  end

  describe "create_rubric/1 (US-033)" do
    test "auto-derives slug" do
      %{user: user, organization: org} = org_with_owner()

      assert {:ok, r} =
               Rubrics.create_rubric(%{
                 "name" => "Tone Rubric!",
                 "organization_id" => org.id,
                 "created_by_user_id" => user.id
               })

      assert r.slug == "tone-rubric"
      assert r.current_version_id == nil
    end
  end

  describe "publish_version/2 (US-033)" do
    test "publishes with default scale + no criteria" do
      %{user: user, organization: org} = org_with_owner()
      pv = published_prompt_version(org, user)
      rubric = create_rubric!(org, user)

      assert {:ok, :published, v} =
               Rubrics.publish_version(rubric, %{
                 judge_prompt_version_id: pv.id,
                 judge_model: "anthropic:claude-sonnet-4-5",
                 published_by_user_id: user.id
               })

      assert v.version_number == 1
      assert v.scale["type"] == "continuous"
      assert v.criteria == %{}

      reloaded = Rubrics.get_rubric!(org.id, rubric.id)
      assert reloaded.current_version_id == v.id
    end

    test "identical config → noop" do
      %{user: user, organization: org} = org_with_owner()
      pv = published_prompt_version(org, user)
      rubric = create_rubric!(org, user)

      attrs = %{judge_prompt_version_id: pv.id, judge_model: "m"}
      {:ok, :published, v1} = Rubrics.publish_version(rubric, attrs)
      assert {:ok, :noop, v_same} = Rubrics.publish_version(rubric, attrs)
      assert v_same.id == v1.id
    end

    test "monotonic version numbers" do
      %{user: user, organization: org} = org_with_owner()
      pv = published_prompt_version(org, user)
      rubric = create_rubric!(org, user)

      {:ok, :published, _} =
        Rubrics.publish_version(rubric, %{judge_prompt_version_id: pv.id, judge_model: "a"})

      {:ok, :published, v2} =
        Rubrics.publish_version(rubric, %{judge_prompt_version_id: pv.id, judge_model: "b"})

      {:ok, :published, v3} =
        Rubrics.publish_version(rubric, %{judge_prompt_version_id: pv.id, judge_model: "c"})

      assert v2.version_number == 2
      assert v3.version_number == 3
    end

    test "rejects judge_prompt_version_id from another org" do
      %{user: user_a, organization: org_a} = org_with_owner()
      %{user: user_b, organization: org_b} = org_with_owner()
      pv_a = published_prompt_version(org_a, user_a)

      rubric_b = create_rubric!(org_b, user_b)

      assert {:error, :judge_prompt_not_pinnable} =
               Rubrics.publish_version(rubric_b, %{
                 judge_prompt_version_id: pv_a.id,
                 judge_model: "m"
               })
    end

    test "missing required field" do
      %{user: user, organization: org} = org_with_owner()
      rubric = create_rubric!(org, user)

      assert {:error, {:required, :judge_prompt_version_id}} =
               Rubrics.publish_version(rubric, %{judge_model: "x"})
    end
  end

  describe "resolve_current_version/2 + pinnable?/2 (US-034)" do
    test ":not_published before first publish" do
      %{user: user, organization: org} = org_with_owner()
      rubric = create_rubric!(org, user)
      assert {:error, :not_published} = Rubrics.resolve_current_version(org.id, rubric.id)
    end

    test "pinnable?/2 enforces tenant boundary" do
      %{user: user_a, organization: org_a} = org_with_owner()
      %{user: _u_b, organization: org_b} = org_with_owner()
      pv = published_prompt_version(org_a, user_a)
      rubric = create_rubric!(org_a, user_a)

      {:ok, :published, rv} =
        Rubrics.publish_version(rubric, %{judge_prompt_version_id: pv.id, judge_model: "m"})

      assert Rubrics.pinnable?(org_a.id, rv.id)
      refute Rubrics.pinnable?(org_b.id, rv.id)
    end
  end
end
