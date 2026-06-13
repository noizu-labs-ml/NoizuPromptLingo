pub mod resolve;
pub mod generate;

use anyhow::Result;
use serde::{Deserialize, Serialize};

use crate::api::InfisicalClient;
use crate::config::v1::{Section, SecretSpec};
use crate::dc;

// ── Verify result ─────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum VerifyStatus {
    Ok,
    Mismatch,
    MissingYaml,
    MissingDc,
    MissingInfisical,
    MissingAll,
}

impl VerifyStatus {
    pub fn is_ok(&self) -> bool {
        *self == VerifyStatus::Ok
    }

    pub fn label(&self) -> &'static str {
        match self {
            VerifyStatus::Ok => "ok",
            VerifyStatus::Mismatch => "mismatch",
            VerifyStatus::MissingYaml => "missing_yaml",
            VerifyStatus::MissingDc => "missing_dc",
            VerifyStatus::MissingInfisical => "missing_infisical",
            VerifyStatus::MissingAll => "missing_all",
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VerifyResult {
    pub name: String,
    pub section_id: String,
    pub path: String,
    pub status: VerifyStatus,
    pub dc_scope: Option<String>,
    pub dc_path: Option<String>,
    pub dc_value: Option<String>,
    pub infisical_value: Option<String>,
}

impl VerifyResult {
    pub fn is_ok(&self) -> bool {
        self.status.is_ok()
    }
}

// ── Verify engine ─────────────────────────────────────────────────────────────

/// Verify a single secret: compare dc value vs Infisical value
pub async fn verify_secret(
    client: &InfisicalClient,
    section: &Section,
    name: &str,
    spec: &SecretSpec,
    show_values: bool,
) -> Result<VerifyResult> {
    let mut result = VerifyResult {
        name: name.to_owned(),
        section_id: section.id.clone(),
        path: section.path.clone(),
        status: VerifyStatus::Ok,
        dc_scope: None,
        dc_path: None,
        dc_value: None,
        infisical_value: None,
    };

    // Get dc ref
    let dc_ref = spec.dc.as_ref().or(spec.fallback_dc.as_ref());

    let dc_value = if let Some(dc_ref) = dc_ref {
        result.dc_scope = Some(dc_ref.scope.clone());
        result.dc_path = Some(dc_ref.path.clone());
        dc::dc_get_optional(&dc_ref.scope, &dc_ref.path)
    } else {
        None
    };

    // Get Infisical value
    let infisical_secret = client.get_secret(&section.path, name).await?;
    let infisical_value = infisical_secret.map(|s| s.value);

    // Determine status
    result.status = match (&dc_value, &infisical_value) {
        (None, None) => VerifyStatus::MissingAll,
        (None, Some(_)) => VerifyStatus::MissingDc,
        (Some(_), None) => VerifyStatus::MissingInfisical,
        (Some(dv), Some(iv)) => {
            if dv == iv {
                VerifyStatus::Ok
            } else {
                VerifyStatus::Mismatch
            }
        }
    };

    if show_values {
        result.dc_value = dc_value;
        result.infisical_value = infisical_value;
    }

    Ok(result)
}

/// Verify all secrets in a section
pub async fn verify_section(
    client: &InfisicalClient,
    section: &Section,
    show_values: bool,
    fail_fast: bool,
) -> Result<Vec<VerifyResult>> {
    let mut results = Vec::new();

    for (name, spec) in &section.secrets {
        let r = verify_secret(client, section, name, spec, show_values).await?;
        let ok = r.is_ok();
        results.push(r);
        if fail_fast && !ok {
            break;
        }
    }

    Ok(results)
}

/// Verify all sections
pub async fn verify_all(
    client: &InfisicalClient,
    sections: &[Section],
    show_values: bool,
    fail_fast: bool,
) -> Result<Vec<VerifyResult>> {
    let mut all = Vec::new();
    for section in sections {
        let mut results = verify_section(client, section, show_values, fail_fast).await?;
        let should_stop = fail_fast && results.iter().any(|r| !r.is_ok());
        all.append(&mut results);
        if should_stop {
            break;
        }
    }
    Ok(all)
}

// ── Status summary ────────────────────────────────────────────────────────────

#[derive(Debug, Default, Serialize, Deserialize)]
pub struct VerifySummary {
    pub ok: usize,
    pub mismatch: usize,
    pub missing_yaml: usize,
    pub missing_dc: usize,
    pub missing_infisical: usize,
    pub missing_all: usize,
    pub total: usize,
}

impl VerifySummary {
    pub fn from_results(results: &[VerifyResult]) -> Self {
        let mut s = Self::default();
        for r in results {
            s.total += 1;
            match r.status {
                VerifyStatus::Ok => s.ok += 1,
                VerifyStatus::Mismatch => s.mismatch += 1,
                VerifyStatus::MissingYaml => s.missing_yaml += 1,
                VerifyStatus::MissingDc => s.missing_dc += 1,
                VerifyStatus::MissingInfisical => s.missing_infisical += 1,
                VerifyStatus::MissingAll => s.missing_all += 1,
            }
        }
        s
    }

    pub fn all_ok(&self) -> bool {
        self.mismatch == 0
            && self.missing_yaml == 0
            && self.missing_dc == 0
            && self.missing_infisical == 0
            && self.missing_all == 0
    }
}
