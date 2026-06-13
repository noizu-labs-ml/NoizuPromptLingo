use std::collections::HashMap;
use std::path::Path;
use std::process::Command;

use super::Renderer;

pub struct PlantUmlRenderer;

impl Renderer for PlantUmlRenderer {
    fn render(
        &self,
        input_path: &Path,
        output_path: &Path,
        params: &HashMap<String, serde_yaml::Value>,
    ) -> color_eyre::Result<bool> {
        let output_format = params
            .get("output_format")
            .and_then(|v| v.as_str())
            .unwrap_or_else(|| {
                output_path
                    .extension()
                    .and_then(|e| e.to_str())
                    .unwrap_or("svg")
            });

        let output_dir = output_path.parent().unwrap_or(Path::new("."));

        let mut cmd = Command::new("plantuml");
        cmd.arg(format!("-t{}", output_format));
        cmd.arg("-o").arg(output_dir);
        cmd.arg(input_path);

        let output = cmd.output()?;
        if output.status.success() {
            // plantuml writes to input_dir/input_stem.ext — move if needed
            let expected = input_path.with_extension(output_format);
            if expected != output_path && expected.exists() {
                std::fs::rename(&expected, output_path)?;
            }
            Ok(true)
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            eprintln!("plantuml failed: {}", stderr);
            Ok(false)
        }
    }

    fn name(&self) -> &str {
        "plantuml"
    }

    fn is_available(&self) -> bool {
        Command::new("plantuml").arg("-version").output().is_ok()
    }
}
