//! Image planning and building.
//!
//! `image/*` only *plans* and enumerates; the actual docker shell-out lives in
//! [`crate::docker`]. The flow: an [`AppSet`] is resolved against locally
//! available images into an [`ImagePlan`], which either reuses an exact image,
//! layers a delta on top of the closest subset image, or builds from scratch.

mod build;
mod closest;
mod dockerfile;
mod registry;
mod slug;
mod snippets;

pub use registry::list_sandbox_images;
pub use slug::AppSet;
pub use snippets::SnippetLibrary;

use crate::config::ImageOverrides;
use crate::error::Result;

/// A resolved plan for producing the image for a requested app set.
#[derive(Debug, Clone)]
pub struct ImagePlan {
    pub requested: AppSet,
    pub kind: PlanKind,
    pub pretty_prefix: String,
}

#[derive(Debug, Clone)]
pub enum PlanKind {
    /// An exact image already exists; reuse it.
    Exact { reference: String },
    /// Layer `add` on top of an existing `base` image.
    Layered { base: String, add: AppSet },
    /// Build from the library base image, adding `add`.
    FromScratch { add: AppSet },
}

impl ImagePlan {
    /// One-line human summary.
    pub fn summary(&self) -> String {
        let pretty = self.requested.pretty(&self.pretty_prefix);
        match &self.kind {
            PlanKind::Exact { reference } => {
                format!("{pretty}: reuse existing image {reference}")
            }
            PlanKind::Layered { base, add } => format!(
                "{pretty}: build from {base}, adding [{}]",
                add.slugs().collect::<Vec<_>>().join(", ")
            ),
            PlanKind::FromScratch { add } => format!(
                "{pretty}: build from scratch with [{}]",
                add.slugs().collect::<Vec<_>>().join(", ")
            ),
        }
    }

    /// Render the Dockerfile this plan would build, or `None` for `Exact`.
    pub fn render_dockerfile(&self, snippets: &SnippetLibrary) -> Result<Option<String>> {
        let (base_line, add, base_apt) = match &self.kind {
            PlanKind::Exact { .. } => return Ok(None),
            PlanKind::Layered { base, add } => (format!("FROM {base}"), add, Vec::new()),
            PlanKind::FromScratch { add } => {
                (snippets.base().body.clone(), add, snippets.base().apt.clone())
            }
        };
        let df = dockerfile::assemble(&base_line, add, &self.requested, &base_apt, snippets)?;
        Ok(Some(df))
    }
}

/// Resolve an app set into a plan using locally available images.
pub fn resolve_image(
    requested: &AppSet,
    overrides: &ImageOverrides,
    _snippets: &SnippetLibrary,
) -> Result<ImagePlan> {
    let available = list_sandbox_images()?;
    closest::select_plan(requested, &available, overrides)
}

/// Build the image for a plan and return its reference.
pub fn build(plan: &ImagePlan, snippets: &SnippetLibrary) -> Result<String> {
    build::build_image(plan, snippets)
}
