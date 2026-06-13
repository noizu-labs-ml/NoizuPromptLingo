use serde::{Deserialize, Serialize};

// ── Auth ─────────────────────────────────────────────────────────────────────

#[derive(Serialize)]
pub struct LoginRequest {
    #[serde(rename = "clientId")]
    pub client_id: String,
    #[serde(rename = "clientSecret")]
    pub client_secret: String,
}

#[derive(Deserialize)]
pub struct LoginResponse {
    #[serde(rename = "accessToken")]
    pub access_token: String,
}

// ── Project ──────────────────────────────────────────────────────────────────

#[allow(dead_code)]
#[derive(Deserialize)]
pub struct ProjectResponse {
    pub project: ProjectInfo,
}

#[allow(dead_code)]
#[derive(Deserialize)]
pub struct ProjectInfo {
    pub id: String,
}

// ── Secrets ──────────────────────────────────────────────────────────────────

#[derive(Deserialize, Debug, Clone)]
pub struct SecretItem {
    #[serde(rename = "secretKey")]
    pub key: String,
    #[serde(rename = "secretValue")]
    pub value: String,
    #[serde(rename = "secretPath", default)]
    #[allow(dead_code)]
    pub path: String,
}

#[derive(Deserialize)]
pub struct ListSecretsResponse {
    pub secrets: Vec<SecretItem>,
}

#[derive(Deserialize)]
pub struct GetSecretResponse {
    pub secret: SecretItem,
}

#[derive(Serialize)]
pub struct CreateSecretRequest {
    #[serde(rename = "workspaceId")]
    pub workspace_id: String,
    pub environment: String,
    #[serde(rename = "secretPath")]
    pub secret_path: String,
    #[serde(rename = "secretValue")]
    pub secret_value: String,
    #[serde(rename = "secretComment", skip_serializing_if = "Option::is_none")]
    pub secret_comment: Option<String>,
}

#[derive(Serialize)]
pub struct UpdateSecretRequest {
    #[serde(rename = "workspaceId")]
    pub workspace_id: String,
    pub environment: String,
    #[serde(rename = "secretPath")]
    pub secret_path: String,
    #[serde(rename = "secretValue")]
    pub secret_value: String,
}

#[derive(Serialize)]
pub struct CreateFolderRequest {
    #[serde(rename = "workspaceId")]
    pub workspace_id: String,
    pub environment: String,
    #[serde(rename = "path")]
    pub path: String,
    pub name: String,
}
