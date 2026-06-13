defmodule CodefreshCli.ConfigTest do
  use ExUnit.Case, async: false

  alias CodefreshCli.Config

  setup do
    tmp = Path.join(System.tmp_dir!(), "codefresh_cli_test_#{:erlang.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    prev = System.get_env("CODEFRESH_HOME")
    System.put_env("CODEFRESH_HOME", tmp)

    on_exit(fn ->
      if prev, do: System.put_env("CODEFRESH_HOME", prev), else: System.delete_env("CODEFRESH_HOME")
      File.rm_rf!(tmp)
    end)

    {:ok, tmp: tmp}
  end

  test "load returns defaults when no file", %{tmp: _tmp} do
    assert {:ok, cfg} = Config.load()
    assert cfg[:api_url] == "https://api.codefre.sh"
    refute Map.has_key?(cfg, :token)
  end

  test "save/load roundtrip with 0600 perms", %{tmp: _tmp} do
    cfg = %{api_url: "https://example.test", token: "abc", org: "acme"}
    assert :ok = Config.save(cfg)

    # file exists at expected path
    assert File.exists?(Config.path())

    # perms are 0600 (on POSIX)
    {:ok, stat} = File.stat(Config.path())
    mode = Bitwise.band(stat.mode, 0o777)
    assert mode == 0o600

    assert {:ok, loaded} = Config.load()
    assert loaded[:token] == "abc"
    assert loaded[:org] == "acme"
    assert loaded[:api_url] == "https://example.test"
  end

  test "env var overrides take precedence over disk" do
    cfg = %{api_url: "https://disk.test", token: "disk-token", org: "disk-org"}
    assert :ok = Config.save(cfg)

    System.put_env("CODEFRESH_API_TOKEN", "env-token")
    System.put_env("CODEFRESH_API_URL", "https://env.test")

    try do
      assert {:ok, loaded} = Config.load()
      assert loaded[:token] == "env-token"
      assert loaded[:api_url] == "https://env.test"
      assert loaded[:org] == "disk-org"
    after
      System.delete_env("CODEFRESH_API_TOKEN")
      System.delete_env("CODEFRESH_API_URL")
    end
  end

  test "require_token errors when missing" do
    assert {:error, :auth, msg} = Config.require_token(%{})
    assert msg =~ "not logged in"
  end

  test "require_org errors when missing" do
    assert {:error, :user, msg} = Config.require_org(%{})
    assert msg =~ "missing org"

    assert {:ok, "acme"} = Config.require_org(%{org: "acme"})
    assert {:ok, "override"} = Config.require_org(%{org: "acme"}, org: "override")
  end

  test "delete removes the file" do
    cfg = %{token: "x"}
    assert :ok = Config.save(cfg)
    assert File.exists?(Config.path())
    assert :ok = Config.delete()
    refute File.exists?(Config.path())
  end
end
