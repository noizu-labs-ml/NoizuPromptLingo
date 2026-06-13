//! `AppSet` — a normalized set of app slugs that maps 1:1 to a docker image tag.

use std::collections::BTreeSet;

/// Docker repository name (must be lowercase). The pretty `AgentSandbox:` form is
/// UI-only; on disk images live under this repo with the app set as the tag.
pub const REPO: &str = "agent-sandbox";

/// OCI label that records the exact app set baked into an image. We match on this
/// label rather than parsing tags, so a manually retagged image can't false-match.
pub const APPS_LABEL: &str = "org.agent-sandbox.apps";

/// A sorted, deduped, lowercased set of app slugs.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AppSet {
    slugs: BTreeSet<String>,
}

impl AppSet {
    pub fn from_slugs<S: AsRef<str>>(slugs: &[S]) -> Self {
        let slugs = slugs
            .iter()
            .map(|s| s.as_ref().trim().to_lowercase())
            .filter(|s| !s.is_empty())
            .collect();
        Self { slugs }
    }

    /// Parse the comma-separated value of the [`APPS_LABEL`].
    pub fn from_label(value: &str) -> Self {
        Self::from_slugs(&value.split(',').collect::<Vec<_>>())
    }

    pub fn is_empty(&self) -> bool {
        self.slugs.is_empty()
    }

    pub fn len(&self) -> usize {
        self.slugs.len()
    }

    pub fn slugs(&self) -> impl Iterator<Item = &str> {
        self.slugs.iter().map(|s| s.as_str())
    }

    pub fn contains(&self, slug: &str) -> bool {
        self.slugs.contains(slug)
    }

    /// True if every slug in `self` is also present in `other`.
    pub fn is_subset_of(&self, other: &AppSet) -> bool {
        self.slugs.is_subset(&other.slugs)
    }

    /// Slugs present in `self` but not in `other`.
    pub fn difference(&self, other: &AppSet) -> AppSet {
        AppSet {
            slugs: self.slugs.difference(&other.slugs).cloned().collect(),
        }
    }

    /// The label value: comma-joined sorted slugs.
    pub fn label_value(&self) -> String {
        self.slugs.iter().cloned().collect::<Vec<_>>().join(",")
    }

    /// The docker tag fragment: dash-joined sorted slugs.
    pub fn tag(&self) -> String {
        self.slugs.iter().cloned().collect::<Vec<_>>().join("-")
    }

    /// Fully qualified `agent-sandbox:slug-set` reference.
    pub fn image_reference(&self) -> String {
        format!("{}:{}", REPO, self.tag())
    }

    /// Pretty name for display, e.g. `AgentSandbox:node-rust`.
    pub fn pretty(&self, prefix: &str) -> String {
        format!("{}:{}", prefix, self.tag())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn normalizes_sorts_dedupes() {
        let a = AppSet::from_slugs(&["Rust", "node", "rust", "  ", "NODE"]);
        assert_eq!(a.tag(), "node-rust");
        assert_eq!(a.label_value(), "node,rust");
        assert_eq!(a.len(), 2);
    }

    #[test]
    fn subset_and_difference() {
        let req = AppSet::from_slugs(&["node", "rust", "claude"]);
        let base = AppSet::from_slugs(&["node", "rust"]);
        assert!(base.is_subset_of(&req));
        assert!(!req.is_subset_of(&base));
        assert_eq!(req.difference(&base), AppSet::from_slugs(&["claude"]));
    }

    #[test]
    fn image_reference_is_lowercase() {
        let a = AppSet::from_slugs(&["Node"]);
        assert_eq!(a.image_reference(), "agent-sandbox:node");
    }

    #[test]
    fn from_label_parses_comma_list() {
        let a = AppSet::from_label("rust,node,claude");
        assert_eq!(a.tag(), "claude-node-rust");
    }

    #[test]
    fn contains_and_len() {
        let a = AppSet::from_slugs(&["node", "rust"]);
        assert!(a.contains("node"));
        assert!(!a.contains("python"));
        assert_eq!(a.len(), 2);
        assert!(!a.is_empty());
        assert!(AppSet::from_slugs::<&str>(&[]).is_empty());
    }
}
