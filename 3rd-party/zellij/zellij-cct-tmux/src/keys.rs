/// Translate tmux send-keys arguments to raw bytes.
/// Each arg is either a named key ("Enter", "Tab", "C-c") or a literal string.
/// Multiple args concatenate in order.
pub fn translate_args(args: &[&str]) -> Vec<u8> {
    let mut bytes = Vec::new();
    for arg in args {
        if let Some(b) = translate_named_key(arg) {
            bytes.extend_from_slice(&b);
        } else {
            bytes.extend_from_slice(arg.as_bytes());
        }
    }
    bytes
}

fn translate_named_key(key: &str) -> Option<Vec<u8>> {
    match key {
        "Enter" | "Return" | "C-m" | "C-M" => Some(vec![0x0D]),
        "Tab" | "C-i" | "C-I" => Some(vec![0x09]),
        "Space" => Some(vec![0x20]),
        "Escape" | "Esc" => Some(vec![0x1B]),
        "BSpace" | "Backspace" | "C-h" | "C-H" => Some(vec![0x7F]),
        "C-c" | "C-C" => Some(vec![0x03]),
        "C-d" | "C-D" => Some(vec![0x04]),
        "C-z" | "C-Z" => Some(vec![0x1A]),
        "C-a" | "C-A" => Some(vec![0x01]),
        "C-e" | "C-E" => Some(vec![0x05]),
        "C-l" | "C-L" => Some(vec![0x0C]),
        "C-u" | "C-U" => Some(vec![0x15]),
        "C-w" | "C-W" => Some(vec![0x17]),
        "C-[" => Some(vec![0x1B]),
        "Up" => Some(b"\x1b[A".to_vec()),
        "Down" => Some(b"\x1b[B".to_vec()),
        "Right" => Some(b"\x1b[C".to_vec()),
        "Left" => Some(b"\x1b[D".to_vec()),
        "Home" => Some(b"\x1b[H".to_vec()),
        "End" => Some(b"\x1b[F".to_vec()),
        _ => {
            // General C-<letter> pattern
            if key.len() == 3 && key.starts_with("C-") {
                let ch = key.as_bytes()[2];
                let upper = ch.to_ascii_uppercase();
                if upper >= b'A' && upper <= b'Z' {
                    return Some(vec![upper - b'@']);
                }
            }
            None
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn enter_is_cr() {
        assert_eq!(translate_args(&["Enter"]), vec![0x0D]);
    }

    #[test]
    fn literal_plus_enter() {
        assert_eq!(
            translate_args(&["echo hello", "Enter"]),
            b"echo hello\r".to_vec()
        );
    }

    #[test]
    fn ctrl_c() {
        assert_eq!(translate_args(&["C-c"]), vec![0x03]);
    }

    #[test]
    fn general_ctrl_letter() {
        assert_eq!(translate_args(&["C-g"]), vec![0x07]);
    }

    #[test]
    fn multiple_literals_concatenate() {
        assert_eq!(
            translate_args(&["cd /tmp", "Enter", "ls", "Enter"]),
            b"cd /tmp\rls\r".to_vec()
        );
    }
}
