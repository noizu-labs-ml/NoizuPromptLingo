use anyhow::Result;

pub fn run(from_envrc: Option<&str>) -> Result<()> {
    let cwd = std::env::current_dir()?;
    let store = crate::store::ensure_store(&cwd)?;

    if let Some(envrc_path) = from_envrc {
        let content = std::fs::read_to_string(envrc_path)?;
        let mut imports = Vec::new();
        for line in content.lines() {
            let trimmed = line.trim();
            if let Some(rest) = trimmed.strip_prefix("export ") {
                if let Some(eq_pos) = rest.find('=') {
                    let key = rest[..eq_pos].trim();
                    let val = rest[eq_pos + 1..].trim().trim_matches('"').trim_matches('\'');
                    imports.push((key.to_string(), val.to_string()));
                }
            }
        }
        if !imports.is_empty() {
            let mut map = serde_yaml::Mapping::new();
            for (k, v) in &imports {
                map.insert(
                    serde_yaml::Value::String(k.clone()),
                    serde_yaml::Value::String(v.clone()),
                );
            }
            let val = serde_yaml::Value::Mapping(map);
            let config_name = "imported";
            crate::store::ensure_config(&store, config_name)?;
            let layer = crate::store::layout::layer_path(&store, config_name, "base");
            let yaml_str = serde_yaml::to_string(&val)?;
            std::fs::write(&layer, yaml_str)?;
            crate::store::resolve::resolve_active(&store, config_name)?;
            eprintln!("Imported {} vars into config '{}'", imports.len(), config_name);
        }
    }

    crate::store::meta::update_configs_list(&store)?;
    eprintln!("Store initialized at {}", store.display());
    Ok(())
}
