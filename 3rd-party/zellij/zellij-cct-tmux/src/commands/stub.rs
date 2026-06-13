use crate::logger;

pub fn run(subcmd: &str, args: &[&str]) -> i32 {
    logger::log_unimplemented(subcmd, args);
    0
}
