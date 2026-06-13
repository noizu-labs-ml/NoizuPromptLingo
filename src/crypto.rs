//! Reversible authenticated encryption for `dc` secret values.
//!
//! Secrets are stored at rest as a single self-describing YAML string scalar:
//!
//! ```text
//! dcenc:v1:t<tier>:<base64url(nonce(24) || ciphertext || tag)>
//! ```
//!
//! The flat-scalar shape keeps merge/path/flatten and every language SDK working
//! unchanged — they pass the opaque string through without needing the key. Only
//! `dc` (holding the key in `~/.config/direnv-config/settings.yaml`) can decrypt.
//! The sensitivity tier rides inside the token so it survives every merge/copy.

use anyhow::{anyhow, Result};
use base64::Engine;
use chacha20poly1305::aead::{Aead, KeyInit};
use chacha20poly1305::{Key, XChaCha20Poly1305, XNonce};
use rand::RngCore;

const PREFIX: &str = "dcenc:v1:";
const NONCE_LEN: usize = 24;

fn b64url() -> base64::engine::general_purpose::GeneralPurpose {
    base64::engine::general_purpose::URL_SAFE_NO_PAD
}

/// True if `s` is a `dc` encrypted token. Cheap prefix check — never touches the key.
pub fn is_encrypted(s: &str) -> bool {
    s.starts_with(PREFIX)
}

/// Parse the sensitivity tier from a token without decrypting it.
pub fn token_tier(s: &str) -> Option<u8> {
    let rest = s.strip_prefix(PREFIX)?;
    let rest = rest.strip_prefix('t')?;
    let (tier_str, _) = rest.split_once(':')?;
    tier_str.parse::<u8>().ok()
}

/// Encrypt `plaintext` into a `dcenc:v1` token carrying the sensitivity `tier`.
pub fn encode_token(plaintext: &str, tier: u8, key: &[u8; 32]) -> Result<String> {
    let cipher = XChaCha20Poly1305::new(Key::from_slice(key));
    let mut nonce_bytes = [0u8; NONCE_LEN];
    rand::thread_rng().fill_bytes(&mut nonce_bytes);
    let nonce = XNonce::from_slice(&nonce_bytes);
    let ct = cipher
        .encrypt(nonce, plaintext.as_bytes())
        .map_err(|e| anyhow!("encryption failed: {e}"))?;
    let mut blob = Vec::with_capacity(NONCE_LEN + ct.len());
    blob.extend_from_slice(&nonce_bytes);
    blob.extend_from_slice(&ct);
    Ok(format!("{PREFIX}t{tier}:{}", b64url().encode(&blob)))
}

/// Decrypt a `dcenc:v1` token, returning `(tier, plaintext)`.
pub fn decode_token(token: &str, key: &[u8; 32]) -> Result<(u8, String)> {
    let rest = token
        .strip_prefix(PREFIX)
        .ok_or_else(|| anyhow!("not a dc encrypted token"))?;
    let rest = rest
        .strip_prefix('t')
        .ok_or_else(|| anyhow!("malformed dc token (missing tier marker)"))?;
    let (tier_str, payload) = rest
        .split_once(':')
        .ok_or_else(|| anyhow!("malformed dc token (missing payload)"))?;
    let tier: u8 = tier_str
        .parse()
        .map_err(|_| anyhow!("malformed dc token (bad tier)"))?;
    let blob = b64url()
        .decode(payload)
        .map_err(|e| anyhow!("malformed dc token (bad base64): {e}"))?;
    if blob.len() < NONCE_LEN {
        return Err(anyhow!("malformed dc token (truncated)"));
    }
    let (nonce_bytes, ct) = blob.split_at(NONCE_LEN);
    let cipher = XChaCha20Poly1305::new(Key::from_slice(key));
    let nonce = XNonce::from_slice(nonce_bytes);
    let pt = cipher
        .decrypt(nonce, ct)
        .map_err(|_| anyhow!("decryption failed (wrong key or corrupt token)"))?;
    let s = String::from_utf8(pt).map_err(|_| anyhow!("decrypted value is not valid UTF-8"))?;
    Ok((tier, s))
}

/// Decode a base64 (standard alphabet) string — used for the key material in settings.yaml.
pub fn b64_standard_decode(s: &str) -> Result<Vec<u8>> {
    base64::engine::general_purpose::STANDARD
        .decode(s)
        .map_err(|e| anyhow!("invalid base64: {e}"))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn test_key() -> [u8; 32] {
        let mut k = [0u8; 32];
        for (i, b) in k.iter_mut().enumerate() {
            *b = i as u8;
        }
        k
    }

    #[test]
    fn round_trip_preserves_value_and_tier() {
        let key = test_key();
        let secret = "hunter2            spaces\n \n keep";
        let token = encode_token(secret, 2, &key).unwrap();
        assert!(is_encrypted(&token));
        assert_eq!(token_tier(&token), Some(2));
        let (tier, plain) = decode_token(&token, &key).unwrap();
        assert_eq!(tier, 2);
        assert_eq!(plain, secret);
    }

    #[test]
    fn distinct_nonces_yield_distinct_tokens() {
        let key = test_key();
        let a = encode_token("same", 0, &key).unwrap();
        let b = encode_token("same", 0, &key).unwrap();
        assert_ne!(a, b, "random nonce should produce different ciphertexts");
    }

    #[test]
    fn wrong_key_fails_to_decrypt() {
        let token = encode_token("secret", 0, &test_key()).unwrap();
        let mut bad = test_key();
        bad[0] ^= 0xff;
        assert!(decode_token(&token, &bad).is_err());
    }

    #[test]
    fn non_token_is_not_encrypted() {
        assert!(!is_encrypted("plain value"));
        assert!(token_tier("plain value").is_none());
    }
}
