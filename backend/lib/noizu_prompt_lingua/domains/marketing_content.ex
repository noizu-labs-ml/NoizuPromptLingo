defmodule NoizuPromptLingua.Domains.MarketingContent do
  @moduledoc """
  Shared LLM text-generation helper for the marketing domains (customers /
  market / campaigns). Wraps `Assets.ContentGenerator` (which loads FIM
  references and calls the configured LLM) and persists the result as an
  artifact via the Artifacts domain.

  Generation is best-effort: a missing API key returns `{:error, :missing_api_key}`
  (never a crash), exactly like the asset generate flow. A test/offline path
  (`llm_generate: false`) skips the LLM and returns the prompt text itself, so
  the persist + artifact wiring stays exercisable without a provider.
  """
  alias NoizuPromptLingua.Domains.Assets.ContentGenerator
  alias NoizuPromptLingua.Domains.Artifacts

  @doc """
  Generate marketing text from a plain prompt. Returns `{:ok, text}` or
  `{:error, reason}`.

  Opts:
    * `:system`       — optional system prompt prepended as guidance
    * `:provider`     — override LLM provider (openai, anthropic, z.ai, local)
    * `:model`        — override LLM model
    * `:endpoint`     — override LLM endpoint URL (Bandit-stub seam for tests)
    * `:llm_generate` — set false to skip the LLM and echo the prompt (default true)
    * `:format`       — output format hint (text, markdown, html); default "markdown"
  """
  def generate_text(prompt_text, opts \\ []) do
    if opts[:llm_generate] == false do
      {:ok, prompt_text}
    else
      prompt_yaml = build_prompt_yaml(prompt_text, opts)

      ContentGenerator.generate(prompt_yaml,
        provider: opts[:provider],
        model: opts[:model],
        endpoint: opts[:endpoint]
      )
    end
  end

  @doc """
  Generate text and persist it as an artifact in one call. Returns
  `{:ok, %{artifact_id: id, content: text}}` or `{:error, reason}`.

  `attrs` must include `:organization_id`; `:project_id`, `:title`, and `:kind`
  are optional (kind defaults to "document", mime to "text/markdown").
  """
  def generate_artifact(prompt_text, attrs, opts \\ []) do
    with {:ok, text} <- generate_text(prompt_text, opts),
         {:ok, artifact} <-
           Artifacts.create(%{
             organization_id: attrs[:organization_id],
             project_id: attrs[:project_id],
             kind: attrs[:kind] || "document",
             title: attrs[:title] || "Generated content",
             content: text,
             mime_type: attrs[:mime_type] || "text/markdown"
           }) do
      {:ok, %{artifact_id: artifact.id, content: text}}
    end
  end

  # Build a minimal .media.prompt YAML the ContentGenerator understands. The
  # prompt text goes in a literal block scalar so arbitrary content is safe
  # without escaping.
  defp build_prompt_yaml(prompt_text, opts) do
    format = opts[:format] || "markdown"
    system = opts[:system]

    system_block =
      if system do
        "  system: |\n" <> indent(system, 4) <> "\n"
      else
        ""
      end

    """
    type: document
    output:
      text_format: #{format}
    prompt:
    #{String.trim_trailing(system_block)}
      text: |
    #{indent(prompt_text, 4)}
    """
  end

  defp indent(text, n) do
    pad = String.duplicate(" ", n)

    text
    |> String.split("\n")
    |> Enum.map_join("\n", fn line -> pad <> line end)
  end
end
