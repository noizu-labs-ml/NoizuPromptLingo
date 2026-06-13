//! Closest-match image selection: reuse an exact image, else the closest existing
//! image whose app set is a *subset* of what we want, adding only the delta.

use super::registry::SandboxImage;
use super::slug::AppSet;
use super::{ImagePlan, PlanKind};
use crate::config::ImageOverrides;
use crate::error::{Result, SandboxError};

/// Heavy toolchains we prefer to reuse (build-time expensive layers). Used only
/// as a tie-breaker between equally-sized subset bases.
const HEAVY: &[&str] = &["elixir", "rust", "node", "python", "go", "java"];

fn heavy_overlap(set: &AppSet) -> usize {
    HEAVY.iter().filter(|h| set.contains(h)).count()
}

/// Pure selection over an already-enumerated image list. Separated from docker
/// enumeration so it can be unit-tested.
pub fn select_plan(
    requested: &AppSet,
    available: &[SandboxImage],
    overrides: &ImageOverrides,
) -> Result<ImagePlan> {
    if requested.is_empty() {
        return Err(SandboxError::EmptyAppSet.into());
    }

    // Explicit base pin: add everything on top of the user's chosen base.
    if let Some(base) = &overrides.base {
        return Ok(ImagePlan {
            requested: requested.clone(),
            kind: PlanKind::Layered {
                base: base.clone(),
                add: requested.clone(),
            },
            pretty_prefix: overrides.registry_prefix.clone(),
        });
    }

    // 1. Exact hit.
    if let Some(img) = available.iter().find(|i| &i.app_set == requested) {
        return Ok(ImagePlan {
            requested: requested.clone(),
            kind: PlanKind::Exact {
                reference: img.reference.clone(),
            },
            pretty_prefix: overrides.registry_prefix.clone(),
        });
    }

    // 2. Closest subset base. Subset-only on purpose: a superset base would
    //    carry tooling we did not request (larger attack surface).
    let best = available
        .iter()
        .filter(|i| i.app_set.is_subset_of(requested) && !i.app_set.is_empty())
        .max_by(|a, b| {
            a.app_set
                .len()
                .cmp(&b.app_set.len())
                .then(heavy_overlap(&a.app_set).cmp(&heavy_overlap(&b.app_set)))
                // deterministic final tie-break by tag string
                .then(b.app_set.tag().cmp(&a.app_set.tag()))
        });

    match best {
        Some(base) => Ok(ImagePlan {
            requested: requested.clone(),
            kind: PlanKind::Layered {
                base: base.reference.clone(),
                add: requested.difference(&base.app_set),
            },
            pretty_prefix: overrides.registry_prefix.clone(),
        }),
        None => Ok(ImagePlan {
            requested: requested.clone(),
            kind: PlanKind::FromScratch {
                add: requested.clone(),
            },
            pretty_prefix: overrides.registry_prefix.clone(),
        }),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn img(apps: &[&str]) -> SandboxImage {
        let app_set = AppSet::from_slugs(apps);
        SandboxImage {
            reference: app_set.image_reference(),
            apps: app_set.slugs().map(|s| s.to_string()).collect(),
            app_set,
        }
    }

    #[test]
    fn exact_match_wins() {
        let req = AppSet::from_slugs(&["node", "rust"]);
        let avail = vec![img(&["node"]), img(&["node", "rust"])];
        let plan = select_plan(&req, &avail, &ImageOverrides::default()).unwrap();
        assert!(matches!(plan.kind, PlanKind::Exact { .. }));
    }

    #[test]
    fn closest_subset_base_with_delta() {
        let req = AppSet::from_slugs(&["node", "rust", "claude"]);
        let avail = vec![img(&["node"]), img(&["node", "rust"])];
        let plan = select_plan(&req, &avail, &ImageOverrides::default()).unwrap();
        match plan.kind {
            PlanKind::Layered { base, add } => {
                assert_eq!(base, "agent-sandbox:node-rust");
                assert_eq!(add, AppSet::from_slugs(&["claude"]));
            }
            other => panic!("expected layered, got {other:?}"),
        }
    }

    #[test]
    fn superset_image_is_not_used_as_base() {
        // available image has MORE than requested -> not a subset -> from scratch
        let req = AppSet::from_slugs(&["node"]);
        let avail = vec![img(&["node", "rust", "elixir"])];
        let plan = select_plan(&req, &avail, &ImageOverrides::default()).unwrap();
        assert!(matches!(plan.kind, PlanKind::FromScratch { .. }));
    }

    #[test]
    fn from_scratch_when_nothing_matches() {
        let req = AppSet::from_slugs(&["node"]);
        let plan = select_plan(&req, &[], &ImageOverrides::default()).unwrap();
        assert!(matches!(plan.kind, PlanKind::FromScratch { .. }));
    }

    #[test]
    fn empty_request_errors() {
        let req = AppSet::from_slugs::<&str>(&[]);
        assert!(select_plan(&req, &[], &ImageOverrides::default()).is_err());
    }

    #[test]
    fn explicit_base_override() {
        let req = AppSet::from_slugs(&["node"]);
        let ov = ImageOverrides {
            base: Some("ubuntu:24.04".into()),
            ..ImageOverrides::default()
        };
        let plan = select_plan(&req, &[], &ov).unwrap();
        match plan.kind {
            PlanKind::Layered { base, add } => {
                assert_eq!(base, "ubuntu:24.04");
                assert_eq!(add, req);
            }
            other => panic!("expected layered, got {other:?}"),
        }
    }
}
