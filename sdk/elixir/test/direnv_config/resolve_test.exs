defmodule DirenvConfig.ResolveTest do
  use ExUnit.Case, async: false

  alias DirenvConfig.Resolve

  setup do
    tmp = Path.join(System.tmp_dir!(), "dc_resolve_test_#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)

    on_exit(fn ->
      File.rm_rf!(tmp)
    end)

    {:ok, store: tmp}
  end

  defp write_layer(store, config, layer, data) do
    config_dir = Path.join(store, config)
    File.mkdir_p!(config_dir)
    File.write!(Path.join(config_dir, "#{layer}.yaml"), Ymlr.document!(data))
  end

  describe "resolve_active/2" do
    test "merges base + local layers", %{store: store} do
      write_layer(store, "app", "base", %{"host" => "localhost", "port" => 3000})
      write_layer(store, "app", "local", %{"port" => 4000, "debug" => true})

      assert {:ok, merged} = Resolve.resolve_active(store, "app")
      assert merged["host"] == "localhost"
      assert merged["port"] == 4000
      assert merged["debug"] == true
    end

    test "respects DC_ENV", %{store: store} do
      original = System.get_env("DC_ENV")

      try do
        System.put_env("DC_ENV", "staging")
        write_layer(store, "svc", "base", %{"env" => "base", "shared" => true})
        write_layer(store, "svc", "staging", %{"env" => "staging"})

        assert {:ok, merged} = Resolve.resolve_active(store, "svc")
        assert merged["env"] == "staging"
        assert merged["shared"] == true
      after
        case original do
          nil -> System.delete_env("DC_ENV")
          val -> System.put_env("DC_ENV", val)
        end
      end
    end

    test "skips missing layers", %{store: store} do
      write_layer(store, "minimal", "base", %{"only" => "base"})

      assert {:ok, merged} = Resolve.resolve_active(store, "minimal")
      assert merged == %{"only" => "base"}
    end

    test "writes .active file", %{store: store} do
      write_layer(store, "cfg", "base", %{"key" => "value"})

      assert {:ok, _} = Resolve.resolve_active(store, "cfg")

      active_path = Path.join([store, "cfg", ".active"])
      assert File.exists?(active_path)

      {:ok, active_data} = YamlElixir.read_from_file(active_path)
      assert active_data["key"] == "value"
    end

    test "returns merged value", %{store: store} do
      write_layer(store, "ret", "base", %{"a" => 1})
      write_layer(store, "ret", "local", %{"b" => 2})

      assert {:ok, merged} = Resolve.resolve_active(store, "ret")
      assert merged["a"] == 1
      assert merged["b"] == 2
    end

    test "empty store returns empty map", %{store: store} do
      config_dir = Path.join(store, "empty")
      File.mkdir_p!(config_dir)

      assert {:ok, %{}} = Resolve.resolve_active(store, "empty")
    end
  end
end
