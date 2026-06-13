use anyhow::Result;
use std::collections::HashMap;

use crate::config::v1::SecretSpec;
use crate::dc;
use crate::engine::generate;

/// Resolve a single SecretSpec to a concrete value.
/// The `resolved_vars` map contains section-level vars already resolved.
pub fn resolve_spec(
    spec: &SecretSpec,
    resolved_vars: &HashMap<String, String>,
) -> Result<Option<String>> {
    // 1. override env var (highest priority)
    if let Some(override_var) = &spec.override_ {
        if let Ok(val) = std::env::var(override_var) {
            if !val.is_empty() {
                return Ok(Some(apply_decode(&val, spec)?));
            }
        }
    }

    // 2. dc get
    if let Some(dc_ref) = &spec.dc {
        if let Some(val) = dc::dc_get_optional(&dc_ref.scope, &dc_ref.path) {
            if !val.is_empty() {
                return Ok(Some(apply_decode(&val, spec)?));
            }
        }
    }

    // 3. env var
    if let Some(env_var) = &spec.env {
        if let Ok(val) = std::env::var(env_var) {
            if !val.is_empty() {
                return Ok(Some(apply_decode(&val, spec)?));
            }
        }
    }

    // 4. ref to another resolved var
    if let Some(ref_name) = &spec.ref_ {
        if let Some(val) = resolved_vars.get(ref_name.as_str()) {
            return Ok(Some(apply_decode(val, spec)?));
        }
    }

    // 5. template: "{{VAR_ONE}}-{{VAR_TWO}}"
    if let Some(template) = &spec.template {
        let val = render_template(template, resolved_vars);
        if !val.is_empty() {
            return Ok(Some(apply_decode(&val, spec)?));
        }
    }

    // 6. file
    if let Some(file_path) = &spec.file {
        if let Ok(contents) = std::fs::read_to_string(file_path) {
            let val = contents.trim().to_owned();
            return Ok(Some(apply_decode(&val, spec)?));
        }
    }

    // 7. fallback dc
    if let Some(fallback) = &spec.fallback_dc {
        if let Some(val) = dc::dc_get_optional(&fallback.scope, &fallback.path) {
            if !val.is_empty() {
                return Ok(Some(apply_decode(&val, spec)?));
            }
        }
    }

    // 8. auto generate
    if let Some(auto) = &spec.auto {
        let val = generate::generate_value(&auto.kind, auto.length)?;
        return Ok(Some(val));
    }

    // 9. default
    if let Some(default) = &spec.default {
        return Ok(Some(apply_decode(default, spec)?));
    }

    // Optional — return None without error
    if spec.optional {
        return Ok(None);
    }

    Ok(None)
}

fn apply_decode(value: &str, spec: &SecretSpec) -> Result<String> {
    match spec.decode.as_deref() {
        Some("base64") => {
            let bytes = base64::engine::general_purpose::STANDARD
                .decode(value.trim())
                .map_err(|e| anyhow::anyhow!("base64 decode: {e}"))?;
            Ok(String::from_utf8(bytes)?)
        }
        _ => Ok(value.to_owned()),
    }
}

fn render_template(template: &str, vars: &HashMap<String, String>) -> String {
    let mut result = template.to_owned();
    for (k, v) in vars {
        // Handle {{VAR_NAME}} and {{VAR_NAME|urlencode}}
        result = result.replace(&format!("{{{{{}}}}}", k), v);
        let encoded = urlencoding::encode(v);
        result = result.replace(&format!("{{{{{}|urlencode}}}}", k), &encoded);
    }
    result
}

// Bring in base64 engine
use base64::Engine as _;
