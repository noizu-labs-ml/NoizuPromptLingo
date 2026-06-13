//! Shared credential resolution — mirrors the priority chain in secret-engine.sh

use anyhow::Result;

use crate::api::{InfisicalClient, InfisicalCreds};
use crate::dc;
use crate::error::InfisicalError;

fn require(name: &str, value: Option<String>) -> Result<String> {
    value.ok_or_else(|| InfisicalError::MissingCredential(name.to_owned()).into())
}

fn env_or_dc(env_var: &str, dc_scope: &str, dc_path: &str) -> Option<String> {
    std::env::var(env_var)
        .ok()
        .filter(|v| !v.is_empty())
        .or_else(|| dc::dc_get_optional(dc_scope, dc_path))
}

pub async fn build_client(env: &str) -> Result<InfisicalClient> {
    let host = require(
        "INFISICAL_HOST",
        env_or_dc("INFISICAL_HOST", "secrets", "infisical.host")
            .or_else(|| env_or_dc("K8_INFISICAL_HOST", "secrets", "infisical.host")),
    )?;

    let project_slug = env_or_dc("INFISICAL_PROJECT_SLUG", "secrets", "infisical.project_slug")
        .or_else(|| std::env::var("K8_INFISICAL_PROJECT_SLUG").ok());

    let project_id = std::env::var("INFISICAL_PROJECT_ID")
        .ok()
        .filter(|v| !v.is_empty())
        .or_else(|| std::env::var("K8_INFISICAL_PROJECT_ID").ok().filter(|v| !v.is_empty()));

    if project_id.is_none() && project_slug.is_none() {
        return Err(InfisicalError::MissingCredential(
            "INFISICAL_PROJECT_ID or INFISICAL_PROJECT_SLUG".into(),
        )
        .into());
    }

    let client_id = require(
        "INFISICAL_CLIENT_ID",
        env_or_dc("EKS_OPERATOR_CLIENT_ID", "secrets", "operator.client_id")
            .or_else(|| env_or_dc("K8_INFISICAL_CLIENT_ID", "secrets", "operator.client_id")),
    )?;

    let client_secret = require(
        "INFISICAL_CLIENT_SECRET",
        env_or_dc("EKS_OPERATOR_CLIENT_SECRET", "secrets", "operator.client_secret")
            .or_else(|| {
                env_or_dc("K8_INFISICAL_CLIENT_SECRET", "secrets", "operator.client_secret")
            }),
    )?;

    let cf_client_id = env_or_dc("CF_ACCESS_CLIENT_ID", "cf", "access.client_id");
    let cf_client_secret = env_or_dc("CF_ACCESS_CLIENT_SECRET", "cf", "access.client_secret");

    let environment = if env == "stage" {
        "staging".to_owned()
    } else {
        env.to_owned()
    };

    InfisicalClient::connect(InfisicalCreds {
        host,
        project_id,
        project_slug,
        client_id,
        client_secret,
        environment,
        cf_client_id,
        cf_client_secret,
    })
    .await
}
