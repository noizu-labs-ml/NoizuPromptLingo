defmodule Mix.Tasks.McpClientTest do
  @moduledoc """
  Pure parse_args!/1 tests for Mix.Tasks.Mcp.Client.
  No network, no server, no side effects.
  """
  use ExUnit.Case, async: true

  alias Mix.Tasks.Mcp.Client, as: McpClient

  describe "parse_args!/1 — module target" do
    test "positional module name produces {:module, atom}" do
      {target, _opts} = McpClient.parse_args!(["MyApp.MCP"])
      assert target == {:module, MyApp.MCP}
      # Module.concat always produces the Elixir-prefixed atom
      assert target == {:module, :"Elixir.MyApp.MCP"}
    end

    test "fully qualified Elixir.X.Y module name" do
      {target, _opts} = McpClient.parse_args!(["Noizu.MCP.Fixtures.Server"])
      assert target == {:module, Noizu.MCP.Fixtures.Server}
    end
  end

  describe "parse_args!/1 — stdio target" do
    test "--stdio simple command produces {:stdio, executable, opts}" do
      {target, _opts} = McpClient.parse_args!(["--stdio", "node server.js --flag"])
      assert {:stdio, "node", args: ["server.js", "--flag"], env: nil, cd: nil} = target
    end

    test "--stdio with --cd" do
      {target, _opts} = McpClient.parse_args!(["--stdio", "node server.js", "--cd", "/tmp/app"])
      assert {:stdio, "node", args: ["server.js"], env: nil, cd: "/tmp/app"} = target
    end

    test "--stdio with single --env K=V" do
      {target, _opts} = McpClient.parse_args!(["--stdio", "node s.js", "--env", "FOO=bar"])
      assert {:stdio, "node", args: ["s.js"], env: env, cd: nil} = target
      assert env == %{"FOO" => "bar"}
    end

    test "--stdio with multiple --env pairs" do
      {target, _opts} =
        McpClient.parse_args!([
          "--stdio",
          "python main.py",
          "--env",
          "KEY1=val1",
          "--env",
          "KEY2=val2"
        ])

      assert {:stdio, "python", args: ["main.py"], env: env, cd: nil} = target
      assert env["KEY1"] == "val1"
      assert env["KEY2"] == "val2"
    end

    test "--stdio with --cd and --env together" do
      {target, _opts} =
        McpClient.parse_args!([
          "--stdio",
          "node s.js",
          "--cd",
          "/var/app",
          "--env",
          "PORT=4000"
        ])

      assert {:stdio, "node", args: ["s.js"], env: %{"PORT" => "4000"}, cd: "/var/app"} = target
    end

    test "empty --stdio raises Mix.Error" do
      assert_raise Mix.Error, fn ->
        McpClient.parse_args!(["--stdio", ""])
      end
    end
  end

  describe "parse_args!/1 — url target" do
    test "--url produces {:url, url, bearer: nil}" do
      {target, _opts} = McpClient.parse_args!(["--url", "http://x/mcp"])
      assert {:url, "http://x/mcp", bearer: nil} = target
    end

    test "--url with --bearer produces {:url, url, bearer: token}" do
      {target, _opts} = McpClient.parse_args!(["--url", "http://x/mcp", "--bearer", "t"])
      assert {:url, "http://x/mcp", bearer: "t"} = target
    end
  end

  describe "parse_args!/1 — errors" do
    test "no target returns {nil, opts}" do
      {target, opts} = McpClient.parse_args!([])
      assert target == nil
      assert is_list(opts)
    end

    test "no target with extra opts still returns {nil, opts}" do
      {target, opts} = McpClient.parse_args!(["--port", "9999"])
      assert target == nil
      assert opts[:port] == 9999
    end

    test "both module and --url raises Mix.Error" do
      assert_raise Mix.Error, fn ->
        McpClient.parse_args!(["MyApp.MCP", "--url", "http://x/mcp"])
      end
    end

    test "both --stdio and --url raises Mix.Error" do
      assert_raise Mix.Error, fn ->
        McpClient.parse_args!(["--stdio", "node s.js", "--url", "http://x/mcp"])
      end
    end

    test "invalid --env (no = sign) raises Mix.Error" do
      assert_raise Mix.Error, fn ->
        McpClient.parse_args!(["--stdio", "node s.js", "--env", "INVALID"])
      end
    end

    test "invalid option flag raises Mix.Error" do
      assert_raise Mix.Error, fn ->
        McpClient.parse_args!(["--stdio", "node s.js", "--not-a-flag"])
      end
    end
  end

  describe "parse_args!/1 — extra opts" do
    test "--port is parsed into opts" do
      {_target, opts} = McpClient.parse_args!(["MyApp.MCP", "--port", "9000"])
      assert opts[:port] == 9000
    end

    test "--no-open is parsed into opts" do
      {_target, opts} = McpClient.parse_args!(["MyApp.MCP", "--no-open"])
      assert opts[:open] == false
    end

    test "--name and --version are parsed into opts" do
      {_target, opts} =
        McpClient.parse_args!([
          "MyApp.MCP",
          "--name",
          "my-inspector",
          "--version",
          "1.2.3"
        ])

      assert opts[:name] == "my-inspector"
      assert opts[:version] == "1.2.3"
    end
  end
end
