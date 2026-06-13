const RED: &str = "\x1b[0;31m";
const YEL: &str = "\x1b[1;33m";
const GRN: &str = "\x1b[0;32m";
const BLU: &str = "\x1b[0;34m";
const CYN: &str = "\x1b[0;36m";
const NC: &str = "\x1b[0m";
const BOLD: &str = "\x1b[1m";

pub fn banner(msg: &str) {
    eprintln!(
        "\n{BLU}{BOLD}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}{NC}"
    );
    eprintln!("{BLU}{BOLD}  {msg}{NC}");
    eprintln!(
        "{BLU}{BOLD}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}\u{2550}{NC}"
    );
}

pub fn step(msg: &str) {
    eprintln!("\n{BLU}\u{25b6} {msg}{NC}");
}

pub fn ok(msg: &str) {
    eprintln!("  {GRN}\u{2705} {msg}{NC}");
}

pub fn warn_msg(msg: &str) {
    eprintln!("  {YEL}\u{26a0}\u{fe0f}  {msg}{NC}");
}

pub fn fail_msg(msg: &str) {
    eprintln!("  {RED}\u{274c} {msg}{NC}");
}

pub fn info(msg: &str) {
    eprintln!("  {CYN}\u{2139}\u{fe0f}  {msg}{NC}");
}

pub fn verbose(msg: &str) {
    eprintln!("  {CYN}   {msg}{NC}");
}

pub fn progress_label(index: usize, total: usize, label: &str) {
    eprintln!("\n  {CYN}[{index}/{total}]{NC} {label}");
}

pub fn plan_item(id: &str, asset_type: &str, service: &str) {
    eprintln!("\n  {BOLD}{id}{NC} ({asset_type}, {service})");
}

pub fn plan_detail(label: &str, value: &str) {
    eprintln!("    {:<7}: {}", label, value);
}
