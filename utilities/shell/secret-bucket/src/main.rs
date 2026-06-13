use anyhow::{bail, Context, Result};
use clap::{Parser, Subcommand, ValueEnum};
use serde::{Deserialize, Serialize};
use serde_yaml::{Mapping, Value};
use std::collections::{BTreeMap, BTreeSet};
use std::fs;
#[cfg(unix)]
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};

#[derive(Parser)]
#[command(name = "secret-bucket")]
#[command(about = "Agent-safe local secret bucket manipulation")]
struct Cli {
    #[arg(long, global = true)]
    policy: Option<PathBuf>,
    #[command(subcommand)]
    command: Command,
}

#[derive(Subcommand)]
enum Command {
    List {
        prefix: String,
        #[arg(long, value_enum, default_value_t = OutputFormat::Text)]
        format: OutputFormat,
    },
    Diff {
        left: String,
        right: String,
        #[arg(long, value_enum, default_value_t = OutputFormat::Text)]
        format: OutputFormat,
    },
    Copy {
        source: String,
        destination: String,
        #[arg(long)]
        dry_run: bool,
    },
    Set {
        destination: String,
        #[arg(long)]
        value_file: PathBuf,
        #[arg(long)]
        dry_run: bool,
    },
}

#[derive(Clone, Copy, Debug, ValueEnum)]
enum OutputFormat {
    Text,
    Json,
}

#[derive(Debug, Clone)]
enum Address {
    Envrc {
        file: PathBuf,
        key: Option<String>,
    },
    DcFile {
        file: PathBuf,
        bucket: String,
        key: Option<String>,
    },
}

#[derive(Debug, Serialize)]
struct KeyList {
    keys: Vec<String>,
}

#[derive(Debug, Serialize)]
struct DiffReport {
    same: Vec<String>,
    changed: Vec<String>,
    missing_left: Vec<String>,
    missing_right: Vec<String>,
}

#[derive(Debug, Serialize)]
struct ActionReport {
    action: &'static str,
    source: Option<String>,
    destination: String,
    status: &'static str,
}

fn main() -> Result<()> {
    let cli = Cli::parse();
    let policy = match cli.policy {
        Some(path) => Some(Policy::load(&path)?),
        None => None,
    };

    match cli.command {
        Command::List { prefix, format } => {
            let address = Address::parse(&prefix)?;
            authorize_address(&policy, &address, AccessKind::Read)?;
            let keys = list(&address)?;
            emit_list(keys, format)?;
        }
        Command::Diff {
            left,
            right,
            format,
        } => {
            let left = Address::parse(&left)?;
            let right = Address::parse(&right)?;
            authorize_address(&policy, &left, AccessKind::Read)?;
            authorize_address(&policy, &right, AccessKind::Read)?;
            let report = diff(&left, &right)?;
            emit_diff(report, format)?;
        }
        Command::Copy {
            source,
            destination,
            dry_run,
        } => {
            let source_address = Address::parse(&source)?;
            let destination_address = Address::parse(&destination)?;
            authorize_address(&policy, &source_address, AccessKind::Read)?;
            authorize_address(&policy, &destination_address, AccessKind::Write)?;
            let value = read_one(&source_address)?;
            if !dry_run {
                write_one(&destination_address, &value)?;
            }
            emit_action(ActionReport {
                action: "copy",
                source: Some(source_address.safe_label()),
                destination: destination_address.safe_label(),
                status: if dry_run { "dry_run" } else { "updated" },
            })?;
        }
        Command::Set {
            destination,
            value_file,
            dry_run,
        } => {
            let destination_address = Address::parse(&destination)?;
            authorize_address(&policy, &destination_address, AccessKind::Write)?;
            authorize_value_file(&policy, &value_file)?;
            let value = fs::read_to_string(&value_file)
                .with_context(|| format!("failed to read value file {}", value_file.display()))?;
            let value = value.trim_end_matches(['\r', '\n']).to_string();
            if !dry_run {
                write_one(&destination_address, &value)?;
            }
            emit_action(ActionReport {
                action: "set",
                source: None,
                destination: destination_address.safe_label(),
                status: if dry_run { "dry_run" } else { "updated" },
            })?;
        }
    }

    Ok(())
}

#[derive(Debug, Deserialize)]
struct PolicyFile {
    allow: PolicyAllow,
}

#[derive(Debug, Deserialize)]
struct PolicyAllow {
    #[serde(default)]
    read: Vec<PathBuf>,
    #[serde(default)]
    write: Vec<PathBuf>,
    #[serde(default)]
    value_file: Vec<PathBuf>,
}

#[derive(Debug)]
struct Policy {
    read: Vec<AllowedPath>,
    write: Vec<AllowedPath>,
    value_file: Vec<AllowedPath>,
}

#[derive(Debug)]
struct AllowedPath {
    canonical: PathBuf,
    is_dir: bool,
}

#[derive(Clone, Copy, Debug)]
enum AccessKind {
    Read,
    Write,
    ValueFile,
}

impl Policy {
    fn load(path: &Path) -> Result<Self> {
        if !path.is_absolute() {
            bail!("policy path must be absolute");
        }
        let metadata = fs::metadata(path)
            .with_context(|| format!("failed to stat policy file {}", path.display()))?;
        if !metadata.is_file() {
            bail!("policy path is not a file");
        }
        #[cfg(unix)]
        {
            let mode = metadata.permissions().mode();
            if mode & 0o022 != 0 {
                bail!("policy file must not be group/world writable");
            }
        }

        let content = fs::read_to_string(path)
            .with_context(|| format!("failed to read policy file {}", path.display()))?;
        let parsed: PolicyFile = serde_yaml::from_str(&content)
            .with_context(|| format!("failed to parse policy file {}", path.display()))?;

        Ok(Self {
            read: canonicalize_allowlist(parsed.allow.read, "read")?,
            write: canonicalize_allowlist(parsed.allow.write, "write")?,
            value_file: canonicalize_allowlist(parsed.allow.value_file, "value_file")?,
        })
    }

    fn authorize(&self, kind: AccessKind, path: &Path) -> Result<()> {
        let canonical = canonicalize_existing(path)?;
        let allowlist = match kind {
            AccessKind::Read => &self.read,
            AccessKind::Write => &self.write,
            AccessKind::ValueFile => &self.value_file,
        };
        if allowlist.iter().any(|allowed| allowed.matches(&canonical)) {
            return Ok(());
        }
        bail!("policy denied {:?} access to {}", kind, canonical.display())
    }
}

impl AllowedPath {
    fn matches(&self, path: &Path) -> bool {
        if self.is_dir {
            path == self.canonical || path.starts_with(&self.canonical)
        } else {
            path == self.canonical
        }
    }
}

fn canonicalize_allowlist(paths: Vec<PathBuf>, name: &str) -> Result<Vec<AllowedPath>> {
    paths
        .into_iter()
        .map(|path| {
            if !path.is_absolute() {
                bail!("policy {name} path must be absolute: {}", path.display());
            }
            let metadata = fs::metadata(&path)
                .with_context(|| format!("failed to stat policy {name} path {}", path.display()))?;
            let canonical = fs::canonicalize(&path).with_context(|| {
                format!(
                    "failed to canonicalize policy {name} path {}",
                    path.display()
                )
            })?;
            Ok(AllowedPath {
                canonical,
                is_dir: metadata.is_dir(),
            })
        })
        .collect()
}

fn canonicalize_existing(path: &Path) -> Result<PathBuf> {
    fs::canonicalize(path).with_context(|| format!("failed to canonicalize {}", path.display()))
}

fn authorize_address(policy: &Option<Policy>, address: &Address, kind: AccessKind) -> Result<()> {
    let Some(policy) = policy else {
        return Ok(());
    };
    policy.authorize(kind, address.file())
}

fn authorize_value_file(policy: &Option<Policy>, path: &Path) -> Result<()> {
    let Some(policy) = policy else {
        return Ok(());
    };
    policy.authorize(AccessKind::ValueFile, path)
}

impl Address {
    fn parse(input: &str) -> Result<Self> {
        let parts: Vec<&str> = input.split(':').collect();
        match parts.as_slice() {
            ["envrc", file] => Ok(Address::Envrc {
                file: PathBuf::from(file),
                key: None,
            }),
            ["envrc", file, key] => Ok(Address::Envrc {
                file: PathBuf::from(file),
                key: Some((*key).to_string()),
            }),
            ["dcfile", file, bucket] => Ok(Address::DcFile {
                file: PathBuf::from(file),
                bucket: (*bucket).to_string(),
                key: None,
            }),
            ["dcfile", file, bucket, key] => Ok(Address::DcFile {
                file: PathBuf::from(file),
                bucket: (*bucket).to_string(),
                key: Some((*key).to_string()),
            }),
            _ => bail!("invalid address; expected envrc:<file>[:KEY] or dcfile:<file>:<bucket>[:yaml.path]"),
        }
    }

    fn require_key(&self) -> Result<&str> {
        match self {
            Address::Envrc { key: Some(key), .. } => Ok(key),
            Address::DcFile { key: Some(key), .. } => Ok(key),
            _ => bail!("operation requires a full address with a key"),
        }
    }

    fn safe_label(&self) -> String {
        match self {
            Address::Envrc { file, key } => match key {
                Some(key) => format!("envrc:{}:{}", file.display(), key),
                None => format!("envrc:{}", file.display()),
            },
            Address::DcFile { file, bucket, key } => match key {
                Some(key) => format!("dcfile:{}:{}:{}", file.display(), bucket, key),
                None => format!("dcfile:{}:{}", file.display(), bucket),
            },
        }
    }

    fn file(&self) -> &Path {
        match self {
            Address::Envrc { file, .. } => file,
            Address::DcFile { file, .. } => file,
        }
    }
}

fn list(address: &Address) -> Result<Vec<String>> {
    let mut keys: Vec<String> = match address {
        Address::Envrc { file, .. } => parse_envrc(file)?.keys().cloned().collect(),
        Address::DcFile { file, bucket, .. } => {
            let (_, yaml) = read_dc_bucket(file, bucket)?;
            let mut out = BTreeMap::new();
            flatten_yaml("", &yaml, &mut out);
            out.keys().cloned().collect()
        }
    };
    keys.sort();
    Ok(keys)
}

fn read_one(address: &Address) -> Result<String> {
    let key = address.require_key()?;
    match address {
        Address::Envrc { file, .. } => {
            let values = parse_envrc(file)?;
            values
                .get(key)
                .cloned()
                .with_context(|| format!("missing key {}", key))
        }
        Address::DcFile { file, bucket, .. } => {
            let (_, yaml) = read_dc_bucket(file, bucket)?;
            get_yaml_path(&yaml, key)
                .and_then(value_to_string)
                .with_context(|| format!("missing key {}", key))
        }
    }
}

fn write_one(address: &Address, value: &str) -> Result<()> {
    let key = address.require_key()?.to_string();
    match address {
        Address::Envrc { file, .. } => update_envrc(file, &key, value),
        Address::DcFile { file, bucket, .. } => update_dcfile(file, bucket, &key, value),
    }
}

fn diff(left: &Address, right: &Address) -> Result<DiffReport> {
    let left_values = read_all(left)?;
    let right_values = read_all(right)?;
    let left_keys: BTreeSet<String> = left_values.keys().cloned().collect();
    let right_keys: BTreeSet<String> = right_values.keys().cloned().collect();

    let mut same = Vec::new();
    let mut changed = Vec::new();
    let mut missing_left = Vec::new();
    let mut missing_right = Vec::new();

    for key in left_keys.union(&right_keys) {
        match (left_values.get(key), right_values.get(key)) {
            (Some(l), Some(r)) if l == r => same.push(key.clone()),
            (Some(_), Some(_)) => changed.push(key.clone()),
            (None, Some(_)) => missing_left.push(key.clone()),
            (Some(_), None) => missing_right.push(key.clone()),
            (None, None) => {}
        }
    }

    Ok(DiffReport {
        same,
        changed,
        missing_left,
        missing_right,
    })
}

fn read_all(address: &Address) -> Result<BTreeMap<String, String>> {
    match address {
        Address::Envrc { file, .. } => parse_envrc(file),
        Address::DcFile { file, bucket, .. } => {
            let (_, yaml) = read_dc_bucket(file, bucket)?;
            let mut flattened = BTreeMap::new();
            flatten_yaml("", &yaml, &mut flattened);
            Ok(flattened
                .into_iter()
                .filter_map(|(key, value)| value_to_string(&value).map(|v| (key, v)))
                .collect())
        }
    }
}

fn parse_envrc(path: &Path) -> Result<BTreeMap<String, String>> {
    let content = fs::read_to_string(path)
        .with_context(|| format!("failed to read envrc file {}", path.display()))?;
    let mut out = BTreeMap::new();

    for line in content.lines() {
        let trimmed = line.trim_start();
        let Some(rest) = trimmed.strip_prefix("export ") else {
            continue;
        };
        let Some((key, raw_value)) = rest.split_once('=') else {
            continue;
        };
        if !is_shell_name(key) {
            continue;
        }
        if let Some(value) = parse_shell_value(raw_value.trim()) {
            out.insert(key.to_string(), value);
        }
    }

    Ok(out)
}

fn update_envrc(path: &Path, key: &str, value: &str) -> Result<()> {
    let content = fs::read_to_string(path)
        .with_context(|| format!("failed to read envrc file {}", path.display()))?;
    let mut found = false;
    let mut lines = Vec::new();

    for line in content.lines() {
        let trimmed = line.trim_start();
        if let Some(rest) = trimmed.strip_prefix("export ") {
            if let Some((existing_key, _)) = rest.split_once('=') {
                if existing_key == key {
                    let indent_len = line.len() - trimmed.len();
                    let indent = &line[..indent_len];
                    lines.push(format!("{indent}export {key}=\"{}\"", shell_escape(value)));
                    found = true;
                    continue;
                }
            }
        }
        lines.push(line.to_string());
    }

    if !found {
        lines.push(format!("export {key}=\"{}\"", shell_escape(value)));
    }

    fs::write(path, format!("{}\n", lines.join("\n")))
        .with_context(|| format!("failed to write envrc file {}", path.display()))
}

fn parse_shell_value(raw: &str) -> Option<String> {
    let value = raw.split_once(" #").map(|(v, _)| v).unwrap_or(raw).trim();
    if value.starts_with('"') {
        parse_double_quoted(value)
    } else if value.starts_with('\'') {
        parse_single_quoted(value)
    } else {
        Some(value.split_whitespace().next().unwrap_or("").to_string())
    }
}

fn parse_double_quoted(raw: &str) -> Option<String> {
    let mut chars = raw.chars();
    if chars.next()? != '"' {
        return None;
    }
    let mut out = String::new();
    let mut escaped = false;
    for ch in chars {
        if escaped {
            out.push(ch);
            escaped = false;
        } else if ch == '\\' {
            escaped = true;
        } else if ch == '"' {
            return Some(out);
        } else {
            out.push(ch);
        }
    }
    None
}

fn parse_single_quoted(raw: &str) -> Option<String> {
    let rest = raw.strip_prefix('\'')?;
    let end = rest.find('\'')?;
    Some(rest[..end].to_string())
}

fn shell_escape(value: &str) -> String {
    value
        .replace('\\', "\\\\")
        .replace('"', "\\\"")
        .replace('$', "\\$")
        .replace('`', "\\`")
}

fn is_shell_name(key: &str) -> bool {
    let mut chars = key.chars();
    match chars.next() {
        Some(ch) if ch == '_' || ch.is_ascii_uppercase() => {}
        _ => return false,
    }
    chars.all(|ch| ch == '_' || ch.is_ascii_uppercase() || ch.is_ascii_digit())
}

fn read_dc_bucket(path: &Path, bucket: &str) -> Result<(DcBlock, Value)> {
    let content = fs::read_to_string(path)
        .with_context(|| format!("failed to read dcfile {}", path.display()))?;
    let block = find_dc_block(&content, bucket)
        .with_context(|| format!("missing dc_yaml bucket {}", bucket))?;
    let value = serde_yaml::from_str(&block.yaml)
        .with_context(|| format!("invalid YAML in dc_yaml bucket {}", bucket))?;
    Ok((block, value))
}

#[derive(Debug, Clone)]
struct DcBlock {
    start_line: usize,
    end_line: usize,
    yaml: String,
}

fn find_dc_block(content: &str, bucket: &str) -> Result<DcBlock> {
    let lines: Vec<&str> = content.lines().collect();
    let mut idx = 0;
    while idx < lines.len() {
        let line = lines[idx].trim();
        if line.starts_with("dc_yaml ") && dc_line_bucket(line).as_deref() == Some(bucket) {
            let marker = heredoc_marker(line).unwrap_or_else(|| "YAML".to_string());
            let yaml_start = idx + 1;
            let mut end = yaml_start;
            while end < lines.len() && lines[end].trim() != marker {
                end += 1;
            }
            if end >= lines.len() {
                bail!("unterminated dc_yaml block for bucket {}", bucket);
            }
            return Ok(DcBlock {
                start_line: idx,
                end_line: end,
                yaml: lines[yaml_start..end].join("\n"),
            });
        }
        idx += 1;
    }
    bail!("missing dc_yaml bucket {}", bucket)
}

fn dc_line_bucket(line: &str) -> Option<String> {
    let mut tokens = line.split_whitespace();
    if tokens.next()? != "dc_yaml" {
        return None;
    }
    for token in tokens {
        if token.starts_with("<<") {
            break;
        }
        if token.starts_with('-') {
            continue;
        }
        return Some(token.to_string());
    }
    None
}

fn heredoc_marker(line: &str) -> Option<String> {
    let (_, marker) = line.split_once("<<")?;
    Some(
        marker
            .trim()
            .trim_matches('\'')
            .trim_matches('"')
            .to_string(),
    )
}

fn update_dcfile(path: &Path, bucket: &str, key: &str, value: &str) -> Result<()> {
    let content = fs::read_to_string(path)
        .with_context(|| format!("failed to read dcfile {}", path.display()))?;
    let block = find_dc_block(&content, bucket)?;
    let mut yaml: Value = serde_yaml::from_str(&block.yaml)
        .with_context(|| format!("invalid YAML in dc_yaml bucket {}", bucket))?;
    set_yaml_path(&mut yaml, key, Value::String(value.to_string()))?;
    let new_yaml = serde_yaml::to_string(&yaml)?;

    let mut lines: Vec<String> = content.lines().map(ToString::to_string).collect();
    lines.splice(
        (block.start_line + 1)..block.end_line,
        new_yaml.trim_end().lines().map(ToString::to_string),
    );
    fs::write(path, format!("{}\n", lines.join("\n")))
        .with_context(|| format!("failed to write dcfile {}", path.display()))
}

fn flatten_yaml(prefix: &str, value: &Value, out: &mut BTreeMap<String, Value>) {
    match value {
        Value::Mapping(map) => {
            for (key, val) in map {
                let Some(key) = key.as_str() else {
                    continue;
                };
                let path = if prefix.is_empty() {
                    key.to_string()
                } else {
                    format!("{prefix}.{key}")
                };
                flatten_yaml(&path, val, out);
            }
        }
        _ => {
            out.insert(prefix.to_string(), value.clone());
        }
    }
}

fn get_yaml_path<'a>(value: &'a Value, path: &str) -> Option<&'a Value> {
    let mut cursor = value;
    for part in path.split('.') {
        let map = cursor.as_mapping()?;
        cursor = map.get(Value::String(part.to_string()))?;
    }
    Some(cursor)
}

fn set_yaml_path(value: &mut Value, path: &str, new_value: Value) -> Result<()> {
    let mut cursor = value;
    let parts: Vec<&str> = path.split('.').collect();
    for (idx, part) in parts.iter().enumerate() {
        if idx == parts.len() - 1 {
            ensure_mapping(cursor)?.insert(Value::String((*part).to_string()), new_value);
            return Ok(());
        }
        let map = ensure_mapping(cursor)?;
        cursor = map
            .entry(Value::String((*part).to_string()))
            .or_insert_with(|| Value::Mapping(Mapping::new()));
    }
    Ok(())
}

fn ensure_mapping(value: &mut Value) -> Result<&mut Mapping> {
    if !matches!(value, Value::Mapping(_)) {
        *value = Value::Mapping(Mapping::new());
    }
    match value {
        Value::Mapping(map) => Ok(map),
        _ => unreachable!(),
    }
}

fn value_to_string(value: &Value) -> Option<String> {
    match value {
        Value::String(v) => Some(v.clone()),
        Value::Bool(v) => Some(v.to_string()),
        Value::Number(v) => Some(v.to_string()),
        Value::Null => Some(String::new()),
        _ => None,
    }
}

fn emit_list(keys: Vec<String>, format: OutputFormat) -> Result<()> {
    match format {
        OutputFormat::Text => {
            for key in keys {
                println!("{key}");
            }
        }
        OutputFormat::Json => println!("{}", serde_json::to_string_pretty(&KeyList { keys })?),
    }
    Ok(())
}

fn emit_diff(report: DiffReport, format: OutputFormat) -> Result<()> {
    match format {
        OutputFormat::Text => {
            print_group("same", &report.same);
            print_group("changed", &report.changed);
            print_group("missing_left", &report.missing_left);
            print_group("missing_right", &report.missing_right);
        }
        OutputFormat::Json => println!("{}", serde_json::to_string_pretty(&report)?),
    }
    Ok(())
}

fn print_group(name: &str, values: &[String]) {
    println!("{name}:");
    for value in values {
        println!("  {value}");
    }
}

fn emit_action(report: ActionReport) -> Result<()> {
    println!("{}", serde_json::to_string_pretty(&report)?);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    const SENTINEL_A: &str = "TOP_SECRET_SENTINEL_ALPHA";
    const SENTINEL_B: &str = "TOP_SECRET_SENTINEL_BRAVO";

    #[test]
    fn diff_reports_names_without_values() -> Result<()> {
        let dir = tempdir()?;
        let left = dir.path().join(".envrc");
        let right = dir.path().join(".envrc.k8.dc");
        fs::write(
            &left,
            format!("export SHARED=\"{SENTINEL_A}\"\nexport LEFT_ONLY=\"{SENTINEL_B}\"\n"),
        )?;
        fs::write(
            &right,
            format!(
                "dc_yaml --no-bump k8 --layer secrets <<'YAML'\nshared: {SENTINEL_B}\nright_only: visible_name_only\nYAML\n"
            ),
        )?;

        let report = diff(
            &Address::parse(&format!("envrc:{}", left.display()))?,
            &Address::parse(&format!("dcfile:{}:k8", right.display()))?,
        )?;
        let output = serde_json::to_string(&report)?;

        assert!(output.contains("SHARED"));
        assert!(output.contains("shared"));
        assert!(!output.contains(SENTINEL_A));
        assert!(!output.contains(SENTINEL_B));
        Ok(())
    }

    #[test]
    fn copy_updates_destination_without_returning_value() -> Result<()> {
        let dir = tempdir()?;
        let source = dir.path().join(".envrc");
        let destination = dir.path().join(".envrc.k8.dc");
        fs::write(&source, format!("export TOKEN=\"{SENTINEL_A}\"\n"))?;
        fs::write(
            &destination,
            "dc_yaml --no-bump k8 --layer secrets <<'YAML'\ntoken: old\nYAML\n",
        )?;

        let source_address = Address::parse(&format!("envrc:{}:TOKEN", source.display()))?;
        let destination_address =
            Address::parse(&format!("dcfile:{}:k8:token", destination.display()))?;
        let value = read_one(&source_address)?;
        write_one(&destination_address, &value)?;

        let updated = fs::read_to_string(&destination)?;
        assert!(updated.contains(SENTINEL_A));

        let report = serde_json::to_string(&ActionReport {
            action: "copy",
            source: Some(source_address.safe_label()),
            destination: destination_address.safe_label(),
            status: "updated",
        })?;
        assert!(!report.contains(SENTINEL_A));
        Ok(())
    }

    #[test]
    fn policy_denies_unlisted_paths() -> Result<()> {
        let dir = tempdir()?;
        let allowed = dir.path().join("allowed.envrc");
        let denied = dir.path().join("denied.envrc");
        let policy_path = dir.path().join("policy.yaml");
        fs::write(&allowed, "export TOKEN=\"allowed\"\n")?;
        fs::write(&denied, "export TOKEN=\"denied\"\n")?;
        fs::write(
            &policy_path,
            format!(
                "allow:\n  read:\n    - {}\n  write: []\n  value_file: []\n",
                allowed.display()
            ),
        )?;

        let policy = Policy::load(&policy_path)?;
        let allowed_address = Address::parse(&format!("envrc:{}", allowed.display()))?;
        let denied_address = Address::parse(&format!("envrc:{}", denied.display()))?;

        assert!(authorize_address(&Some(policy), &allowed_address, AccessKind::Read).is_ok());

        let policy = Policy::load(&policy_path)?;
        assert!(authorize_address(&Some(policy), &denied_address, AccessKind::Read).is_err());
        Ok(())
    }

    #[test]
    fn policy_allows_value_file_directory() -> Result<()> {
        let dir = tempdir()?;
        let inbox = dir.path().join("inbox");
        fs::create_dir(&inbox)?;
        let value_file = inbox.join("value.txt");
        let denied_file = dir.path().join("value.txt");
        let policy_path = dir.path().join("policy.yaml");
        fs::write(&value_file, SENTINEL_A)?;
        fs::write(&denied_file, SENTINEL_B)?;
        fs::write(
            &policy_path,
            format!(
                "allow:\n  read: []\n  write: []\n  value_file:\n    - {}\n",
                inbox.display()
            ),
        )?;

        let policy = Policy::load(&policy_path)?;
        assert!(authorize_value_file(&Some(policy), &value_file).is_ok());

        let policy = Policy::load(&policy_path)?;
        assert!(authorize_value_file(&Some(policy), &denied_file).is_err());
        Ok(())
    }
}
