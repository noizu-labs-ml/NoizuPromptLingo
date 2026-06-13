use anyhow::Result;

pub fn run() -> Result<()> {
    let store = crate::store::find_current_store()?;
    let meta = crate::store::meta::read_meta(&store)?;
    let version = crate::store::read_version(&store);
    let dc_env = std::env::var("DC_ENV").unwrap_or_else(|_| "dev".into());

    println!("Source:      {}", meta.source.display());
    println!("Store:       {}", store.display());
    println!("Environment: {}", dc_env);
    println!("Version:     {}", version);
    println!("Created:     {}", meta.created);

    if meta.configs.is_empty() {
        println!("Configs:     (none)");
    } else {
        println!("Configs:     {}", meta.configs.join(", "));
    }

    if let Some(ref parent) = meta.parent {
        println!("Parent:      {}", parent.display());
    }

    let chain = crate::store::resolve::resolve_chain(&store);
    if chain.len() > 1 {
        println!("Chain:       {} stores ({} parents)", chain.len(), chain.len() - 1);
    }

    Ok(())
}
