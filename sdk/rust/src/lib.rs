//! # direnv-config
//!
//! Rust SDK for [direnv-config (dc)](https://github.com/noizu/direnv-config) —
//! read and write YAML-backed directory configuration from Rust.
//!
//! ## Quick start
//!
//! ```rust,no_run
//! use direnv_config::{DcClient, DcClientOptions, DcMode};
//!
//! let client = DcClient::new(None).expect("failed to discover dc store");
//!
//! // Read a value
//! if let Some(host) = client.get_string("myapp", "db.host").unwrap() {
//!     println!("db host: {host}");
//! }
//!
//! // Write a value to the local layer
//! client.set("myapp", "db.port", "5433", None, false).unwrap();
//! ```
//!
//! ## Backends
//!
//! The SDK provides two backends via [`DcMode`]:
//!
//! - **Native** (default) — reads and writes YAML files directly on the filesystem.
//! - **Cli** — shells out to the `dc` binary for all operations.
//!
//! See the [repository README](https://github.com/noizu/direnv-config) for full
//! documentation on the direnv-config system.

pub mod store;
pub mod version;
pub mod path;
pub mod merge;
pub mod resolve;
pub mod meta;
pub mod client;

// Re-export primary public types
pub use client::{DcClient, DcClientOptions, DcMode, Backend};
pub use meta::StoreMeta;
pub use serde_yaml::Value;
