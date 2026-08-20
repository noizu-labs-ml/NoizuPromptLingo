defmodule NoizuPromptLinguaWeb.Plugs.McpHostRedirectTest do
  use ExUnit.Case, async: false

  import Plug.Test

  @opts NoizuPromptLinguaWeb.Plugs.McpHostRedirect.init([])

  setup do
    previous = System.get_env("PHX_HOST")
    System.put_env("PHX_HOST", "tobor.locker")

    on_exit(fn ->
      if previous, do: System.put_env("PHX_HOST", previous), else: System.delete_env("PHX_HOST")
    end)

    :ok
  end

  test "redirects wiki host app/wiki paths to the apex" do
    conn =
      :get
      |> conn("/app/acme/wiki")
      |> Map.put(:host, "wiki.tobor.locker")
      |> NoizuPromptLinguaWeb.Plugs.McpHostRedirect.call(@opts)

    assert conn.halted
    assert conn.status == 302
    assert Plug.Conn.get_resp_header(conn, "location") == ["https://tobor.locker/app/acme/wiki"]
  end

  test "redirects other MCP-host browser paths too" do
    conn =
      :get
      |> conn("/login")
      |> Map.put(:host, "tickets.tobor.locker")
      |> NoizuPromptLinguaWeb.Plugs.McpHostRedirect.call(@opts)

    assert conn.halted
    assert Plug.Conn.get_resp_header(conn, "location") == ["https://tobor.locker/login"]
  end

  test "leaves wiki MCP transport on the subdomain" do
    conn =
      :get
      |> conn("/mcp")
      |> Map.put(:host, "wiki.tobor.locker")
      |> NoizuPromptLinguaWeb.Plugs.McpHostRedirect.call(@opts)

    refute conn.halted
  end

  test "leaves the apex host alone" do
    conn =
      :get
      |> conn("/app/acme/wiki")
      |> Map.put(:host, "tobor.locker")
      |> NoizuPromptLinguaWeb.Plugs.McpHostRedirect.call(@opts)

    refute conn.halted
  end
end
