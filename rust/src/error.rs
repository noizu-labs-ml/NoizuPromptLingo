use thiserror::Error;

#[allow(dead_code)]
#[derive(Error, Debug)]
pub enum InfisicalError {
    #[error("HTTP error {status}: {message}")]
    Api { status: u16, message: String },

    #[error("Authentication failed: {0}")]
    Auth(String),

    #[error("Config not found — checked: .infisical-secrets.yaml, infisical-secrets.yaml, secrets.yaml")]
    ConfigNotFound,

    #[error("Config parse error: {0}")]
    ConfigParse(String),

    #[error(".envrc.dc not found in current directory or any parent")]
    EnvrcNotFound,

    #[error("dc CLI error: {0}")]
    DcCli(String),

    #[error("Secret not found: {path}/{key}")]
    SecretNotFound { path: String, key: String },

    #[error("kubectl error: {0}")]
    Kubectl(String),

    #[error("Missing required env var or dc value: {0}")]
    MissingCredential(String),
}
