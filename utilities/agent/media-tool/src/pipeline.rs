use std::path::PathBuf;

use crate::attachments::{load_attachments, validate_attachments};
use crate::dag::topological_sort;
use crate::eval::{evaluate_candidates, Evaluator};
use crate::output::{genai_candidate_path, link_active, resolve_output_paths, write_metadata};
use crate::prep::PromptPrepper;
use crate::providers::{
    self, api_key_env, available, candidates_for, constraints, get_chat_provider, get_provider,
    is_stub_provider, Candidate, GenerationOptions,
};
use crate::refine::interactive_refine_loop;
use crate::renderers;
use crate::schema::{AssetType, ParsedPrompt, Quality};
use crate::ui;
use crate::validate;

pub struct PipelineConfig {
    pub variant_count: usize,
    pub dry_run: bool,
    pub force: bool,
    pub model_override: Option<String>,
    pub verbose: bool,
    pub refine: bool,
    pub quality_override: Option<Quality>,
    pub service_override: Option<String>,
    pub no_eval: bool,
    pub no_prep: bool,
    pub eval_url: Option<String>,
    pub eval_model: Option<String>,
}

pub async fn run_generation(
    prompts: Vec<ParsedPrompt>,
    config: &PipelineConfig,
) -> color_eyre::Result<()> {
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
            let svc = p.meta.service.as_deref().unwrap_or("auto");
            ui::info(&format!(
                "  {}. {} ({:?}, service={}, quality={}, schema=v{})",
                i + 1,
                p.meta.id,
                p.meta.asset_type,
                svc,
                p.meta.quality.as_str(),
                p.meta.schema_version
            ));
        }
    }

    // Each output entry is (path, optional per-output description).
    // When description is set, it replaces the main prompt.text for that output.
    let mut plan: Vec<(ParsedPrompt, Vec<(PathBuf, Option<String>)>)> = Vec::new();
    let mut total_outputs = 0usize;

    for prompt in sorted_prompts {
        let mut output_entries = resolve_output_paths(&prompt);

        // Exclude formats produced by renderer post-processing
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
            output_entries.retain(|(p, _)| {
                let ext = p.extension().and_then(|e| e.to_str()).unwrap_or("");
                !renderer_formats.contains(&ext.to_string())
            });
        }

        if !output_entries.is_empty() {
            total_outputs += output_entries.len();
            plan.push((prompt, output_entries));
        }
    }

    if plan.is_empty() {
        ui::ok("No prompt files to process");
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
        let quality = config.quality_override.unwrap_or(meta.quality);

        // Determine candidate list for plan display
        let (display_service, display_model) = resolve_display_service(config, prompt, quality);

        let prompt_text = &prompt.payload.prompt.text;
        let aspect = prompt
            .payload
            .output
            .dimensions
            .as_ref()
            .and_then(|d| d.aspect_ratio.as_deref());

        ui::plan_item(&meta.id, &format!("{:?}", meta.asset_type), &display_service);
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
        ui::plan_detail("Model", &display_model);

        // Show duration if set
        if let Some(dur) = meta.duration {
            ui::plan_detail("Duration", &format!("{:.1}s", dur));
        }

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
                eprintln!("             - {} ({})", att.path, att.role);
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

        if let Some(eval) = &prompt.payload.eval {
            ui::plan_detail(
                "Eval",
                &format!(
                    "threshold={:.2}, max_attempts={:?}, criteria={}",
                    eval.effective_pass_threshold(),
                    eval.max_attempts,
                    eval.criteria.len()
                ),
            );
        }

        for (op, desc) in paths {
            if let Some(d) = desc {
                let preview: String = d.chars().take(60).collect();
                ui::plan_detail("Output", &format!("{} — {}", op.display(), preview));
            } else {
                ui::plan_detail("Output", &op.display().to_string());
            }
        }
    }

    if config.dry_run {
        eprintln!();
        ui::ok("Dry run complete \u{2014} no API calls made");
        return Ok(());
    }

    // Resolve evaluator (vision-capable LLM for scoring outputs)
    let evaluator_instance: Option<Evaluator> = if config.no_eval {
        None
    } else {
        Evaluator::resolve(
            config.eval_url.as_deref(),
            config.eval_model.as_deref(),
            config.verbose,
        )
        .await
    };
    let evaluator: Option<&Evaluator> = evaluator_instance.as_ref();

    // Resolve prompt prepper (fast text LLM for distilling specs into provider prompts)
    let prepper_instance: Option<PromptPrepper> = if config.no_prep {
        None
    } else {
        PromptPrepper::resolve(None, None, config.verbose)
    };
    let prep_llm: Option<&PromptPrepper> = prepper_instance.as_ref();

    let groq_key = std::env::var("GROQ_API_KEY").unwrap_or_default();
    let groq_model = std::env::var("GROQ_VISION_MODEL").ok();

    ui::step(&format!(
        "Generating {} output(s), {} candidate(s) each",
        total_outputs, config.variant_count
    ));
    if config.variant_count > 1 && groq_key.is_empty() && evaluator.is_none() {
        ui::warn_msg(
            "GROQ_API_KEY not set and no eval endpoint \u{2014} will pick first candidate",
        );
    }

    let mut succeeded = 0usize;
    let mut failed = 0usize;
    let mut gen_index = 0usize;

    for (mut prompt, paths) in plan {
        let quality = config.quality_override.unwrap_or(prompt.meta.quality);

        // Resolve candidate list for this prompt
        let candidates = resolve_candidates(config, &prompt, quality);

        if candidates.is_empty() {
            // Build missing-key message
            let needed: Vec<String> = if let Some(svc) = config
                .service_override
                .as_deref()
                .or(prompt.meta.service.as_deref())
            {
                vec![format!("{} ({})", svc, api_key_env(svc))]
            } else {
                let all = candidates_for(prompt.meta.asset_type, prompt.meta.audio_kind, quality);
                all.iter()
                    .map(|c| format!("{} ({})", c.service, api_key_env(c.service)))
                    .collect()
            };
            ui::fail_msg(&format!(
                "No available providers for {} — missing API keys: {}",
                prompt.meta.id,
                needed.join(", ")
            ));
            failed += paths.len();
            continue;
        }

        let has_eval_block = prompt.payload.eval.is_some();
        let use_eval_gating = has_eval_block && evaluator.is_some() && !config.no_eval;

        let max_attempts = if use_eval_gating {
            prompt
                .payload
                .eval
                .as_ref()
                .and_then(|e| e.max_attempts)
                .unwrap_or(candidates.len())
                .min(candidates.len())
        } else {
            1
        };

        let attachments = load_attachments(&prompt)?;

        let mut path_results = Vec::new();

        for (output_path, per_output_desc) in &paths {
            gen_index += 1;
            let basename = output_path.file_name().unwrap().to_string_lossy();
            ui::progress_label(gen_index, total_outputs, &basename);

            // If this output has its own description, temporarily override
            // the prompt text for this generation (multi-output SFX, etc.).
            // Per-output descriptions are self-contained — no system merge.
            let saved_text = if let Some(desc) = per_output_desc {
                let orig = prompt.payload.prompt.text.clone();
                prompt.payload.prompt.text = desc.clone();
                Some(orig)
            } else {
                None
            };

            if use_eval_gating {
                // Eval-gated provider fallback loop
                let result = run_eval_gated(
                    &candidates[..max_attempts],
                    &mut prompt,
                    output_path,
                    &attachments,
                    config,
                    evaluator.unwrap(),
                    prep_llm,
                )
                .await;

                match result {
                    Ok(true) => {
                        succeeded += 1;
                        path_results.push(output_path.clone());
                    }
                    Ok(false) => {
                        failed += 1;
                    }
                    Err(e) => {
                        ui::fail_msg(&format!("Error generating {}: {}", basename, e));
                        failed += 1;
                    }
                }
            } else {
                // Legacy: single candidate, multi-variant, pick-best behavior
                let candidate = &candidates[0];
                let result = run_legacy_variants(
                    candidate,
                    &prompt,
                    output_path,
                    &attachments,
                    config,
                    &groq_key,
                    groq_model.as_deref(),
                    evaluator,
                    prep_llm,
                )
                .await;

                match result {
                    Ok(true) => {
                        succeeded += 1;
                        path_results.push(output_path.clone());
                    }
                    Ok(false) => {
                        failed += 1;
                    }
                    Err(e) => {
                        ui::fail_msg(&format!("Error generating {}: {}", basename, e));
                        failed += 1;
                    }
                }
            }

            // Restore original prompt text if we overrode it for a per-output description
            if let Some(orig) = saved_text {
                prompt.payload.prompt.text = orig;
            }
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
                                            validate::validate_svg(&render_output, config.verbose, prep_llm).await;
                                            ui::ok(&format!("Rendered: {}", render_output.display()));
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
            // Use actual service for refinement (first candidate's service)
            let refine_service = candidates[0].service;
            let refine_model = candidates[0].model;
            let refine_key = std::env::var(api_key_env(refine_service)).unwrap_or_default();

            interactive_refine_loop(
                &mut prompt,
                &path_results,
                &refine_key,
                refine_model,
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

// ---------------------------------------------------------------------------
// Candidate resolution
// ---------------------------------------------------------------------------

fn resolve_candidates(config: &PipelineConfig, prompt: &ParsedPrompt, quality: Quality) -> Vec<Candidate> {
    // Priority 1: CLI --service override
    if let Some(ref svc) = config.service_override {
        let model = config
            .model_override
            .as_deref()
            .unwrap_or_else(|| providers::default_model(svc))
            .to_string();
        // Leak to get 'static — safe for CLI strings that live for program duration
        let svc_static: &'static str = Box::leak(svc.clone().into_boxed_str());
        let model_static: &'static str = Box::leak(model.into_boxed_str());
        return vec![Candidate { service: svc_static, model: model_static }];
    }

    // Priority 2: YAML service: pinned
    if let Some(ref svc) = prompt.meta.service {
        let model = config
            .model_override
            .as_deref()
            .or(prompt.meta.model.as_deref())
            .unwrap_or_else(|| providers::default_model(svc))
            .to_string();
        let svc_static: &'static str = Box::leak(svc.clone().into_boxed_str());
        let model_static: &'static str = Box::leak(model.into_boxed_str());
        return vec![Candidate { service: svc_static, model: model_static }];
    }

    // Priority 3: Auto-select via candidates_for, filtered by available()
    let all = candidates_for(prompt.meta.asset_type, prompt.meta.audio_kind, quality);
    all.into_iter().filter(|c| available(c)).collect()
}

fn resolve_display_service(config: &PipelineConfig, prompt: &ParsedPrompt, quality: Quality) -> (String, String) {
    if let Some(ref svc) = config.service_override {
        let model = config
            .model_override
            .as_deref()
            .unwrap_or_else(|| providers::default_model(svc))
            .to_string();
        return (svc.clone(), model);
    }

    if let Some(ref svc) = prompt.meta.service {
        let model = config
            .model_override
            .as_deref()
            .or(prompt.meta.model.as_deref())
            .unwrap_or_else(|| providers::default_model(svc))
            .to_string();
        return (svc.clone(), model);
    }

    // Auto-select display
    let all = candidates_for(prompt.meta.asset_type, prompt.meta.audio_kind, quality);
    let available_candidates: Vec<&Candidate> = all.iter().filter(|c| available(c)).collect();

    if available_candidates.is_empty() {
        let fallback_names: Vec<String> = all.iter().map(|c| c.service.to_string()).collect();
        let display = format!(
            "auto (quality={}): {}",
            quality.as_str(),
            fallback_names.join("\u{2192}")
        );
        let first_model = all.first().map(|c| c.model.to_string()).unwrap_or_else(|| "unknown".into());
        return (display, first_model);
    }

    let names: Vec<String> = available_candidates.iter().map(|c| c.service.to_string()).collect();
    let display = format!(
        "auto (quality={}): {}",
        quality.as_str(),
        names.join("\u{2192}")
    );
    let first_model = available_candidates[0].model.to_string();
    (display, first_model)
}

// ---------------------------------------------------------------------------
// Eval-gated loop
// ---------------------------------------------------------------------------

async fn run_eval_gated(
    candidates: &[Candidate],
    prompt: &mut ParsedPrompt,
    output_path: &std::path::Path,
    attachments: &[crate::attachments::LoadedAttachment],
    config: &PipelineConfig,
    evaluator: &Evaluator,
    prep_llm: Option<&PromptPrepper>,
) -> color_eyre::Result<bool> {
    let basename = output_path.file_name().unwrap().to_string_lossy();
    let eval_section = prompt.payload.eval.as_ref().unwrap();

    let mut global_best: Option<(f64, PathBuf, String)> = None; // (score, path, service)

    const MAX_REFINEMENTS: usize = 2;

    for candidate in candidates {
        let svc = candidate.service;
        if is_stub_provider(svc) {
            if config.verbose {
                ui::verbose(&format!("Skipping stub provider '{}'", svc));
            }
            continue;
        }

        let env_name = api_key_env(svc);
        let api_key = std::env::var(env_name).unwrap_or_default();
        if api_key.is_empty() {
            ui::warn_msg(&format!(
                "{} not set — skipping {} ({} provider)",
                env_name, prompt.meta.id, svc
            ));
            continue;
        }

        // Track refinement state per provider
        let mut last_eval_feedback: Option<String> = None;
        let mut last_scores_summary: Option<String> = None;
        let mut last_failed_output: Option<PathBuf> = None;

        // If the output already exists, assume the verbatim prompt was
        // already tried — skip straight to LLM-refined attempts.
        let start_attempt = if output_path.exists() {
            ui::info("Output exists — skipping verbatim, starting with LLM-refined prompt");
            1usize
        } else {
            0usize
        };

        for attempt in start_attempt..=MAX_REFINEMENTS {
            if config.verbose {
                if attempt == 0 {
                    ui::verbose(&format!(
                        "Trying provider {} / {} for {}",
                        svc, candidate.model, basename
                    ));
                } else {
                    ui::verbose(&format!(
                        "Retry {}/{} for {} via {} (refining prompt from eval feedback)",
                        attempt, MAX_REFINEMENTS, basename, svc
                    ));
                }
            }

            let genai_path = genai_candidate_path(output_path);
            let options = build_options(candidate.model, prompt, config);

            // Attempt 0: send the verbatim prompt as authored — UNLESS it
            // exceeds the provider's prompt length limit, in which case use
            // the LLM to condense it on the first attempt.
            // Attempts 1+: use the LLM to refine based on eval feedback
            // and the actual failed output (vision-informed).
            let (gen_text, gen_negative) = if attempt == 0 {
                // Merge system context into text for non-chat providers.
                // Skip merge when the constraint would be exceeded (happens
                // with per-output descriptions that are meant to be short).
                let raw_text = if get_chat_provider(svc).is_none() {
                    if let Some(ref sys) = prompt.payload.prompt.system {
                        format!("{}\n\n{}", sys.trim(), prompt.payload.prompt.text.trim())
                    } else {
                        prompt.payload.prompt.text.clone()
                    }
                } else {
                    prompt.payload.prompt.text.clone()
                };

                // Use SFX-specific constraint when model targets sound generation
                let constraint_key = if candidate.model.contains("SOUND") { "suno-sfx" } else { svc };
                let limit = constraints(constraint_key).max_prompt_chars;
                if let Some(max) = limit {
                    if raw_text.len() > max {
                        // Prompt exceeds provider limit — must use LLM to condense
                        ui::info(&format!(
                            "Prompt ({} chars) exceeds {} limit ({}) — using LLM to condense",
                            raw_text.len(), svc, max
                        ));
                        if let Some(prepper) = prep_llm {
                            match prepper.prepare_prompt(
                                &prompt.payload.prompt,
                                svc,
                                prompt.meta.asset_type,
                                config.verbose,
                            ).await {
                                Some(prepared) => (
                                    prepared.text,
                                    prepared.negative.or_else(|| prompt.payload.prompt.negative.clone()),
                                ),
                                None => {
                                    // Truncate as last resort
                                    ui::warn_msg(&format!(
                                        "LLM prep failed — truncating to {} chars (quality may suffer)",
                                        max
                                    ));
                                    let truncated: String = raw_text.chars().take(max).collect();
                                    (truncated, prompt.payload.prompt.negative.clone())
                                }
                            }
                        } else {
                            ui::warn_msg(&format!(
                                "No LLM available — truncating to {} chars (quality may suffer)",
                                max
                            ));
                            let truncated: String = raw_text.chars().take(max).collect();
                            (truncated, prompt.payload.prompt.negative.clone())
                        }
                    } else {
                        (raw_text, prompt.payload.prompt.negative.clone())
                    }
                } else {
                    (raw_text, prompt.payload.prompt.negative.clone())
                }
            } else if let (Some(prepper), Some(ref feedback), Some(ref scores)) =
                (prep_llm, &last_eval_feedback, &last_scores_summary)
            {
                match prepper.refine_prompt(
                    &prompt.payload.prompt,
                    svc,
                    prompt.meta.asset_type,
                    feedback,
                    scores,
                    last_failed_output.as_deref(),
                    config.verbose,
                ).await {
                    Some(refined) => {
                        ui::info(&format!(
                            "Prompt refined via LLM (attempt {}) for {} provider",
                            attempt + 1, svc
                        ));
                        (
                            refined.text,
                            refined.negative.or_else(|| prompt.payload.prompt.negative.clone()),
                        )
                    }
                    None => {
                        ui::warn_msg("LLM refinement failed — re-sending raw prompt");
                        (prompt.payload.prompt.text.clone(), prompt.payload.prompt.negative.clone())
                    }
                }
            } else {
                (prompt.payload.prompt.text.clone(), prompt.payload.prompt.negative.clone())
            };

            let ok = generate_one(
                svc,
                &gen_text,
                gen_negative.as_deref(),
                prompt.payload.prompt.system.as_deref(),
                &genai_path,
                &api_key,
                &options,
                attachments,
            )
            .await?;

            if !ok {
                ui::warn_msg(&format!("Generation failed for {} via {}", basename, svc));
                break;
            }

            // Write metadata sidecar
            write_metadata(
                &genai_path,
                svc,
                candidate.model,
                &gen_text,
                gen_negative.as_deref(),
                None,
                None,
                &prompt.payload.prompt.provider_options,
            );

            // Score
            let score = evaluator
                .score_output(&genai_path, &prompt.payload.prompt.text, eval_section, config.verbose)
                .await;

            match score {
                None => {
                    ui::warn_msg(&format!(
                        "{} is un-scorable — accepting without eval",
                        basename
                    ));
                    link_active(&genai_path, output_path)?;
                    validate::validate_svg(output_path, config.verbose, prep_llm).await;
                    ui::ok(&format!("Generated: {}", output_path.display()));
                    return Ok(true);
                }
                Some(s) => {
                    let w = s.weighted;

                    // Update metadata with eval score
                    write_metadata(
                        &genai_path,
                        svc,
                        candidate.model,
                        &gen_text,
                        gen_negative.as_deref(),
                        Some(w),
                        Some(&s.notes),
                        &prompt.payload.prompt.provider_options,
                    );

                    if config.verbose {
                        ui::verbose(&format!(
                            "Score for {} via {} (attempt {}): weighted={:.3}, pass={}",
                            basename, svc, attempt + 1, w, s.passes(eval_section)
                        ));
                    }

                    let is_better = global_best.as_ref().map(|(best, _, _)| w > *best).unwrap_or(true);
                    if is_better {
                        global_best = Some((w, genai_path.clone(), svc.to_string()));
                    }

                    if s.passes(eval_section) {
                        link_active(&genai_path, output_path)?;
                        validate::validate_svg(output_path, config.verbose, prep_llm).await;
                        ui::ok(&format!(
                            "Generated (passed eval, score={:.3}): {}",
                            w,
                            output_path.display()
                        ));
                        return Ok(true);
                    }

                    // Store feedback + failed output for vision-informed refinement
                    last_eval_feedback = Some(s.notes.clone());
                    last_failed_output = Some(genai_path.clone());
                    let scores_str: Vec<String> = s.per_criterion.iter()
                        .map(|(k, v)| format!("{}={:.1}", k, v * 10.0))
                        .collect();
                    last_scores_summary = Some(format!(
                        "weighted={:.3}, scores=[{}], reject_hits={:?}",
                        w, scores_str.join(", "), s.reject_hits
                    ));

                    if attempt < MAX_REFINEMENTS && prep_llm.is_some() {
                        ui::info(&format!(
                            "Score {:.3} below threshold {:.2} — refining prompt (attempt {})",
                            w, eval_section.effective_pass_threshold(), attempt + 2
                        ));
                    }
                }
            }
        }
    }

    // Exhausted all candidates — use global best with warning
    if let Some((score, best_path, svc)) = global_best {
        ui::warn_msg(&format!(
            "No provider passed eval for {} (best score={:.3} via {}) \u{2014} keeping best",
            basename, score, svc
        ));
        link_active(&best_path, output_path)?;
        validate::validate_svg(output_path, config.verbose, prep_llm).await;
        ui::ok(&format!("Generated (best available): {}", output_path.display()));
        Ok(true)
    } else {
        ui::fail_msg(&format!("All candidates failed for: {}", output_path.display()));
        Ok(false)
    }
}

// ---------------------------------------------------------------------------
// Legacy multi-variant loop
// ---------------------------------------------------------------------------

async fn run_legacy_variants(
    candidate: &Candidate,
    prompt: &ParsedPrompt,
    output_path: &std::path::Path,
    attachments: &[crate::attachments::LoadedAttachment],
    config: &PipelineConfig,
    groq_key: &str,
    groq_model: Option<&str>,
    evaluator: Option<&Evaluator>,
    prep_llm: Option<&PromptPrepper>,
) -> color_eyre::Result<bool> {
    let svc = candidate.service;
    let basename = output_path.file_name().unwrap().to_string_lossy();

    if is_stub_provider(svc) {
        ui::warn_msg(&format!(
            "Provider '{}' is not yet implemented \u{2014} skipping generation",
            svc
        ));
        return Ok(false);
    }

    let is_chat = prompt.meta.asset_type.is_chat_type()
        || get_chat_provider(svc).is_some();

    let supported = if is_chat {
        get_chat_provider(svc).is_some()
    } else {
        match svc {
            "gemini" => prompt.meta.asset_type == AssetType::Image,
            "suno" | "openai-tts" | "elevenlabs" | "qwen-tts" => {
                prompt.meta.asset_type == AssetType::Audio
            }
            "grok-video" | "veo" => prompt.meta.asset_type == AssetType::Video,
            _ => prompt.meta.asset_type == AssetType::Image,
        }
    };

    if !supported {
        ui::warn_msg(&format!(
            "Skipping {}: {:?} generation not supported via {}",
            prompt.meta.id, prompt.meta.asset_type, svc
        ));
        return Ok(false);
    }

    let env_name = api_key_env(svc);
    let api_key = std::env::var(env_name).unwrap_or_default();
    if api_key.is_empty() {
        ui::warn_msg(&format!(
            "{} not set — skipping {} ({} provider)",
            env_name, prompt.meta.id, svc
        ));
        return Ok(false);
    }

    let options = build_options(candidate.model, prompt, config);

    let mut variant_paths: Vec<PathBuf> = Vec::new();
    for v in 0..config.variant_count {
        let genai_path = genai_candidate_path(output_path);
        if config.variant_count > 1 && config.verbose {
            ui::verbose(&format!(
                "Candidate {}/{}: {}",
                v + 1,
                config.variant_count,
                genai_path.file_name().unwrap().to_string_lossy()
            ));
        }

        // Legacy path uses the prompt text as-is (system merge already
        // happened in the outer loop for non-per-output cases).
        let raw_text = prompt.payload.prompt.text.clone();

        let constraint_key = if candidate.model.contains("SOUND") { "suno-sfx" } else { svc };
        let limit = constraints(constraint_key).max_prompt_chars;
        let (gen_text, gen_neg) = if let Some(max) = limit {
            if raw_text.len() > max {
                ui::info(&format!(
                    "Prompt ({} chars) exceeds {} limit ({}) — using LLM to condense",
                    raw_text.len(), svc, max
                ));
                if let Some(prepper) = prep_llm {
                    match prepper.prepare_prompt(
                        &prompt.payload.prompt,
                        svc,
                        prompt.meta.asset_type,
                        config.verbose,
                    ).await {
                        Some(prepared) => (
                            prepared.text,
                            prepared.negative.or_else(|| prompt.payload.prompt.negative.clone()),
                        ),
                        None => {
                            ui::warn_msg(&format!("LLM prep failed — truncating to {} chars", max));
                            let truncated: String = raw_text.chars().take(max).collect();
                            (truncated, prompt.payload.prompt.negative.clone())
                        }
                    }
                } else {
                    ui::warn_msg(&format!("No LLM available — truncating to {} chars", max));
                    let truncated: String = raw_text.chars().take(max).collect();
                    (truncated, prompt.payload.prompt.negative.clone())
                }
            } else {
                (raw_text, prompt.payload.prompt.negative.clone())
            }
        } else {
            (raw_text, prompt.payload.prompt.negative.clone())
        };

        let ok = generate_one(
            svc,
            &gen_text,
            gen_neg.as_deref(),
            prompt.payload.prompt.system.as_deref(),
            &genai_path,
            &api_key,
            &options,
            attachments,
        )
        .await?;

        if ok {
            write_metadata(
                &genai_path,
                svc,
                candidate.model,
                &gen_text,
                prompt.payload.prompt.negative.as_deref(),
                None,
                None,
                &prompt.payload.prompt.provider_options,
            );
            variant_paths.push(genai_path);
        } else {
            ui::warn_msg(&format!(
                "Candidate {} failed for {}",
                v + 1,
                basename
            ));
        }
    }

    if variant_paths.is_empty() {
        ui::fail_msg(&format!("All candidates failed: {}", output_path.display()));
        return Ok(false);
    }

    let best_idx = if variant_paths.len() > 1 {
        ui::step(&format!(
            "Evaluating {} candidates for {}",
            variant_paths.len(),
            basename
        ));
        let refs: Vec<&std::path::Path> = variant_paths.iter().map(|p| p.as_path()).collect();

        if let Some(ev) = evaluator {
            // Use LM Studio evaluator for best-of-N selection
            let mut best_i = 0usize;
            let mut best_score = -1.0f64;
            let dummy_eval = crate::schema::EvalSection::default();
            for (i, p) in refs.iter().enumerate() {
                if let Some(score) = ev
                    .score_output(p, &prompt.payload.prompt.text, &dummy_eval, config.verbose)
                    .await
                {
                    if score.weighted > best_score {
                        best_score = score.weighted;
                        best_i = i;
                    }
                }
            }
            ui::info(&format!(
                "Selected candidate {} of {} (score={:.3})",
                best_i + 1,
                variant_paths.len(),
                best_score
            ));
            best_i
        } else {
            // Groq fallback
            let eval_criteria = prompt.payload.eval.as_ref().map(|e| &e.criteria);
            let idx = evaluate_candidates(
                &refs,
                &prompt.payload.prompt.text,
                eval_criteria,
                groq_key,
                groq_model,
                config.verbose,
            )
            .await;
            ui::info(&format!(
                "Selected candidate {} of {}",
                idx + 1,
                variant_paths.len()
            ));
            idx
        }
    } else {
        0
    };

    link_active(&variant_paths[best_idx], output_path)?;
    validate::validate_svg(output_path, config.verbose, prep_llm).await;
    ui::ok(&format!("Generated: {}", output_path.display()));
    if config.verbose {
        ui::verbose(&format!(
            "Active link: {} -> {}",
            variant_paths[best_idx].file_name().unwrap().to_string_lossy(),
            basename
        ));
    }
    Ok(true)
}

// ---------------------------------------------------------------------------
// Low-level generation dispatch
// ---------------------------------------------------------------------------

/// Dispatch generation to the appropriate provider.
/// Sends the prompt text verbatim — caller is responsible for any
/// prep/refinement before calling this.
async fn generate_one(
    svc: &str,
    prompt_text: &str,
    negative: Option<&str>,
    system: Option<&str>,
    output_path: &std::path::Path,
    api_key: &str,
    options: &GenerationOptions,
    attachments: &[crate::attachments::LoadedAttachment],
) -> color_eyre::Result<bool> {
    let is_chat = get_chat_provider(svc).is_some();

    // Show full prompt sent to the provider
    eprintln!();
    ui::step(&format!("Prompt sent to {} provider ({} chars):", svc, prompt_text.len()));
    for line in prompt_text.lines() {
        eprintln!("  {}", line);
    }
    if let Some(neg) = negative {
        if !neg.is_empty() {
            eprintln!();
            ui::plan_detail("Negative", neg);
        }
    }
    eprintln!();

    if is_chat {
        let Some(chat_provider) = get_chat_provider(svc) else {
            return Ok(false);
        };
        chat_provider
            .generate(system.unwrap_or(""), prompt_text, output_path, api_key, options, attachments)
            .await
    } else {
        let Some(provider) = get_provider(svc) else {
            return Ok(false);
        };
        let mut options = options.clone();
        options.negative_prompt = negative.map(|s| s.to_string());
        provider
            .generate(prompt_text, output_path, api_key, &options, attachments)
            .await
    }
}

fn build_options(model: &str, prompt: &ParsedPrompt, config: &PipelineConfig) -> GenerationOptions {
    let effective_model = config
        .model_override
        .as_deref()
        .unwrap_or(model)
        .to_string();

    GenerationOptions {
        model: effective_model,
        aspect_ratio: prompt
            .payload
            .output
            .dimensions
            .as_ref()
            .and_then(|d| d.aspect_ratio.clone()),
        negative_prompt: prompt.payload.prompt.negative.clone(),
        provider_options: prompt.payload.prompt.provider_options.clone(),
        verbose: config.verbose,
        duration_seconds: prompt.meta.duration,
    }
}
