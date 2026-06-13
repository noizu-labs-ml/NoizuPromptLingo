pub mod anthropic;
pub mod elevenlabs;
pub mod gemini;
pub mod gemini_chat;
pub mod grok_video;
pub mod openai_chat;
pub mod openai_tts;
pub mod qwen_tts;
pub mod suno;
pub mod veo;
pub mod zai;

use std::collections::HashMap;
use std::path::Path;

use crate::attachments::LoadedAttachment;
use crate::schema::{AssetType, AudioKind, Quality};

// ---------------------------------------------------------------------------
// GenerationOptions
// ---------------------------------------------------------------------------

#[derive(Debug, Clone)]
pub struct GenerationOptions {
    pub model: String,
    pub aspect_ratio: Option<String>,
    pub negative_prompt: Option<String>,
    pub provider_options: HashMap<String, serde_yaml::Value>,
    pub verbose: bool,
    pub duration_seconds: Option<f64>,
}

// ---------------------------------------------------------------------------
// Provider traits
// ---------------------------------------------------------------------------

#[async_trait::async_trait]
pub trait MediaProvider: Send + Sync {
    async fn generate(
        &self,
        prompt_text: &str,
        output_path: &Path,
        api_key: &str,
        options: &GenerationOptions,
        attachments: &[LoadedAttachment],
    ) -> color_eyre::Result<bool>;

    fn name(&self) -> &str;
}

#[async_trait::async_trait]
pub trait ChatProvider: Send + Sync {
    async fn generate(
        &self,
        system_prompt: &str,
        user_prompt: &str,
        output_path: &Path,
        api_key: &str,
        options: &GenerationOptions,
        attachments: &[LoadedAttachment],
    ) -> color_eyre::Result<bool>;

    fn name(&self) -> &str;
}

// ---------------------------------------------------------------------------
// Candidate selection
// ---------------------------------------------------------------------------

#[derive(Debug, Clone)]
pub struct Candidate {
    pub service: &'static str,
    pub model: &'static str,
}

/// Returns candidates ordered best-first for the given asset type / audio kind / quality tier.
/// The list is NOT filtered by API-key availability — call `available()` to filter.
pub fn candidates_for(asset_type: AssetType, audio_kind: AudioKind, quality: Quality) -> Vec<Candidate> {
    match asset_type {
        AssetType::Image => match quality {
            Quality::Low => vec![
                Candidate { service: "gemini", model: "imagen-4.0-fast-generate-001" },
            ],
            Quality::Medium => vec![
                Candidate { service: "gemini", model: "imagen-4.0-generate-001" },
            ],
            Quality::High => vec![
                Candidate { service: "gemini", model: "imagen-4.0-ultra-generate-001" },
                Candidate { service: "gemini", model: "imagen-4.0-generate-001" },
            ],
        },

        AssetType::Video => match quality {
            Quality::Low => vec![
                Candidate { service: "grok-video", model: "grok-imagine-video" },
                Candidate { service: "veo",        model: "veo-3.0-fast-generate-001" },
            ],
            Quality::Medium => vec![
                Candidate { service: "veo",        model: "veo-3.0-fast-generate-001" },
                Candidate { service: "grok-video", model: "grok-imagine-video" },
            ],
            Quality::High => vec![
                Candidate { service: "veo",        model: "veo-3.0-generate-001" },
                Candidate { service: "grok-video", model: "grok-imagine-video" },
            ],
        },

        AssetType::Audio => match audio_kind {
            AudioKind::Music => vec![
                Candidate { service: "suno", model: "V5_5" },
            ],
            AudioKind::Sfx => vec![
                Candidate { service: "suno", model: "V5_SOUND" },
            ],
            AudioKind::Voice => match quality {
                Quality::Low => vec![
                    Candidate { service: "qwen-tts",    model: "qwen3-tts-flash" },
                    Candidate { service: "openai-tts",  model: "gpt-4o-mini-tts" },
                ],
                Quality::Medium => vec![
                    Candidate { service: "openai-tts",  model: "gpt-4o-mini-tts" },
                    Candidate { service: "elevenlabs",  model: "eleven_multilingual_v2" },
                ],
                Quality::High => vec![
                    Candidate { service: "elevenlabs",  model: "eleven_multilingual_v2" },
                    Candidate { service: "openai-tts",  model: "gpt-4o-mini-tts" },
                ],
            },
        },

        // Chat / code generation types
        AssetType::Component
        | AssetType::ReactPage
        | AssetType::Html
        | AssetType::StyleGuide
        | AssetType::Diagram
        | AssetType::Document => match quality {
            Quality::Low => vec![
                Candidate { service: "gemini-chat", model: "gemini-2.5-flash" },
                Candidate { service: "openai-chat", model: "gpt-4.1" },
            ],
            Quality::Medium => vec![
                Candidate { service: "anthropic",   model: "claude-sonnet-4-6" },
                Candidate { service: "openai-chat", model: "gpt-4.1" },
                Candidate { service: "gemini-chat", model: "gemini-2.5-flash" },
            ],
            Quality::High => vec![
                Candidate { service: "anthropic",   model: "claude-opus-4-6" },
                Candidate { service: "anthropic",   model: "claude-sonnet-4-6" },
                Candidate { service: "gemini-chat", model: "gemini-2.5-pro" },
            ],
        },

        AssetType::Unknown => vec![
            Candidate { service: "gemini", model: "imagen-4.0-generate-001" },
        ],
    }
}

/// Returns true if the candidate's required API key env var is set and non-empty.
pub fn available(c: &Candidate) -> bool {
    let env = api_key_env(c.service);
    std::env::var(env).map(|v| !v.is_empty()).unwrap_or(false)
}

// ---------------------------------------------------------------------------
// Provider factory helpers
// ---------------------------------------------------------------------------

pub fn get_provider(service: &str) -> Option<Box<dyn MediaProvider>> {
    match service {
        "gemini" => Some(Box::new(gemini::GeminiProvider)),
        "suno" => Some(Box::new(suno::SunoProvider)),
        "openai-tts" => Some(Box::new(openai_tts::OpenAiTtsProvider)),
        "elevenlabs" => Some(Box::new(elevenlabs::ElevenLabsProvider)),
        "qwen-tts" => Some(Box::new(qwen_tts::QwenTtsProvider)),
        "grok-video" => Some(Box::new(grok_video::GrokVideoProvider)),
        "veo" => Some(Box::new(veo::VeoProvider)),
        _ => None,
    }
}

pub fn get_chat_provider(service: &str) -> Option<Box<dyn ChatProvider>> {
    match service {
        "anthropic" => Some(Box::new(anthropic::AnthropicProvider)),
        "gemini-chat" => Some(Box::new(gemini_chat::GeminiChatProvider)),
        "openai-chat" => Some(Box::new(openai_chat::OpenAiChatProvider)),
        "zai" | "z.ai" => Some(Box::new(zai::ZaiProvider)),
        _ => None,
    }
}

pub fn is_stub_provider(service: &str) -> bool {
    !matches!(
        service,
        "gemini"
            | "suno"
            | "openai-tts"
            | "elevenlabs"
            | "qwen-tts"
            | "grok-video"
            | "veo"
            | "anthropic"
            | "gemini-chat"
            | "openai-chat"
            | "zai"
            | "z.ai"
    )
}

pub fn api_key_env(service: &str) -> &'static str {
    match service {
        "gemini" | "veo" => "GEMINI_API_KEY",
        "suno" => "SUNO_API_KEY",
        "openai-tts" => "OPENAI_API_KEY",
        "elevenlabs" => "ELEVENLABS_API_KEY",
        "qwen-tts" => "DASHSCOPE_API_KEY",
        "grok-video" => "XAI_API_KEY",
        "anthropic" => "ANTHROPIC_API_KEY",
        "gemini-chat" => "GEMINI_API_KEY",
        "openai-chat" => "OPENAI_API_KEY",
        "zai" | "z.ai" => "XAI_API_KEY",
        _ => "GEMINI_API_KEY",
    }
}

pub fn sanitize_chat_output(raw: &str, output_path: &Path) -> String {
    let mut text = raw.trim().to_string();

    // Strip markdown code fences: ```lang\n...\n```
    if text.starts_with("```") {
        if let Some(first_newline) = text.find('\n') {
            text = text[first_newline + 1..].to_string();
        }
        if text.ends_with("```") {
            text = text[..text.len() - 3].trim_end().to_string();
        }
    }

    // Format-specific validation
    let ext = output_path
        .extension()
        .and_then(|e| e.to_str())
        .unwrap_or("");

    match ext {
        "svg" => {
            if !text.starts_with('<') {
                if let Some(svg_start) = text.find("<svg") {
                    text = text[svg_start..].to_string();
                }
            }
            if !text.contains("</svg>") {
                if text.contains("<svg") {
                    if let Some(last_open) = text.rfind('<') {
                        let after = &text[last_open..];
                        if !after.contains('>') {
                            text.truncate(last_open);
                        }
                    }
                    text = text.trim_end().to_string();
                    text.push_str("\n</svg>");
                }
            }
        }
        "mmd" => {
            text = text
                .trim_start_matches("```mermaid")
                .trim_start_matches("```")
                .trim_end_matches("```")
                .trim()
                .to_string();
        }
        "puml" => {
            if !text.contains("@startuml") {
                text = format!("@startuml\n{}", text);
            }
            if !text.contains("@enduml") {
                text.push_str("\n@enduml");
            }
        }
        _ => {}
    }

    text
}

/// Provider constraints that affect prompt preparation.
pub struct ProviderConstraints {
    pub max_prompt_chars: Option<usize>,
}

pub fn constraints(service: &str) -> ProviderConstraints {
    match service {
        // Suno music: 3000 in custom mode (auto-enabled). Sounds endpoint: 500.
        // Use 3000 here; SFX constraint enforced via suno-sfx key below.
        "suno" => ProviderConstraints { max_prompt_chars: Some(3000) },
        "suno-sfx" => ProviderConstraints { max_prompt_chars: Some(500) },
        "gemini" => ProviderConstraints { max_prompt_chars: Some(4000) },
        "veo" => ProviderConstraints { max_prompt_chars: Some(1000) },
        "grok-video" => ProviderConstraints { max_prompt_chars: Some(1000) },
        _ => ProviderConstraints { max_prompt_chars: None },
    }
}

pub fn default_model(service: &str) -> &'static str {
    match service {
        "gemini" => "imagen-4.0-generate-001",
        "suno" => "V5_5",
        "openai-tts" => "gpt-4o-mini-tts",
        "elevenlabs" => "eleven_multilingual_v2",
        "qwen-tts" => "qwen3-tts-flash",
        "grok-video" => "grok-imagine-video",
        "veo" => "veo-3.0-generate-001",
        "anthropic" => "claude-sonnet-4-6",
        "gemini-chat" => "gemini-2.5-flash",
        "openai-chat" => "gpt-4.1",
        "zai" | "z.ai" => "grok-4.3",
        _ => "default",
    }
}
