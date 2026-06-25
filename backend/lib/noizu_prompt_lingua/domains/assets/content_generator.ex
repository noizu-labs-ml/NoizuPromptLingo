defmodule NoizuPromptLingua.Domains.Assets.ContentGenerator do
  @moduledoc """
  Generates asset content by parsing .media.prompt YAML, loading relevant
  FIM (Fill-In-the-Middle) references from the content-generator skill,
  and calling an LLM to produce the actual content.

  The content-generator skill provides format-specific instructions for
  173 rendering solutions (Mermaid, SVG, Three.js, LaTeX, etc.) organized
  by use-case. This module selects the right reference based on the asset
  type and prompt, injects it as LLM context, and returns the generated content.
  """

  @skill_dir Application.app_dir(:noizu_prompt_lingua, "priv/skills/content-generator")

  @type_to_use_case %{
    "diagram" => "diagram-generation",
    "svg" => "creative-animation",
    "image" => "creative-animation",
    "html" => "prototyping",
    "component" => "prototyping",
    "style_guide" => "design-systems",
    "document" => "document-processing",
    "video" => "media-processing",
    "music" => "music-notation",
    "voice" => "media-processing"
  }

  @type_to_solutions %{
    "diagram" => ~w(mermaid plantuml graphviz-dot structurizr-dsl nomnoml),
    "svg" => ~w(svg_js p5_js rough_js two_js paper_js),
    "image" => ~w(canvas-api sharp node-canvas svg_js),
    "html" => ~w(html markdown),
    "component" => ~w(html p5_js react-three-fiber),
    "style_guide" => ~w(html svg_js),
    "document" => ~w(markdown latex typst pandoc),
    "video" => ~w(ffmpeg-wasm lottie gsap),
    "music" => ~w(vexflow abcjs tone_js lilypond),
    "voice" => ~w(web-audio-api tone_js)
  }

  def generate(prompt_yaml, opts \\ []) do
    case YamlElixir.read_from_string(prompt_yaml) do
      {:ok, config} -> generate_from_config(config, opts)
      {:error, reason} -> {:error, {:yaml_parse_error, reason}}
    end
  end

  defp generate_from_config(config, opts) do
    asset_type = config["type"] || "document"
    prompt_text = get_in(config, ["prompt", "text"]) || ""
    system_prompt = get_in(config, ["prompt", "system"])
    provider_opts = get_in(config, ["prompt", "provider_options"]) || %{}

    output_format = detect_output_format(config)
    solution_hint = detect_solution(config, asset_type)

    fim_context = build_fim_context(asset_type, solution_hint)

    system = build_system_prompt(system_prompt, fim_context, asset_type, output_format)

    messages = [
      %{role: "system", content: system},
      %{role: "user", content: prompt_text}
    ]

    provider = opts[:provider] || config["service"] || "openai"
    model = opts[:model] || config["model"]
    endpoint = opts[:endpoint]

    temperature = provider_opts["temperature"] || 0.3
    max_tokens = provider_opts["max_tokens"] || 8192

    call_llm(messages, provider, model, endpoint, temperature, max_tokens)
  end

  defp detect_output_format(config) do
    formats = get_in(config, ["output", "formats"]) || []
    case formats do
      [%{"format" => fmt} | _] -> fmt
      _ ->
        config["output"]["text_format"] ||
        config["output"]["diagram_type"] ||
        "text"
    end
  end

  defp detect_solution(config, asset_type) do
    cond do
      config["output"]["diagram_type"] -> config["output"]["diagram_type"]
      config["output"]["text_format"] -> config["output"]["text_format"]
      true -> List.first(@type_to_solutions[asset_type] || [])
    end
  end

  def build_fim_context(asset_type, solution_hint) do
    parts = []

    use_case = @type_to_use_case[asset_type]
    parts = if use_case do
      case load_fim_file("use-case/#{use_case}.md") do
        {:ok, content} -> [{"Use-Case Guide (#{use_case})", content} | parts]
        _ -> parts
      end
    else
      parts
    end

    parts = if solution_hint do
      case load_fim_file("solution/#{solution_hint}.md") do
        {:ok, content} -> [{"Solution Reference (#{solution_hint})", content} | parts]
        _ -> parts
      end
    else
      parts
    end

    Enum.reverse(parts)
  end

  def list_solutions(asset_type) do
    Map.get(@type_to_solutions, asset_type, [])
  end

  def list_use_cases do
    @type_to_use_case
  end

  def get_solution_reference(solution_name) do
    load_fim_file("solution/#{solution_name}.md")
  end

  def get_use_case_reference(use_case) do
    load_fim_file("use-case/#{use_case}.md")
  end

  defp build_system_prompt(custom_system, fim_context, asset_type, output_format) do
    base = custom_system || default_system_prompt(asset_type, output_format)

    fim_section = case fim_context do
      [] -> ""
      refs ->
        sections = Enum.map(refs, fn {title, content} ->
          "## #{title}\n\n#{content}"
        end)
        "\n\n--- FORMAT REFERENCE ---\n\n#{Enum.join(sections, "\n\n")}\n\n--- END FORMAT REFERENCE ---"
    end

    "#{base}#{fim_section}"
  end

  defp default_system_prompt(asset_type, output_format) do
    """
    You are a content generator specialized in producing #{asset_type} content.
    Output format: #{output_format}.

    RULES:
    - Output ONLY the raw content in the specified format.
    - Do NOT wrap output in markdown code fences.
    - Do NOT include explanatory text before or after the content.
    - Ensure the output is valid, well-formed #{output_format}.
    - Be precise with syntax — the output will be consumed programmatically.
    """
  end

  defp load_fim_file(relative_path) do
    path = Path.join([@skill_dir, "references", "fim", relative_path])
    case File.read(path) do
      {:ok, content} -> {:ok, content}
      {:error, _} -> :error
    end
  end

  defp call_llm(messages, provider, model, endpoint, temperature, max_tokens) do
    with {url, headers, resolved_model} <- resolve_provider(provider, model, endpoint) do
      do_call_llm(messages, url, headers, resolved_model, temperature, max_tokens)
    end
  end

  defp do_call_llm(messages, url, headers, resolved_model, temperature, max_tokens) do
    body = Jason.encode!(%{
      model: resolved_model,
      messages: messages,
      temperature: temperature,
      max_tokens: max_tokens
    })

    :inets.start()
    :ssl.start()

    case :httpc.request(:post,
      {String.to_charlist(url),
       [{~c"Content-Type", ~c"application/json"} | headers],
       ~c"application/json", body},
      [{:timeout, 60_000}], []) do
      {:ok, {{_, 200, _}, _, resp_body}} ->
        case Jason.decode(to_string(resp_body)) do
          {:ok, %{"choices" => [%{"message" => %{"content" => content}} | _]}} ->
            {:ok, String.trim(content)}
          {:ok, other} ->
            {:error, {:unexpected_response, other}}
        end
      {:ok, {{_, status, _}, _, resp_body}} ->
        {:error, {:http_error, status, to_string(resp_body)}}
      {:error, reason} ->
        {:error, {:request_failed, reason}}
    end
  end

  defp resolve_provider("openai" <> _, model, endpoint) do
    with {:ok, key} <- require_key("OPENAI_API_KEY") do
      url = endpoint || "https://api.openai.com/v1/chat/completions"
      {url, [{~c"Authorization", String.to_charlist("Bearer #{key}")}], model || "gpt-4o-mini"}
    end
  end

  defp resolve_provider("gemini" <> _, model, endpoint) do
    with {:ok, key} <- require_key("OPENAI_API_KEY") do
      url = endpoint || "https://api.openai.com/v1/chat/completions"
      {url, [{~c"Authorization", String.to_charlist("Bearer #{key}")}], model || "gpt-4o-mini"}
    end
  end

  defp resolve_provider("anthropic" <> _, model, endpoint) do
    with {:ok, key} <- require_key("ANTHROPIC_API_KEY") do
      url = endpoint || "https://api.anthropic.com/v1/messages"
      {url, [
        {~c"x-api-key", String.to_charlist(key)},
        {~c"anthropic-version", ~c"2023-06-01"}
      ], model || "claude-sonnet-4-20250514"}
    end
  end

  defp resolve_provider("z.ai" <> _, model, endpoint) do
    with {:ok, key} <- require_key("XAI_API_KEY") do
      url = endpoint || "https://api.x.ai/v1/chat/completions"
      {url, [{~c"Authorization", String.to_charlist("Bearer #{key}")}], model || "grok-3"}
    end
  end

  # No-key fallthrough = a local/self-hosted OpenAI-compatible endpoint (no auth).
  defp resolve_provider(_, model, endpoint) do
    url = endpoint || "http://localhost:1234/v1/chat/completions"
    {url, [], model || "default"}
  end

  # A configured provider with no API key set fails fast (clean {:error}) instead of
  # firing a doomed request that 401s — so "no provider configured" is a graceful
  # {:error, :generation_unavailable} upstream, never a crash (ticket 2989d130).
  defp require_key(env) do
    case System.get_env(env, "") do
      "" -> {:error, :missing_api_key}
      key -> {:ok, key}
    end
  end
end
