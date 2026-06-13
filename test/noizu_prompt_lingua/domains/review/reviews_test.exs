defmodule NoizuPromptLingua.Domains.ReviewsTest do
  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.Domains.Reviews
  alias NoizuPromptLingua.Services.Comment

  defp create_review(attrs \\ %{}) do
    defaults = %{
      artifact_id: Ecto.UUID.generate(),
      revision_id: Ecto.UUID.generate(),
      reviewer_persona: "alice"
    }
    Reviews.create(Map.merge(defaults, attrs))
  end

  describe "create/1" do
    test "creates a review" do
      assert {:ok, review} = create_review(%{title: "Code Review"})
      assert review.status == "open"
      assert review.title == "Code Review"
      assert review.reviewer_persona == "alice"
    end

    test "requires artifact_id, revision_id, reviewer_persona" do
      assert {:error, _} = Reviews.create(%{})
    end
  end

  describe "get/1" do
    test "returns review with comments and overlays" do
      {:ok, review} = create_review()
      Comment.add("review", review.id, %{content: "Looks good", author: "bob"})
      Reviews.add_overlay(%{review_id: review.id, x: 10, y: 20, comment: "Check this", persona: "bob"})

      {r, comments, overlays} = Reviews.get(review.id)
      assert r.id == review.id
      assert length(comments) == 1
      assert length(overlays) == 1
    end

    test "returns nil for missing" do
      assert is_nil(Reviews.get(Ecto.UUID.generate()))
    end
  end

  describe "complete/2" do
    test "marks review as completed" do
      {:ok, review} = create_review()
      assert {:ok, completed} = Reviews.complete(review.id, %{summary: "LGTM", verdict: "approved"})
      assert completed.status == "completed"
      assert completed.verdict == "approved"
      assert completed.summary == "LGTM"
    end

    test "returns error for missing review" do
      assert {:error, :not_found} = Reviews.complete(Ecto.UUID.generate())
    end
  end

  describe "overlays" do
    test "add_overlay/1 creates an overlay" do
      {:ok, review} = create_review()
      assert {:ok, overlay} = Reviews.add_overlay(%{
        review_id: review.id, x: 100, y: 200,
        comment: "Fix alignment", persona: "alice",
        width: 50, height: 30
      })
      assert overlay.x == 100
      assert overlay.y == 200
      assert overlay.width == 50
    end

    test "list_overlays/1 returns overlays" do
      {:ok, review} = create_review()
      Reviews.add_overlay(%{review_id: review.id, x: 10, y: 20, comment: "A", persona: "a"})
      Reviews.add_overlay(%{review_id: review.id, x: 30, y: 40, comment: "B", persona: "b"})

      overlays = Reviews.list_overlays(review.id)
      assert length(overlays) == 2
    end
  end

  describe "count_by_status/0" do
    test "returns counts" do
      {:ok, _} = create_review()
      {:ok, r2} = create_review()
      Reviews.complete(r2.id)

      counts = Reviews.count_by_status()
      assert counts["open"] >= 1
      assert counts["completed"] >= 1
    end
  end

  describe "cross-cutting integration" do
    test "comments on reviews use Comment service" do
      {:ok, review} = create_review()
      {:ok, c} = Comment.add("review", review.id, %{content: "Inline note", author: "bob", location: "line:42"})
      assert c.location == "line:42"

      comments = Comment.list("review", review.id)
      assert length(comments) == 1
    end
  end
end
