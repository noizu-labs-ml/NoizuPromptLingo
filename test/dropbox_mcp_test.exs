defmodule DropboxMCPTest do
  use ExUnit.Case, async: false
  import Noizu.MCP.Test

  alias DropboxMCP.Access
  alias DropboxMCP.Client
  alias DropboxMCP.Test.FinchStub
  alias Noizu.Dropbox.Client, as: DropboxClient

  setup do
    Client.put(DropboxClient.new(access_token: "test-token"))

    Application.put_env(:noizu_dropbox, :request_fun, &http_stub/1)

    on_exit(fn ->
      Client.clear()
      Application.delete_env(:noizu_dropbox, :request_fun)
    end)

    %{client: connect(DropboxMCP.Server)}
  end

  test "lists filesystem tools", %{client: client} do
    assert {:ok, tools} = list_tools(client)
    names = Enum.map(tools, & &1.name)

    for expected <- [
          "dropbox_list_folder",
          "dropbox_read_file",
          "dropbox_write_file",
          "dropbox_create_folder",
          "dropbox_move",
          "dropbox_copy",
          "dropbox_delete",
          "dropbox_search",
          "dropbox_get_current_account"
        ] do
      assert expected in names
    end
  end

  test "dropbox_list_folder", %{client: client} do
    assert {:ok, result} = call_tool(client, "dropbox_list_folder", %{"path" => ""})
    assert result.is_error == false, inspect(result)
    assert [%{type: :text, text: text}] = result.content
    assert text =~ "readme.md"
  end

  test "dropbox_read_file", %{client: client} do
    assert {:ok, result} = call_tool(client, "dropbox_read_file", %{"path" => "/readme.md"})
    assert result.is_error == false, inspect(result)
    assert [%{type: :text, text: text}] = result.content
    assert text =~ "hello dropbox"
  end

  test "writes are disabled by default", %{client: client} do
    assert {:ok, result} =
             call_tool(client, "dropbox_write_file", %{
               "path" => "/notes.txt",
               "content" => "hi",
               "mode" => "overwrite"
             })

    assert result.is_error == true
    assert [%{type: :text, text: text}] = result.content
    assert text =~ "DROPBOX_MCP_WRITES=1"
  end

  test "dropbox_delete requires confirm even when writes are on", %{client: client} do
    enable_writes()

    assert {:ok, result} =
             call_tool(client, "dropbox_delete", %{"path" => "/c.txt", "confirm" => false})

    assert result.is_error == true
    assert [%{type: :text, text: text}] = result.content
    assert text =~ "confirm"
  end

  test "path jail rejects paths outside default_root", %{client: client} do
    Application.put_env(:dropbox_mcp, :default_root, "/docs")
    on_exit(fn -> Application.put_env(:dropbox_mcp, :default_root, "") end)

    assert {:ok, result} =
             call_tool(client, "dropbox_read_file", %{"path" => "/secret.txt"})

    assert result.is_error == true
    assert [%{type: :text, text: text}] = result.content
    assert text =~ "outside default_root"
  end

  test "dropbox_write_file", %{client: client} do
    enable_writes()

    assert {:ok, result} =
             call_tool(client, "dropbox_write_file", %{
               "path" => "/notes.txt",
               "content" => "hi",
               "mode" => "overwrite"
             })

    assert result.is_error == false, inspect(result)
    assert [%{type: :text, text: text}] = result.content
    assert text =~ "notes.txt"
  end

  test "dropbox_create_folder", %{client: client} do
    enable_writes()

    assert {:ok, result} =
             call_tool(client, "dropbox_create_folder", %{"path" => "/projects"})

    assert result.is_error == false, inspect(result)
  end

  test "dropbox_move copy delete", %{client: client} do
    enable_writes()

    assert {:ok, r1} =
             call_tool(client, "dropbox_move", %{
               "from_path" => "/a.txt",
               "to_path" => "/b.txt"
             })

    assert r1.is_error == false, inspect(r1)

    assert {:ok, r2} =
             call_tool(client, "dropbox_copy", %{
               "from_path" => "/b.txt",
               "to_path" => "/c.txt"
             })

    assert r2.is_error == false, inspect(r2)

    assert {:ok, r3} =
             call_tool(client, "dropbox_delete", %{"path" => "/c.txt", "confirm" => true})

    assert r3.is_error == false, inspect(r3)
  end

  test "dropbox_get_current_account", %{client: client} do
    assert {:ok, result} = call_tool(client, "dropbox_get_current_account", %{})
    assert result.is_error == false, inspect(result)
    assert [%{type: :text, text: text}] = result.content
    assert text =~ "user@example.com"
  end

  test "path normalization" do
    assert Client.normalize_path(nil) == ""
    assert Client.normalize_path("") == ""
    assert Client.normalize_path("/") == ""
    assert Client.normalize_path("docs") == "/docs"
    assert Client.normalize_path("/docs") == "/docs"
    assert Client.normalize_path("/docs/./a/../b") == "/docs/b"
    assert Client.normalize_path("/docs/../../secret") == "/secret"
  end

  test "path jail under default_root" do
    Application.put_env(:dropbox_mcp, :default_root, "/docs")
    on_exit(fn -> Application.put_env(:dropbox_mcp, :default_root, "") end)

    assert Access.jail_path(nil) == {:ok, "/docs"}
    assert Access.jail_path("") == {:ok, "/docs"}
    assert Access.jail_path("/docs") == {:ok, "/docs"}
    assert Access.jail_path("/docs/a.txt") == {:ok, "/docs/a.txt"}
    assert {:error, msg} = Access.jail_path("/other")
    assert msg =~ "outside default_root"
    assert {:error, _} = Access.jail_path("/docs/../secret")
    assert {:error, _} = Access.jail_path("/docs2")
  end

  test "DROPBOX_MCP_WRITES env enables writes" do
    refute Access.writes_enabled?()
    System.put_env("DROPBOX_MCP_WRITES", "1")
    on_exit(fn -> System.delete_env("DROPBOX_MCP_WRITES") end)
    assert Access.writes_enabled?()
  end

  defp enable_writes do
    Application.put_env(:dropbox_mcp, :writes, true)
    on_exit(fn -> Application.put_env(:dropbox_mcp, :writes, false) end)
  end

  # ---------------------------------------------------------------------------
  # Cross-process HTTP stub (via :noizu_dropbox, :request_fun)
  # ---------------------------------------------------------------------------

  defp http_stub(%{url: url, body: body, headers: headers}) do
    uri = URI.parse(url)
    path = uri.path || ""

    cond do
      String.contains?(path, "/files/list_folder") and not String.contains?(path, "continue") ->
        FinchStub.json(200, %{
          "entries" => [
            %{
              ".tag" => "file",
              "name" => "readme.md",
              "path_display" => "/readme.md",
              "id" => "id:1",
              "size" => 13
            }
          ],
          "cursor" => "cur",
          "has_more" => false
        })

      String.contains?(path, "/files/create_folder_v2") ->
        FinchStub.json(200, %{
          "metadata" => %{
            ".tag" => "folder",
            "name" => "projects",
            "path_display" => "/projects",
            "id" => "id:f"
          }
        })

      String.contains?(path, "/files/move_v2") ->
        FinchStub.json(200, %{
          "metadata" => %{
            ".tag" => "file",
            "name" => "b.txt",
            "path_display" => "/b.txt",
            "id" => "1"
          }
        })

      String.contains?(path, "/files/copy_v2") ->
        FinchStub.json(200, %{
          "metadata" => %{
            ".tag" => "file",
            "name" => "c.txt",
            "path_display" => "/c.txt",
            "id" => "2"
          }
        })

      String.contains?(path, "/files/delete_v2") ->
        FinchStub.json(200, %{
          "metadata" => %{
            ".tag" => "file",
            "name" => "c.txt",
            "path_display" => "/c.txt",
            "id" => "2"
          }
        })

      String.contains?(path, "/users/get_current_account") ->
        FinchStub.json(200, %{
          "account_id" => "dbid:1",
          "email" => "user@example.com",
          "name" => %{"display_name" => "User"},
          "account_type" => %{".tag" => "pro"}
        })

      String.contains?(path, "/files/download") ->
        FinchStub.download(
          %{
            ".tag" => "file",
            "name" => "readme.md",
            "path_display" => "/readme.md",
            "id" => "id:1",
            "size" => 13
          },
          "hello dropbox"
        )

      String.contains?(path, "/files/upload") ->
        assert body == "hi"

        FinchStub.json(200, %{
          ".tag" => "file",
          "name" => "notes.txt",
          "path_display" => "/notes.txt",
          "id" => "id:n",
          "size" => 2
        })

      true ->
        FinchStub.json(404, %{
          error_summary: "unexpected #{path} headers=#{inspect(headers)}"
        })
    end
  end
end
