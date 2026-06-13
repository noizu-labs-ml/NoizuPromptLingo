use std::env;
use std::io::{self, Write};

#[derive(Debug, Clone, PartialEq)]
pub enum Terminal {
    ITerm2,
    Ghostty,
    Kitty,
    WezTerm,
    AppleTerminal,
    WindowsTerminal,
    Alacritty,
    Konsole,
    GnomeTerminal,
    Tmux,
    Zellij,
    Xterm,
    Unknown,
}

impl Terminal {
    pub fn as_str(&self) -> &'static str {
        match self {
            Terminal::ITerm2 => "iterm2",
            Terminal::Ghostty => "ghostty",
            Terminal::Kitty => "kitty",
            Terminal::WezTerm => "wezterm",
            Terminal::AppleTerminal => "apple-terminal",
            Terminal::WindowsTerminal => "windows-terminal",
            Terminal::Alacritty => "alacritty",
            Terminal::Konsole => "konsole",
            Terminal::GnomeTerminal => "gnome-terminal",
            Terminal::Tmux => "tmux",
            Terminal::Zellij => "zellij",
            Terminal::Xterm => "xterm",
            Terminal::Unknown => "unknown",
        }
    }
}

pub fn detect() -> Terminal {
    if env::var("TAB_TERMINAL").is_ok() {
        return match env::var("TAB_TERMINAL").unwrap().as_str() {
            "iterm2" => Terminal::ITerm2,
            "ghostty" => Terminal::Ghostty,
            "kitty" => Terminal::Kitty,
            "wezterm" => Terminal::WezTerm,
            "apple-terminal" => Terminal::AppleTerminal,
            "windows-terminal" => Terminal::WindowsTerminal,
            "alacritty" => Terminal::Alacritty,
            "konsole" => Terminal::Konsole,
            "gnome-terminal" => Terminal::GnomeTerminal,
            "tmux" => Terminal::Tmux,
            "zellij" => Terminal::Zellij,
            "xterm" => Terminal::Xterm,
            _ => Terminal::Unknown,
        };
    }

    if env::var("ITERM_SESSION_ID").is_ok() {
        Terminal::ITerm2
    } else if env::var("GHOSTTY_RESOURCES_DIR").is_ok() {
        Terminal::Ghostty
    } else if env::var("KITTY_WINDOW_ID").is_ok() {
        Terminal::Kitty
    } else if env::var("TERM_PROGRAM").as_deref() == Ok("WezTerm") {
        Terminal::WezTerm
    } else if env::var("TERM_PROGRAM").as_deref() == Ok("Apple_Terminal") {
        Terminal::AppleTerminal
    } else if env::var("WT_SESSION").is_ok() {
        Terminal::WindowsTerminal
    } else if env::var("TERM_PROGRAM").as_deref() == Ok("Alacritty")
        || env::var("TERM").as_deref() == Ok("alacritty")
    {
        Terminal::Alacritty
    } else if env::var("KONSOLE_VERSION").is_ok() {
        Terminal::Konsole
    } else if env::var("GNOME_TERMINAL_SCREEN").is_ok() {
        Terminal::GnomeTerminal
    } else if env::var("TMUX").is_ok() {
        Terminal::Tmux
    } else if env::var("ZELLIJ").is_ok() {
        Terminal::Zellij
    } else if matches!(env::var("TERM").as_deref(), Ok("xterm") | Ok("xterm-256color")) {
        Terminal::Xterm
    } else {
        Terminal::Unknown
    }
}

pub fn send_title(title: &str) {
    let tty = std::fs::OpenOptions::new().write(true).open("/dev/tty");

    if let Ok(mut tty) = tty {
        let _ = write!(tty, "\x1b]0;{}\x07", title);
    } else {
        print!("\x1b]0;{}\x07", title);
        let _ = io::stdout().flush();
    }

    if env::var("ZELLIJ").is_ok() {
        let _ = std::process::Command::new("zellij")
            .args(["action", "rename-tab", title])
            .stderr(std::process::Stdio::null())
            .stdout(std::process::Stdio::null())
            .spawn();
    }
}

pub fn clear_title() {
    let tty = std::fs::OpenOptions::new().write(true).open("/dev/tty");
    if let Ok(mut tty) = tty {
        let _ = write!(tty, "\x1b]2;\x07");
    } else {
        print!("\x1b]2;\x07");
        let _ = io::stdout().flush();
    }
}

pub fn send_tab_color(terminal: &Terminal, r: u8, g: u8, b: u8) {
    let tty = std::fs::OpenOptions::new().write(true).open("/dev/tty");
    match terminal {
        Terminal::ITerm2 => {
            if let Ok(mut tty) = tty {
                let _ = write!(tty, "\x1b]6;1;bg;red;brightness;{}\x07", r);
                let _ = write!(tty, "\x1b]6;1;bg;green;brightness;{}\x07", g);
                let _ = write!(tty, "\x1b]6;1;bg;blue;brightness;{}\x07", b);
            }
        }
        Terminal::Kitty => {
            let hex = format!("active_bg=#{:02x}{:02x}{:02x}", r, g, b);
            let _ = std::process::Command::new("kitty")
                .args(["@", "set-tab-color", &hex])
                .stderr(std::process::Stdio::null())
                .stdout(std::process::Stdio::null())
                .spawn();
        }
        _ => {}
    }
}

pub fn send_bg_color(hex: &str) {
    let tty = std::fs::OpenOptions::new().write(true).open("/dev/tty");
    if let Ok(mut tty) = tty {
        let _ = write!(tty, "\x1b]11;{}\x07", hex);
    } else {
        print!("\x1b]11;{}\x07", hex);
        let _ = io::stdout().flush();
    }
}

pub fn clear_bg_color() {
    let tty = std::fs::OpenOptions::new().write(true).open("/dev/tty");
    if let Ok(mut tty) = tty {
        let _ = write!(tty, "\x1b]111\x07");
    } else {
        print!("\x1b]111\x07");
        let _ = io::stdout().flush();
    }
}

pub fn clear_tab_color() {
    let terminal = detect();
    match terminal {
        Terminal::ITerm2 => {
            let tty = std::fs::OpenOptions::new().write(true).open("/dev/tty");
            if let Ok(mut tty) = tty {
                let _ = write!(tty, "\x1b]6;1;bg;*;default\x07");
            }
        }
        Terminal::Kitty => {
            let _ = std::process::Command::new("kitty")
                .args(["@", "set-tab-color", "--reset"])
                .stderr(std::process::Stdio::null())
                .stdout(std::process::Stdio::null())
                .spawn();
        }
        _ => {} // No-op for terminals without tab color support
    }
}

pub fn clear_badge() {
    let terminal = detect();
    match terminal {
        Terminal::ITerm2 => {
            let tty = std::fs::OpenOptions::new().write(true).open("/dev/tty");
            if let Ok(mut tty) = tty {
                let _ = write!(tty, "\x1b]1337;SetBadgeFormat=\x07");
            }
        }
        _ => {} // No-op for terminals without badge support
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_terminal_as_str() {
        assert_eq!(Terminal::ITerm2.as_str(), "iterm2");
        assert_eq!(Terminal::Ghostty.as_str(), "ghostty");
        assert_eq!(Terminal::Kitty.as_str(), "kitty");
        assert_eq!(Terminal::WezTerm.as_str(), "wezterm");
        assert_eq!(Terminal::AppleTerminal.as_str(), "apple-terminal");
        assert_eq!(Terminal::Tmux.as_str(), "tmux");
        assert_eq!(Terminal::Zellij.as_str(), "zellij");
        assert_eq!(Terminal::Unknown.as_str(), "unknown");
    }

    #[test]
    fn test_terminal_all_variants_have_str() {
        let terminals = [
            Terminal::ITerm2,
            Terminal::Ghostty,
            Terminal::Kitty,
            Terminal::WezTerm,
            Terminal::AppleTerminal,
            Terminal::WindowsTerminal,
            Terminal::Alacritty,
            Terminal::Konsole,
            Terminal::GnomeTerminal,
            Terminal::Tmux,
            Terminal::Zellij,
            Terminal::Xterm,
            Terminal::Unknown,
        ];
        for t in &terminals {
            assert!(!t.as_str().is_empty());
        }
    }
}

pub fn terminal_info(terminal: &Terminal) {
    println!("Terminal: {}", terminal.as_str());
    if env::var("ZELLIJ").is_ok() {
        println!("Zellij:   yes (tab rename via zellij action)");
    }
    println!("Features:");
    println!("  Title (OSC 0):  yes (universal)");
    match terminal {
        Terminal::ITerm2 => {
            println!("  Tab Color:      yes (iTerm2 OSC 6)");
            println!("  Background:     yes (OSC 11)");
            println!("  Badge:          yes (iTerm2 OSC 1337)");
        }
        Terminal::Ghostty => {
            println!("  Tab Color:      no");
            println!("  Background:     yes (OSC 11)");
            println!("  Badge:          no");
        }
        Terminal::Kitty => {
            println!("  Tab Color:      yes (kitty remote control)");
            println!("  Background:     yes (OSC 11)");
            println!("  Badge:          no");
        }
        Terminal::Zellij => {
            println!("  Tab Color:      no");
            println!("  Background:     yes (OSC 11, passthrough)");
            println!("  Badge:          no");
            println!("  Zellij Tab:     yes (zellij action rename-tab)");
        }
        Terminal::WezTerm | Terminal::Xterm => {
            println!("  Tab Color:      no");
            println!("  Background:     yes (OSC 11)");
            println!("  Badge:          no");
        }
        _ => {
            println!("  Tab Color:      no");
            println!("  Background:     no");
            println!("  Badge:          no");
        }
    }
}
