defmodule DirenvConfig.ContractTest do
  use ExUnit.Case, async: true

  @fixtures_dir Path.expand("../../contract-tests/fixtures", __DIR__)
  @expectations_file Path.expand("../../contract-tests/expectations.yaml", __DIR__)

  setup_all do
    {:ok, expectations} = YamlElixir.read_from_file(@expectations_file)
    %{tests: expectations["tests"]}
  end

  describe "contract expectations" do
    setup %{tests: tests} do
      %{tests: tests}
    end

    test "all value lookup cases pass", %{tests: tests} do
      tests
      |> Enum.filter(&Map.has_key?(&1, "config"))
      |> Enum.filter(&Map.has_key?(&1, "expected"))
      |> Enum.each(fn tc ->
        store = Path.join(@fixtures_dir, tc["store"])
        config = tc["config"]
        path = tc["path"]

        result = DirenvConfig.Native.get(store, config, path)

        case tc["type"] do
          "null" ->
            assert result == :error,
                   "#{tc["name"]}: expected :error, got #{inspect(result)}"

          "string" ->
            assert {:ok, value} = result, "#{tc["name"]}: expected {:ok, _}, got :error"
            assert to_string(value) == to_string(tc["expected"]),
                   "#{tc["name"]}: expected #{inspect(tc["expected"])}, got #{inspect(value)}"

          "integer" ->
            assert {:ok, value} = result, "#{tc["name"]}: expected {:ok, _}, got :error"
            assert value == tc["expected"],
                   "#{tc["name"]}: expected #{tc["expected"]}, got #{inspect(value)}"

          "boolean" ->
            assert {:ok, value} = result, "#{tc["name"]}: expected {:ok, _}, got :error"
            assert value == tc["expected"],
                   "#{tc["name"]}: expected #{tc["expected"]}, got #{inspect(value)}"

          "string_array" ->
            assert {:ok, value} = result, "#{tc["name"]}: expected {:ok, _}, got :error"
            assert Enum.map(value, &to_string/1) == Enum.map(tc["expected"], &to_string/1),
                   "#{tc["name"]}: expected #{inspect(tc["expected"])}, got #{inspect(value)}"

          "integer_array" ->
            assert {:ok, value} = result, "#{tc["name"]}: expected {:ok, _}, got :error"
            assert value == tc["expected"],
                   "#{tc["name"]}: expected #{inspect(tc["expected"])}, got #{inspect(value)}"

          "map" ->
            assert {:ok, _value} = result, "#{tc["name"]}: expected {:ok, _}, got :error"
        end
      end)
    end

    test "map key expectations", %{tests: tests} do
      tests
      |> Enum.filter(&Map.has_key?(&1, "expected_keys"))
      |> Enum.each(fn tc ->
        store = Path.join(@fixtures_dir, tc["store"])
        config = tc["config"]
        path = tc["path"]

        assert {:ok, value} =
                 DirenvConfig.Native.get(store, config, path),
                 "#{tc["name"]}: expected {:ok, _}, got :error"

        assert is_map(value), "#{tc["name"]}: expected map, got #{inspect(value)}"

        Enum.each(tc["expected_keys"], fn key ->
          assert Map.has_key?(value, key),
                 "#{tc["name"]}: missing key #{inspect(key)} in #{inspect(Map.keys(value))}"
        end)
      end)
    end

    test "version expectations", %{tests: tests} do
      tests
      |> Enum.filter(&Map.has_key?(&1, "expected_version"))
      |> Enum.each(fn tc ->
        store = Path.join(@fixtures_dir, tc["store"])
        version = DirenvConfig.Version.read(store)

        assert version == tc["expected_version"],
               "#{tc["name"]}: expected version #{tc["expected_version"]}, got #{version}"
      end)
    end

    test "config listing expectations", %{tests: tests} do
      tests
      |> Enum.filter(&Map.has_key?(&1, "expected_configs"))
      |> Enum.each(fn tc ->
        store = Path.join(@fixtures_dir, tc["store"])
        assert {:ok, configs} = DirenvConfig.Native.list_configs(store)

        assert configs == tc["expected_configs"],
               "#{tc["name"]}: expected #{inspect(tc["expected_configs"])}, got #{inspect(configs)}"
      end)
    end

    test "path hash expectations", %{tests: tests} do
      tests
      |> Enum.filter(&Map.has_key?(&1, "input_path"))
      |> Enum.each(fn tc ->
        hash = DirenvConfig.Store.path_to_hash(tc["input_path"])

        assert hash == tc["expected_hash"],
               "#{tc["name"]}: expected #{inspect(tc["expected_hash"])}, got #{inspect(hash)}"
      end)
    end
  end
end
