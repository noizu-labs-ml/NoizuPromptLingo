use std::path::PathBuf;
use std::process::Command;

use anyhow::{Context, Result};
use serde_yaml::Value;

use crate::meta;
use crate::path::{delete_path, get_path, set_path};
use crate::resolve::resolve_active;
use crate::store;
use crate::version;

// ---------------------------------------------------------------------------
// Backend trait
// ---------------------------------------------------------------------------

/// Abstraction over native filesystem access and CLI subprocess access.
pub trait Backend {
    fn get(&self, config: &str, path: Option<&str>) -> Result<Option<Value>>;
    fn list_configs(&self) -> Result<Vec<String>>;
    fn set(
        &self,
        config: &str,
        key: &str,
        value: &str,
        layer: Option<&str>,
        no_bump: bool,
    ) -> Result<()>;
    fn unset(
        &self,
        config: &str,
        keys: &[&str],
        layer: Option<&str>,
        no_bump: bool,
    ) -> Result<()>;
    fn bump(&self) -> Result<u64>;
}

// ---------------------------------------------------------------------------
// NativeBackend
// ---------------------------------------------------------------------------

/// Backend that reads/writes directly via filesystem operations.
pub struct NativeBackend {
    store_path: PathBuf,
}

impl NativeBackend {
    pub fn new(store_path: PathBuf) -> Self {
        Self { store_path }
    }
}

impl Backend for NativeBackend {
    fn get(&self, config: &str, path: Option<&str>) -> Result<Option<Value>> {
        let active = store::active_path(&self.store_path, config);
        let content = match std::fs::read_to_string(&active) {
            Ok(c) => c,
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => return Ok(None),
            Err(e) => {
                return Err(e)
                    .with_context(|| format!("failed to read active file: {}", active.display()))
            }
        };
        let root: Value = serde_yaml::from_str(&content)
            .with_context(|| format!("failed to parse active file: {}", active.display()))?;

        match path {
            None => Ok(Some(root)),
            Some(p) => Ok(get_path(&root, p)),
        }
    }

    fn list_configs(&self) -> Result<Vec<String>> {
        let m = meta::read_meta(&self.store_path)?;
        Ok(m.configs)
    }

    fn set(
        &self,
        config: &str,
        key: &str,
        value: &str,
        layer: Option<&str>,
        no_bump: bool,
    ) -> Result<()> {
        // Derive the source directory from the store meta so ensure_store works.
        let m = meta::read_meta(&self.store_path)?;
        let _ = store::ensure_store(&m.source)?;
        store::ensure_config(&self.store_path, config)?;

        let layer_name = layer.unwrap_or("local");
        let lp = store::layer_path(&self.store_path, config, layer_name);

        // Read existing layer or start with empty mapping
        let mut doc: Value = if lp.exists() {
            let contents = std::fs::read_to_string(&lp)
                .with_context(|| format!("failed to read layer: {}", lp.display()))?;
            serde_yaml::from_str(&contents)
                .with_context(|| format!("failed to parse layer: {}", lp.display()))?
        } else {
            Value::Mapping(serde_yaml::Mapping::new())
        };

        // Parse the value string as YAML for proper typing
        let yaml_val: Value = serde_yaml::from_str(value).unwrap_or(Value::String(value.into()));

        set_path(&mut doc, key, yaml_val)?;

        // Write layer file
        let yaml =
            serde_yaml::to_string(&doc).context("failed to serialize layer")?;
        std::fs::write(&lp, &yaml)
            .with_context(|| format!("failed to write layer: {}", lp.display()))?;

        // Re-resolve active
        resolve_active(&self.store_path, config)?;

        if !no_bump {
            version::bump_version(&self.store_path)?;
        }

        Ok(())
    }

    fn unset(
        &self,
        config: &str,
        keys: &[&str],
        layer: Option<&str>,
        no_bump: bool,
    ) -> Result<()> {
        let m = meta::read_meta(&self.store_path)?;
        let _ = store::ensure_store(&m.source)?;
        store::ensure_config(&self.store_path, config)?;

        let layer_name = layer.unwrap_or("local");
        let lp = store::layer_path(&self.store_path, config, layer_name);

        if !lp.exists() {
            return Ok(());
        }

        let contents = std::fs::read_to_string(&lp)
            .with_context(|| format!("failed to read layer: {}", lp.display()))?;
        let mut doc: Value = serde_yaml::from_str(&contents)
            .with_context(|| format!("failed to parse layer: {}", lp.display()))?;

        for key in keys {
            delete_path(&mut doc, key);
        }

        let yaml =
            serde_yaml::to_string(&doc).context("failed to serialize layer")?;
        std::fs::write(&lp, &yaml)
            .with_context(|| format!("failed to write layer: {}", lp.display()))?;

        resolve_active(&self.store_path, config)?;

        if !no_bump {
            version::bump_version(&self.store_path)?;
        }

        Ok(())
    }

    fn bump(&self) -> Result<u64> {
        version::bump_version(&self.store_path)
    }
}

// ---------------------------------------------------------------------------
// CliBackend
// ---------------------------------------------------------------------------

/// Backend that shells out to the `dc` CLI binary.
pub struct CliBackend {
    #[allow(dead_code)]
    store_path: PathBuf,
    dc_binary: String,
}

impl CliBackend {
    pub fn new(store_path: PathBuf, dc_binary: String) -> Self {
        Self {
            store_path,
            dc_binary,
        }
    }

    fn run_dc(&self, args: &[&str]) -> Result<String> {
        let output = Command::new(&self.dc_binary)
            .args(args)
            .output()
            .with_context(|| format!("failed to execute: {} {}", self.dc_binary, args.join(" ")))?;

        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!(
                "`{} {}` failed (exit {}): {}",
                self.dc_binary,
                args.join(" "),
                output.status,
                stderr.trim()
            );
        }

        Ok(String::from_utf8_lossy(&output.stdout).to_string())
    }
}

impl Backend for CliBackend {
    fn get(&self, config: &str, path: Option<&str>) -> Result<Option<Value>> {
        let mut args = vec!["get", config];
        if let Some(p) = path {
            args.push(p);
        }

        let stdout = self.run_dc(&args)?;
        if stdout.trim().is_empty() {
            return Ok(None);
        }
        let val: Value = serde_yaml::from_str(stdout.trim())
            .with_context(|| "failed to parse dc get output as YAML")?;
        Ok(Some(val))
    }

    fn list_configs(&self) -> Result<Vec<String>> {
        let stdout = self.run_dc(&["list"])?;
        let configs: Vec<String> = stdout.lines().map(|l| l.trim().to_string()).collect();
        Ok(configs)
    }

    fn set(
        &self,
        config: &str,
        key: &str,
        value: &str,
        layer: Option<&str>,
        no_bump: bool,
    ) -> Result<()> {
        let mut args = vec!["set", config, key, value];
        if let Some(l) = layer {
            args.push("--layer");
            args.push(l);
        }
        if no_bump {
            args.push("--no-bump");
        }
        self.run_dc(&args)?;
        Ok(())
    }

    fn unset(
        &self,
        config: &str,
        keys: &[&str],
        layer: Option<&str>,
        no_bump: bool,
    ) -> Result<()> {
        let mut args = vec!["unset", config];
        for k in keys {
            args.push(k);
        }
        if let Some(l) = layer {
            args.push("--layer");
            args.push(l);
        }
        if no_bump {
            args.push("--no-bump");
        }
        self.run_dc(&args)?;
        Ok(())
    }

    fn bump(&self) -> Result<u64> {
        let stdout = self.run_dc(&["bump"])?;
        let v: u64 = stdout
            .trim()
            .parse()
            .with_context(|| format!("failed to parse dc bump output: {:?}", stdout.trim()))?;
        Ok(v)
    }
}

// ---------------------------------------------------------------------------
// DcClient
// ---------------------------------------------------------------------------

/// Operating mode for the client.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DcMode {
    /// Direct filesystem access (default).
    Native,
    /// Shell out to the `dc` CLI binary.
    Cli,
}

impl Default for DcMode {
    fn default() -> Self {
        Self::Native
    }
}

/// Options for constructing a [`DcClient`].
#[derive(Debug, Clone)]
pub struct DcClientOptions {
    /// Operating mode (default: [`DcMode::Native`]).
    pub mode: DcMode,
    /// Starting directory for store discovery. Defaults to CWD.
    pub directory: Option<PathBuf>,
    /// Explicit store path, bypassing discovery.
    pub state_dir: Option<PathBuf>,
    /// Name of the `dc` binary (default: `"dc"`).
    pub dc_binary: String,
}

impl Default for DcClientOptions {
    fn default() -> Self {
        Self {
            mode: DcMode::Native,
            directory: None,
            state_dir: None,
            dc_binary: "dc".to_string(),
        }
    }
}

/// High-level client for direnv-config with read and write support.
pub struct DcClient {
    backend: Box<dyn Backend>,
    store_path: PathBuf,
}

impl DcClient {
    /// Create a new client. Discovers (or uses explicit) store path and
    /// initializes the appropriate backend.
    pub fn new(options: Option<DcClientOptions>) -> Result<Self> {
        let opts = options.unwrap_or_default();

        let sp = if let Some(ref sd) = opts.state_dir {
            sd.clone()
        } else {
            store::find_current_store(opts.directory.as_deref())?
        };

        let backend: Box<dyn Backend> = match opts.mode {
            DcMode::Cli => Box::new(CliBackend::new(sp.clone(), opts.dc_binary)),
            DcMode::Native => Box::new(NativeBackend::new(sp.clone())),
        };

        Ok(Self {
            backend,
            store_path: sp,
        })
    }

    // -- Read ---------------------------------------------------------------

    /// Get a config value. If `path` is `None`, returns the entire config.
    pub fn get(&self, config: &str, path: Option<&str>) -> Result<Option<Value>> {
        self.backend.get(config, path)
    }

    /// Get a string value at the given path.
    pub fn get_string(&self, config: &str, path: &str) -> Result<Option<String>> {
        let val = self.backend.get(config, Some(path))?;
        Ok(val.map(|v| match v {
            Value::String(s) => s,
            other => {
                // Convert non-string scalars to their string representation
                serde_yaml::to_string(&other)
                    .unwrap_or_default()
                    .trim()
                    .to_string()
            }
        }))
    }

    /// Get an integer value at the given path.
    pub fn get_int(&self, config: &str, path: &str) -> Result<Option<i64>> {
        let val = self.backend.get(config, Some(path))?;
        Ok(val.and_then(|v| v.as_i64()))
    }

    /// Get a boolean value at the given path.
    pub fn get_bool(&self, config: &str, path: &str) -> Result<Option<bool>> {
        let val = self.backend.get(config, Some(path))?;
        Ok(val.and_then(|v| match v {
            Value::Bool(b) => Some(b),
            Value::String(ref s) if s == "true" => Some(true),
            Value::String(ref s) if s == "false" => Some(false),
            _ => None,
        }))
    }

    /// List all config names in the current store.
    pub fn list_configs(&self) -> Result<Vec<String>> {
        self.backend.list_configs()
    }

    /// Read the current store version.
    pub fn version(&self) -> u64 {
        version::read_version(&self.store_path)
    }

    /// Check whether the store version has changed since `since`.
    pub fn has_changed(&self, since: u64) -> bool {
        version::read_version(&self.store_path) != since
    }

    // -- Write --------------------------------------------------------------

    /// Set a value in a config layer.
    ///
    /// The `value` string is parsed as YAML for proper typing (numbers, bools),
    /// falling back to a plain string.
    ///
    /// Default layer: `"local"`. Pass `no_bump = true` to suppress the version bump.
    pub fn set(
        &self,
        config: &str,
        key: &str,
        value: &str,
        layer: Option<&str>,
        no_bump: bool,
    ) -> Result<()> {
        self.backend.set(config, key, value, layer, no_bump)
    }

    /// Remove one or more keys from a config layer.
    ///
    /// Default layer: `"local"`. Pass `no_bump = true` to suppress the version bump.
    pub fn unset(
        &self,
        config: &str,
        keys: &[&str],
        layer: Option<&str>,
        no_bump: bool,
    ) -> Result<()> {
        self.backend.unset(config, keys, layer, no_bump)
    }

    /// Manually bump the store version.
    pub fn bump(&self) -> Result<u64> {
        self.backend.bump()
    }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;
    use crate::meta::StoreMeta;
    use tempfile::TempDir;

    /// Set up a temporary store with a config and an .active file.
    fn setup_store() -> (TempDir, PathBuf) {
        let tmp = TempDir::new().unwrap();
        let sp = tmp.path().join("test-store");
        std::fs::create_dir_all(sp.join("myapp")).unwrap();

        let m = StoreMeta {
            source: PathBuf::from("/test/project"),
            created: "2026-01-01T00:00:00+00:00".to_string(),
            parent: None,
            configs: vec!["myapp".to_string()],
        };
        meta::write_meta(&sp, &m).unwrap();

        std::fs::write(
            sp.join("myapp/.active"),
            "host: localhost\nport: 5432\ndebug: true\nname: testdb\n",
        )
        .unwrap();

        (tmp, sp)
    }

    #[test]
    fn native_get_full_config() {
        let (_tmp, sp) = setup_store();
        let backend = NativeBackend::new(sp);
        let val = backend.get("myapp", None).unwrap().unwrap();
        assert_eq!(val["host"], Value::String("localhost".into()));
    }

    #[test]
    fn native_get_path() {
        let (_tmp, sp) = setup_store();
        let backend = NativeBackend::new(sp);
        let val = backend.get("myapp", Some("host")).unwrap().unwrap();
        assert_eq!(val, Value::String("localhost".into()));
    }

    #[test]
    fn native_get_missing_config() {
        let (_tmp, sp) = setup_store();
        let backend = NativeBackend::new(sp);
        let val = backend.get("nonexistent", None).unwrap();
        assert!(val.is_none());
    }

    #[test]
    fn native_get_missing_path() {
        let (_tmp, sp) = setup_store();
        let backend = NativeBackend::new(sp);
        let val = backend.get("myapp", Some("nonexistent")).unwrap();
        assert!(val.is_none());
    }

    #[test]
    fn native_list_configs() {
        let (_tmp, sp) = setup_store();
        let backend = NativeBackend::new(sp);
        let configs = backend.list_configs().unwrap();
        assert_eq!(configs, vec!["myapp".to_string()]);
    }

    #[test]
    fn native_set_and_get() {
        let (_tmp, sp) = setup_store();

        // Write base.yaml so resolve_active has something
        std::fs::write(sp.join("myapp/base.yaml"), "host: localhost\nport: 5432").unwrap();

        // Suppress DC_ENV layer lookup to simplify
        std::env::set_var("DC_ENV", "nonexistent_env_for_test");

        let backend = NativeBackend::new(sp.clone());
        backend
            .set("myapp", "timeout", "30", None, false)
            .unwrap();

        // Check the local.yaml was written
        let local_content = std::fs::read_to_string(sp.join("myapp/local.yaml")).unwrap();
        let local_val: Value = serde_yaml::from_str(&local_content).unwrap();
        assert_eq!(local_val["timeout"], serde_yaml::from_str::<Value>("30").unwrap());

        // Check .active was re-resolved
        let active_content = std::fs::read_to_string(sp.join("myapp/.active")).unwrap();
        let active_val: Value = serde_yaml::from_str(&active_content).unwrap();
        assert_eq!(active_val["timeout"], serde_yaml::from_str::<Value>("30").unwrap());
        assert_eq!(active_val["host"], Value::String("localhost".into()));
    }

    #[test]
    fn native_set_bool_value() {
        let (_tmp, sp) = setup_store();
        std::fs::write(sp.join("myapp/base.yaml"), "host: localhost").unwrap();
        std::env::set_var("DC_ENV", "nonexistent_env_for_test");

        let backend = NativeBackend::new(sp.clone());
        backend
            .set("myapp", "verbose", "true", None, true)
            .unwrap();

        let local_content = std::fs::read_to_string(sp.join("myapp/local.yaml")).unwrap();
        let local_val: Value = serde_yaml::from_str(&local_content).unwrap();
        assert_eq!(local_val["verbose"], Value::Bool(true));
    }

    #[test]
    fn native_unset() {
        let (_tmp, sp) = setup_store();

        // Write a local.yaml with keys to unset
        std::fs::write(sp.join("myapp/local.yaml"), "a: 1\nb: 2\nc: 3").unwrap();
        std::fs::write(sp.join("myapp/base.yaml"), "host: localhost").unwrap();
        std::env::set_var("DC_ENV", "nonexistent_env_for_test");

        let backend = NativeBackend::new(sp.clone());
        backend
            .unset("myapp", &["a", "c"], None, true)
            .unwrap();

        let local_content = std::fs::read_to_string(sp.join("myapp/local.yaml")).unwrap();
        let local_val: Value = serde_yaml::from_str(&local_content).unwrap();
        assert!(local_val["a"].is_null());
        assert_eq!(local_val["b"], serde_yaml::from_str::<Value>("2").unwrap());
        assert!(local_val["c"].is_null());
    }

    #[test]
    fn native_bump() {
        let (_tmp, sp) = setup_store();
        let backend = NativeBackend::new(sp.clone());
        let v1 = backend.bump().unwrap();
        assert_eq!(v1, 1);
        let v2 = backend.bump().unwrap();
        assert_eq!(v2, 2);
    }

    #[test]
    fn client_typed_getters() {
        let (_tmp, sp) = setup_store();
        let client = DcClient::new(Some(DcClientOptions {
            mode: DcMode::Native,
            state_dir: Some(sp),
            ..Default::default()
        }))
        .unwrap();

        assert_eq!(
            client.get_string("myapp", "host").unwrap(),
            Some("localhost".to_string())
        );
        assert_eq!(client.get_int("myapp", "port").unwrap(), Some(5432));
        assert_eq!(client.get_bool("myapp", "debug").unwrap(), Some(true));
        assert_eq!(
            client.get_string("myapp", "nonexistent").unwrap(),
            None
        );
    }

    #[test]
    fn client_version_and_has_changed() {
        let (_tmp, sp) = setup_store();
        let client = DcClient::new(Some(DcClientOptions {
            mode: DcMode::Native,
            state_dir: Some(sp),
            ..Default::default()
        }))
        .unwrap();

        let v0 = client.version();
        assert_eq!(v0, 0);
        assert!(!client.has_changed(0));

        client.bump().unwrap();
        assert!(client.has_changed(v0));
        assert_eq!(client.version(), 1);
    }
}
