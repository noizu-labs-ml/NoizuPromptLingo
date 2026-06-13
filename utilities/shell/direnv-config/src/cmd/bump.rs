use anyhow::Result;

pub fn run() -> Result<()> {
    let store = crate::store::find_current_store()?;
    let new_ver = crate::store::bump_version(&store)?;
    eprintln!("Version bumped to {}", new_ver);
    Ok(())
}
