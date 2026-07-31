defmodule NoizuPromptLingua.Domains.Assets.GenAIGenerator do
  @moduledoc """
  Generates binary-media assets (image / voice / music / video) via the genai media
  framework — `GenAI.generate_media/2` (ADR-016). Parses an entry's `.media.prompt` YAML
  into a `GenAI.Media.Request`, and the genai Router (config `:genai, :media_providers`)
  picks a registered provider for the modality: OpenAI Image (gpt-image-2), Gemini Imagen,
  OpenAI Speech (TTS), Suno (music, async), etc.

  This is the genai-core port of the asset image/media path (ede43647). The media-tool
  shell-out (`MediaToolRunner`, e146ff64) stays as the fallback for asset types genai
  doesn't serve and when no provider is registered/keyed.

  Returns:
    * `{:ok, bytes, mime}`      — sync providers (image/speech) returned inline bytes
    * `{:ok, {:job, job}}`      — async providers (Suno music) returned a `GenAI.Media.Job`
    * `{:error, reason}`        — unsupported asset type, no provider, missing key, etc.

  Swappable via `config :noizu_prompt_lingua, :genai_media_generator` for unit tests.
  """

  @callback generate(entry :: map, opts :: keyword) ::
              {:ok, binary, String.t()} | {:ok, {:job, struct}} | {:error, term}

  # Asset type -> media modality (only the true binary-media types; svg/html/diagram/
  # document are text/markup and stay on the text/media-tool path).
  @type_to_modality %{
    "image" => :image,
    "voice" => :speech,
    "music" => :music,
    "video" => :video
  }

  @doc "Whether this asset type is a binary-media type the genai path handles."
  def media_type?(asset_type), do: Map.has_key?(@type_to_modality, asset_type)

  @doc "Dispatch to the configured generator (default: the genai impl GenAIGenerator.Default)."
  def generate(entry, opts \\ []), do: impl().generate(entry, opts)

  defp impl,
    do: Application.get_env(:noizu_prompt_lingua, :genai_media_generator, __MODULE__.Default)

  @doc "Map an asset type to its media modality, or `{:error, {:unsupported_asset_type, t}}`."
  def modality(asset_type) do
    case Map.fetch(@type_to_modality, asset_type) do
      {:ok, modality} -> {:ok, modality}
      :error -> {:error, {:unsupported_asset_type, asset_type}}
    end
  end

  @doc "Build a GenAI.Media.Request from the entry's .media.prompt YAML + opts."
  def build_request(entry, modality, opts) do
    config =
      case YamlElixir.read_from_string(entry.prompt_yaml || "") do
        {:ok, %{} = cfg} -> cfg
        _ -> %{}
      end

    prompt = get_in(config, ["prompt", "text"]) || entry.title || ""

    # Provider settings: prompt YAML provider_options, overlaid with any per-org
    # config settings (opts[:settings], string-keyed from JSONB) — explicit opts win.
    settings =
      (get_in(config, ["prompt", "provider_options"]) || %{})
      |> Map.merge(opts[:settings] || %{})
      |> atomize()

    # `service` in the prompt selects a chat LLM; for media the modality + registry decide,
    # so only an explicit module/atom provider override is honored (else the Router picks).
    # The per-org MediaProviders config supplies that module (and an api_key).
    provider = if is_atom(opts[:provider]), do: opts[:provider], else: nil

    struct(GenAI.Media.Request,
      output: modality,
      prompt: prompt,
      provider: provider,
      model: opts[:model] || config["model"],
      settings: settings,
      api_key: blank_to_nil(opts[:api_key])
    )
  end

  defp blank_to_nil(v) when v in [nil, ""], do: nil
  defp blank_to_nil(v), do: v

  # Prompt YAML keys are strings; provider settings (voice/size/format/...) want atom keys.
  defp atomize(map) when is_map(map) do
    Map.new(map, fn
      {k, v} when is_binary(k) -> {String.to_atom(k), v}
      {k, v} -> {k, v}
    end)
  end

  defp atomize(_), do: %{}
end

defmodule NoizuPromptLingua.Domains.Assets.GenAIGenerator.Default do
  @moduledoc "Default GenAIGenerator: routes the entry through GenAI.generate_media/2."
  @behaviour NoizuPromptLingua.Domains.Assets.GenAIGenerator

  alias NoizuPromptLingua.Domains.Assets.GenAIGenerator

  @impl true
  def generate(entry, opts) do
    with {:ok, modality} <- GenAIGenerator.modality(entry.asset_type) do
      entry
      |> GenAIGenerator.build_request(modality, opts)
      |> run(opts)
    end
  end

  defp run(request, opts) do
    case GenAI.generate_media(request, opts[:genai_opts] || []) do
      {:ok, %{data: data, mime: mime}} when is_binary(data) ->
        {:ok, data, mime}

      {:ok, %GenAI.Media.Job{} = job} ->
        {:ok, {:job, job}}

      {:error, reason} ->
        {:error, reason}

      other ->
        {:error, {:unexpected_result, other}}
    end
  end
end
