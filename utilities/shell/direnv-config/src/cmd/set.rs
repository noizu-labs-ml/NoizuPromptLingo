use anyhow::Result;

pub fn run(name: &str, key: &str, value: &str, layer: Option<&str>, no_bump: bool) -> Result<()> {
    let cwd = std::env::current_dir()?;
    let store = crate::store::ensure_store(&cwd)?;
    crate::store::ensure_config(&store, name)?;

    let layer_name = layer.unwrap_or("local");
    let layer_file = crate::store::layout::layer_path(&store, name, layer_name);

    let mut doc = if layer_file.exists() {
        let content = std::fs::read_to_string(&layer_file)?;
        serde_yaml::from_str(&content)
            .unwrap_or(serde_yaml::Value::Mapping(serde_yaml::Mapping::new()))
    } else {
        serde_yaml::Value::Mapping(serde_yaml::Mapping::new())
    };

    // Parse the value as YAML to get proper typing (numbers, bools)
    let yaml_val: serde_yaml::Value = serde_yaml::from_str(value)
        .unwrap_or(serde_yaml::Value::String(value.to_string()));

    crate::yaml::path::set_path(&mut doc, key, yaml_val)?;

    let yaml_str = serde_yaml::to_string(&doc)?;
    std::fs::write(&layer_file, yaml_str)?;

    crate::store::resolve::resolve_active(&store, name)?;

    if !no_bump {
        crate::store::bump_version(&store)?;
    }

    Ok(())
}
