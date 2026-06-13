//! Build an image from a plan by generating a Dockerfile in a temp context and
//! invoking `docker build`.

use super::{ImagePlan, PlanKind, SnippetLibrary};
use crate::docker;
use crate::error::Result;
use anyhow::Context;

/// Build the image for `plan`, returning its reference. An `Exact` plan is a
/// no-op that returns the existing reference.
pub fn build_image(plan: &ImagePlan, snippets: &SnippetLibrary) -> Result<String> {
    if let PlanKind::Exact { reference } = &plan.kind {
        return Ok(reference.clone());
    }

    let dockerfile = plan
        .render_dockerfile(snippets)?
        .expect("non-exact plan always renders a Dockerfile");

    let tag = plan.requested.image_reference();

    let ctx = tempfile::Builder::new()
        .prefix("agent-sandbox-build-")
        .tempdir()
        .context("creating temp build context")?;
    let dockerfile_path = ctx.path().join("Dockerfile");
    std::fs::write(&dockerfile_path, &dockerfile)
        .with_context(|| format!("writing {}", dockerfile_path.display()))?;

    docker::run_streaming(&[
        "build",
        "-t",
        &tag,
        "-f",
        &dockerfile_path.to_string_lossy(),
        &ctx.path().to_string_lossy(),
    ])
    .context("docker build failed")?;

    Ok(tag)
}
