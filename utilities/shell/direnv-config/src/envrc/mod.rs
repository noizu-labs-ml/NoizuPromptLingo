//! Line-oriented editing of hand-authored `.envrc*` source files.
//!
//! Unlike the state store, these are the literal files a human wrote, so edits
//! must preserve comments and formatting. We therefore never re-serialize YAML;
//! we scan `dc_yaml … <<'YAML' … YAML` heredoc blocks, index key paths to line
//! ranges, and splice only the targeted lines.

pub mod locator;
