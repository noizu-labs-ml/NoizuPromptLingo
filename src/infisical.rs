//! Native Infisical API client (universal-auth + secrets v3 + folders v2).
//!
//! Mirrors the request/response contract used by the existing
//! `infisical-populate-secrets` / `infisical-fetch-secrets` shell tools, but in
//! Rust so `dc compare`/`dc push` never shell out. Plaintext only ever travels
//! in request bodies — never to stdout or logs.

use anyhow::{anyhow, bail, Context, Result};
use reqwest::blocking::{Client as HttpClient, RequestBuilder};
use reqwest::header::{HeaderMap, HeaderValue, AUTHORIZATION, CONTENT_TYPE};
use serde_json::Value as Json;

pub struct InfisicalConfig {
    pub host: String, // normalized, no trailing `/api` or `/`
    pub project_slug: Option<String>,
    pub project_id: Option<String>,
    pub environment: String,
    pub client_id: String,
    pub client_secret: String,
    pub cf_access: Option<(String, String)>,
}

fn resolve_str(env_vars: &[&str], dc: Option<(&str, &str)>) -> Option<String> {
    for v in env_vars {
        if let Ok(val) = std::env::var(v) {
            if !val.is_empty() {
                return Some(val);
            }
        }
    }
    if let Some((cfg, path)) = dc {
        if let Ok(Some(val)) = crate::cmd::get::get_secret_plaintext(cfg, path) {
            if !val.is_empty() {
                return Some(val);
            }
        }
    }
    None
}

fn normalize_host(raw: &str) -> String {
    let h = raw.trim().trim_end_matches('/');
    h.strip_suffix("/api").unwrap_or(h).trim_end_matches('/').to_string()
}

impl InfisicalConfig {
    /// Resolve connection settings from env vars, falling back to dc config.
    pub fn resolve(env_override: Option<&str>) -> Result<Self> {
        let host = resolve_str(&["INFISICAL_HOST", "K8_INFISICAL_HOST"], Some(("secrets", "infisical.host")))
            .ok_or_else(|| anyhow!("INFISICAL_HOST not set and `dc get secrets infisical.host` empty"))?;
        let project_slug = resolve_str(
            &["INFISICAL_PROJECT_SLUG", "K8_INFISICAL_PROJECT_SLUG"],
            Some(("secrets", "infisical.project_slug")),
        );
        let project_id = resolve_str(&["INFISICAL_PROJECT_ID", "K8_INFISICAL_PROJECT_ID"], None);
        let environment = env_override
            .map(|s| s.to_string())
            .or_else(|| resolve_str(&["INFISICAL_ENV"], Some(("secrets", "infisical.env"))))
            .unwrap_or_else(|| "prod".to_string());
        let client_id = resolve_str(
            &["EKS_OPERATOR_CLIENT_ID", "K8_INFISICAL_CLIENT_ID"],
            Some(("secrets", "operator.client_id")),
        )
        .ok_or_else(|| anyhow!("Infisical client id not set (EKS_OPERATOR_CLIENT_ID / operator.client_id)"))?;
        let client_secret = resolve_str(
            &["EKS_OPERATOR_CLIENT_SECRET", "K8_INFISICAL_CLIENT_SECRET"],
            Some(("secrets", "operator.client_secret")),
        )
        .ok_or_else(|| anyhow!("Infisical client secret not set (EKS_OPERATOR_CLIENT_SECRET / operator.client_secret)"))?;

        let cf_id = resolve_str(&["CF_ACCESS_CLIENT_ID"], Some(("cf", "access.client_id")));
        let cf_secret = resolve_str(&["CF_ACCESS_CLIENT_SECRET"], Some(("cf", "access.client_secret")));
        let cf_access = match (cf_id, cf_secret) {
            (Some(i), Some(s)) => Some((i, s)),
            _ => None,
        };

        if project_slug.is_none() && project_id.is_none() {
            bail!("neither INFISICAL_PROJECT_SLUG nor INFISICAL_PROJECT_ID resolved");
        }

        Ok(InfisicalConfig {
            host: normalize_host(&host),
            project_slug,
            project_id,
            environment,
            client_id,
            client_secret,
            cf_access,
        })
    }
}

pub struct Client {
    http: HttpClient,
    cfg: InfisicalConfig,
    token: String,
    project_id: String,
}

#[derive(Debug, PartialEq, Eq)]
pub enum UpsertOutcome {
    Created,
    Updated,
    Unchanged,
}

impl Client {
    fn cf_headers(&self, map: &mut HeaderMap) {
        if let Some((id, secret)) = &self.cfg.cf_access {
            if let (Ok(i), Ok(s)) = (HeaderValue::from_str(id), HeaderValue::from_str(secret)) {
                map.insert("CF-Access-Client-Id", i);
                map.insert("CF-Access-Client-Secret", s);
            }
        }
    }

    fn req(&self, builder: RequestBuilder) -> RequestBuilder {
        let mut headers = HeaderMap::new();
        headers.insert(
            AUTHORIZATION,
            HeaderValue::from_str(&format!("Bearer {}", self.token)).unwrap(),
        );
        headers.insert(CONTENT_TYPE, HeaderValue::from_static("application/json"));
        self.cf_headers(&mut headers);
        builder.headers(headers)
    }

    /// Authenticate via universal-auth and resolve the project id.
    pub fn login(cfg: InfisicalConfig) -> Result<Client> {
        let http = HttpClient::builder()
            .build()
            .context("building HTTP client")?;

        let mut login_headers = HeaderMap::new();
        login_headers.insert(CONTENT_TYPE, HeaderValue::from_static("application/json"));
        if let Some((id, secret)) = &cfg.cf_access {
            if let (Ok(i), Ok(s)) = (HeaderValue::from_str(id), HeaderValue::from_str(secret)) {
                login_headers.insert("CF-Access-Client-Id", i);
                login_headers.insert("CF-Access-Client-Secret", s);
            }
        }

        let resp = http
            .post(format!("{}/api/v1/auth/universal-auth/login", cfg.host))
            .headers(login_headers.clone())
            .json(&serde_json::json!({
                "clientId": cfg.client_id,
                "clientSecret": cfg.client_secret,
            }))
            .send()
            .map_err(|e| map_net_err(e, &cfg.host))?;
        if !resp.status().is_success() {
            bail!("Infisical auth failed (HTTP {})", resp.status());
        }
        let body: Json = resp.json().context("parsing auth response")?;
        let token = body
            .get("accessToken")
            .and_then(|v| v.as_str())
            .filter(|s| !s.is_empty())
            .ok_or_else(|| anyhow!("Infisical auth returned no accessToken"))?
            .to_string();

        // Resolve project id from slug if needed.
        let project_id = if let Some(id) = cfg.project_id.clone() {
            id
        } else {
            let slug = cfg.project_slug.clone().unwrap();
            let resp = http
                .get(format!("{}/api/v1/projects/slug/{}", cfg.host, slug))
                .headers({
                    let mut h = login_headers.clone();
                    h.insert(AUTHORIZATION, HeaderValue::from_str(&format!("Bearer {token}")).unwrap());
                    h
                })
                .send()
                .map_err(|e| map_net_err(e, &cfg.host))?;
            if !resp.status().is_success() {
                bail!("Infisical project lookup failed for slug '{slug}' (HTTP {})", resp.status());
            }
            let pj: Json = resp.json().context("parsing project response")?;
            pj.get("id")
                .or_else(|| pj.pointer("/project/id"))
                .and_then(|v| v.as_str())
                .ok_or_else(|| anyhow!("Infisical project '{slug}' has no id"))?
                .to_string()
        };

        Ok(Client { http, cfg, token, project_id })
    }

    /// GET a single secret value. Returns `Ok(None)` on 404.
    pub fn get_secret(&self, path: &str, key: &str) -> Result<Option<String>> {
        let resp = self
            .req(self.http.get(format!("{}/api/v3/secrets/raw/{}", self.cfg.host, key)))
            .query(&[
                ("workspaceId", self.project_id.as_str()),
                ("environment", self.cfg.environment.as_str()),
                ("secretPath", path),
            ])
            .send()
            .map_err(|e| map_net_err(e, &self.cfg.host))?;
        if resp.status() == reqwest::StatusCode::NOT_FOUND {
            return Ok(None);
        }
        if !resp.status().is_success() {
            bail!("Infisical get_secret {path}/{key} failed (HTTP {})", resp.status());
        }
        let body: Json = resp.json()?;
        Ok(body
            .pointer("/secret/secretValue")
            .and_then(|v| v.as_str())
            .map(|s| s.to_string()))
    }

    /// Create or update a secret (create-or-update with no-op detection).
    pub fn upsert_secret(&self, path: &str, key: &str, value: &str) -> Result<UpsertOutcome> {
        match self.get_secret(path, key)? {
            Some(existing) if existing == value => Ok(UpsertOutcome::Unchanged),
            Some(_) => {
                self.write_secret(reqwest::Method::PATCH, path, key, value)?;
                Ok(UpsertOutcome::Updated)
            }
            None => {
                self.ensure_folder_path(path)?;
                self.write_secret(reqwest::Method::POST, path, key, value)?;
                Ok(UpsertOutcome::Created)
            }
        }
    }

    fn write_secret(&self, method: reqwest::Method, path: &str, key: &str, value: &str) -> Result<()> {
        let url = format!("{}/api/v3/secrets/raw/{}", self.cfg.host, key);
        let builder = match method {
            reqwest::Method::POST => self.http.post(url),
            _ => self.http.patch(url),
        };
        let resp = self
            .req(builder)
            .json(&serde_json::json!({
                "workspaceId": self.project_id,
                "environment": self.cfg.environment,
                "secretPath": path,
                "secretValue": value,
                "type": "shared",
            }))
            .send()
            .map_err(|e| map_net_err(e, &self.cfg.host))?;
        if !resp.status().is_success() {
            // Scrub: never echo the body (may include secretValue).
            bail!("Infisical write {path}/{key} failed (HTTP {})", resp.status());
        }
        Ok(())
    }

    /// Create each folder segment of `path` (idempotent — conflicts ignored).
    pub fn ensure_folder_path(&self, path: &str) -> Result<()> {
        let mut prefix = String::from("/");
        for seg in path.split('/').filter(|s| !s.is_empty()) {
            let resp = self
                .req(self.http.post(format!("{}/api/v2/folders", self.cfg.host)))
                .json(&serde_json::json!({
                    "projectId": self.project_id,
                    "environment": self.cfg.environment,
                    "name": seg,
                    "path": prefix,
                }))
                .send()
                .map_err(|e| map_net_err(e, &self.cfg.host))?;
            // 200/201 created, 400/409 already exists — both fine.
            let _ = resp;
            if prefix == "/" {
                prefix = format!("/{seg}");
            } else {
                prefix = format!("{prefix}/{seg}");
            }
        }
        Ok(())
    }
}

fn map_net_err(e: reqwest::Error, host: &str) -> anyhow::Error {
    if e.is_connect() || e.is_timeout() {
        anyhow!("Infisical unreachable ({host})")
    } else {
        anyhow!("Infisical request error: {e}")
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn normalizes_host_variants() {
        assert_eq!(normalize_host("https://x.com/api"), "https://x.com");
        assert_eq!(normalize_host("https://x.com/api/"), "https://x.com");
        assert_eq!(normalize_host("https://x.com/"), "https://x.com");
        assert_eq!(normalize_host("https://x.com"), "https://x.com");
    }

    #[test]
    fn resolve_str_prefers_env() {
        std::env::set_var("DC_TEST_INFISICAL_HOST", "https://env.example");
        assert_eq!(
            resolve_str(&["DC_TEST_INFISICAL_HOST"], None).as_deref(),
            Some("https://env.example")
        );
        std::env::remove_var("DC_TEST_INFISICAL_HOST");
        assert_eq!(resolve_str(&["DC_TEST_INFISICAL_HOST_UNSET"], None), None);
    }
}
