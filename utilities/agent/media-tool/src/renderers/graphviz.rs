use std::collections::HashMap;
use std::path::Path;
use std::process::Command;

use super::Renderer;

pub struct GraphvizRenderer;

impl Renderer for GraphvizRenderer {
    fn render(
        &self,
        input_path: &Path,
        output_path: &Path,
        params: &HashMap<String, serde_yaml::Value>,
    ) -> color_eyre::Result<bool> {
        let layout = params
            .get("layout")
            .and_then(|v| v.as_str())
            .unwrap_or("dot");

        let output_format = params
            .get("output_format")
            .and_then(|v| v.as_str())
            .unwrap_or_else(|| {
                output_path
                    .extension()
                    .and_then(|e| e.to_str())
                    .unwrap_or("svg")
            });

        let mut cmd = Command::new(layout);
        cmd.arg(format!("-T{}", output_format));
        cmd.arg(input_path);
        cmd.arg("-o").arg(output_path);

        if let Some(dpi) = params.get("dpi").and_then(|v| v.as_u64()) {
            cmd.arg(format!("-Gdpi={}", dpi));
        }

        let output = cmd.output()?;
        if output.status.success() {
            Ok(true)
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            eprintln!("{} failed: {}", layout, stderr);
            Ok(false)
        }
    }

    fn name(&self) -> &str {
        "graphviz"
    }

    fn is_available(&self) -> bool {
        Command::new("dot").arg("-V").output().is_ok()
    }
}
