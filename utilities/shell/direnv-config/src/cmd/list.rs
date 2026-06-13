use anyhow::Result;

pub fn run() -> Result<()> {
    let sd = crate::store::layout::state_dir();
    if !sd.exists() {
        println!("No stores found. Run `dc init` in a project directory.");
        return Ok(());
    }

    let mut entries: Vec<(String, String, usize, u64)> = Vec::new();

    for entry in std::fs::read_dir(&sd)? {
        let entry = entry?;
        let path = entry.path();
        if !path.is_dir() {
            continue;
        }
        let meta_file = path.join(".meta");
        if !meta_file.exists() {
            continue;
        }
        let meta = match crate::store::meta::read_meta(&path) {
            Ok(m) => m,
            Err(_) => continue,
        };
        let version = crate::store::read_version(&path);
        let source = meta.source.to_string_lossy()
            .replace(&dirs::home_dir().map(|h| h.to_string_lossy().to_string()).unwrap_or_default(), "~");

        entries.push((
            entry.file_name().to_string_lossy().to_string(),
            source,
            meta.configs.len(),
            version,
        ));
    }

    entries.sort_by(|a, b| a.0.cmp(&b.0));

    if entries.is_empty() {
        println!("No stores found.");
        return Ok(());
    }

    println!("{:<50} {:<45} {:>7} {:>4}", "Store", "Source", "Configs", "Ver");
    println!("{}", "-".repeat(110));
    for (store_name, source, configs, ver) in &entries {
        println!("{:<50} {:<45} {:>7} {:>4}", store_name, source, configs, ver);
    }

    Ok(())
}
