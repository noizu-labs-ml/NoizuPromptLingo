defmodule DocPointers.MCP.RuntimeTest do
  use ExUnit.Case, async: false

  alias DocPointers.MCP.Runtime

  test "parse --write and --root" do
    opts = Runtime.parse(["--write", "--root", "/tmp/proj", "--port", "9"])
    assert opts[:write] == true
    assert opts[:root] == "/tmp/proj"
    assert opts[:port] == 9
  end

  test "writes_enabled? from flag" do
    assert Runtime.writes_enabled?(write: true)
    refute Runtime.writes_enabled?([])
  end

  test "writes_enabled? from env" do
    System.put_env("DOC_POINTERS_MCP_WRITES", "1")
    on_exit(fn -> System.delete_env("DOC_POINTERS_MCP_WRITES") end)
    assert Runtime.writes_enabled?([])
  end

  test "port falls back to 4242" do
    System.delete_env("DOC_POINTERS_PORT")
    assert Runtime.port([]) == 4242
    assert Runtime.port(port: 9) == 9
  end
end
