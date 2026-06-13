use anyhow::Result;
use std::collections::HashMap;

pub fn run(list: bool, _diff: bool) -> Result<()> {
    let store = crate::store::find_current_store()?;
    let chain = crate::store::resolve::resolve_chain(&store);

    // Load the _dc config for flatten rules
    let dc_config = crate::store::resolve::resolve_config(&chain, "_dc")
        .unwrap_or(serde_yaml::Value::Mapping(serde_yaml::Mapping::new()));
    let rules = crate::yaml::flatten::parse_rules(&dc_config);

    // Resolve all named configs referenced in the rules
    let mut config_names: Vec<String> = rules.iter().map(|r| r.config_name.clone()).collect();
    config_names.sort();
    config_names.dedup();

    let mut configs: HashMap<String, serde_yaml::Value> = HashMap::new();
    for name in &config_names {
        if let Ok(val) = crate::store::resolve::resolve_config(&chain, name) {
            if !val.is_null() {
                configs.insert(name.clone(), val);
            }
        }
    }

    let results = crate::yaml::flatten::flatten(&rules, &configs);
    let version = crate::store::read_version(&store);

    if list {
        for (key, val) in &results {
            println!("{}={}", key, val);
        }
    } else {
        print!("{}", crate::yaml::flatten::emit_exports_with_dc_vars(&results, &store, version));
    }

    Ok(())
}
