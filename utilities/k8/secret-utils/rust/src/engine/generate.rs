use anyhow::Result;
use rand::Rng;

use crate::config::v1::AutoKind;

const DJANGO_CHARS: &[u8] =
    b"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*(-_=+)";

pub fn generate_value(kind: &AutoKind, length: usize) -> Result<String> {
    match kind {
        AutoKind::Password => {
            let bytes = random_bytes(length);
            Ok(base64::engine::general_purpose::STANDARD.encode(&bytes))
        }
        AutoKind::Hex => {
            let bytes = random_bytes(length / 2 + 1);
            Ok(hex::encode(&bytes)[..length].to_owned())
        }
        AutoKind::Django => {
            let mut rng = rand::thread_rng();
            let s: String = (0..length)
                .map(|_| {
                    let idx = rng.gen_range(0..DJANGO_CHARS.len());
                    DJANGO_CHARS[idx] as char
                })
                .collect();
            Ok(s)
        }
    }
}

fn random_bytes(n: usize) -> Vec<u8> {
    let mut rng = rand::thread_rng();
    (0..n).map(|_| rng.gen::<u8>()).collect()
}

use base64::Engine as _;
