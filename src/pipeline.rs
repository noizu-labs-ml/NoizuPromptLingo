use std::path::PathBuf;

use crate::attachments::{load_attachments, validate_attachments};
use crate::dag::topological_sort;
use crate::eval::evaluate_candidates;
use crate::output::{genai_candidate_path, link_active, resolve_output_paths};
use crate::providers::{self, get_chat_provider, get_provider, is_stub_provider, GenerationOptions};
use crate::refine::interactive_refine_loop;
use crate::renderers;
use crate::schema::{AssetType, ParsedPrompt};
use crate::ui;

pub struct PipelineConfig {
    pub variant_count: usize,
    pub dry_run: bool,
    pub force: bool,
    pub model_override: Option<String>,
    pub verbose: bool,
    pub refine: bool,
}

pub async fn run_generation(
    prompts: Vec<ParsedPrompt>,
    config: &PipelineConfig,
) -> color_eyre::Result<()> {
    // API keys are resolved per-provider at generation time

    // Validate attachments
    ui::step("Validating prompt files");
    for prompt in &prompts {
        if !validate_attachments(prompt) {
            color_eyre::eyre::bail!(
                "Attachment validation failed for {}",
                prompt.meta.path.display()
            );
        }
    }
    ui::ok("All attachments validated");

    // Dependency sort
    ui::step("Resolving dependencies");
    let sorted_prompts = topological_sort(prompts)?;
    ui::ok(&format!(
        "{} prompt(s) in generation order",
        sorted_prompts.len()
    ));

    if config.verbose {
        for (i, p) in sorted_prompts.iter().enumerate() {
            ui::info(&format!(
                "  {}. {} ({:?}, service={}, schema=v{})",
                i + 1,
                p.meta.id,
                p.meta.asset_type,
                p.meta.service,
                p.meta.schema_version
            ));
        }
    }

    // Build generation plan
    let mut plan: Vec<(ParsedPrompt, Vec<PathBuf>)> = Vec::new();
    let mut total_outputs = 0usize;
    let mut skipped = 0usize;

    for prompt in sorted_prompts {
        let mut output_paths = resolve_output_paths(&prompt);

        // Exclude formats produced by renderer post-processing (e.g., svg from mermaid/plantuml)
        let renderer_formats: Vec<String> = prompt
            .payload
            .post_processing
            .iter()
            .filter(|pp| pp.action == "render")
            .filter_map(|pp| {
                pp.params
                    .get("output_format")
                    .and_then(|v| v.as_str())
                    .map(|s| s.to_string())
            })
            .collect();
        if !renderer_formats.is_empty() {
            output_paths.retain(|p| {
                let ext = p.extension().and_then(|e| e.to_str()).unwrap_or("");
                !renderer_formats.contains(&ext.to_string())
            });
        }

        if !config.force {
            let mut remaining = Vec::new();
            for op in output_paths {
                if op.exists() {
                    if config.verbose {
                        ui::info(&format!("Skipping (exists): {}", op.display()));
                    }
                    skipped += 1;
                } else {
                    remaining.push(op);
                }
            }
            output_paths = remaining;
        }

        if !output_paths.is_empty() {
            total_outputs += output_paths.len();
            plan.push((prompt, output_paths));
        }
    }

    if skipped > 0 {
        ui::info(&format!(
            "Skipped {} existing output(s) (use --force to overwrite)",
            skipped
        ));
    }

    if plan.is_empty() {
        ui::ok("Nothing to generate \u{2014} all outputs exist");
        return Ok(());
    }

    // Show plan
    ui::step(&format!(
        "Generation plan: {} output(s) from {} prompt(s)",
        total_outputs,
        plan.len()
    ));

    for (prompt, paths) in &plan {
        let meta = &prompt.meta;
        let prompt_model = config
            .model_override
            .as_deref()
            .or(meta.model.as_deref())
            .unwrap_or_else(|| providers::default_model(&prompt.meta.service));

        let prompt_text = &prompt.payload.prompt.text;
        let aspect = prompt
            .payload
            .output
            .dimensions
            .as_ref()
            .and_then(|d| d.aspect_ratio.as_deref());

        ui::plan_item(&meta.id, &format!("{:?}", meta.asset_type), &meta.service);
        let preview: String = prompt_text.chars().take(100).collect();
        ui::plan_detail(
            "Prompt",
            &format!(
                "{}{}",
                preview,
                if prompt_text.len() > 100 { "..." } else { "" }
            ),
        );
        if let Some(ar) = aspect {
            ui::plan_detail("Aspect", ar);
        }
        if let Some(ref neg) = prompt.payload.prompt.negative {
            let preview: String = neg.chars().take(80).collect();
            ui::plan_detail(
                "Neg.",
                &format!(
                    "{}{}",
                    preview,
                    if neg.len() > 80 { "..." } else { "" }
                ),
            );
        }
        ui::plan_detail("Model", prompt_model);

        if !prompt.payload.prompt.provider_options.is_empty() {
            ui::plan_detail(
                "Options",
                &format!("{:?}", prompt.payload.prompt.provider_options),
            );
        }

        if !prompt.payload.attachments.is_empty() {
            ui::plan_detail(
                "Attach",
                &format!("{} file(s)", prompt.payload.attachments.len()),
            );
            for att in &prompt.payload.attachments {
                eprintln!(
                    "             - {} ({})",
                    att.path,
                    att.role
                );
            }
        }

        if !prompt.payload.post_processing.is_empty() {
            ui::plan_detail(
                "Post",
                &format!("{} step(s)", prompt.payload.post_processing.len()),
            );
            for ps in &prompt.payload.post_processing {
                eprintln!("             - {}", ps.action);
            }
        }

        for op in paths {
            ui::plan_detail("Output", &op.display().to_string());
        }
    }

    if config.dry_run {
        eprintln!();
        ui::ok("Dry run complete \u{2014} no API calls made");
        return Ok(());
    }

    // Execute
    let groq_key = std::env::var("GROQ_API_KEY").unwrap_or_default();
    let groq_model = std::env::var("GROQ_VISION_MODEL").ok();

    ui::step(&format!(
        "Generating {} output(s), {} candidate(s) each",
        total_outputs, config.variant_count
    ));
    if config.variant_count > 1 && groq_key.is_empty() {
        ui::warn_msg(
            "GROQ_API_KEY not set \u{2014} will pick first candidate instead of vision-evaluating",
        );
    }

    let mut succeeded = 0usize;
    let mut failed = 0usize;
    let mut gen_index = 0usize;

    for (mut prompt, paths) in plan {
        let prompt_model = config
            .model_override
            .as_deref()
            .or(prompt.meta.model.as_deref())
            .unwrap_or_else(|| providers::default_model(&prompt.meta.service))
            .to_string();

        if is_stub_provider(&prompt.meta.service) {
            gen_index += paths.len();
            for output_path in &paths {
                ui::progress_label(
                    gen_index,
                    total_outputs,
                    &output_path.file_name().unwrap().to_string_lossy(),
                );
            }
            ui::warn_msg(&format!(
                "Provider '{}' is not yet implemented \u{2014} skipping generation",
                prompt.meta.service
            ));
            failed += paths.len();
            continue;
        }

        let is_chat_type = matches!(
            prompt.meta.asset_type,
            AssetType::Component | AssetType::ReactPage | AssetType::Html
            | AssetType::StyleGuide | AssetType::Diagram | AssetType::Document
        ) || get_chat_provider(&prompt.meta.service).is_some();

        let supported = if is_chat_type {
            get_chat_provider(&prompt.meta.service).is_some()
        } else {
            match prompt.meta.service.as_str() {
                "gemini" => prompt.meta.asset_type == AssetType::Image,
                "suno" | "openai-tts" | "elevenlabs" | "qwen-tts" => prompt.meta.asset_type == AssetType::Audio,
                "grok-video" | "veo" => prompt.meta.asset_type == AssetType::Video,
                _ => prompt.meta.asset_type == AssetType::Image,
            }
        };
        if !supported {
            ui::warn_msg(&format!(
                "Skipping {}: {:?} generation not supported via {}",
                prompt.meta.id, prompt.meta.asset_type, prompt.meta.service
            ));
            failed += paths.len();
            continue;
        }

        let env_name = providers::api_key_env(&prompt.meta.service);
        let api_key = std::env::var(env_name).unwrap_or_default();
        if api_key.is_empty() && !config.dry_run {
            ui::warn_msg(&format!(
                "{} not set — skipping {} ({} provider)",
                env_name, prompt.meta.id, prompt.meta.service
            ));
            failed += paths.len();
            continue;
        }

        let attachments = load_attachments(&prompt)?;

        let options = GenerationOptions {
            model: prompt_model.to_string(),
            aspect_ratio: prompt
                .payload
                .output
                .dimensions
                .as_ref()
                .and_then(|d| d.aspect_ratio.clone()),
            negative_prompt: prompt.payload.prompt.negative.clone(),
            provider_options: prompt.payload.prompt.provider_options.clone(),
            verbose: config.verbose,
        };

        let mut path_results = Vec::new();

        for output_path in &paths {
            gen_index += 1;
            let basename = output_path.file_name().unwrap().to_string_lossy();
            ui::progress_label(gen_index, total_outputs, &basename);

            let mut candidates: Vec<PathBuf> = Vec::new();
            for v in 0..config.variant_count {
                let candidate = genai_candidate_path(output_path);
                if config.variant_count > 1 && config.verbose {
                    ui::verbose(&format!(
                        "Candidate {}/{}: {}",
                        v + 1,
                        config.variant_count,
                        candidate.file_name().unwrap().to_string_lossy()
                    ));
                }

                if is_chat_type {
                    let Some(chat_provider) = get_chat_provider(&prompt.meta.service) else {
                        ui::fail_msg(&format!(
                            "No chat provider for service '{}' — skipping {}",
                            prompt.meta.service, basename
                        ));
                        failed += 1;
                        break;
                    };
                    let system_prompt = prompt.payload.prompt.system.as_deref().unwrap_or("");
                    match chat_provider
                        .generate(
                            system_prompt,
                            &prompt.payload.prompt.text,
                            &candidate,
                            &api_key,
                            &options,
                            &attachments,
                        )
                        .await
                    {
                        Ok(true) => candidates.push(candidate),
                        Ok(false) => {
                            ui::warn_msg(&format!(
                                "Candidate {} failed for {}",
                                v + 1,
                                basename
                            ));
                        }
                        Err(e) => {
                            ui::fail_msg(&format!(
                                "Candidate {} error for {}: {}",
                                v + 1, basename, e
                            ));
                        }
                    }
                } else {
                    let Some(provider) = get_provider(&prompt.meta.service) else {
                        ui::fail_msg(&format!(
                            "No media provider for service '{}' — skipping {}",
                            prompt.meta.service, basename
                        ));
                        failed += 1;
                        break;
                    };
                    match provider
                        .generate(
                            &prompt.payload.prompt.text,
                            &candidate,
                            &api_key,
                            &options,
                            &attachments,
                        )
                        .await
                    {
                        Ok(true) => candidates.push(candidate),
                        Ok(false) => {
                            ui::warn_msg(&format!(
                                "Candidate {} failed for {}",
                                v + 1,
                                basename
                            ));
                        }
                        Err(e) => {
                            ui::fail_msg(&format!(
                                "Candidate {} error for {}: {}",
                                v + 1, basename, e
                            ));
                        }
                    }
                }
            }

            if candidates.is_empty() {
                ui::fail_msg(&format!("All candidates failed: {}", output_path.display()));
                failed += 1;
                continue;
            }

            let best_idx = if candidates.len() > 1 {
                ui::step(&format!(
                    "Evaluating {} candidates for {}",
                    candidates.len(),
                    basename
                ));
                let candidate_refs: Vec<&std::path::Path> =
                    candidates.iter().map(|p| p.as_path()).collect();
                let eval_criteria = prompt
                    .payload
                    .eval
                    .as_ref()
                    .map(|e| &e.criteria);
                let idx = evaluate_candidates(
                    &candidate_refs,
                    &prompt.payload.prompt.text,
                    eval_criteria,
                    &groq_key,
                    groq_model.as_deref(),
                    config.verbose,
                )
                .await;
                ui::info(&format!(
                    "Selected candidate {} of {}",
                    idx + 1,
                    candidates.len()
                ));
                idx
            } else {
                0
            };

            link_active(&candidates[best_idx], output_path)?;
            ui::ok(&format!("Generated: {}", output_path.display()));
            if config.verbose {
                ui::verbose(&format!(
                    "Active link: {} -> {}",
                    candidates[best_idx].file_name().unwrap().to_string_lossy(),
                    basename
                ));
            }
            succeeded += 1;
            path_results.push(output_path.clone());
        }

        // Post-processing
        if !prompt.payload.post_processing.is_empty() && !path_results.is_empty() {
            for pp_step in &prompt.payload.post_processing {
                match pp_step.action.as_str() {
                    "render" => {
                        let tool_name = pp_step
                            .params
                            .get("tool")
                            .and_then(|v| v.as_str())
                            .unwrap_or("mermaid");

                        match renderers::get_renderer(tool_name) {
                            Some(renderer) => {
                                if !renderer.is_available() {
                                    ui::warn_msg(&format!(
                                        "Renderer '{}' not found \u{2014} install it to enable rendering",
                                        tool_name
                                    ));
                                    continue;
                                }

                                let output_format = pp_step
                                    .params
                                    .get("output_format")
                                    .and_then(|v| v.as_str())
                                    .unwrap_or("svg");

                                for src in &path_results {
                                    let render_output = src.with_extension(output_format);
                                    ui::step(&format!(
                                        "Rendering {} \u{2192} {}",
                                        src.file_name().unwrap().to_string_lossy(),
                                        render_output.file_name().unwrap().to_string_lossy()
                                    ));
                                    match renderer.render(src, &render_output, &pp_step.params) {
                                        Ok(true) => {
                                            ui::ok(&format!(
                                                "Rendered: {}",
                                                render_output.display()
                                            ));
                                        }
                                        Ok(false) => {
                                            ui::fail_msg(&format!(
                                                "Render failed: {}",
                                                render_output.display()
                                            ));
                                        }
                                        Err(e) => {
                                            ui::fail_msg(&format!(
                                                "Render error for {}: {}",
                                                render_output.display(),
                                                e
                                            ));
                                        }
                                    }
                                }
                            }
                            None => {
                                ui::warn_msg(&format!(
                                    "Unknown renderer '{}' \u{2014} skipping",
                                    tool_name
                                ));
                            }
                        }
                    }
                    other => {
                        ui::info(&format!(
                            "Post-processing: {} (not yet implemented) \u{2014} params: {:?}",
                            other, pp_step.params
                        ));
                    }
                }
            }
        }

        // Interactive refinement
        if config.refine && succeeded > 0 {
            interactive_refine_loop(
                &mut prompt,
                &path_results,
                &api_key,
                &prompt_model,
                config.verbose,
            )
            .await;
        }
    }

    // Summary
    ui::step("Generation complete");
    ui::ok(&format!("{} succeeded", succeeded));
    if failed > 0 {
        ui::fail_msg(&format!("{} failed", failed));
    }
    eprintln!();

    Ok(())
}
