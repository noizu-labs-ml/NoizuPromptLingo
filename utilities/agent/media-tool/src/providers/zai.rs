use std::path::Path;

use crate::attachments::LoadedAttachment;
use crate::providers::openai_chat::openai_compatible_generate;
use crate::providers::{ChatProvider, GenerationOptions};

pub struct ZaiProvider;

#[async_trait::async_trait]
impl ChatProvider for ZaiProvider {
    async fn generate(
        &self,
        system_prompt: &str,
        user_prompt: &str,
        output_path: &Path,
        api_key: &str,
        options: &GenerationOptions,
        attachments: &[LoadedAttachment],
    ) -> color_eyre::Result<bool> {
        openai_compatible_generate(
            "https://api.x.ai/v1/chat/completions",
            system_prompt,
            user_prompt,
            output_path,
            api_key,
            options,
            attachments,
        )
        .await
    }

    fn name(&self) -> &str {
        "zai"
    }
}
