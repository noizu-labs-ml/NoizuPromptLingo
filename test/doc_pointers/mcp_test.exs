defmodule DocPointers.MCPTest do
  use ExUnit.Case, async: false

  import Noizu.MCP.Test

  alias DocPointers.Store

  setup do
    tmp_dir = System.tmp_dir!() |> Path.join("doc_pointers_mcp_#{:rand.uniform(100_000)}")
    File.mkdir_p!(tmp_dir)
    Store.set_root(tmp_dir)
    Application.put_env(:doc_pointers, :mcp_writes, false)

    on_exit(fn ->
      Application.delete_env(:doc_pointers, :mcp_writes)
      File.rm_rf!(tmp_dir)
    end)

    {:ok, client: connect(DocPointers.MCP)}
  end

  test "tools/list is lookup and list by default", %{client: client} do
    assert {:ok, tools} = list_tools(client)
    names = Enum.map(tools, & &1.name)

    assert "doc-pointer/lookup" in names
    assert "doc-pointer/list" in names
    refute "doc-pointer/generate" in names
    refute "doc-pointer/update" in names
  end

  test "tools/list includes generate/update when writes enabled", %{client: client} do
    Application.put_env(:doc_pointers, :mcp_writes, true)
    assert {:ok, tools} = list_tools(client)
    names = Enum.map(tools, & &1.name)

    assert "doc-pointer/generate" in names
    assert "doc-pointer/update" in names
  end
end
