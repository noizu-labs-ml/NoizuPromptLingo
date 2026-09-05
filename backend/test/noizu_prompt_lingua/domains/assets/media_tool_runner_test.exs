defmodule NoizuPromptLingua.Domains.Assets.MediaToolRunnerTest do
  @moduledoc """
  MediaToolRunner dispatch plus the CLI shell-out (default impl), exercised
  through a throwaway shell script standing in for the generate-media-prompt
  binary — no external binary or provider keys needed (the seam the module was
  built for: `:media_tool_runner` / `:media_tool_bin`).

  Not covered by design: the domain-level generation flow (Assets writing the
  prompt and consuming run/3) lives in the assets domain suites; only the
  runner contract and CLI behaviors are pinned here.
  """
  use ExUnit.Case, async: false

  alias NoizuPromptLingua.Domains.Assets.MediaToolRunner

  setup do
    dir = Path.join(System.tmp_dir!(), "mtr-#{System.unique_integer([:positive])}")
    File.mkdir_p!(dir)
    on_exit(fn -> File.rm_rf!(dir) end)

    %{dir: dir}
  end

  defp script!(dir, body) do
    path = Path.join(dir, ".fake-tool.sh")
    File.write!(path, "#!/bin/sh\n#{body}\n")
    File.chmod!(path, 0o755)
    path
  end

  defp prompt!(dir) do
    path = Path.join(dir, "asset.media.prompt")
    File.write!(path, "media: test")
    path
  end

  defmodule FakeRunner do
    @moduledoc false
    @behaviour NoizuPromptLingua.Domains.Assets.MediaToolRunner

    @impl true
    def run(_prompt, _dir, _opts), do: {:ok, %{output_path: "x.png", mime: "image/png"}}
  end

  test "run/3 delegates to the configured runner impl" do
    Application.put_env(:noizu_prompt_lingua, :media_tool_runner, FakeRunner)

    on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :media_tool_runner) end)

    assert {:ok, %{output_path: "x.png", mime: "image/png"}} =
             MediaToolRunner.run("prompt", "dir")
  end

  test "CLI happy path finds the produced file and maps its mime", %{dir: dir} do
    bin = script!(dir, "echo rendered > out.png")
    Application.put_env(:noizu_prompt_lingua, :media_tool_bin, bin)

    on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :media_tool_bin) end)

    assert {:ok, %{output_path: out, mime: "image/png"}} =
             MediaToolRunner.CLI.run(prompt!(dir), dir, [])

    assert String.ends_with?(out, "out.png")
  end

  test "CLI: non-zero exit surfaces {:error, {:exit, code}}", %{dir: dir} do
    bin = script!(dir, "echo boom >&2; exit 3")
    Application.put_env(:noizu_prompt_lingua, :media_tool_bin, bin)

    on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :media_tool_bin) end)

    assert {:error, {:exit, 3}} = MediaToolRunner.CLI.run(prompt!(dir), dir, [])
  end

  test "CLI: clean exit with no produced file → {:error, :no_output}", %{dir: dir} do
    bin = script!(dir, "true")
    Application.put_env(:noizu_prompt_lingua, :media_tool_bin, bin)

    on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :media_tool_bin) end)

    assert {:error, :no_output} = MediaToolRunner.CLI.run(prompt!(dir), dir, [])
  end

  test "CLI: missing binary degrades to {:error, {:exception, _}}", %{dir: dir} do
    Application.put_env(:noizu_prompt_lingua, :media_tool_bin, Path.join(dir, "no-such-bin"))

    on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :media_tool_bin) end)

    assert {:error, {:exception, _}} = MediaToolRunner.CLI.run(prompt!(dir), dir, [])
  end

  test "CLI: hidden, candidate, directory, and prompt entries are skipped", %{dir: dir} do
    bin = script!(dir, """
    mkdir sub
    touch .genai.candidate
    echo video > out.webm
    """)

    Application.put_env(:noizu_prompt_lingua, :media_tool_bin, bin)

    on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :media_tool_bin) end)

    assert {:ok, %{output_path: out, mime: "video/webm"}} =
             MediaToolRunner.CLI.run(prompt!(dir), dir, [])

    assert String.ends_with?(out, "out.webm")
  end

  test "CLI: unknown extensions map to application/octet-stream", %{dir: dir} do
    bin = script!(dir, "echo data > out.xyz")
    Application.put_env(:noizu_prompt_lingua, :media_tool_bin, bin)

    on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :media_tool_bin) end)

    assert {:ok, %{mime: "application/octet-stream"}} =
             MediaToolRunner.CLI.run(prompt!(dir), dir, [])
  end
end
