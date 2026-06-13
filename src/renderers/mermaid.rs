use std::collections::HashMap;
use std::path::Path;
use std::process::Command;

use super::Renderer;

pub struct MermaidRenderer;

impl Renderer for MermaidRenderer {
    fn render(
        &self,
        input_path: &Path,
        output_path: &Path,
        params: &HashMap<String, serde_yaml::Value>,
    ) -> color_eyre::Result<bool> {
        let mut cmd = Command::new("mmdc");
        cmd.arg("-i").arg(input_path);
        cmd.arg("-o").arg(output_path);

        if let Some(theme) = params.get("theme").and_then(|v| v.as_str()) {
            cmd.arg("-t").arg(theme);
        }
        if let Some(bg) = params.get("background").and_then(|v| v.as_str()) {
            cmd.arg("-b").arg(bg);
        }
        if let Some(w) = params.get("width").and_then(|v| v.as_u64()) {
            cmd.arg("-w").arg(w.to_string());
        }
        if let Some(h) = params.get("height").and_then(|v| v.as_u64()) {
            cmd.arg("-H").arg(h.to_string());
        }
        if let Some(css) = params.get("css").and_then(|v| v.as_str()) {
            cmd.arg("-C").arg(css);
        }

        let output = cmd.output()?;
        if output.status.success() {
            Ok(true)
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            eprintln!("mmdc failed: {}", stderr);
            Ok(false)
        }
    }

    fn name(&self) -> &str {
        "mermaid"
    }

    fn is_available(&self) -> bool {
        Command::new("mmdc").arg("--version").output().is_ok()
    }
}
