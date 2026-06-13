use std::collections::HashMap;
use std::path::Path;
use std::process::Command;

use super::Renderer;

pub struct PuppeteerRenderer;

const RENDER_SCRIPT: &str = r#"
const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

(async () => {
    const [inputPath, outputPath, paramsJson] = process.argv.slice(2);
    const params = JSON.parse(paramsJson || '{}');

    const browser = await puppeteer.launch({ headless: 'new' });
    const page = await browser.newPage();

    const width = params.viewport?.width || 1440;
    const height = params.viewport?.height || 900;
    const scale = params.device_scale_factor || 2;
    await page.setViewport({ width, height, deviceScaleFactor: scale });

    const fileUrl = 'file://' + path.resolve(inputPath);
    await page.goto(fileUrl, { waitUntil: params.wait_for || 'networkidle0', timeout: 30000 });

    const ext = path.extname(outputPath).toLowerCase();
    if (ext === '.pdf') {
        await page.pdf({ path: outputPath, width, height });
    } else {
        await page.screenshot({
            path: outputPath,
            fullPage: params.full_page || false,
        });
    }

    await browser.close();
})();
"#;

impl Renderer for PuppeteerRenderer {
    fn render(
        &self,
        input_path: &Path,
        output_path: &Path,
        params: &HashMap<String, serde_yaml::Value>,
    ) -> color_eyre::Result<bool> {
        let params_json = serde_json::to_string(params)?;

        let script_dir = std::env::temp_dir().join("media-tools-puppeteer");
        std::fs::create_dir_all(&script_dir)?;
        let script_path = script_dir.join("render.js");
        std::fs::write(&script_path, RENDER_SCRIPT)?;

        let output = Command::new("node")
            .arg(&script_path)
            .arg(input_path)
            .arg(output_path)
            .arg(&params_json)
            .output()?;

        if output.status.success() {
            Ok(true)
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            eprintln!("puppeteer render failed: {}", stderr);
            Ok(false)
        }
    }

    fn name(&self) -> &str {
        "puppeteer"
    }

    fn is_available(&self) -> bool {
        Command::new("node")
            .arg("-e")
            .arg("require('puppeteer')")
            .output()
            .map(|o| o.status.success())
            .unwrap_or(false)
    }
}
