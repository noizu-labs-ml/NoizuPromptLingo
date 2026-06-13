mod attachments;
mod dag;
mod eval;
mod output;
mod pipeline;
mod prep;
mod providers;
mod refine;
mod renderers;
mod schema;
mod ui;
mod validate;

use std::path::{Path, PathBuf};

use clap::Parser;

use pipeline::PipelineConfig;
use schema::{parse_prompt_file, Quality};

#[derive(Parser, Debug)]
#[command(
    name = "generate-media-prompt",
    about = "Generate media assets from .media.prompt YAML files",
    version
)]
struct Cli {
    /// Prompt files or directories to process
    #[arg(required = true)]
    inputs: Vec<PathBuf>,

    /// Number of candidates to generate; best is vision-selected
    #[arg(short = 'n', default_value = "1")]
    variants: usize,

    /// Show generation plan without making API calls
    #[arg(long)]
    dry_run: bool,

    /// Overwrite existing output files
    #[arg(long)]
    force: bool,

    /// Interactive refinement loop after generation
    #[arg(long)]
    refine: bool,

    /// Override generation model
    #[arg(long)]
    model: Option<String>,

    /// Show detailed output
    #[arg(long)]
    verbose: bool,

    /// Quality tier override: low|medium|high (default: per-prompt or medium)
    #[arg(long, value_name = "TIER")]
    quality: Option<String>,

    /// Pin provider service (skips auto-selection)
    #[arg(long, value_name = "SVC")]
    service: Option<String>,

    /// Skip eval grading and provider fallback
    #[arg(long)]
    no_eval: bool,

    /// Skip LLM prompt preparation (send raw prompt text to provider)
    #[arg(long)]
    no_prep: bool,

    /// Override eval endpoint base URL
    #[arg(long, value_name = "URL")]
    eval_url: Option<String>,

    /// Override eval model ID
    #[arg(long, value_name = "ID")]
    eval_model: Option<String>,
}

#[tokio::main]
async fn main() -> color_eyre::Result<()> {
    color_eyre::install()?;
    let cli = Cli::parse();

    if cli.variants < 1 {
        color_eyre::eyre::bail!("Variant count must be at least 1");
    }

    // Parse quality override
    let quality_override: Option<Quality> = if let Some(ref q) = cli.quality {
        match q.parse::<Quality>() {
            Ok(v) => Some(v),
            Err(e) => {
                color_eyre::eyre::bail!("--quality: {}", e);
            }
        }
    } else {
        None
    };

    // Load .envrc.k8.dc for API keys (GEMINI, SUNO, OPENAI, ELEVENLABS, DASHSCOPE)
    try_load_envrc();

    // Expand inputs: directories become all *.prompt files within (recursive)
    let mut prompt_files: Vec<PathBuf> = Vec::new();
    for input in &cli.inputs {
        if input.is_dir() {
            let mut found: Vec<PathBuf> = Vec::new();
            collect_prompt_files(input, &mut found);
            found.sort();
            if found.is_empty() {
                ui::warn_msg(&format!(
                    "No *.prompt files found in directory: {}",
                    input.display()
                ));
            }
            prompt_files.extend(found);
        } else if input.is_file() {
            prompt_files.push(input.clone());
        } else {
            ui::fail_msg(&format!("File or directory not found: {}", input.display()));
        }
    }

    if prompt_files.is_empty() {
        color_eyre::eyre::bail!("No valid .prompt files to process");
    }

    // Parse all prompt files
    ui::step("Loading prompt files");
    let mut prompts = Vec::new();
    for path in &prompt_files {
        let p = parse_prompt_file(path)?;
        if cli.verbose {
            let svc = p.meta.service.as_deref().unwrap_or("auto");
            ui::verbose(&format!(
                "Loaded: {} ({:?}, service={}, quality={}, schema=v{})",
                path.display(),
                p.meta.asset_type,
                svc,
                p.meta.quality.as_str(),
                p.meta.schema_version
            ));
        }
        prompts.push(p);
    }
    ui::ok(&format!("Loaded {} prompt file(s)", prompts.len()));

    // Run pipeline
    let config = PipelineConfig {
        variant_count: cli.variants,
        dry_run: cli.dry_run,
        force: cli.force,
        model_override: cli.model,
        verbose: cli.verbose,
        refine: cli.refine,
        quality_override,
        service_override: cli.service,
        no_eval: cli.no_eval,
        no_prep: cli.no_prep,
        eval_url: cli.eval_url,
        eval_model: cli.eval_model,
    };

    pipeline::run_generation(prompts, &config).await?;

    Ok(())
}

fn try_load_envrc() {
    let candidates = [
        std::env::var("INFRA_ROOT")
            .ok()
            .map(|r| PathBuf::from(r).join(".envrc.k8.dc")),
        std::env::var("HOME")
            .ok()
            .map(|h| PathBuf::from(h).join(".envrc.k8.dc")),
    ];

    for candidate in candidates.into_iter().flatten() {
        if candidate.is_file() {
            if let Ok(content) = std::fs::read_to_string(&candidate) {
                for line in content.lines() {
                    let line = line.trim();
                    if let Some(rest) = line.strip_prefix("export ") {
                        if let Some((key, val)) = rest.split_once('=') {
                            let key = key.trim();
                            let val = val.trim().trim_matches('"').trim_matches('\'');
                            if std::env::var(key).is_err() {
                                std::env::set_var(key, val);
                            }
                        }
                    }
                }
            }
        }
    }
}

fn collect_prompt_files(dir: &Path, out: &mut Vec<PathBuf>) {
    let entries = match std::fs::read_dir(dir) {
        Ok(e) => e,
        Err(_) => return,
    };
    for entry in entries.filter_map(|e| e.ok()) {
        let path = entry.path();
        if path.is_dir() {
            // Skip hidden directories (.genai.*, .DS_Store dirs, etc.)
            if path
                .file_name()
                .and_then(|n| n.to_str())
                .map(|n| n.starts_with('.'))
                .unwrap_or(false)
            {
                continue;
            }
            collect_prompt_files(&path, out);
        } else if path.is_file()
            && path
                .file_name()
                .and_then(|n| n.to_str())
                .map(|n| n.ends_with(".prompt"))
                .unwrap_or(false)
        {
            out.push(path);
        }
    }
}
