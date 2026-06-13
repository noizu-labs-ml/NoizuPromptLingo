defmodule Codefresh.Rubrics.ScoringTest do
  use ExUnit.Case, async: true

  alias Codefresh.Rubrics.Scoring

  describe "weighted_average/2 (US-056)" do
    test "normalizes unequal weights" do
      c = %{"items" => [%{"name" => "a", "weight" => 0.6}, %{"name" => "b", "weight" => 0.4}]}
      assert_in_delta Scoring.weighted_average(c, %{"a" => 0.8, "b" => 0.5}), 0.68, 1.0e-9
    end

    test "weights don't need to sum to 1" do
      c = %{"items" => [%{"name" => "a", "weight" => 3.0}, %{"name" => "b", "weight" => 1.0}]}
      # 3/(3+1) * 1.0 + 1/4 * 0.0 = 0.75
      assert Scoring.weighted_average(c, %{"a" => 1.0, "b" => 0.0}) == 0.75
    end

    test "missing subscore errors" do
      c = %{"items" => [%{"name" => "a", "weight" => 1.0}]}
      assert {:error, {:missing_subscore, "a"}} = Scoring.weighted_average(c, %{})
    end

    test "zero weights error" do
      c = %{"items" => [%{"name" => "a", "weight" => 0}]}
      assert {:error, :zero_total_weight} = Scoring.weighted_average(c, %{"a" => 1.0})
    end
  end

  describe "confidence_band/1 (US-120)" do
    test "returns mean + stddev + n for multiple samples" do
      %{n: n, mean: m, stddev: s, low: l, high: h} =
        Scoring.confidence_band([0.80, 0.82, 0.78, 0.84, 0.80])

      assert n == 5
      assert m == 0.808
      assert_in_delta(s, 0.0228, 0.0002)
      assert_in_delta(l, m - s, 0.0001)
      assert_in_delta(h, m + s, 0.0001)
    end

    test "single sample → stddev 0" do
      %{n: 1, mean: 0.5, stddev: 0.0} = Scoring.confidence_band([0.5])
    end

    test "empty input errors" do
      assert {:error, :insufficient_samples} = Scoring.confidence_band([])
    end
  end

  describe "label_for_score/2 + score_for_label/2 (US-057)" do
    setup do
      scale = %{
        "type" => "ladder",
        "values" => [
          %{"label" => "poor", "score" => 0.0},
          %{"label" => "ok", "score" => 0.5},
          %{"label" => "good", "score" => 1.0}
        ]
      }

      %{scale: scale}
    end

    test "maps score to highest-matching label", %{scale: scale} do
      assert {:ok, "poor"} = Scoring.label_for_score(scale, 0.1)
      assert {:ok, "ok"} = Scoring.label_for_score(scale, 0.6)
      assert {:ok, "good"} = Scoring.label_for_score(scale, 1.0)
    end

    test "below lowest score errors", %{scale: scale} do
      assert {:error, :no_match} = Scoring.label_for_score(scale, -0.1)
    end

    test "inverse lookup", %{scale: scale} do
      assert {:ok, 0.5} = Scoring.score_for_label(scale, "ok")
      assert {:error, :unknown_label} = Scoring.score_for_label(scale, "missing")
    end
  end
end
