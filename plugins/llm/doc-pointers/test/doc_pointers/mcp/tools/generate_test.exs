defmodule DocPointers.MCP.Tools.GenerateTest do
  use ExUnit.Case

  alias DocPointers.MCP.Tools.Generate
  alias DocPointers.Store

  setup do
    tmp_dir = System.tmp_dir!() |> Path.join("doc_pointers_gen_test_#{:rand.uniform(100_000)}")
    File.mkdir_p!(tmp_dir)
    Store.set_root(tmp_dir)
    Application.put_env(:doc_pointers, :mcp_writes, true)

    on_exit(fn ->
      Application.delete_env(:doc_pointers, :mcp_writes)
      File.rm_rf!(tmp_dir)
    end)

    {:ok, root: tmp_dir}
  end

  describe "call/2" do
    test "generates a pointer with full UUID and token" do
      args = %{
        file_path: "lib/my_app/auth.ex",
        function_name: "login",
        description: "Authenticates user credentials"
      }

      {:ok, result} = Generate.call(args, nil)

      assert is_binary(result.uuid)
      assert String.length(result.uuid) == 36
      assert is_binary(result.token)
      assert String.length(result.token) == 4
      assert result.marker == "⟦#{result.token}⟧"
      assert result.file_path == "lib/my_app/auth.ex"
      assert result.function == "login"
    end

    test "persists the pointer to store" do
      args = %{
        file_path: "lib/repo.ex",
        function_name: "get",
        description: "Fetches a record"
      }

      {:ok, result} = Generate.call(args, nil)

      stored = Store.get(result.uuid)
      assert stored != nil
      assert stored.token == result.token
      assert stored.description == "Fetches a record"
    end

    test "includes optional class" do
      args = %{
        file_path: "lib/repo.ex",
        function_name: "insert",
        description: "Inserts a record",
        class: "MyApp.Repo"
      }

      {:ok, result} = Generate.call(args, nil)
      assert result.class == "MyApp.Repo"
    end

    test "deterministic with same inputs" do
      args = %{
        file_path: "lib/stable.ex",
        function_name: "stable_fn",
        description: "A stable function"
      }

      {:ok, r1} = Generate.call(args, nil)

      # Second call with same annotation name will collide on token,
      # so it will retry with attempt=1 and get a different UUID
      {:ok, r2} = Generate.call(args, nil)
      refute r1.uuid == r2.uuid
    end
  end
end
