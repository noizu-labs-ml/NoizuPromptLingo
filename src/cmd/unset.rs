use anyhow::Result;

pub fn run(name: &str, keys: &[String], layer: Option<&str>, no_bump: bool) -> Result<()> {
    let cwd = std::env::current_dir()?;
    let store = crate::store::ensure_store(&cwd)?;
    crate::store::ensure_config(&store, name)?;

    let layer_name = layer.unwrap_or("local");
    let layer_file = crate::store::layout::layer_path(&store, name, layer_name);

    if !layer_file.exists() {
        return Ok(());
    }

    let content = std::fs::read_to_string(&layer_file)?;
    let mut doc: serde_yaml::Value = serde_yaml::from_str(&content)
        .unwrap_or(serde_yaml::Value::Mapping(serde_yaml::Mapping::new()));

    for key in keys {
        crate::yaml::path::delete_path(&mut doc, key);
    }

    let yaml_str = serde_yaml::to_string(&doc)?;
    std::fs::write(&layer_file, yaml_str)?;

    crate::store::resolve::resolve_active(&store, name)?;

    if !no_bump {
        crate::store::bump_version(&store)?;
    }

    Ok(())
}
