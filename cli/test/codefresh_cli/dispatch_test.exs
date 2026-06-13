defmodule CodefreshCli.DispatchTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  test "no args prints usage and returns user-error (1)" do
    out = capture_io(fn -> assert CodefreshCli.run([]) == 1 end)
    assert out =~ "Usage:"
  end

  test "--help prints usage and returns 0" do
    out = capture_io(fn -> assert CodefreshCli.run(["--help"]) == 0 end)
    assert out =~ "Usage:"
    assert out =~ "login"
    assert out =~ "import"
    assert out =~ "run"
  end

  test "--version prints version and returns 0" do
    out = capture_io(fn -> assert CodefreshCli.run(["--version"]) == 0 end)
    assert out =~ "codefresh"
  end

  test "unknown command returns user-error (1)" do
    stderr = capture_io(:stderr, fn ->
      capture_io(fn -> assert CodefreshCli.run(["bogus-cmd"]) == 1 end)
    end)

    assert stderr =~ "unknown command"
  end

  test "logout is idempotent (safe to call with no config)" do
    tmp = Path.join(System.tmp_dir!(), "cf_logout_#{:erlang.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    System.put_env("CODEFRESH_HOME", tmp)

    try do
      out = capture_io(fn -> assert CodefreshCli.run(["logout"]) == 0 end)
      assert out =~ "logged out"
    after
      System.delete_env("CODEFRESH_HOME")
      File.rm_rf!(tmp)
    end
  end
end
