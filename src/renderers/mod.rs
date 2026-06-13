pub mod graphviz;
pub mod mermaid;
pub mod plantuml;
pub mod puppeteer;

use std::collections::HashMap;
use std::path::Path;

pub trait Renderer: Send + Sync {
    fn render(
        &self,
        input_path: &Path,
        output_path: &Path,
        params: &HashMap<String, serde_yaml::Value>,
    ) -> color_eyre::Result<bool>;

    fn name(&self) -> &str;
    fn is_available(&self) -> bool;
}

pub fn get_renderer(tool: &str) -> Option<Box<dyn Renderer>> {
    match tool {
        "mermaid" => Some(Box::new(mermaid::MermaidRenderer)),
        "plantuml" => Some(Box::new(plantuml::PlantUmlRenderer)),
        "graphviz" => Some(Box::new(graphviz::GraphvizRenderer)),
        "puppeteer" => Some(Box::new(puppeteer::PuppeteerRenderer)),
        _ => None,
    }
}
