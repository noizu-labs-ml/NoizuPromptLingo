use anyhow::Result;

pub fn run(name: &str, keys: &[String], layer: Option<&str>, no_bump: bool) -> Result<()> {
    let cwd = std::env::current_dir()?;
    let store = crate::store::ensure_store(&cwd)?;
    crate::store::ensure_config(&store, name)?;

    let layer_name = layer.unwrap_or("base");
    let layer_file = crate::store::layout::layer_path(&store, name, layer_name);

    if keys.is_empty() {
        // Prune the entire named config — write a tombstone at root
        let mut map = serde_yaml::Mapping::new();
        map.insert(
            serde_yaml::Value::String("_dc_pruned".into()),
            serde_yaml::Value::Bool(true),
        );
        let val = serde_yaml::Value::Mapping(map);
        let yaml_str = serde_yaml::to_string(&val)?;
        std::fs::write(&layer_file, yaml_str)?;
    } else {
        // Prune specific branches within the config
        let mut doc = if layer_file.exists() {
            let content = std::fs::read_to_string(&layer_file)?;
            serde_yaml::from_str(&content)
                .unwrap_or(serde_yaml::Value::Mapping(serde_yaml::Mapping::new()))
        } else {
            serde_yaml::Value::Mapping(serde_yaml::Mapping::new())
        };

        for key in keys {
            // Write a tombstone at the key location
            let mut tombstone = serde_yaml::Mapping::new();
            tombstone.insert(
                serde_yaml::Value::String("_dc_pruned".into()),
                serde_yaml::Value::Bool(true),
            );
            crate::yaml::path::set_path(
                &mut doc,
                key,
                serde_yaml::Value::Mapping(tombstone),
            )?;
        }

        let yaml_str = serde_yaml::to_string(&doc)?;
        std::fs::write(&layer_file, yaml_str)?;
    }

    crate::store::resolve::resolve_active(&store, name)?;

    if !no_bump {
        crate::store::bump_version(&store)?;
    }

    Ok(())
}
