defmodule DirenvConfig.VersionTest do
  use ExUnit.Case, async: true

  alias DirenvConfig.Version

  setup do
    tmp = Path.join(System.tmp_dir!(), "dc_version_test_#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)

    on_exit(fn ->
      File.rm_rf!(tmp)
    end)

    {:ok, store: tmp}
  end

  describe "read/1" do
    test "returns 0 when no version file exists", %{store: store} do
      assert Version.read(store) == 0
    end

    test "reads existing version", %{store: store} do
      File.write!(Path.join(store, ".version"), "5")
      assert Version.read(store) == 5
    end

    test "returns 0 for invalid content", %{store: store} do
      File.write!(Path.join(store, ".version"), "garbage")
      assert Version.read(store) == 0
    end
  end

  describe "bump/1" do
    test "bump from zero returns 1", %{store: store} do
      assert {:ok, 1} = Version.bump(store)
      assert Version.read(store) == 1
    end

    test "bump increments existing", %{store: store} do
      File.write!(Path.join(store, ".version"), "7")
      assert {:ok, 8} = Version.bump(store)
      assert Version.read(store) == 8
    end

    test "sequential bumps", %{store: store} do
      assert {:ok, 1} = Version.bump(store)
      assert {:ok, 2} = Version.bump(store)
      assert {:ok, 3} = Version.bump(store)
      assert Version.read(store) == 3
    end
  end
end
