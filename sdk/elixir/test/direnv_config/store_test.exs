defmodule DirenvConfig.StoreTest do
  use ExUnit.Case, async: true

  alias DirenvConfig.Store

  describe "path_to_hash/1" do
    test "simple path" do
      assert Store.path_to_hash("/Users/keith/Github/k8/projects") ==
               "Users-keith-Github-k8-projects"
    end

    test "root path" do
      assert Store.path_to_hash("/") == ""
    end

    test "single segment" do
      assert Store.path_to_hash("/tmp") == "tmp"
    end

    test "truncation for long paths" do
      segments = List.duplicate("abcdefghij", 20)
      path = "/" <> Enum.join(segments, "/")
      hash = Store.path_to_hash(path)

      assert byte_size(hash) == 209
      assert binary_part(hash, 200, 1) == "-"

      suffix = binary_part(hash, 201, 8)
      assert Regex.match?(~r/^[0-9a-f]{8}$/, suffix)
    end
  end

  describe "state_dir/0" do
    test "uses XDG_STATE_HOME when set" do
      original = System.get_env("XDG_STATE_HOME")

      try do
        System.put_env("XDG_STATE_HOME", "/custom/state")
        assert Store.state_dir() == "/custom/state/direnv-config"
      after
        case original do
          nil -> System.delete_env("XDG_STATE_HOME")
          val -> System.put_env("XDG_STATE_HOME", val)
        end
      end
    end

    test "falls back to ~/.local/state/direnv-config" do
      original = System.get_env("XDG_STATE_HOME")

      try do
        System.delete_env("XDG_STATE_HOME")
        expected = Path.join([System.user_home!(), ".local", "state", "direnv-config"])
        assert Store.state_dir() == expected
      after
        if original, do: System.put_env("XDG_STATE_HOME", original)
      end
    end
  end
end
