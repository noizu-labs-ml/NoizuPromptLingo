defmodule DirenvConfig.PathTest do
  use ExUnit.Case, async: true

  alias DirenvConfig.Path

  describe "parse/1" do
    test "simple key" do
      assert Path.parse("name") == [{:key, "name"}]
    end

    test "dotted path" do
      assert Path.parse("a.b.c") == [{:key, "a"}, {:key, "b"}, {:key, "c"}]
    end

    test "index" do
      assert Path.parse("items[0]") == [{:key, "items"}, {:index, 0}]
    end

    test "negative index" do
      assert Path.parse("items[-1]") == [{:key, "items"}, {:index, -1}]
    end

    test "wildcard" do
      assert Path.parse("endpoints[*].host") == [
               {:key, "endpoints"},
               :wildcard,
               {:key, "host"}
             ]
    end

    test "length" do
      assert Path.parse("items.length") == [{:key, "items"}, :length]
    end

    test "chained brackets" do
      assert Path.parse("matrix[0][1]") == [{:key, "matrix"}, {:index, 0}, {:index, 1}]
    end

    test "mixed path" do
      assert Path.parse("folder[5].person.mobile") == [
               {:key, "folder"},
               {:index, 5},
               {:key, "person"},
               {:key, "mobile"}
             ]
    end

    test "empty string" do
      assert Path.parse("") == []
    end

    test "length as first token is a key" do
      assert Path.parse("length") == [{:key, "length"}]
    end
  end

  describe "get/2" do
    test "simple key" do
      assert Path.get(%{"name" => "alice"}, "name") == {:ok, "alice"}
    end

    test "nested dot" do
      data = %{"db" => %{"host" => "localhost", "port" => 5432}}
      assert Path.get(data, "db.host") == {:ok, "localhost"}
      assert Path.get(data, "db.port") == {:ok, 5432}
    end

    test "missing key" do
      assert Path.get(%{"a" => 1}, "b") == :error
    end

    test "array index" do
      data = %{"items" => ["alpha", "beta", "gamma"]}
      assert Path.get(data, "items[0]") == {:ok, "alpha"}
      assert Path.get(data, "items[2]") == {:ok, "gamma"}
    end

    test "negative index" do
      data = %{"items" => ["alpha", "beta", "gamma"]}
      assert Path.get(data, "items[-1]") == {:ok, "gamma"}
      assert Path.get(data, "items[-2]") == {:ok, "beta"}
    end

    test "out of bounds" do
      data = %{"items" => ["a"]}
      assert Path.get(data, "items[5]") == :error
      assert Path.get(data, "items[-5]") == :error
    end

    test "length of list" do
      data = %{"items" => ["a", "b", "c"]}
      assert Path.get(data, "items.length") == {:ok, 3}
    end

    test "length of map" do
      data = %{"m" => %{"a" => 1, "b" => 2}}
      assert Path.get(data, "m.length") == {:ok, 2}
    end

    test "wildcard" do
      data = %{
        "endpoints" => [
          %{"host" => "a.com", "port" => 80},
          %{"host" => "b.com", "port" => 443}
        ]
      }

      assert Path.get(data, "endpoints[*].host") == {:ok, ["a.com", "b.com"]}
    end

    test "chained index" do
      data = %{"matrix" => [[1, 2, 3], [4, 5, 6]]}
      assert Path.get(data, "matrix[0][1]") == {:ok, 2}
      assert Path.get(data, "matrix[1][-1]") == {:ok, 6}
    end

    test "deep nested" do
      data = %{"a" => %{"b" => %{"c" => "deep"}}}
      assert Path.get(data, "a.b.c") == {:ok, "deep"}
    end
  end

  describe "set/3" do
    test "set a simple top-level key" do
      assert Path.set(%{}, "name", "alice") == {:ok, %{"name" => "alice"}}
    end

    test "set a nested key creates intermediate maps" do
      assert Path.set(%{}, "a.b.c", 42) == {:ok, %{"a" => %{"b" => %{"c" => 42}}}}
    end

    test "set preserves existing keys" do
      data = %{"a" => %{"x" => 1}}
      assert Path.set(data, "a.y", 2) == {:ok, %{"a" => %{"x" => 1, "y" => 2}}}
    end

    test "set a list index" do
      data = %{"items" => ["a", "b", "c"]}
      assert Path.set(data, "items[1]", "B") == {:ok, %{"items" => ["a", "B", "c"]}}
    end

    test "set extends list with nils when index beyond length" do
      data = %{"items" => ["a"]}
      assert Path.set(data, "items[3]", "d") == {:ok, %{"items" => ["a", nil, nil, "d"]}}
    end

    test "set returns error on wildcard" do
      assert Path.set(%{"items" => [1, 2]}, "items[*]", 0) == {:error, :not_supported}
    end

    test "set returns error on length" do
      assert Path.set(%{"items" => [1, 2]}, "items.length", 5) == {:error, :not_supported}
    end
  end

  describe "delete/2" do
    test "delete a top-level key" do
      data = %{"a" => 1, "b" => 2}
      assert Path.delete(data, "a") == {:ok, %{"b" => 2}}
    end

    test "delete a nested key" do
      data = %{"a" => %{"b" => 1, "c" => 2}}
      assert Path.delete(data, "a.b") == {:ok, %{"a" => %{"c" => 2}}}
    end

    test "delete a list element" do
      data = %{"items" => ["a", "b", "c"]}
      assert Path.delete(data, "items[1]") == {:ok, %{"items" => ["a", "c"]}}
    end

    test "delete returns error for missing key" do
      data = %{"a" => 1}
      assert Path.delete(data, "b") == {:ok, %{"a" => 1}}
    end

    test "delete returns error for missing nested key" do
      data = %{"a" => %{"b" => 1}}
      assert Path.delete(data, "a.z") == {:ok, %{"a" => %{"b" => 1}}}
    end

    test "delete returns error for deeply missing path" do
      data = %{"a" => 1}
      assert Path.delete(data, "x.y.z") == :error
    end
  end
end
