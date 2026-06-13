defmodule DirenvConfig.NativeTest do
  use ExUnit.Case, async: false

  @fixtures_dir Path.expand("../../../contract-tests/fixtures", __DIR__)

  describe "get/3 with simple-store" do
    @store Path.join(@fixtures_dir, "simple-store")

    test "reads a simple string" do
      assert DirenvConfig.Native.get(@store, "cluster", "name") == {:ok, "noizu"}
    end

    test "reads nested string" do
      assert DirenvConfig.Native.get(@store, "cluster", "node_pool.instance_type") ==
               {:ok, "m5.xlarge"}
    end

    test "reads integer" do
      assert DirenvConfig.Native.get(@store, "cluster", "port") == {:ok, 6443}
    end

    test "reads boolean" do
      assert DirenvConfig.Native.get(@store, "cluster", "enabled") == {:ok, true}
    end

    test "reads entire config as map" do
      assert {:ok, data} = DirenvConfig.Native.get(@store, "cluster")
      assert is_map(data)
      assert Map.has_key?(data, "name")
      assert Map.has_key?(data, "node_pool")
    end

    test "missing key returns error" do
      assert DirenvConfig.Native.get(@store, "cluster", "nonexistent") == :error
    end
  end

  describe "get/3 with nested-store" do
    @nested_store Path.join(@fixtures_dir, "nested-store")

    test "array index" do
      assert DirenvConfig.Native.get(@nested_store, "app", "endpoints[0].host") ==
               {:ok, "api.example.com"}
    end

    test "wildcard" do
      assert {:ok, hosts} =
               DirenvConfig.Native.get(@nested_store, "app", "endpoints[*].host")

      assert hosts == ["api.example.com", "internal.example.com", "backup.example.com"]
    end

    test "length" do
      assert DirenvConfig.Native.get(@nested_store, "app", "endpoints.length") == {:ok, 3}
    end

    test "chained brackets" do
      assert DirenvConfig.Native.get(@nested_store, "app", "matrix[0][1]") == {:ok, 2}
    end
  end

  describe "list_configs/1" do
    test "simple store" do
      assert DirenvConfig.Native.list_configs(Path.join(@fixtures_dir, "simple-store")) ==
               {:ok, ["cluster"]}
    end

    test "nested store" do
      assert DirenvConfig.Native.list_configs(Path.join(@fixtures_dir, "nested-store")) ==
               {:ok, ["app"]}
    end
  end

  describe "set/6" do
    setup do
      tmp = Path.join(System.tmp_dir!(), "dc_native_test_#{System.unique_integer([:positive])}")
      File.mkdir_p!(tmp)

      on_exit(fn ->
        File.rm_rf!(tmp)
      end)

      {:ok, store: tmp}
    end

    test "set writes to layer and updates .active", %{store: store} do
      assert :ok = DirenvConfig.Native.set(store, "myconfig", "db.host", "pg.local")

      # Verify the local layer was written
      layer_file = Path.join([store, "myconfig", "local.yaml"])
      assert File.exists?(layer_file)
      {:ok, layer_data} = YamlElixir.read_from_file(layer_file)
      assert layer_data["db"]["host"] == "pg.local"

      # Verify .active was created
      active_file = Path.join([store, "myconfig", ".active"])
      assert File.exists?(active_file)

      # Verify version was bumped
      assert DirenvConfig.Version.read(store) == 1
    end

    test "set with no_bump skips version bump", %{store: store} do
      assert :ok = DirenvConfig.Native.set(store, "myconfig", "key", "val", "local", true)
      assert DirenvConfig.Version.read(store) == 0
    end

    test "set to a specific layer", %{store: store} do
      assert :ok = DirenvConfig.Native.set(store, "myconfig", "env", "production", "base")

      layer_file = Path.join([store, "myconfig", "base.yaml"])
      {:ok, data} = YamlElixir.read_from_file(layer_file)
      assert data["env"] == "production"
    end
  end

  describe "unset/5" do
    setup do
      tmp = Path.join(System.tmp_dir!(), "dc_native_unset_#{System.unique_integer([:positive])}")
      File.mkdir_p!(tmp)

      on_exit(fn ->
        File.rm_rf!(tmp)
      end)

      {:ok, store: tmp}
    end

    test "unset removes key and updates .active", %{store: store} do
      # First set some keys
      :ok = DirenvConfig.Native.set(store, "cfg", "a", "1")
      :ok = DirenvConfig.Native.set(store, "cfg", "b", "2")

      version_before = DirenvConfig.Version.read(store)

      # Unset one key
      assert :ok = DirenvConfig.Native.unset(store, "cfg", ["a"])

      # Verify key was removed from layer
      layer_file = Path.join([store, "cfg", "local.yaml"])
      {:ok, data} = YamlElixir.read_from_file(layer_file)
      refute Map.has_key?(data, "a")
      assert data["b"] == 2

      # Verify version was bumped
      assert DirenvConfig.Version.read(store) > version_before
    end

    test "unset with no_bump skips version bump", %{store: store} do
      :ok = DirenvConfig.Native.set(store, "cfg", "x", "1")
      version_before = DirenvConfig.Version.read(store)

      assert :ok = DirenvConfig.Native.unset(store, "cfg", ["x"], "local", true)
      assert DirenvConfig.Version.read(store) == version_before
    end

    test "unset on nonexistent layer file is ok", %{store: store} do
      assert :ok = DirenvConfig.Native.unset(store, "cfg", ["x"])
    end
  end

  describe "bump/1" do
    setup do
      tmp = Path.join(System.tmp_dir!(), "dc_native_bump_#{System.unique_integer([:positive])}")
      File.mkdir_p!(tmp)

      on_exit(fn ->
        File.rm_rf!(tmp)
      end)

      {:ok, store: tmp}
    end

    test "bump increments version", %{store: store} do
      assert {:ok, 1} = DirenvConfig.Native.bump(store)
      assert {:ok, 2} = DirenvConfig.Native.bump(store)
    end
  end
end
