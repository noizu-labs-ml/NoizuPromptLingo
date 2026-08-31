defmodule DocPointers.MCP.WritesTest do
  use ExUnit.Case, async: false

  alias DocPointers.MCP.Tools.{Generate, Update}
  alias DocPointers.Store

  setup do
    tmp_dir = System.tmp_dir!() |> Path.join("doc_pointers_writes_#{:rand.uniform(100_000)}")
    File.mkdir_p!(tmp_dir)
    Store.set_root(tmp_dir)
    Application.put_env(:doc_pointers, :mcp_writes, false)

    on_exit(fn ->
      Application.delete_env(:doc_pointers, :mcp_writes)
      File.rm_rf!(tmp_dir)
    end)

    {:ok, root: tmp_dir}
  end

  defp generate_args(extra \\ %{}) do
    Map.merge(
      %{
        file_path: "lib/gate.ex",
        function_name: "run",
        description: "Gate test"
      },
      extra
    )
  end

  describe "generate/update gate" do
    test "refuses writes without --write or confirm" do
      assert {:error, msg} = Generate.call(generate_args(), nil)
      assert msg =~ "--write"
    end

    test "allows generate when confirm=true" do
      assert {:ok, result} = Generate.call(generate_args(%{confirm: true}), nil)
      assert Store.get(result.uuid)
    end

    test "allows generate when mcp_writes is enabled" do
      Application.put_env(:doc_pointers, :mcp_writes, true)
      assert {:ok, result} = Generate.call(generate_args(), nil)
      assert Store.get(result.uuid)
    end

    test "update requires confirm unless writes enabled" do
      Application.put_env(:doc_pointers, :mcp_writes, true)
      {:ok, minted} = Generate.call(generate_args(%{function_name: "upd"}), nil)
      Application.put_env(:doc_pointers, :mcp_writes, false)

      assert {:error, msg} =
               Update.call(%{uuid: minted.uuid, description: "changed"}, nil)

      assert msg =~ "--write"

      assert {:ok, updated} =
               Update.call(%{uuid: minted.uuid, description: "changed", confirm: true}, nil)

      assert updated.description == "changed"
    end
  end
end
