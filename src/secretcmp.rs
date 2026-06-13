//! No-leak secret comparison.
//!
//! Compares two plaintexts by their SHA-256 digests in constant time. Hashing
//! first hides length and keeps raw bytes from lingering; only equality verdicts
//! (never the value) reach stdout.

use sha2::{Digest, Sha256};

/// Constant-time-ish equality: compare SHA-256 digests of both inputs.
pub fn eq_ct(a: &[u8], b: &[u8]) -> bool {
    let ha = Sha256::digest(a);
    let hb = Sha256::digest(b);
    // Constant-time digest comparison.
    let mut diff = 0u8;
    for (x, y) in ha.iter().zip(hb.iter()) {
        diff |= x ^ y;
    }
    diff == 0
}

/// Format a comparison verdict line — `DC == k8  ns/secret/KEY`.
pub fn verdict(op_equal: bool, target_label: &str, target_display: &str) -> String {
    let op = if op_equal { "==" } else { "!=" };
    format!("DC {op} {target_label}  {target_display}")
}

/// Format a verdict when the remote side is missing.
pub fn missing(target_label: &str, target_display: &str) -> String {
    format!("DC ?? {target_label}  {target_display} (remote missing)")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn equal_and_unequal() {
        assert!(eq_ct(b"secret", b"secret"));
        assert!(!eq_ct(b"secret", b"Secret"));
        assert!(!eq_ct(b"secret", b"secretx"));
    }

    #[test]
    fn verdict_strings() {
        assert_eq!(verdict(true, "k8", "ns/s/K"), "DC == k8  ns/s/K");
        assert_eq!(verdict(false, "infisical", "/p/N"), "DC != infisical  /p/N");
        assert_eq!(missing("k8", "ns/s/K"), "DC ?? k8  ns/s/K (remote missing)");
    }
}
