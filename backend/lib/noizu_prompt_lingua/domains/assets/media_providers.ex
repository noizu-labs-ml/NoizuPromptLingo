defmodule NoizuPromptLingua.Domains.Assets.MediaProviders do
  @moduledoc """
  Per-org media-generation provider config (ADR-016).

  The genai media Router picks a registered provider by modality (config
  `:genai, :media_providers`); providers read their API key from the pod env by
  default. This domain lets an org override a provider's per-request `api_key` /
  `model` / `settings` (and toggle it on/off) for asset generation, via the
  `media_provider_configs` table and the admin UI.

  `registry/0` is the catalog of providers the admin UI can configure — it mirrors
  the compiled `:genai, :media_providers` list, mapping each provider slug to its
  genai module, modality, and the env var it reads when no per-org key is set.
  """
  import Ecto.Query
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.MediaProviderConfig

  # asset_type -> media modality (mirrors GenAIGenerator's binary-media map).
  @type_to_modality %{
    "image" => "image",
    "voice" => "speech",
    "music" => "music",
    "video" => "video"
  }

  @registry [
    %{
      slug: "openai_image",
      label: "OpenAI · Image (gpt-image-1)",
      modality: "image",
      module: GenAI.Provider.OpenAI.Image,
      env_var: "OPENAI_API_KEY"
    },
    %{
      slug: "gemini_image",
      label: "Gemini · Imagen",
      modality: "image",
      module: GenAI.Provider.Gemini.Image,
      env_var: "GEMINI_API_KEY"
    },
    %{
      slug: "qwen_image",
      label: "Qwen · Image 3.0 (DashScope)",
      modality: "image",
      module: GenAI.Provider.Qwen.Image,
      env_var: "DASHSCOPE_API_KEY"
    },
    %{
      slug: "litellm_media",
      label: "LiteLLM · Media proxy",
      modality: "image",
      module: GenAI.Provider.LiteLLM.Media,
      env_var: "LITELLM_API_KEY"
    },
    %{
      slug: "openai_speech",
      label: "OpenAI · Speech / TTS",
      modality: "speech",
      module: GenAI.Provider.OpenAI.Speech,
      env_var: "OPENAI_API_KEY"
    },
    %{
      slug: "qwen_speech",
      label: "Qwen · TTS (DashScope)",
      modality: "speech",
      module: GenAI.Provider.Qwen.Speech,
      env_var: "DASHSCOPE_API_KEY"
    },
    %{
      slug: "qwen_video",
      label: "Wan · Video 2.7 (DashScope)",
      modality: "video",
      module: GenAI.Provider.Qwen.Video,
      env_var: "DASHSCOPE_API_KEY"
    },
    %{
      slug: "openai_transcription",
      label: "OpenAI · Transcription",
      modality: "text",
      module: GenAI.Provider.OpenAI.Transcription,
      env_var: "OPENAI_API_KEY"
    },
    %{
      slug: "suno",
      label: "Suno · Music",
      modality: "music",
      module: GenAI.Provider.Suno,
      env_var: "SUNO_API_KEY"
    }
  ]

  @doc "The provider catalog the admin UI can configure (static list of known providers)."
  def registry, do: @registry

  @doc "Registry entry for a provider slug, or nil."
  def registry_entry(slug), do: Enum.find(@registry, &(&1.slug == slug))

  @doc "Whether the server has the env var backing this provider set (read-only status hint)."
  def env_key_set?(%{env_var: env}) when is_binary(env), do: System.get_env(env) not in [nil, ""]
  def env_key_set?(_), do: false

  @doc "Map an asset type to its media modality string, or nil."
  def modality_for(asset_type), do: Map.get(@type_to_modality, asset_type)

  # ── Per-org config CRUD ─────────────────────────────────────

  def list_configs(org_id) do
    MediaProviderConfig
    |> where([c], c.organization_id == ^org_id)
    |> order_by([c], asc: c.provider)
    |> Repo.all()
  end

  def get_config(id), do: Repo.get(MediaProviderConfig, id)

  @doc "Create a per-org config; `modality` is derived from the registry slug when omitted."
  def create_config(attrs) do
    %MediaProviderConfig{}
    |> MediaProviderConfig.changeset(with_modality(attrs))
    |> Repo.insert()
  end

  def update_config(id, attrs) do
    case get_config(id) do
      nil -> {:error, :not_found}
      cfg -> cfg |> MediaProviderConfig.changeset(with_modality(attrs)) |> Repo.update()
    end
  end

  def delete_config(id) do
    case get_config(id) do
      nil -> {:error, :not_found}
      cfg -> Repo.delete(cfg)
    end
  end

  # Fill modality from the registry when the caller didn't provide one.
  defp with_modality(attrs) do
    slug = attrs[:provider] || attrs["provider"]
    has_modality = (attrs[:modality] || attrs["modality"]) not in [nil, ""]

    case {has_modality, registry_entry(slug)} do
      {false, %{modality: modality}} -> Map.put(attrs, :modality, modality)
      _ -> attrs
    end
  end

  @doc """
  Resolve generate opts for an org + asset type from the enabled per-org config
  for the matching modality. Returns a keyword list (`provider`/`model`/`api_key`/
  `endpoint`/`settings`) with nils dropped — `[]` when nothing is configured, so
  generation falls back to the Router's modality pick + env keys.
  """
  def generate_opts(org_id, asset_type) do
    with modality when is_binary(modality) <- modality_for(asset_type),
         cfg when not is_nil(cfg) <- pick_enabled(org_id, modality) do
      entry = registry_entry(cfg.provider)

      [
        provider: entry && entry.module,
        model: blank_to_nil(cfg.default_model),
        api_key: blank_to_nil(cfg.api_key),
        endpoint: blank_to_nil(cfg.endpoint),
        settings: cfg.settings || %{}
      ]
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    else
      _ -> []
    end
  end

  defp pick_enabled(org_id, modality) do
    MediaProviderConfig
    |> where([c], c.organization_id == ^org_id and c.enabled == true and c.modality == ^modality)
    |> order_by([c], asc: c.provider)
    |> limit(1)
    |> Repo.one()
  end

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(v), do: v
end
