defmodule DocPointers.StoreTest do
  use ExUnit.Case

  alias DocPointers.{Pointer, Store}

  setup do
    tmp_dir = System.tmp_dir!() |> Path.join("doc_pointers_test_#{:rand.uniform(100_000)}")
    File.mkdir_p!(tmp_dir)
    Store.set_root(tmp_dir)

    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    {:ok, root: tmp_dir}
  end

  describe "put and get" do
    test "stores and retrieves a pointer by UUID" do
      pointer = make_pointer("test-uuid-1", "𓳔𔐮𔘟𔄵")
      Store.put(pointer)

      result = Store.get("test-uuid-1")
      assert result.uuid == "test-uuid-1"
      assert result.token == "𓳔𔐮𔘟𔄵"
      assert result.function == "login"
    end

    test "retrieves by token" do
      pointer = make_pointer("test-uuid-2", "𓀀𓀻𓃉𓏦")
      Store.put(pointer)

      result = Store.get_by_token("𓀀𓀻𓃉𓏦")
      assert result.uuid == "test-uuid-2"
    end

    test "returns nil for unknown UUID" do
      assert Store.get("nonexistent") == nil
    end

    test "returns nil for unknown token" do
      assert Store.get_by_token("𓀀𓀀𓀀𓀀") == nil
    end
  end

  describe "token_exists?" do
    test "returns true for existing token" do
      pointer = make_pointer("uuid-exists", "𓃉𓏦𓀀𓀻")
      Store.put(pointer)

      assert Store.token_exists?("𓃉𓏦𓀀𓀻")
    end

    test "returns false for unknown token" do
      refute Store.token_exists?("𓀀𓀀𓀀𓀀")
    end
  end

  describe "update" do
    test "updates description" do
      pointer = make_pointer("uuid-update", "𓏦𓀀𓀻𓃉")
      Store.put(pointer)

      {:ok, updated} = Store.update("uuid-update", %{description: "new desc"})
      assert updated.description == "new desc"
      assert updated.function == "login"

      reloaded = Store.get("uuid-update")
      assert reloaded.description == "new desc"
    end

    test "returns error for nonexistent UUID" do
      assert Store.update("nope", %{description: "x"}) == {:error, :not_found}
    end
  end

  describe "list" do
    test "returns all pointers with total count" do
      Store.put(make_pointer("a", "𓀀𓀻𓃉𓏦", file_path: "lib/a.ex"))
      Store.put(make_pointer("b", "𓳔𔐮𔘟𔄵", file_path: "lib/b.ex"))

      {pointers, total} = Store.list()
      assert total == 2
      assert length(pointers) == 2
    end

    test "filters by file_prefix" do
      Store.put(make_pointer("c", "𓀀𓃉𓏦𓀻", file_path: "lib/auth/login.ex"))
      Store.put(make_pointer("d", "𓳔𔘟𔐮𔄵", file_path: "test/auth_test.exs"))

      {pointers, total} = Store.list(file_prefix: "lib/")
      assert total == 1
      assert hd(pointers).file_path == "lib/auth/login.ex"
    end

    test "filters by class" do
      Store.put(make_pointer("e", "𓀻𓃉𓏦𓀀", class: "MyApp.Auth"))
      Store.put(make_pointer("f", "𔐮𓳔𔘟𔄵", class: "MyApp.Repo"))

      {pointers, _} = Store.list(class: "MyApp.Auth")
      assert length(pointers) == 1
      assert hd(pointers).class == "MyApp.Auth"
    end

    test "pagination" do
      for i <- 1..5 do
        token_char = <<(0x13000 + i)::utf8>>
        token = String.duplicate(token_char, 4)
        Store.put(make_pointer("page-#{i}", token))
      end

      {pointers, total} = Store.list(limit: 2, offset: 0)
      assert total == 5
      assert length(pointers) == 2
    end
  end

  describe "persistence" do
    test "writes .meta/pointers.yaml", %{root: root} do
      Store.put(make_pointer("persist-1", "𓳔𔐮𔘟𔄵"))

      yaml_path = Path.join([root, ".meta", "pointers.yaml"])
      assert File.exists?(yaml_path)

      {:ok, data} = YamlElixir.read_from_file(yaml_path)
      assert data["pointers"]["persist-1"]["token"] == "𓳔𔐮𔘟𔄵"
    end
  end

  describe "legacy import" do
    test "imports from docs/doc-pointer-db.json", %{root: root} do
      docs_dir = Path.join(root, "docs")
      File.mkdir_p!(docs_dir)

      json = Jason.encode!(%{
        "𓀀𓀻𓃉𓏦" => %{
          "path" => "lib/auth.ex",
          "line" => 42,
          "name" => "login",
          "description" => "auto-generated pointer"
        }
      })

      File.write!(Path.join(docs_dir, "doc-pointer-db.json"), json)

      Store.set_root(root)

      all = Store.all()
      assert length(all) >= 1
      imported = Enum.find(all, fn p -> p.token == "𓀀𓀻𓃉𓏦" end)
      assert imported != nil
      assert imported.file_path == "lib/auth.ex"
      assert imported.function == "login"
    end
  end

  defp make_pointer(uuid, token, opts \\ []) do
    Pointer.new(%{
      uuid: uuid,
      token: token,
      file_path: Keyword.get(opts, :file_path, "lib/test.ex"),
      class: Keyword.get(opts, :class),
      function: Keyword.get(opts, :function, "login"),
      line: Keyword.get(opts, :line),
      description: Keyword.get(opts, :description, "test pointer")
    })
  end
end
