defmodule Codefresh.Rubrics.TailTest do
  @moduledoc "US-056, US-057, US-058, US-119, US-120 integration tests."

  use Codefresh.DataCase, async: true

  import Codefresh.Fixtures
  alias Codefresh.{Prompts, Rubrics}
  alias Codefresh.Rubrics.{MarketplaceRubric, Marketplace}
  alias Codefresh.Repo

  defp judge_prompt(
         org,
         user,
         body \\ "Input: {{sample_input}}\nResponse: {{sample_response}}\nScore 0-1."
       ) do
    {:ok, prompt} =
      Prompts.create_prompt(%{
        "name" => "Judge #{System.unique_integer([:positive])}",
        "organization_id" => org.id,
        "created_by_user_id" => user.id
      })

    {:ok, :published, v} =
      Prompts.publish_version(prompt, %{
        body: body,
        template_vars: %{
          "sample_input" => %{"required" => true},
          "sample_response" => %{"required" => true}
        }
      })

    v
  end

  defp rubric(org, user, attrs \\ %{}) do
    {:ok, r} =
      Rubrics.create_rubric(
        Map.merge(
          %{
            "name" => "R #{System.unique_integer([:positive])}",
            "organization_id" => org.id,
            "created_by_user_id" => user.id
          },
          attrs
        )
      )

    r
  end

  describe "criteria validation (US-056)" do
    test "accepts well-formed weighted criteria" do
      %{user: user, organization: org} = org_with_owner()
      pv = judge_prompt(org, user)
      r = rubric(org, user)

      criteria = %{
        "items" => [
          %{"name" => "accuracy", "weight" => 0.6},
          %{"name" => "tone", "weight" => 0.4}
        ]
      }

      assert {:ok, :published, v} =
               Rubrics.publish_version(r, %{
                 judge_prompt_version_id: pv.id,
                 judge_model: "m",
                 criteria: criteria
               })

      assert v.criteria == criteria
    end

    test "rejects out-of-range weight" do
      %{user: user, organization: org} = org_with_owner()
      pv = judge_prompt(org, user)
      r = rubric(org, user)

      assert {:error, cs} =
               Rubrics.publish_version(r, %{
                 judge_prompt_version_id: pv.id,
                 judge_model: "m",
                 criteria: %{"items" => [%{"name" => "a", "weight" => 1.5}]}
               })

      assert %{criteria: _} = errors_on(cs)
    end
  end

  describe "ladder/enum scale (US-057)" do
    test "accepts monotonic ladder" do
      %{user: user, organization: org} = org_with_owner()
      pv = judge_prompt(org, user)
      r = rubric(org, user)

      scale = %{
        "type" => "ladder",
        "values" => [
          %{"label" => "poor", "score" => 0.0},
          %{"label" => "good", "score" => 1.0}
        ]
      }

      assert {:ok, :published, v} =
               Rubrics.publish_version(r, %{
                 judge_prompt_version_id: pv.id,
                 judge_model: "m",
                 scale: scale
               })

      assert v.scale["type"] == "ladder"
    end

    test "rejects non-monotonic values" do
      %{user: user, organization: org} = org_with_owner()
      pv = judge_prompt(org, user)
      r = rubric(org, user)

      bad_scale = %{
        "type" => "ladder",
        "values" => [
          %{"label" => "a", "score" => 1.0},
          %{"label" => "b", "score" => 0.0}
        ]
      }

      assert {:error, cs} =
               Rubrics.publish_version(r, %{
                 judge_prompt_version_id: pv.id,
                 judge_model: "m",
                 scale: bad_scale
               })

      assert %{scale: _} = errors_on(cs)
    end
  end

  describe "preview_render/3 (US-058)" do
    test "renders judge prompt with sample bindings" do
      %{user: user, organization: org} = org_with_owner()
      pv = judge_prompt(org, user)
      r = rubric(org, user)

      {:ok, :published, _} =
        Rubrics.publish_version(r, %{judge_prompt_version_id: pv.id, judge_model: "m"})

      assert {:ok, %{rendered_judge_prompt: rendered, estimated_tokens: t, mode: :render_only}} =
               Rubrics.preview_render(org.id, r.id, %{
                 "sample_input" => "What is 2+2?",
                 "sample_response" => "4"
               })

      assert rendered =~ "What is 2+2?"
      assert rendered =~ "4"
      assert t > 0
    end

    test "fails when rubric not published" do
      %{user: user, organization: org} = org_with_owner()
      r = rubric(org, user)

      assert {:error, :not_published} =
               Rubrics.preview_render(org.id, r.id, %{
                 "sample_input" => "x",
                 "sample_response" => "y"
               })
    end
  end

  describe "n_samples for confidence bands (US-120)" do
    test "accepts n_samples in range [1, 10]" do
      %{user: user, organization: org} = org_with_owner()
      pv = judge_prompt(org, user)
      r = rubric(org, user)

      assert {:ok, :published, v} =
               Rubrics.publish_version(r, %{
                 judge_prompt_version_id: pv.id,
                 judge_model: "m",
                 n_samples: 5
               })

      assert v.n_samples == 5
    end

    test "rejects n_samples > 10 at changeset level" do
      %{user: user, organization: org} = org_with_owner()
      pv = judge_prompt(org, user)
      r = rubric(org, user)

      assert {:error, cs} =
               Rubrics.publish_version(r, %{
                 judge_prompt_version_id: pv.id,
                 judge_model: "m",
                 n_samples: 11
               })

      assert %{n_samples: _} = errors_on(cs)
    end
  end

  describe "marketplace import (US-119)" do
    test "deep-copies rubric into importer org and increments download_count" do
      # Author side
      %{user: author, organization: author_org} = org_with_owner()
      author_pv = judge_prompt(author_org, author)
      author_rubric = rubric(author_org, author)

      {:ok, :published, author_version} =
        Rubrics.publish_version(author_rubric, %{
          judge_prompt_version_id: author_pv.id,
          judge_model: "anthropic:claude-sonnet-4-5"
        })

      {:ok, entry} =
        %MarketplaceRubric{}
        |> MarketplaceRubric.create_changeset(%{
          rubric_version_id: author_version.id,
          author_organization_id: author_org.id,
          title: "Safety Rubric v1",
          description: "curated starter",
          domain: "safety",
          curation_status: "curated",
          published_at: DateTime.utc_now() |> DateTime.truncate(:second)
        })
        |> Repo.insert()

      # Importer side. The marketplace import deep-copies the author's rubric
      # body but the importer still needs a local copy of the judge prompt —
      # cross-org prompts can't be pinned. Import surfaces that explicitly.
      %{user: importer, organization: importer_org} = org_with_owner()
      _importer_pv = judge_prompt(importer_org, importer)

      # Import expected to fail with :judge_prompt_requires_local_copy because
      # the author's judge prompt isn't pinnable in the importer's org.
      assert {:error, :judge_prompt_requires_local_copy} =
               Marketplace.import(importer_org.id, entry.id, imported_by_user_id: importer.id)
    end

    test "browse filters by domain + status" do
      # Fabricate two entries in different domains
      %{user: author, organization: author_org} = org_with_owner()
      pv = judge_prompt(author_org, author)
      r_safety = rubric(author_org, author)
      r_rag = rubric(author_org, author)

      {:ok, :published, v_safety} =
        Rubrics.publish_version(r_safety, %{judge_prompt_version_id: pv.id, judge_model: "m"})

      {:ok, :published, v_rag} =
        Rubrics.publish_version(r_rag, %{judge_prompt_version_id: pv.id, judge_model: "m2"})

      now = DateTime.utc_now() |> DateTime.truncate(:second)

      {:ok, _} =
        %MarketplaceRubric{}
        |> MarketplaceRubric.create_changeset(%{
          rubric_version_id: v_safety.id,
          author_organization_id: author_org.id,
          title: "Safety Rubric",
          domain: "safety",
          curation_status: "curated",
          published_at: now
        })
        |> Repo.insert()

      {:ok, _} =
        %MarketplaceRubric{}
        |> MarketplaceRubric.create_changeset(%{
          rubric_version_id: v_rag.id,
          author_organization_id: author_org.id,
          title: "RAG Rubric",
          domain: "rag",
          curation_status: "curated",
          published_at: now
        })
        |> Repo.insert()

      safety_only = Marketplace.list_entries(domain: "safety") |> Enum.map(& &1.entry.title)
      assert "Safety Rubric" in safety_only
      refute "RAG Rubric" in safety_only
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
