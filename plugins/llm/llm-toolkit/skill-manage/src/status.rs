use crate::config::AppConfig;
use crate::kinds::{InstallStatus, Kind, Provider};
use crate::link::classify;
use crate::sources::discover;
use anyhow::Result;
use std::collections::BTreeMap;

// ⟦𓄼𓋂𓀊𓁁⟧ print_status :: auto-generated pointer for public function print_status
pub fn print_status(cfg: &AppConfig) -> Result<()> {
    println!(
        "{:<10} {:<10} {:>8} {:>8} {:>8} {:>8} {:>8}",
        "KIND", "PROVIDER", "enabled", "disabled", "real", "foreign", "broken"
    );

    for kind in Kind::all() {
        let (items, _) = discover(cfg, kind)?;
        for provider in Provider::all() {
            let Some(kind_dir) = cfg.kind_dir(provider, kind) else {
                continue;
            };
            let mut counts: BTreeMap<&str, usize> = BTreeMap::new();
            for key in ["enabled", "disabled", "real", "foreign", "broken"] {
                counts.insert(key, 0);
            }
            for item in items.values() {
                let dest = item.dest_path(&kind_dir);
                let st = classify(cfg, kind, &dest, Some(&item.path));
                let k = match st {
                    InstallStatus::Enabled => "enabled",
                    InstallStatus::Disabled => "disabled",
                    InstallStatus::Real => "real",
                    InstallStatus::Foreign => "foreign",
                    InstallStatus::Broken | InstallStatus::MissingSource => "broken",
                };
                *counts.entry(k).or_default() += 1;
            }
            println!(
                "{:<10} {:<10} {:>8} {:>8} {:>8} {:>8} {:>8}",
                kind.as_str(),
                provider.as_str(),
                counts["enabled"],
                counts["disabled"],
                counts["real"],
                counts["foreign"],
                counts["broken"],
            );
        }
    }
    Ok(())
}
