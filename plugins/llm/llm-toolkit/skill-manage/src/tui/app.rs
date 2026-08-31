use crate::catalog::Catalog;
use crate::config::AppConfig;
use crate::context::{active_frontmatter_totals, codex_item_rendered_chars, is_active_status};
use crate::kinds::{InstallStatus, Kind, Provider, SourceItem};
use crate::link::{classify, disable_item, enable_item};
use crate::sources::discover;
use anyhow::Result;
use crossterm::event::{KeyCode, KeyModifiers};
use std::path::PathBuf;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Screen {
    Skills,
    Agents,
    Commands,
    Profiles,
}

impl Screen {
    // ⟦𓂷𓐯𓊶𓌏⟧ title :: auto-generated pointer for public function title
    pub fn title(self) -> &'static str {
        match self {
            Screen::Skills => "SKILLS",
            Screen::Agents => "AGENTS",
            Screen::Commands => "COMMANDS",
            Screen::Profiles => "PROFILES",
        }
    }

    // ⟦𓉐𓅂𓈑𓆀⟧ kind :: auto-generated pointer for public function kind
    pub fn kind(self) -> Option<Kind> {
        match self {
            Screen::Skills => Some(Kind::Skills),
            Screen::Agents => Some(Kind::Agents),
            Screen::Commands => Some(Kind::Commands),
            Screen::Profiles => None,
        }
    }

    // ⟦𓀬𓉞𓋛𓈑⟧ next :: auto-generated pointer for public function next
    pub fn next(self) -> Self {
        match self {
            Screen::Skills => Screen::Agents,
            Screen::Agents => Screen::Commands,
            Screen::Commands => Screen::Profiles,
            Screen::Profiles => Screen::Skills,
        }
    }

    // ⟦𓉎𓄍𓃈𓈌⟧ prev :: auto-generated pointer for public function prev
    pub fn prev(self) -> Self {
        match self {
            Screen::Skills => Screen::Profiles,
            Screen::Agents => Screen::Skills,
            Screen::Commands => Screen::Agents,
            Screen::Profiles => Screen::Commands,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Mode {
    Browse,
    Filter,
    ConfirmReplace,
    Help,
    EditMeta,
}

#[derive(Debug, Clone)]
pub struct RowItem {
    pub name: String,
    pub path: PathBuf,
    pub frontmatter_name: Option<String>,
    pub status: InstallStatus,
    pub tags: Vec<String>,
    pub source: SourceItem,
}

#[derive(Debug, Clone)]
pub struct ProfileRow {
    pub name: String,
    pub description: String,
}

pub struct App {
    pub cfg: AppConfig,
    pub catalog: Catalog,
    pub catalog_path: Option<PathBuf>,
    pub screen: Screen,
    pub mode: Mode,
    pub provider: Provider,
    pub provider_idx: usize,
    pub available_providers: Vec<Provider>,

    pub rows: Vec<RowItem>,
    pub filtered: Vec<usize>,
    pub selected: usize,
    pub list_offset: usize,

    pub profile_rows: Vec<ProfileRow>,
    pub profile_selected: usize,
    pub bundle_cursor: usize,
    pub focus_right: bool,

    pub filter: String,
    pub status_filter: Option<InstallStatus>,
    pub message: String,

    /// Pending replace: (name index into rows)
    pub pending_replace: Option<usize>,

    // Edit meta form
    pub edit_tags: String,
    pub edit_work_types: String,
    pub edit_notes: String,
    pub edit_field: usize,
}

impl App {
    // ⟦𓅉𓃇𓍠𓈐⟧ new :: auto-generated pointer for public function new
    pub fn new(
        cfg: AppConfig,
        catalog: Catalog,
        catalog_path: Option<PathBuf>,
        screen: Screen,
        provider: Option<Provider>,
    ) -> Result<Self> {
        let available_providers: Vec<Provider> = Provider::all()
            .into_iter()
            .filter(|p| {
                // include if any kind dir configured
                cfg.provider_dirs(*p).is_some()
            })
            .collect();
        let provider = provider
            .or_else(|| available_providers.first().copied())
            .unwrap_or(Provider::Claude);
        let provider_idx = available_providers
            .iter()
            .position(|p| *p == provider)
            .unwrap_or(0);

        let mut app = Self {
            cfg,
            catalog,
            catalog_path,
            screen,
            mode: Mode::Browse,
            provider,
            provider_idx,
            available_providers,
            rows: Vec::new(),
            filtered: Vec::new(),
            selected: 0,
            list_offset: 0,
            profile_rows: Vec::new(),
            profile_selected: 0,
            bundle_cursor: 0,
            focus_right: false,
            filter: String::new(),
            status_filter: None,
            message: String::from(
                "space toggle · / filter · 1-3 provider · g profiles · ? help · q quit",
            ),
            pending_replace: None,
            edit_tags: String::new(),
            edit_work_types: String::new(),
            edit_notes: String::new(),
            edit_field: 0,
        };
        app.reload()?;
        Ok(app)
    }

    // ⟦𓆩𓁪𓋻𓆚⟧ reload :: auto-generated pointer for public function reload
    pub fn reload(&mut self) -> Result<()> {
        match self.screen {
            Screen::Profiles => self.reload_profiles(),
            _ => self.reload_kind(),
        }
    }

    fn reload_kind(&mut self) -> Result<()> {
        let kind = self.screen.kind().unwrap_or(Kind::Skills);
        let (discovered, _) = discover(&self.cfg, kind)?;
        let mut rows = Vec::new();
        for (name, item) in discovered {
            let status = status_for(&self.cfg, self.provider, &item);
            let tags = self.catalog.tags_for(kind, &name);
            rows.push(RowItem {
                name,
                path: item.path.clone(),
                frontmatter_name: item.frontmatter_name.clone(),
                status,
                tags,
                source: item,
            });
        }
        rows.sort_by(|a, b| a.name.cmp(&b.name));
        self.rows = rows;
        self.apply_filter();
        Ok(())
    }

    fn reload_profiles(&mut self) -> Result<()> {
        self.profile_rows = self
            .catalog
            .work_types
            .iter()
            .map(|(name, wt)| ProfileRow {
                name: name.clone(),
                description: wt.description.clone(),
            })
            .collect();
        if self.profile_selected >= self.profile_rows.len() && !self.profile_rows.is_empty() {
            self.profile_selected = self.profile_rows.len() - 1;
        }
        self.bundle_cursor = 0;
        Ok(())
    }

    // ⟦𓋝𓐑𓁟𓁘⟧ apply_filter :: auto-generated pointer for public function apply_filter
    pub fn apply_filter(&mut self) {
        let q = self.filter.to_ascii_lowercase();
        self.filtered = self
            .rows
            .iter()
            .enumerate()
            .filter(|(_, r)| {
                if let Some(sf) = self.status_filter {
                    if r.status != sf {
                        return false;
                    }
                }
                if q.is_empty() {
                    return true;
                }
                r.name.to_ascii_lowercase().contains(&q)
                    || r.frontmatter_name
                        .as_ref()
                        .map(|n| n.to_ascii_lowercase().contains(&q))
                        .unwrap_or(false)
                    || r.tags.iter().any(|t| t.to_ascii_lowercase().contains(&q))
            })
            .map(|(i, _)| i)
            .collect();
        if self.selected >= self.filtered.len() {
            self.selected = self.filtered.len().saturating_sub(1);
        }
        self.clamp_offset(20);
    }

    fn clamp_offset(&mut self, visible: usize) {
        if self.selected < self.list_offset {
            self.list_offset = self.selected;
        } else if self.selected >= self.list_offset + visible {
            self.list_offset = self.selected + 1 - visible;
        }
    }

    // ⟦𓅞𓃔𓏆𓇴⟧ current_row :: auto-generated pointer for public function current_row
    pub fn current_row(&self) -> Option<&RowItem> {
        self.filtered
            .get(self.selected)
            .and_then(|i| self.rows.get(*i))
    }

    // ⟦𓋒𓀮𓀵𓏄⟧ current_profile :: auto-generated pointer for public function current_profile
    pub fn current_profile(&self) -> Option<&ProfileRow> {
        self.profile_rows.get(self.profile_selected)
    }

    /// Bundle lines for right pane of profiles: ("skill", name, status)
    // ⟦𓊊𓃺𓅄𓅸⟧ profile_bundle_lines :: Bundle lines for right pane of profiles: ("skill", name, status)
    pub fn profile_bundle_lines(&self) -> Vec<(Kind, String, InstallStatus)> {
        let Some(pr) = self.current_profile() else {
            return Vec::new();
        };
        let Some(wt) = self.catalog.work_types.get(&pr.name) else {
            return Vec::new();
        };
        let mut out = Vec::new();
        for n in &wt.skills {
            out.push((
                Kind::Skills,
                n.clone(),
                status_by_name(&self.cfg, self.provider, Kind::Skills, n),
            ));
        }
        for n in &wt.agents {
            out.push((
                Kind::Agents,
                n.clone(),
                status_by_name(&self.cfg, self.provider, Kind::Agents, n),
            ));
        }
        for n in &wt.commands {
            out.push((
                Kind::Commands,
                n.clone(),
                status_by_name(&self.cfg, self.provider, Kind::Commands, n),
            ));
        }
        out
    }

    /// Returns true if should quit.
    // ⟦𓍎𓄄𓈡𓃌⟧ handle_key :: Returns true if should quit.
    pub fn handle_key(&mut self, code: KeyCode, mods: KeyModifiers) -> Result<bool> {
        match self.mode {
            Mode::Help => {
                if matches!(code, KeyCode::Esc | KeyCode::Char('?') | KeyCode::Char('q')) {
                    self.mode = Mode::Browse;
                }
                return Ok(false);
            }
            Mode::Filter => {
                match code {
                    KeyCode::Esc => {
                        self.filter.clear();
                        self.apply_filter();
                        self.mode = Mode::Browse;
                    }
                    KeyCode::Enter => {
                        self.mode = Mode::Browse;
                    }
                    KeyCode::Backspace => {
                        self.filter.pop();
                        self.apply_filter();
                    }
                    KeyCode::Char(c) => {
                        self.filter.push(c);
                        self.apply_filter();
                    }
                    _ => {}
                }
                return Ok(false);
            }
            Mode::ConfirmReplace => {
                match code {
                    KeyCode::Char('y') | KeyCode::Char('Y') => {
                        if let Some(idx) = self.pending_replace.take() {
                            self.do_enable(idx, true)?;
                        }
                        self.mode = Mode::Browse;
                    }
                    KeyCode::Char('n') | KeyCode::Char('N') | KeyCode::Esc => {
                        self.pending_replace = None;
                        self.mode = Mode::Browse;
                        self.message = "replace cancelled".into();
                    }
                    _ => {}
                }
                return Ok(false);
            }
            Mode::EditMeta => {
                match code {
                    KeyCode::Esc => {
                        self.mode = Mode::Browse;
                        self.message = "edit discarded".into();
                    }
                    KeyCode::Tab => {
                        self.edit_field = (self.edit_field + 1) % 3;
                    }
                    KeyCode::BackTab => {
                        self.edit_field = (self.edit_field + 2) % 3;
                    }
                    KeyCode::Char('s') if mods.contains(KeyModifiers::CONTROL) => {
                        self.save_edit_meta()?;
                        self.mode = Mode::Browse;
                    }
                    KeyCode::Enter if mods.contains(KeyModifiers::CONTROL) => {
                        self.save_edit_meta()?;
                        self.mode = Mode::Browse;
                    }
                    KeyCode::Char('s') if self.edit_field == 99 => {}
                    KeyCode::Backspace => {
                        let field = self.edit_field_mut();
                        field.pop();
                    }
                    KeyCode::Char(c) if !mods.contains(KeyModifiers::CONTROL) => {
                        self.edit_field_mut().push(c);
                    }
                    // save with 'S' alone when not typing? use F2
                    KeyCode::F(2) => {
                        self.save_edit_meta()?;
                        self.mode = Mode::Browse;
                    }
                    _ => {}
                }
                return Ok(false);
            }
            Mode::Browse => {}
        }

        // Browse mode
        if self.screen == Screen::Profiles {
            return self.handle_profiles_key(code, mods);
        }

        match code {
            KeyCode::Char('q') => return Ok(true),
            KeyCode::Char('?') => {
                self.mode = Mode::Help;
            }
            KeyCode::Char('/') => {
                self.mode = Mode::Filter;
            }
            KeyCode::Char('g') => {
                self.screen = Screen::Profiles;
                self.reload()?;
                self.message = "profiles · A apply set · tab panes".into();
            }
            KeyCode::Tab if !mods.contains(KeyModifiers::SHIFT) => {
                self.screen = self.screen.next();
                self.selected = 0;
                self.list_offset = 0;
                self.reload()?;
            }
            KeyCode::BackTab => {
                self.screen = self.screen.prev();
                self.selected = 0;
                self.list_offset = 0;
                self.reload()?;
            }
            KeyCode::Char('1') => self.set_provider(Provider::Claude)?,
            KeyCode::Char('2') => self.set_provider(Provider::Codex)?,
            KeyCode::Char('3') => self.set_provider(Provider::Grok)?,
            KeyCode::Char('p') => self.cycle_provider()?,
            KeyCode::Down | KeyCode::Char('j') => {
                if !self.filtered.is_empty() {
                    self.selected = (self.selected + 1).min(self.filtered.len() - 1);
                    self.clamp_offset(20);
                }
            }
            KeyCode::Up | KeyCode::Char('k') => {
                self.selected = self.selected.saturating_sub(1);
                self.clamp_offset(20);
            }
            KeyCode::PageDown => {
                if !self.filtered.is_empty() {
                    self.selected = (self.selected + 10).min(self.filtered.len() - 1);
                    self.clamp_offset(20);
                }
            }
            KeyCode::PageUp => {
                self.selected = self.selected.saturating_sub(10);
                self.clamp_offset(20);
            }
            KeyCode::Home => {
                self.selected = 0;
                self.list_offset = 0;
            }
            KeyCode::End | KeyCode::Char('G') => {
                if !self.filtered.is_empty() {
                    self.selected = self.filtered.len() - 1;
                    self.clamp_offset(20);
                }
            }
            KeyCode::Char(' ') => {
                self.toggle_current(false)?;
            }
            KeyCode::Char('r') => {
                self.toggle_current(true)?;
            }
            KeyCode::Char('e') => {
                self.begin_edit_meta();
            }
            KeyCode::Char('R') => {
                self.reload()?;
                self.message = "reloaded".into();
            }
            KeyCode::Char('f') => {
                // cycle status filter
                self.status_filter = match self.status_filter {
                    None => Some(InstallStatus::Enabled),
                    Some(InstallStatus::Enabled) => Some(InstallStatus::Disabled),
                    Some(InstallStatus::Disabled) => Some(InstallStatus::Real),
                    Some(InstallStatus::Real) => Some(InstallStatus::Foreign),
                    Some(InstallStatus::Foreign) => Some(InstallStatus::Broken),
                    Some(InstallStatus::Broken) | Some(InstallStatus::MissingSource) => None,
                };
                self.apply_filter();
                self.message = format!(
                    "status filter: {}",
                    self.status_filter.map(|s| s.as_str()).unwrap_or("all")
                );
            }
            _ => {}
        }
        Ok(false)
    }

    fn handle_profiles_key(&mut self, code: KeyCode, mods: KeyModifiers) -> Result<bool> {
        match code {
            KeyCode::Char('q') => return Ok(true),
            KeyCode::Char('?') => self.mode = Mode::Help,
            KeyCode::Tab => {
                if mods.contains(KeyModifiers::SHIFT) {
                    self.screen = self.screen.prev();
                    self.reload()?;
                } else if self.focus_right {
                    self.focus_right = false;
                } else {
                    self.focus_right = true;
                }
            }
            KeyCode::Char('1') => self.set_provider(Provider::Claude)?,
            KeyCode::Char('2') => self.set_provider(Provider::Codex)?,
            KeyCode::Char('3') => self.set_provider(Provider::Grok)?,
            KeyCode::Char('p') => self.cycle_provider()?,
            KeyCode::Down | KeyCode::Char('j') => {
                if self.focus_right {
                    let n = self.profile_bundle_lines().len();
                    if n > 0 {
                        self.bundle_cursor = (self.bundle_cursor + 1).min(n - 1);
                    }
                } else if !self.profile_rows.is_empty() {
                    self.profile_selected =
                        (self.profile_selected + 1).min(self.profile_rows.len() - 1);
                    self.bundle_cursor = 0;
                }
            }
            KeyCode::Up | KeyCode::Char('k') => {
                if self.focus_right {
                    self.bundle_cursor = self.bundle_cursor.saturating_sub(1);
                } else {
                    self.profile_selected = self.profile_selected.saturating_sub(1);
                    self.bundle_cursor = 0;
                }
            }
            KeyCode::Char('A') | KeyCode::Char('a') => {
                self.apply_profile_set()?;
            }
            KeyCode::Char(' ') => {
                // toggle single bundle line
                let lines = self.profile_bundle_lines();
                if let Some((kind, name, status)) = lines.get(self.bundle_cursor).cloned() {
                    self.toggle_named(kind, &name, status, false)?;
                    // refresh status display
                    self.message = format!("toggled {kind}/{name}");
                }
            }
            KeyCode::Char('g') => {
                self.screen = Screen::Skills;
                self.reload()?;
            }
            KeyCode::BackTab => {
                self.screen = self.screen.prev();
                self.reload()?;
            }
            KeyCode::Char('R') => {
                self.reload()?;
            }
            _ => {}
        }
        Ok(false)
    }

    fn set_provider(&mut self, p: Provider) -> Result<()> {
        if let Some(idx) = self.available_providers.iter().position(|x| *x == p) {
            self.provider = p;
            self.provider_idx = idx;
            self.reload()?;
            self.message = format!("provider: {p}");
        } else {
            self.message = format!("provider {p} not configured");
        }
        Ok(())
    }

    fn cycle_provider(&mut self) -> Result<()> {
        if self.available_providers.is_empty() {
            return Ok(());
        }
        self.provider_idx = (self.provider_idx + 1) % self.available_providers.len();
        self.provider = self.available_providers[self.provider_idx];
        self.reload()?;
        self.message = format!("provider: {}", self.provider);
        Ok(())
    }

    fn toggle_current(&mut self, force_replace: bool) -> Result<()> {
        let Some(fidx) = self.filtered.get(self.selected).copied() else {
            return Ok(());
        };
        let status = self.rows[fidx].status;
        let name = self.rows[fidx].name.clone();
        let kind = self.rows[fidx].source.kind;

        match status {
            InstallStatus::Enabled => {
                let item = self.rows[fidx].source.clone();
                match disable_item(&self.cfg, self.provider, kind, &name, Some(&item), false) {
                    Ok(act) => {
                        self.message = format!("{} {}/{}", act.message, self.provider, name);
                    }
                    Err(e) => self.message = format!("error: {e}"),
                }
            }
            InstallStatus::Disabled | InstallStatus::Broken | InstallStatus::Foreign => {
                self.do_enable(fidx, force_replace)?;
            }
            InstallStatus::Real => {
                if force_replace {
                    self.do_enable(fidx, true)?;
                } else {
                    self.pending_replace = Some(fidx);
                    self.mode = Mode::ConfirmReplace;
                    self.message = "real path — y replace / n cancel".into();
                    return Ok(());
                }
            }
            InstallStatus::MissingSource => {
                self.message = "missing source".into();
            }
        }
        self.reload_kind()?;
        // reselect same name
        if let Some(pos) = self
            .filtered
            .iter()
            .position(|i| self.rows.get(*i).map(|r| r.name.as_str()) == Some(name.as_str()))
        {
            self.selected = pos;
        }
        Ok(())
    }

    fn do_enable(&mut self, row_idx: usize, replace: bool) -> Result<()> {
        let item = self.rows[row_idx].source.clone();
        let name = item.name.clone();
        match enable_item(&self.cfg, self.provider, &item, replace, false) {
            Ok(act) => {
                self.message = format!(
                    "{} {}/{} -> {}",
                    act.message,
                    act.provider,
                    name,
                    act.dest.display()
                );
            }
            Err(e) => self.message = format!("error: {e}"),
        }
        Ok(())
    }

    fn toggle_named(
        &mut self,
        kind: Kind,
        name: &str,
        status: InstallStatus,
        replace: bool,
    ) -> Result<()> {
        let (discovered, _) = discover(&self.cfg, kind)?;
        let Some(item) = discovered.get(name) else {
            self.message = format!("unknown {kind}/{name}");
            return Ok(());
        };
        match status {
            InstallStatus::Enabled => {
                match disable_item(&self.cfg, self.provider, kind, name, Some(item), false) {
                    Ok(act) => self.message = act.message,
                    Err(e) => self.message = format!("error: {e}"),
                }
            }
            InstallStatus::Real if !replace => {
                self.message = format!("{name} is real — use r in list view with replace");
            }
            _ => match enable_item(&self.cfg, self.provider, item, replace, false) {
                Ok(act) => self.message = act.message,
                Err(e) => self.message = format!("error: {e}"),
            },
        }
        Ok(())
    }

    fn apply_profile_set(&mut self) -> Result<()> {
        let Some(pr) = self.current_profile().map(|p| p.name.clone()) else {
            self.message = "no work type selected".into();
            return Ok(());
        };
        let Some(wt) = self.catalog.work_types.get(&pr).cloned() else {
            return Ok(());
        };
        let mut ok = 0usize;
        let mut err = 0usize;
        for (kind, names) in [
            (Kind::Skills, &wt.skills),
            (Kind::Agents, &wt.agents),
            (Kind::Commands, &wt.commands),
        ] {
            if self.cfg.kind_dir(self.provider, kind).is_none() {
                continue;
            }
            let (discovered, _) = discover(&self.cfg, kind)?;
            for n in names {
                let Some(item) = discovered.get(n) else {
                    err += 1;
                    continue;
                };
                match enable_item(&self.cfg, self.provider, item, false, false) {
                    Ok(_) => ok += 1,
                    Err(_) => {
                        // try replace? leave as error count
                        err += 1;
                    }
                }
            }
        }
        self.message = format!("apply {pr}: {ok} enabled, {err} skipped/failed");
        Ok(())
    }

    fn begin_edit_meta(&mut self) {
        let Some(row) = self.current_row() else {
            return;
        };
        let kind = row.source.kind;
        let meta = self
            .catalog
            .meta(kind, &row.name)
            .cloned()
            .unwrap_or_default();
        self.edit_tags = meta.tags.join(", ");
        self.edit_work_types = meta.work_types.join(", ");
        self.edit_notes = meta.notes.unwrap_or_default();
        self.edit_field = 0;
        self.mode = Mode::EditMeta;
        self.message = "edit meta · Tab fields · F2 save · Esc cancel".into();
    }

    fn edit_field_mut(&mut self) -> &mut String {
        match self.edit_field {
            0 => &mut self.edit_tags,
            1 => &mut self.edit_work_types,
            _ => &mut self.edit_notes,
        }
    }

    fn save_edit_meta(&mut self) -> Result<()> {
        let Some(row) = self.current_row() else {
            return Ok(());
        };
        let kind = row.source.kind;
        let name = row.name.clone();
        let tags: Vec<String> = split_csv(&self.edit_tags);
        let work_types: Vec<String> = split_csv(&self.edit_work_types);
        let notes = {
            let n = self.edit_notes.trim();
            if n.is_empty() {
                None
            } else {
                Some(n.to_string())
            }
        };
        let meta = self.catalog.meta_mut(kind, &name);
        meta.tags = tags;
        meta.work_types = work_types;
        meta.notes = notes;

        if let Some(path) = &self.catalog_path {
            self.catalog.save(path)?;
            self.message = format!("saved catalog {}", path.display());
        } else {
            self.message = "catalog path unset — meta kept in memory only".into();
        }
        self.reload_kind()?;
        Ok(())
    }

    // ⟦𓎜𓋼𓄻𓉺⟧ counts :: auto-generated pointer for public function counts
    pub fn counts(&self) -> (usize, usize, usize, usize) {
        let mut en = 0;
        let mut dis = 0;
        let mut real = 0;
        let mut broken = 0;
        for r in &self.rows {
            match r.status {
                InstallStatus::Enabled => en += 1,
                InstallStatus::Disabled => dis += 1,
                InstallStatus::Real => real += 1,
                InstallStatus::Broken | InstallStatus::MissingSource => broken += 1,
                _ => {}
            }
        }
        (en, dis, real, broken)
    }

    // ⟦𓊻𓇟𓏄𓎜⟧ context_totals :: auto-generated pointer for public function context_totals
    pub fn context_totals(&self) -> (usize, usize, Option<usize>) {
        let rows: Vec<_> = self
            .rows
            .iter()
            .map(|row| (row.status, &row.source))
            .collect();
        let (bytes, chars) = active_frontmatter_totals(&rows);
        let codex_chars = (self.provider == Provider::Codex
            && self.screen.kind() == Some(Kind::Skills))
        .then(|| {
            self.rows
                .iter()
                .filter(|row| is_active_status(row.status))
                .map(|row| codex_item_rendered_chars(&row.source))
                .sum()
        });
        (bytes, chars, codex_chars)
    }
}

fn split_csv(s: &str) -> Vec<String> {
    s.split(',')
        .map(|x| x.trim().to_string())
        .filter(|x| !x.is_empty())
        .collect()
}

fn status_for(cfg: &AppConfig, provider: Provider, item: &SourceItem) -> InstallStatus {
    let Some(kind_dir) = cfg.kind_dir(provider, item.kind) else {
        return InstallStatus::Disabled;
    };
    let dest = item.dest_path(&kind_dir);
    classify(cfg, item.kind, &dest, Some(&item.path))
}

fn status_by_name(cfg: &AppConfig, provider: Provider, kind: Kind, name: &str) -> InstallStatus {
    let Ok((items, _)) = discover(cfg, kind) else {
        return InstallStatus::MissingSource;
    };
    let Some(item) = items.get(name) else {
        return InstallStatus::MissingSource;
    };
    status_for(cfg, provider, item)
}
