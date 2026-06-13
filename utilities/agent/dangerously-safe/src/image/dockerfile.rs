//! Assemble a Dockerfile from a base line plus an ordered set of app snippets.

use super::slug::{AppSet, APPS_LABEL};
use super::snippets::SnippetLibrary;
use crate::error::{Result, SandboxError};
use std::collections::{BTreeSet, HashSet};

/// Build a Dockerfile string.
///
/// * `base_line` — the `FROM ...` line (and any base preamble).
/// * `add` — app slugs to install on top of the base.
/// * `requested` — the full app set baked into the result (used for the label).
/// * `base_apt` — apt packages contributed by the base fragment (from-scratch).
pub fn assemble(
    base_line: &str,
    add: &AppSet,
    requested: &AppSet,
    base_apt: &[String],
    snippets: &SnippetLibrary,
) -> Result<String> {
    let ordered = topo_sort(add, snippets)?;

    // Merge apt installs from the base and all added snippets into one
    // cache-friendly layer.
    let mut apt: BTreeSet<String> = base_apt.iter().cloned().collect();
    for slug in &ordered {
        for pkg in &snippets.get(slug)?.apt {
            apt.insert(pkg.clone());
        }
    }

    let mut out = String::new();
    out.push_str(base_line.trim());
    out.push('\n');

    if !apt.is_empty() {
        let pkgs = apt.into_iter().collect::<Vec<_>>().join(" ");
        out.push_str(&format!(
            "RUN apt-get update \\\n    && apt-get install -y --no-install-recommends {pkgs} \\\n    && rm -rf /var/lib/apt/lists/*\n"
        ));
    }

    for slug in &ordered {
        let snip = snippets.get(slug)?;
        if !snip.body.is_empty() {
            out.push_str(&format!("\n# --- app: {slug} ---\n"));
            out.push_str(snip.body.trim());
            out.push('\n');
        }
    }

    out.push_str(&format!(
        "\nLABEL {APPS_LABEL}=\"{}\"\n",
        requested.label_value()
    ));
    out.push_str("WORKDIR /work\n");
    out.push_str("ENTRYPOINT [\"/usr/bin/env\", \"bash\", \"-l\"]\n");
    Ok(out)
}

/// Topologically order `add` slugs so a snippet's `requires` come before it.
/// `requires` entries that aren't themselves in `add` are treated as already
/// satisfied by the base (e.g. `requires: base`) and are skipped. Detects cycles
/// and unknown slugs.
fn topo_sort(add: &AppSet, snippets: &SnippetLibrary) -> Result<Vec<String>> {
    let want: BTreeSet<String> = add.slugs().map(|s| s.to_string()).collect();
    let mut visited: HashSet<String> = HashSet::new();
    let mut on_stack: HashSet<String> = HashSet::new();
    let mut order: Vec<String> = Vec::new();

    fn visit(
        slug: &str,
        want: &BTreeSet<String>,
        snippets: &SnippetLibrary,
        visited: &mut HashSet<String>,
        on_stack: &mut HashSet<String>,
        order: &mut Vec<String>,
    ) -> Result<()> {
        if visited.contains(slug) {
            return Ok(());
        }
        if on_stack.contains(slug) {
            return Err(SandboxError::SnippetCycle(slug.to_string()).into());
        }
        // Validate the slug exists in the library.
        let snip = snippets.get(slug)?;
        on_stack.insert(slug.to_string());
        for dep in &snip.requires {
            // Only order deps that are part of the requested add-set; deps
            // satisfied by the base (not in `want`) are skipped.
            if want.contains(dep) {
                visit(dep, want, snippets, visited, on_stack, order)?;
            }
        }
        on_stack.remove(slug);
        visited.insert(slug.to_string());
        order.push(slug.to_string());
        Ok(())
    }

    for slug in want.iter() {
        visit(slug, &want, snippets, &mut visited, &mut on_stack, &mut order)?;
    }
    Ok(order)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::image::snippets::{BaseImage, Snippet};

    fn lib() -> SnippetLibrary {
        SnippetLibrary::from_parts(
            vec![
                Snippet {
                    slug: "base-lang".into(),
                    requires: vec!["base".into()],
                    apt: vec!["curl".into()],
                    body: "RUN install base-lang".into(),
                },
                Snippet {
                    slug: "framework".into(),
                    requires: vec!["base-lang".into()],
                    apt: vec!["git".into()],
                    body: "RUN install framework".into(),
                },
            ],
            BaseImage {
                apt: vec![],
                body: "FROM debian:stable-slim".into(),
            },
        )
    }

    #[test]
    fn orders_dependencies_first() {
        let add = AppSet::from_slugs(&["framework", "base-lang"]);
        let order = topo_sort(&add, &lib()).unwrap();
        let bl = order.iter().position(|s| s == "base-lang").unwrap();
        let fw = order.iter().position(|s| s == "framework").unwrap();
        assert!(bl < fw, "base-lang must come before framework: {order:?}");
    }

    #[test]
    fn assemble_includes_label_and_apt() {
        let add = AppSet::from_slugs(&["framework", "base-lang"]);
        let df = assemble("FROM debian:stable-slim", &add, &add, &[], &lib()).unwrap();
        assert!(df.contains("apt-get install"));
        assert!(df.contains("curl"));
        assert!(df.contains("git"));
        assert!(df.contains("org.agent-sandbox.apps=\"base-lang,framework\""));
        assert!(df.contains("ENTRYPOINT"));
    }

    #[test]
    fn unknown_slug_errors() {
        let add = AppSet::from_slugs(&["nope"]);
        assert!(topo_sort(&add, &lib()).is_err());
    }

    #[test]
    fn cycle_detected() {
        let cyc = SnippetLibrary::from_parts(
            vec![
                Snippet {
                    slug: "a".into(),
                    requires: vec!["b".into()],
                    apt: vec![],
                    body: "RUN a".into(),
                },
                Snippet {
                    slug: "b".into(),
                    requires: vec!["a".into()],
                    apt: vec![],
                    body: "RUN b".into(),
                },
            ],
            BaseImage {
                apt: vec![],
                body: "FROM x".into(),
            },
        );
        let add = AppSet::from_slugs(&["a", "b"]);
        assert!(topo_sort(&add, &cyc).is_err());
    }
}
