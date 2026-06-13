defmodule DirenvConfig.MergeTest do
  use ExUnit.Case, async: true

  alias DirenvConfig.Merge

  describe "deep_merge/2" do
    test "overlay replaces scalar" do
      assert Merge.deep_merge(%{"a" => 1}, %{"a" => 2}) == %{"a" => 2}
    end

    test "adds new keys" do
      assert Merge.deep_merge(%{"a" => 1}, %{"b" => 2}) == %{"a" => 1, "b" => 2}
    end

    test "recursive map merge" do
      base = %{"db" => %{"host" => "localhost", "port" => 5432}}
      overlay = %{"db" => %{"port" => 3306, "name" => "mydb"}}

      assert Merge.deep_merge(base, overlay) == %{
               "db" => %{"host" => "localhost", "port" => 3306, "name" => "mydb"}
             }
    end

    test "list overlay replaces base" do
      base = %{"tags" => ["a", "b"]}
      overlay = %{"tags" => ["x"]}
      assert Merge.deep_merge(base, overlay) == %{"tags" => ["x"]}
    end

    test "non-map base is replaced by overlay" do
      assert Merge.deep_merge("old", %{"new" => true}) == %{"new" => true}
    end
  end

  describe "strip_tombstones/1" do
    test "tombstone strips subtree" do
      data = %{"a" => 1, "remove_me" => %{"_dc_pruned" => true}}
      assert Merge.strip_tombstones(data) == %{"a" => 1}
    end

    test "nested tombstone" do
      data = %{
        "top" => %{
          "keep" => "yes",
          "drop" => %{"_dc_pruned" => true}
        }
      }

      assert Merge.strip_tombstones(data) == %{"top" => %{"keep" => "yes"}}
    end

    test "top-level tombstone returns nil" do
      assert Merge.strip_tombstones(%{"_dc_pruned" => true}) == nil
    end

    test "tombstones in lists" do
      data = %{"items" => [%{"_dc_pruned" => true}, "kept"]}
      assert Merge.strip_tombstones(data) == %{"items" => [nil, "kept"]}
    end
  end

  describe "deep_merge_multi/1" do
    test "empty list returns nil" do
      assert Merge.deep_merge_multi([]) == nil
    end

    test "single element returns stripped copy" do
      input = %{"a" => 1, "b" => %{"_dc_pruned" => true}}
      assert Merge.deep_merge_multi([input]) == %{"a" => 1}
    end

    test "folds left-to-right" do
      layers = [
        %{"a" => 1, "b" => 2},
        %{"b" => 20, "c" => 3},
        %{"c" => 30, "d" => 4}
      ]

      assert Merge.deep_merge_multi(layers) == %{"a" => 1, "b" => 20, "c" => 30, "d" => 4}
    end

    test "multi merge with tombstones" do
      layers = [
        %{"a" => 1, "b" => %{"x" => 10}},
        %{"b" => %{"_dc_pruned" => true}, "c" => 3}
      ]

      assert Merge.deep_merge_multi(layers) == %{"a" => 1, "c" => 3}
    end
  end
end
