defmodule NoizuPromptLingua.Domains.Assets.MediaToolRunner do
  @moduledoc """
  Invokes the media-tool (`generate-media-prompt`) binary to render a `.media.prompt`
  into a real asset file via the provider APIs (e146ff64 — interim real generation,
  ahead of the genai-core port). The binary reads its provider keys from the pod env.

  Swappable via `config :noizu_prompt_lingua, :media_tool_runner` so the assets domain
  is unit-testable without the binary (which ships in the deployed image, soren's
  e146ff64 (a)). `run/3` returns the produced file's path + mime; the domain reads +
  encodes the bytes.
  """
  @callback run(prompt_path :: String.t(), tmp_dir :: String.t(), opts :: keyword) ::
              {:ok, %{output_path: String.t(), mime: String.t()}} | {:error, term}

  @doc "Dispatch to the configured runner (default: the CLI shell-out)."
  def run(prompt_path, tmp_dir, opts \\ []) do
    impl().run(prompt_path, tmp_dir, opts)
  end

  defp impl, do: Application.get_env(:noizu_prompt_lingua, :media_tool_runner, __MODULE__.CLI)
end

defmodule NoizuPromptLingua.Domains.Assets.MediaToolRunner.CLI do
  @moduledoc "Default MediaToolRunner: shells out to the generate-media-prompt binary."
  @behaviour NoizuPromptLingua.Domains.Assets.MediaToolRunner
  require Logger

  @default_bin "generate-media-prompt"

  @mime %{
    "png" => "image/png", "jpg" => "image/jpeg", "jpeg" => "image/jpeg",
    "webp" => "image/webp", "gif" => "image/gif", "svg" => "image/svg+xml",
    "mp3" => "audio/mpeg", "wav" => "audio/wav", "ogg" => "audio/ogg", "flac" => "audio/flac",
    "mp4" => "video/mp4", "webm" => "video/webm", "mov" => "video/quicktime",
    "html" => "text/html", "txt" => "text/plain", "json" => "application/json", "mmd" => "text/plain"
  }

  @impl true
  def run(prompt_path, tmp_dir, _opts) do
    bin = Application.get_env(:noizu_prompt_lingua, :media_tool_bin, @default_bin)

    case System.cmd(bin, [prompt_path], cd: tmp_dir, stderr_to_stdout: true) do
      {_out, 0} ->
        case find_output(tmp_dir, prompt_path) do
          nil -> {:error, :no_output}
          path -> {:ok, %{output_path: path, mime: mime_for(path)}}
        end

      {out, code} ->
        Logger.warning("generate-media-prompt exited #{code}: #{String.slice(out, 0, 500)}")
        {:error, {:exit, code}}
    end
  rescue
    # binary missing (:enoent) or any cmd failure -> graceful error, never a crash.
    e -> {:error, {:exception, Exception.message(e)}}
  end

  # The produced asset = the first regular file in tmp that isn't the .media.prompt input
  # and isn't a hidden/candidate (.genai.*) entry. media-tool writes the active output to a
  # name-derived file alongside the prompt (resolve_output_paths/link_active).
  defp find_output(tmp_dir, prompt_path) do
    prompt_name = Path.basename(prompt_path)

    tmp_dir
    |> File.ls!()
    |> Enum.reject(&(&1 == prompt_name or String.starts_with?(&1, ".")))
    |> Enum.map(&Path.join(tmp_dir, &1))
    |> Enum.filter(&File.regular?/1)
    |> Enum.sort()
    |> List.first()
  end

  defp mime_for(path) do
    ext = path |> Path.extname() |> String.trim_leading(".") |> String.downcase()
    Map.get(@mime, ext, "application/octet-stream")
  end
end
