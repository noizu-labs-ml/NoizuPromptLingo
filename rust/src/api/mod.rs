pub mod types;

use anyhow::{Context, Result, bail};
use reqwest::{Client, header};
use serde_json::Value;

use crate::error::InfisicalError;
use types::*;

/// Resolved connection config for talking to Infisical
#[derive(Debug, Clone)]
pub struct InfisicalConfig {
    pub host: String,
    pub project_id: String,
    pub environment: String,
    pub token: String,
    /// Optional Cloudflare Access headers
    pub cf_client_id: Option<String>,
    pub cf_client_secret: Option<String>,
}

pub struct InfisicalClient {
    http: Client,
    pub cfg: InfisicalConfig,
}

/// Partial credentials needed before auth; used to build InfisicalConfig
pub struct InfisicalCreds {
    pub host: String,
    pub project_id: Option<String>,
    pub project_slug: Option<String>,
    pub client_id: String,
    pub client_secret: String,
    pub environment: String,
    pub cf_client_id: Option<String>,
    pub cf_client_secret: Option<String>,
}

impl InfisicalClient {
    pub async fn connect(creds: InfisicalCreds) -> Result<Self> {
        let http = Client::builder()
            .user_agent("infisical-cli/0.1")
            .build()
            .context("build HTTP client")?;

        // Authenticate
        let login_url = format!("{}/api/v1/auth/universal-auth/login", creds.host);
        let login_body = LoginRequest {
            client_id: creds.client_id.clone(),
            client_secret: creds.client_secret.clone(),
        };

        let resp = http
            .post(&login_url)
            .json(&login_body)
            .send()
            .await
            .context("POST login")?;

        if !resp.status().is_success() {
            let status = resp.status().as_u16();
            let text = resp.text().await.unwrap_or_default();
            return Err(InfisicalError::Auth(format!("{status}: {text}")).into());
        }

        let login: LoginResponse = resp.json().await.context("parse login response")?;
        let token = login.access_token;

        // Resolve project ID from slug if needed
        let project_id = match creds.project_id {
            Some(id) => id,
            None => {
                let slug = creds.project_slug.ok_or_else(|| {
                    InfisicalError::MissingCredential("project_id or project_slug".into())
                })?;
                resolve_project_id(&http, &creds.host, &slug, &token).await?
            }
        };

        let cfg = InfisicalConfig {
            host: creds.host,
            project_id,
            environment: creds.environment,
            token,
            cf_client_id: creds.cf_client_id,
            cf_client_secret: creds.cf_client_secret,
        };

        Ok(Self { http, cfg })
    }

    fn auth_headers(&self) -> header::HeaderMap {
        let mut headers = header::HeaderMap::new();
        headers.insert(
            header::AUTHORIZATION,
            format!("Bearer {}", self.cfg.token).parse().unwrap(),
        );
        if let (Some(id), Some(secret)) = (&self.cfg.cf_client_id, &self.cfg.cf_client_secret) {
            headers.insert("CF-Access-Client-Id", id.parse().unwrap());
            headers.insert("CF-Access-Client-Secret", secret.parse().unwrap());
        }
        headers
    }

    pub async fn list_secrets(&self, path: &str) -> Result<Vec<SecretItem>> {
        let url = format!("{}/api/v3/secrets/raw", self.cfg.host);
        let resp = self
            .http
            .get(&url)
            .headers(self.auth_headers())
            .query(&[
                ("workspaceId", self.cfg.project_id.as_str()),
                ("environment", self.cfg.environment.as_str()),
                ("secretPath", path),
                ("expandSecretReferences", "true"),
                ("recursive", "false"),
            ])
            .send()
            .await
            .context("list secrets")?;

        let status = resp.status().as_u16();
        if !resp.status().is_success() {
            let text = resp.text().await.unwrap_or_default();
            bail!(InfisicalError::Api { status, message: text });
        }

        let body: ListSecretsResponse = resp.json().await.context("parse list secrets")?;
        Ok(body.secrets)
    }

    pub async fn get_secret(&self, path: &str, key: &str) -> Result<Option<SecretItem>> {
        let url = format!("{}/api/v3/secrets/raw/{}", self.cfg.host, key);
        let resp = self
            .http
            .get(&url)
            .headers(self.auth_headers())
            .query(&[
                ("workspaceId", self.cfg.project_id.as_str()),
                ("environment", self.cfg.environment.as_str()),
                ("secretPath", path),
            ])
            .send()
            .await
            .context("get secret")?;

        if resp.status().as_u16() == 404 {
            return Ok(None);
        }

        let status = resp.status().as_u16();
        if !resp.status().is_success() {
            let text = resp.text().await.unwrap_or_default();
            bail!(InfisicalError::Api { status, message: text });
        }

        let body: GetSecretResponse = resp.json().await.context("parse get secret")?;
        Ok(Some(body.secret))
    }

    /// Create or update a secret. Returns whether it was created (true) or updated (false).
    /// Returns None if value was unchanged (skip).
    pub async fn set_secret(
        &self,
        path: &str,
        key: &str,
        value: &str,
        dry_run: bool,
    ) -> Result<SetSecretOutcome> {
        let existing = self.get_secret(path, key).await?;

        if let Some(ref s) = existing {
            if s.value == value {
                return Ok(SetSecretOutcome::Unchanged);
            }
        }

        if dry_run {
            return Ok(if existing.is_some() {
                SetSecretOutcome::WouldUpdate
            } else {
                SetSecretOutcome::WouldCreate
            });
        }

        if existing.is_some() {
            let url = format!("{}/api/v3/secrets/raw/{}", self.cfg.host, key);
            let body = UpdateSecretRequest {
                workspace_id: self.cfg.project_id.clone(),
                environment: self.cfg.environment.clone(),
                secret_path: path.to_owned(),
                secret_value: value.to_owned(),
            };
            let resp = self
                .http
                .patch(&url)
                .headers(self.auth_headers())
                .json(&body)
                .send()
                .await
                .context("update secret")?;
            check_ok(resp).await?;
            Ok(SetSecretOutcome::Updated)
        } else {
            let url = format!("{}/api/v3/secrets/raw/{}", self.cfg.host, key);
            let body = CreateSecretRequest {
                workspace_id: self.cfg.project_id.clone(),
                environment: self.cfg.environment.clone(),
                secret_path: path.to_owned(),
                secret_value: value.to_owned(),
                secret_comment: None,
            };
            let resp = self
                .http
                .post(&url)
                .headers(self.auth_headers())
                .json(&body)
                .send()
                .await
                .context("create secret")?;
            check_ok(resp).await?;
            Ok(SetSecretOutcome::Created)
        }
    }

    /// Ensure an Infisical folder path exists (creates each segment as needed)
    pub async fn ensure_folder(&self, path: &str) -> Result<()> {
        // Split path into segments, create each one
        let segments: Vec<&str> = path.trim_matches('/').split('/').collect();
        let mut current = String::new();

        for seg in segments {
            let parent = if current.is_empty() { "/" } else { &current };
            let full_path = format!("{}/{}", current, seg);

            let url = format!("{}/api/v2/folders", self.cfg.host);
            let body = CreateFolderRequest {
                workspace_id: self.cfg.project_id.clone(),
                environment: self.cfg.environment.clone(),
                path: parent.to_owned(),
                name: seg.to_owned(),
            };
            let resp = self
                .http
                .post(&url)
                .headers(self.auth_headers())
                .json(&body)
                .send()
                .await
                .context("create folder")?;

            // 409 Conflict means it already exists — that's fine
            if resp.status().as_u16() != 409 {
                check_ok(resp).await?;
            }

            current = full_path;
        }
        Ok(())
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum SetSecretOutcome {
    Created,
    Updated,
    Unchanged,
    WouldCreate,
    WouldUpdate,
}

async fn resolve_project_id(http: &Client, host: &str, slug: &str, token: &str) -> Result<String> {
    let url = format!("{}/api/v1/projects/slug/{}", host, slug);
    let resp = http
        .get(&url)
        .header(header::AUTHORIZATION, format!("Bearer {}", token))
        .send()
        .await
        .context("resolve project slug")?;

    let status = resp.status().as_u16();
    if !resp.status().is_success() {
        let text = resp.text().await.unwrap_or_default();
        bail!(InfisicalError::Api { status, message: text });
    }

    let body: Value = resp.json().await?;
    let id = body["project"]["id"]
        .as_str()
        .ok_or_else(|| anyhow::anyhow!("project.id not found in response"))?
        .to_owned();
    Ok(id)
}

async fn check_ok(resp: reqwest::Response) -> Result<()> {
    let status = resp.status().as_u16();
    if !resp.status().is_success() {
        let text = resp.text().await.unwrap_or_default();
        bail!(InfisicalError::Api { status, message: text });
    }
    Ok(())
}
