// theme.rs — Terminal theme system (OSC palette recoloring)
//
// Ports lib/render.sh (theme section) and lib/theme.sh to Rust.
// Standalone module — no references to other crate modules.

use std::fs;
use std::io::Write;
use std::path::PathBuf;

// ============================================================================
// Theme data: 19 hex values per theme
// Index layout: [bg, fg, cursor, color0..color15]
// ============================================================================

/// Each entry is (name, &[bg, fg, cursor, c0..c15]).
pub const BUILTIN_THEMES: &[(&str, &[&str; 19])] = &[
    // --- Editor Dark ---
    ("catppuccin", &[
        "#1E1E2E", "#CDD6F4", "#F5E0DC",
        "#45475A", "#F38BA8", "#A6E3A1", "#F9E2AF",
        "#89B4FA", "#F5C2E7", "#94E2D5", "#BAC2DE",
        "#585B70", "#F38BA8", "#A6E3A1", "#F9E2AF",
        "#89B4FA", "#F5C2E7", "#94E2D5", "#A6ADC8",
    ]),
    ("catppuccin-latte", &[
        "#EFF1F5", "#4C4F69", "#DC8A78",
        "#BCC0CC", "#D20F39", "#40A02B", "#DF8E1D",
        "#1E66F5", "#EA76CB", "#179299", "#5C5F77",
        "#ACB0BE", "#D20F39", "#40A02B", "#DF8E1D",
        "#1E66F5", "#EA76CB", "#179299", "#6C6F85",
    ]),
    ("catppuccin-frappe", &[
        "#303446", "#C6D0F5", "#F2D5CF",
        "#292C3C", "#E78284", "#A6D189", "#E5C890",
        "#8CAAEE", "#F4B8E4", "#81C8BE", "#B5BFE2",
        "#414559", "#E78284", "#A6D189", "#E5C890",
        "#8CAAEE", "#F4B8E4", "#81C8BE", "#A5ADCE",
    ]),
    ("catppuccin-macchiato", &[
        "#24273A", "#CAD3F5", "#F4DBD6",
        "#1E2030", "#ED8796", "#A6DA95", "#EED49F",
        "#8AADF4", "#F5BDE6", "#8BD5CA", "#B8C0E0",
        "#494D64", "#ED8796", "#A6DA95", "#EED49F",
        "#8AADF4", "#F5BDE6", "#8BD5CA", "#A5ADCB",
    ]),
    ("dracula", &[
        "#282A36", "#F8F8F2", "#F8F8F2",
        "#21222C", "#FF5555", "#50FA7B", "#F1FA8C",
        "#BD93F9", "#FF79C6", "#8BE9FD", "#F8F8F2",
        "#6272A4", "#FF6E6E", "#69FF94", "#FFFFA5",
        "#D6ACFF", "#FF92DF", "#A4FFFF", "#FFFFFF",
    ]),
    ("nord", &[
        "#2E3440", "#D8DEE9", "#D8DEE9",
        "#3B4252", "#BF616A", "#A3BE8C", "#EBCB8B",
        "#81A1C1", "#B48EAD", "#88C0D0", "#E5E9F0",
        "#4C566A", "#BF616A", "#A3BE8C", "#EBCB8B",
        "#81A1C1", "#B48EAD", "#8FBCBB", "#ECEFF4",
    ]),
    ("nord-light", &[
        "#ECEFF4", "#2E3440", "#4C566A",
        "#D8DEE9", "#BF616A", "#A3BE8C", "#EBCB8B",
        "#5E81AC", "#B48EAD", "#88C0D0", "#3B4252",
        "#E5E9F0", "#BF616A", "#A3BE8C", "#EBCB8B",
        "#5E81AC", "#B48EAD", "#8FBCBB", "#2E3440",
    ]),
    ("tokyo-night", &[
        "#1A1B26", "#C0CAF5", "#C0CAF5",
        "#15161E", "#F7768E", "#9ECE6A", "#E0AF68",
        "#7AA2F7", "#BB9AF7", "#7DCFFF", "#A9B1D6",
        "#414868", "#F7768E", "#9ECE6A", "#E0AF68",
        "#7AA2F7", "#BB9AF7", "#7DCFFF", "#C0CAF5",
    ]),
    ("tokyo-night-light", &[
        "#D5D6DB", "#343B59", "#343B59",
        "#C4C5CB", "#8C4351", "#33635C", "#8F5E15",
        "#34548A", "#5A4A78", "#0F4B6E", "#343B59",
        "#9699A3", "#8C4351", "#33635C", "#8F5E15",
        "#34548A", "#5A4A78", "#0F4B6E", "#343B59",
    ]),
    ("gruvbox", &[
        "#282828", "#EBDBB2", "#EBDBB2",
        "#282828", "#CC241D", "#98971A", "#D79921",
        "#458588", "#B16286", "#689D6A", "#A89984",
        "#928374", "#FB4934", "#B8BB26", "#FABD2F",
        "#83A598", "#D3869B", "#8EC07C", "#EBDBB2",
    ]),
    ("gruvbox-light", &[
        "#FBF1C7", "#3C3836", "#3C3836",
        "#FBF1C7", "#CC241D", "#98971A", "#D79921",
        "#458588", "#B16286", "#689D6A", "#7C6F64",
        "#928374", "#9D0006", "#79740E", "#B57614",
        "#076678", "#8F3F71", "#427B58", "#3C3836",
    ]),
    ("solarized-dark", &[
        "#002B36", "#839496", "#839496",
        "#073642", "#DC322F", "#859900", "#B58900",
        "#268BD2", "#D33682", "#2AA198", "#EEE8D5",
        "#002B36", "#CB4B16", "#586E75", "#657B83",
        "#839496", "#6C71C4", "#93A1A1", "#FDF6E3",
    ]),
    ("solarized-light", &[
        "#FDF6E3", "#657B83", "#657B83",
        "#EEE8D5", "#DC322F", "#859900", "#B58900",
        "#268BD2", "#D33682", "#2AA198", "#073642",
        "#FDF6E3", "#CB4B16", "#93A1A1", "#839496",
        "#657B83", "#6C71C4", "#586E75", "#002B36",
    ]),
    ("monokai", &[
        "#272822", "#F8F8F2", "#F8F8F0",
        "#272822", "#F92672", "#A6E22E", "#F4BF75",
        "#66D9EF", "#AE81FF", "#A1EFE4", "#F8F8F2",
        "#75715E", "#F92672", "#A6E22E", "#F4BF75",
        "#66D9EF", "#AE81FF", "#A1EFE4", "#F9F8F5",
    ]),
    ("one-dark", &[
        "#282C34", "#ABB2BF", "#528BFF",
        "#282C34", "#E06C75", "#98C379", "#E5C07B",
        "#61AFEF", "#C678DD", "#56B6C2", "#ABB2BF",
        "#545862", "#E06C75", "#98C379", "#E5C07B",
        "#61AFEF", "#C678DD", "#56B6C2", "#C8CCD4",
    ]),
    ("one-light", &[
        "#FAFAFA", "#383A42", "#526FFF",
        "#F0F0F0", "#E45649", "#50A14F", "#C18401",
        "#4078F2", "#A626A4", "#0184BC", "#383A42",
        "#A0A1A7", "#E45649", "#50A14F", "#C18401",
        "#4078F2", "#A626A4", "#0184BC", "#383A42",
    ]),
    ("rose-pine", &[
        "#191724", "#E0DEF4", "#524F67",
        "#26233A", "#EB6F92", "#31748F", "#F6C177",
        "#9CCFD8", "#C4A7E7", "#EBBCBA", "#E0DEF4",
        "#6E6A86", "#EB6F92", "#31748F", "#F6C177",
        "#9CCFD8", "#C4A7E7", "#EBBCBA", "#E0DEF4",
    ]),
    ("rose-pine-moon", &[
        "#232136", "#E0DEF4", "#59546D",
        "#2A273F", "#EB6F92", "#3E8FB0", "#F6C177",
        "#9CCFD8", "#C4A7E7", "#EA9A97", "#E0DEF4",
        "#6E6A86", "#EB6F92", "#3E8FB0", "#F6C177",
        "#9CCFD8", "#C4A7E7", "#EA9A97", "#E0DEF4",
    ]),
    ("rose-pine-dawn", &[
        "#FAF4ED", "#575279", "#286983",
        "#F2E9E1", "#B4637A", "#56949F", "#EA9D34",
        "#286983", "#907AA9", "#D7827E", "#575279",
        "#9893A5", "#B4637A", "#56949F", "#EA9D34",
        "#286983", "#907AA9", "#D7827E", "#575279",
    ]),
    ("kanagawa", &[
        "#1F1F28", "#DCD7BA", "#C8C093",
        "#16161D", "#C34043", "#76946A", "#C0A36E",
        "#7E9CD8", "#957FB8", "#6A9589", "#C8C093",
        "#727169", "#E82424", "#98BB6C", "#E6C384",
        "#7FB4CA", "#938AA9", "#7AA89F", "#DCD7BA",
    ]),
    ("kanagawa-lotus", &[
        "#F2ECBC", "#545464", "#43436C",
        "#E7DBA0", "#C84053", "#6F894E", "#77713F",
        "#4D699B", "#624C83", "#597B75", "#545464",
        "#8A8980", "#E82424", "#98BB6C", "#E6C384",
        "#7FB4CA", "#938AA9", "#7AA89F", "#545464",
    ]),
    ("everforest-dark", &[
        "#2D353B", "#D3C6AA", "#D3C6AA",
        "#343F44", "#E67E80", "#A7C080", "#DBBC7F",
        "#7FBBB3", "#D699B6", "#83C092", "#D3C6AA",
        "#475258", "#E67E80", "#A7C080", "#DBBC7F",
        "#7FBBB3", "#D699B6", "#83C092", "#D3C6AA",
    ]),
    ("everforest-light", &[
        "#FDF6E3", "#5C6A72", "#5C6A72",
        "#F3EAD3", "#F85552", "#8DA101", "#DFA000",
        "#3A94C5", "#DF69BA", "#35A77C", "#5C6A72",
        "#E0DCC7", "#F85552", "#8DA101", "#DFA000",
        "#3A94C5", "#DF69BA", "#35A77C", "#5C6A72",
    ]),
    ("github-dark", &[
        "#0D1117", "#C9D1D9", "#C9D1D9",
        "#161B22", "#FF7B72", "#7EE787", "#D29922",
        "#79C0FF", "#D2A8FF", "#A5D6FF", "#C9D1D9",
        "#21262D", "#FFA198", "#56D364", "#E3B341",
        "#79C0FF", "#D2A8FF", "#A5D6FF", "#F0F6FC",
    ]),
    ("github-light", &[
        "#FFFFFF", "#24292F", "#0969DA",
        "#F6F8FA", "#CF222E", "#116329", "#4D2D00",
        "#0550AE", "#8250DF", "#1B7C83", "#24292F",
        "#D0D7DE", "#A40E26", "#1A7F37", "#633C01",
        "#0969DA", "#8250DF", "#2AA198", "#24292F",
    ]),
    ("ayu-dark", &[
        "#0B0E14", "#BFBDB6", "#E6B450",
        "#11151C", "#F07178", "#AAD94C", "#E6B450",
        "#399EE6", "#D2A6FF", "#95E6CB", "#BFBDB6",
        "#636A72", "#FF8F40", "#AAD94C", "#FFB454",
        "#59C2FF", "#D2A6FF", "#95E6CB", "#C5C5C5",
    ]),
    ("ayu-light", &[
        "#FAFAFA", "#5C6166", "#FF9940",
        "#F0F0F0", "#F07178", "#86B300", "#F29718",
        "#36A3D9", "#A37ACC", "#4CBF99", "#5C6166",
        "#E7E8E9", "#FF3333", "#86B300", "#F29718",
        "#36A3D9", "#A37ACC", "#4CBF99", "#5C6166",
    ]),
    ("ayu-mirage", &[
        "#1F2430", "#CBCCC6", "#FFCC66",
        "#232834", "#F28779", "#BAE67E", "#FFD580",
        "#73D0FF", "#D4BFFF", "#95E6CB", "#CBCCC6",
        "#707A8C", "#FF3333", "#BAE67E", "#FFD580",
        "#73D0FF", "#D4BFFF", "#95E6CB", "#F3F4F5",
    ]),
    ("material-dark", &[
        "#263238", "#EEFFFF", "#FFCC00",
        "#2C3B41", "#FF5370", "#C3E88D", "#FFCB6B",
        "#82AAFF", "#C792EA", "#89DDFF", "#EEFFFF",
        "#37474F", "#FF5370", "#C3E88D", "#FFCB6B",
        "#82AAFF", "#C792EA", "#89DDFF", "#FFFFFF",
    ]),
    ("material-light", &[
        "#FAFAFA", "#546E7A", "#272727",
        "#F2F2F2", "#FF5370", "#91B859", "#FFB62C",
        "#6182B8", "#7C4DFF", "#39ADB5", "#546E7A",
        "#E7E7E8", "#E53935", "#91B859", "#F6A434",
        "#6182B8", "#7C4DFF", "#39ADB5", "#272727",
    ]),
    ("papercolor-light", &[
        "#EEEEEE", "#444444", "#444444",
        "#E4E4E4", "#AF0000", "#008700", "#D75F00",
        "#005FAF", "#AF00AF", "#005F87", "#444444",
        "#BCBCBC", "#D70000", "#5FAF00", "#D78700",
        "#0087AF", "#D787D7", "#00AFAF", "#005F87",
    ]),
    ("pencil-light", &[
        "#F1F1F1", "#424242", "#20BBFC",
        "#E0E0E0", "#C30771", "#10A778", "#A89C14",
        "#008EC4", "#523C79", "#20A5BA", "#424242",
        "#B8B8B8", "#E32791", "#5FD7A7", "#F3E430",
        "#20BBFC", "#6855DE", "#4FB8CC", "#212121",
    ]),
    ("alabaster", &[
        "#F7F7F7", "#434343", "#007ACC",
        "#ECECEC", "#AA3731", "#448C27", "#CB9000",
        "#325CC0", "#7A3E9D", "#0083B2", "#434343",
        "#DCDCDC", "#D91A1A", "#448C27", "#CB9000",
        "#325CC0", "#7A3E9D", "#0083B2", "#434343",
    ]),

    // --- Chromatic Dark ---
    ("amethyst", &[
        "#2A1B3D", "#D8D0E8", "#E8C050",
        "#1E1030", "#E06070", "#80C070", "#E8C050",
        "#8080D0", "#D070B0", "#60B0B8", "#D0C8E0",
        "#382850", "#F07080", "#90D080", "#F0D060",
        "#9090E0", "#E080C0", "#70C0C8", "#E0D8F0",
    ]),
    ("cobalt", &[
        "#0D1B30", "#C8D8E8", "#E8A030",
        "#081420", "#E06060", "#60C080", "#E8A030",
        "#5090D0", "#B070C0", "#50B0C0", "#C0D0E0",
        "#1A2840", "#F07070", "#70D090", "#F0B040",
        "#60A0E0", "#C080D0", "#60C0D0", "#D8E0F0",
    ]),
    ("merlot", &[
        "#2E1018", "#E8D0D0", "#50C0A0",
        "#200810", "#E05050", "#50C0A0", "#D8A050",
        "#7090C0", "#C060A0", "#40B0A0", "#E0D0D0",
        "#401828", "#F06060", "#60D0B0", "#E8B060",
        "#80A0D0", "#D070B0", "#50C0B0", "#F0E0E0",
    ]),
    ("emerald", &[
        "#0C2818", "#C0D8C0", "#E07080",
        "#061A0F", "#E07080", "#60C060", "#C0B050",
        "#5090B0", "#B070A0", "#50B098", "#B8D0B8",
        "#183820", "#F08090", "#70D070", "#D0C060",
        "#60A0C0", "#C080B0", "#60C0A8", "#D0E8D0",
    ]),
    ("copper", &[
        "#2C1808", "#E8D8C0", "#5098D0",
        "#1A1005", "#E06040", "#90B060", "#D8A040",
        "#5098D0", "#C070A0", "#50A8B8", "#E0D0B8",
        "#402818", "#F07050", "#A0C070", "#E8B050",
        "#60A8E0", "#D080B0", "#60B8C8", "#F0E8D0",
    ]),
    ("indigo-night", &[
        "#181038", "#C8C0E0", "#E88060",
        "#100828", "#E88060", "#A0C050", "#E0B040",
        "#7080D0", "#C068C0", "#60A8C0", "#C0B8D8",
        "#281848", "#F89070", "#B0D060", "#F0C050",
        "#8090E0", "#D078D0", "#70B8D0", "#D8D0F0",
    ]),
    ("plum", &[
        "#281028", "#D8C0D8", "#B0D050",
        "#1C081C", "#E06080", "#B0D050", "#D0A840",
        "#8080C0", "#D060C0", "#60B0A0", "#D0B8D0",
        "#381838", "#F070A0", "#C0E060", "#E0B850",
        "#9090D0", "#E070D0", "#70C0B0", "#E8D0E8",
    ]),
    ("tundra", &[
        "#0C2028", "#C0D8E0", "#70C0D0",
        "#081820", "#D06868", "#60C0A0", "#C0B060",
        "#5898C0", "#A078B0", "#70C0D0", "#B8D0D8",
        "#183038", "#E07878", "#70D0B0", "#D0C070",
        "#68A8D0", "#B088C0", "#80D0E0", "#D0E8F0",
    ]),
    ("mahogany", &[
        "#2E1510", "#E8D8C8", "#D08050",
        "#200E08", "#D85040", "#90A860", "#D08050",
        "#7090B0", "#C06090", "#60A090", "#E0D0C0",
        "#402820", "#E86050", "#A0B870", "#E09060",
        "#80A0C0", "#D070A0", "#70B0A0", "#F0E0D0",
    ]),
    ("olive-dusk", &[
        "#1A2010", "#D0D8B8", "#C0B060",
        "#101808", "#D06860", "#80B050", "#C0B060",
        "#6090B0", "#A878A0", "#60A890", "#C8D0B0",
        "#283018", "#E07870", "#90C060", "#D0C070",
        "#70A0C0", "#B888B0", "#70B8A0", "#E0E8C8",
    ]),
    ("storm", &[
        "#2E3848", "#D0D8E0", "#E8B050",
        "#202830", "#E06868", "#70C080", "#E8B050",
        "#6098D0", "#B078C0", "#60B0C0", "#C8D0D8",
        "#3E4858", "#F07878", "#80D090", "#F0C060",
        "#70A8E0", "#C088D0", "#70C0D0", "#E0E8F0",
    ]),
    ("volcanic", &[
        "#281818", "#E0D0C0", "#E06040",
        "#1A1010", "#E06040", "#90A860", "#D0A040",
        "#7090B8", "#C06890", "#60A898", "#D8C8B8",
        "#382828", "#F07050", "#A0B870", "#E0B050",
        "#80A0C8", "#D078A0", "#70B8A8", "#F0E0D0",
    ]),

    // --- Chromatic Light ---
    ("terracotta", &[
        "#F2E0D0", "#4A3020", "#1A8080",
        "#E0D0C0", "#B83030", "#1A8080", "#A07010",
        "#3060A0", "#883880", "#107070", "#4A3020",
        "#D0C0B0", "#D04040", "#209090", "#B08020",
        "#4070B0", "#984890", "#208080", "#3A2010",
    ]),
    ("sage-mist", &[
        "#E4EDD8", "#2A3820", "#904880",
        "#D4DCC8", "#A83030", "#307030", "#887020",
        "#3060A0", "#904880", "#207868", "#2A3820",
        "#C4D0B8", "#C04040", "#408040", "#988030",
        "#4070B0", "#A05890", "#308878", "#1A2810",
    ]),
    ("lavender-mist", &[
        "#EAE0F2", "#302840", "#B89020",
        "#DAD0E2", "#A83040", "#408030", "#B89020",
        "#4060B0", "#804090", "#207888", "#302840",
        "#C8C0D8", "#C04050", "#509040", "#C8A030",
        "#5070C0", "#9050A0", "#308898", "#201830",
    ]),
    ("coral-sand", &[
        "#F5E2D8", "#3A2820", "#206898",
        "#E4D0C8", "#B03030", "#308868", "#A07818",
        "#206898", "#883880", "#1A7878", "#3A2820",
        "#D4C0B8", "#C84040", "#409878", "#B08828",
        "#3078A8", "#984890", "#2A8888", "#2A1810",
    ]),
    ("arctic", &[
        "#E2ECF5", "#1A2840", "#C05040",
        "#D2DCE4", "#C05040", "#308860", "#A08020",
        "#2860A0", "#804090", "#187880", "#1A2840",
        "#C0D0E0", "#D06050", "#409870", "#B09030",
        "#3870B0", "#9050A0", "#288890", "#0A1830",
    ]),
    ("seafoam", &[
        "#E0F0E8", "#1A3028", "#B84060",
        "#D0E0D8", "#B84060", "#208860", "#888820",
        "#3068A0", "#884088", "#107868", "#1A3028",
        "#C0D4CC", "#C85070", "#309870", "#989830",
        "#4078B0", "#985098", "#208878", "#0A2018",
    ]),
    ("champagne", &[
        "#F5EDE2", "#302818", "#2858A8",
        "#E4DCD0", "#B03030", "#408838", "#A07818",
        "#2858A8", "#883088", "#187078", "#302818",
        "#D0C8B8", "#C84040", "#509848", "#B08828",
        "#3868B8", "#984098", "#288088", "#201808",
    ]),
    ("blush", &[
        "#F5E5E8", "#382030", "#208858",
        "#E4D4D8", "#B03040", "#208858", "#907820",
        "#3060A0", "#883880", "#187870", "#382030",
        "#D4C4C8", "#C84050", "#309868", "#A08830",
        "#4070B0", "#984890", "#288880", "#281020",
    ]),

    // --- Semantic ---
    ("danger", &[
        "#2C0B0E", "#FFCCCC", "#FF6666",
        "#1A0608", "#FF4444", "#CC6666", "#FFAA66",
        "#CC8888", "#FF6688", "#CC9999", "#FFCCCC",
        "#663333", "#FF6666", "#DD8888", "#FFBB88",
        "#DDAAAA", "#FF88AA", "#DDBBBB", "#FFE0E0",
    ]),
    ("safe", &[
        "#0B2B1A", "#CCFFCC", "#66FF66",
        "#061A0F", "#66CC66", "#44FF44", "#AAFF66",
        "#66CCAA", "#88CC66", "#44DDAA", "#CCFFCC",
        "#336633", "#88DD88", "#66FF66", "#CCFF88",
        "#88DDCC", "#AADD88", "#66FFCC", "#E0FFE0",
    ]),
    ("ocean", &[
        "#0A1628", "#B0C4DE", "#87CEEB",
        "#051020", "#CD5C5C", "#66CDAA", "#F0E68C",
        "#6495ED", "#9370DB", "#48D1CC", "#B0C4DE",
        "#2F4F6F", "#E07070", "#7CE0BE", "#F5EEA0",
        "#7CAAF0", "#A888E0", "#5CE0D8", "#D0E0F0",
    ]),
    ("ocean-light", &[
        "#F0F5FA", "#1A3A5C", "#2E6B9E",
        "#E0EAF2", "#C04040", "#2E8B57", "#B8860B",
        "#2E6B9E", "#7B68AE", "#1A8A8A", "#1A3A5C",
        "#CADAE8", "#D04040", "#358B5B", "#C89020",
        "#3878B0", "#8878BE", "#2A9A9A", "#0D2040",
    ]),
    ("forest", &[
        "#0B2B1A", "#A8C8A8", "#8FBC8F",
        "#061A0F", "#CD6060", "#6B8E23", "#BDB76B",
        "#5F9EA0", "#8B7B8B", "#66CDAA", "#A8C8A8",
        "#2E5E3E", "#D87070", "#7BA833", "#CDC87B",
        "#6FB8B0", "#9B8B9B", "#76DDBA", "#C0E0C0",
    ]),
    ("forest-light", &[
        "#F4F8F0", "#2B4020", "#4A7030",
        "#E8F0E0", "#B04040", "#3A7A20", "#9A8020",
        "#4070A0", "#7A5A90", "#2A8A6A", "#2B4020",
        "#D0DCC8", "#C05050", "#4A8A30", "#AA9030",
        "#5080B0", "#8A6AA0", "#3A9A7A", "#1A2A10",
    ]),
    ("sunset", &[
        "#2C1810", "#F0D0B0", "#E8A060",
        "#1A0E0A", "#E06040", "#B8A040", "#F0C060",
        "#C08060", "#D06080", "#C0A080", "#F0D0B0",
        "#604030", "#F07050", "#C8B050", "#F0D070",
        "#D09070", "#E07090", "#D0B090", "#F8E0C8",
    ]),
    ("dawn", &[
        "#FAF5F0", "#5C4A3A", "#D09050",
        "#F0E8E0", "#C05040", "#6A8A40", "#C09030",
        "#4A70A0", "#8A5A90", "#3A8A7A", "#5C4A3A",
        "#E0D8D0", "#D06050", "#7A9A50", "#D0A040",
        "#5A80B0", "#9A6AA0", "#4A9A8A", "#3A2A1A",
    ]),
    ("ivory", &[
        "#FFFFF0", "#3A3A30", "#8A7A60",
        "#F5F5E8", "#B84040", "#5A8A30", "#A08A20",
        "#4A6AA0", "#7A5090", "#2A7A70", "#3A3A30",
        "#E8E8D8", "#C85050", "#6A9A40", "#B09A30",
        "#5A7AB0", "#8A60A0", "#3A8A80", "#1A1A10",
    ]),
    ("slate", &[
        "#1E2832", "#C0C8D0", "#88A0B8",
        "#283440", "#E07070", "#80B880", "#D0B870",
        "#70A0D0", "#A080C0", "#60B0B0", "#C0C8D0",
        "#384858", "#F08080", "#90C890", "#E0C880",
        "#80B0E0", "#B090D0", "#70C0C0", "#E0E8F0",
    ]),
];

/// Theme aliases: (alias_name, canonical_name)
const THEME_ALIASES: &[(&str, &str)] = &[
    ("catppuccin-mocha", "catppuccin"),
    ("gruvbox-dark", "gruvbox"),
    ("production", "danger"),
    ("development", "safe"),
];

/// Theme category metadata for `theme_list()`.
pub struct ThemeCategory {
    pub label: &'static str,
    pub kind: &'static str,   // "editor", "chromatic", "semantic"
    pub variant: &'static str, // "dark", "light"
}

/// Map each built-in theme to its category. Order matches BUILTIN_THEMES.
pub const THEME_META: &[ThemeCategory] = &[
    // Editor Dark
    ThemeCategory { label: "catppuccin",          kind: "editor",    variant: "dark" },
    ThemeCategory { label: "catppuccin-latte",    kind: "editor",    variant: "light" },
    ThemeCategory { label: "catppuccin-frappe",   kind: "editor",    variant: "dark" },
    ThemeCategory { label: "catppuccin-macchiato",kind: "editor",    variant: "dark" },
    ThemeCategory { label: "dracula",             kind: "editor",    variant: "dark" },
    ThemeCategory { label: "nord",                kind: "editor",    variant: "dark" },
    ThemeCategory { label: "nord-light",          kind: "editor",    variant: "light" },
    ThemeCategory { label: "tokyo-night",         kind: "editor",    variant: "dark" },
    ThemeCategory { label: "tokyo-night-light",   kind: "editor",    variant: "light" },
    ThemeCategory { label: "gruvbox",             kind: "editor",    variant: "dark" },
    ThemeCategory { label: "gruvbox-light",       kind: "editor",    variant: "light" },
    ThemeCategory { label: "solarized-dark",      kind: "editor",    variant: "dark" },
    ThemeCategory { label: "solarized-light",     kind: "editor",    variant: "light" },
    ThemeCategory { label: "monokai",             kind: "editor",    variant: "dark" },
    ThemeCategory { label: "one-dark",            kind: "editor",    variant: "dark" },
    ThemeCategory { label: "one-light",           kind: "editor",    variant: "light" },
    ThemeCategory { label: "rose-pine",           kind: "editor",    variant: "dark" },
    ThemeCategory { label: "rose-pine-moon",      kind: "editor",    variant: "dark" },
    ThemeCategory { label: "rose-pine-dawn",      kind: "editor",    variant: "light" },
    ThemeCategory { label: "kanagawa",            kind: "editor",    variant: "dark" },
    ThemeCategory { label: "kanagawa-lotus",      kind: "editor",    variant: "light" },
    ThemeCategory { label: "everforest-dark",     kind: "editor",    variant: "dark" },
    ThemeCategory { label: "everforest-light",    kind: "editor",    variant: "light" },
    ThemeCategory { label: "github-dark",         kind: "editor",    variant: "dark" },
    ThemeCategory { label: "github-light",        kind: "editor",    variant: "light" },
    ThemeCategory { label: "ayu-dark",            kind: "editor",    variant: "dark" },
    ThemeCategory { label: "ayu-light",           kind: "editor",    variant: "light" },
    ThemeCategory { label: "ayu-mirage",          kind: "editor",    variant: "dark" },
    ThemeCategory { label: "material-dark",       kind: "editor",    variant: "dark" },
    ThemeCategory { label: "material-light",      kind: "editor",    variant: "light" },
    ThemeCategory { label: "papercolor-light",    kind: "editor",    variant: "light" },
    ThemeCategory { label: "pencil-light",        kind: "editor",    variant: "light" },
    ThemeCategory { label: "alabaster",           kind: "editor",    variant: "light" },
    // Chromatic Dark
    ThemeCategory { label: "amethyst",            kind: "chromatic", variant: "dark" },
    ThemeCategory { label: "cobalt",              kind: "chromatic", variant: "dark" },
    ThemeCategory { label: "merlot",              kind: "chromatic", variant: "dark" },
    ThemeCategory { label: "emerald",             kind: "chromatic", variant: "dark" },
    ThemeCategory { label: "copper",              kind: "chromatic", variant: "dark" },
    ThemeCategory { label: "indigo-night",        kind: "chromatic", variant: "dark" },
    ThemeCategory { label: "plum",                kind: "chromatic", variant: "dark" },
    ThemeCategory { label: "tundra",              kind: "chromatic", variant: "dark" },
    ThemeCategory { label: "mahogany",            kind: "chromatic", variant: "dark" },
    ThemeCategory { label: "olive-dusk",          kind: "chromatic", variant: "dark" },
    ThemeCategory { label: "storm",               kind: "chromatic", variant: "dark" },
    ThemeCategory { label: "volcanic",            kind: "chromatic", variant: "dark" },
    // Chromatic Light
    ThemeCategory { label: "terracotta",          kind: "chromatic", variant: "light" },
    ThemeCategory { label: "sage-mist",           kind: "chromatic", variant: "light" },
    ThemeCategory { label: "lavender-mist",       kind: "chromatic", variant: "light" },
    ThemeCategory { label: "coral-sand",          kind: "chromatic", variant: "light" },
    ThemeCategory { label: "arctic",              kind: "chromatic", variant: "light" },
    ThemeCategory { label: "seafoam",             kind: "chromatic", variant: "light" },
    ThemeCategory { label: "champagne",           kind: "chromatic", variant: "light" },
    ThemeCategory { label: "blush",               kind: "chromatic", variant: "light" },
    // Semantic
    ThemeCategory { label: "danger",              kind: "semantic",  variant: "dark" },
    ThemeCategory { label: "safe",                kind: "semantic",  variant: "dark" },
    ThemeCategory { label: "ocean",               kind: "semantic",  variant: "dark" },
    ThemeCategory { label: "ocean-light",         kind: "semantic",  variant: "light" },
    ThemeCategory { label: "forest",              kind: "semantic",  variant: "dark" },
    ThemeCategory { label: "forest-light",        kind: "semantic",  variant: "light" },
    ThemeCategory { label: "sunset",              kind: "semantic",  variant: "dark" },
    ThemeCategory { label: "dawn",                kind: "semantic",  variant: "light" },
    ThemeCategory { label: "ivory",               kind: "semantic",  variant: "light" },
    ThemeCategory { label: "slate",               kind: "semantic",  variant: "dark" },
];

// ============================================================================
// TTY output helper
// ============================================================================

/// Open /dev/tty for writing, falling back to stdout.
fn open_tty() -> Box<dyn Write> {
    match std::fs::OpenOptions::new().write(true).open("/dev/tty") {
        Ok(f) => Box::new(f),
        Err(_) => Box::new(std::io::stdout()),
    }
}

/// Write a format string to /dev/tty (or stdout fallback).
macro_rules! tty_write {
    ($tty:expr, $($arg:tt)*) => {
        let _ = write!($tty, $($arg)*);
    };
}

// ============================================================================
// Public API
// ============================================================================

/// Emit OSC escape sequences to apply a 19-color theme to the terminal.
///
/// `colors` layout: `[bg, fg, cursor, color0..color15]`
///
/// Sends:
///   - OSC 4;N for palette colors 0-15
///   - OSC 11 for background
///   - OSC 10 for foreground
///   - OSC 12 for cursor
pub fn send_theme(colors: &[&str; 19]) {
    let mut tty = open_tty();
    let bg = colors[0];
    let fg = colors[1];
    let cursor = colors[2];

    // Palette colors 0-15 via OSC 4
    for i in 0..16 {
        tty_write!(tty, "\x1b]4;{};{}\x07", i, colors[3 + i]);
    }

    // Background (OSC 11), Foreground (OSC 10), Cursor (OSC 12)
    tty_write!(tty, "\x1b]11;{}\x07", bg);
    tty_write!(tty, "\x1b]10;{}\x07", fg);
    tty_write!(tty, "\x1b]12;{}\x07", cursor);
}

/// Reset terminal colors to defaults.
///
/// Sends OSC 104 (reset palette), OSC 110 (reset fg), OSC 111 (reset bg),
/// OSC 112 (reset cursor).
pub fn clear_theme() {
    let mut tty = open_tty();
    tty_write!(tty, "\x1b]104\x07");
    tty_write!(tty, "\x1b]110\x07");
    tty_write!(tty, "\x1b]111\x07");
    tty_write!(tty, "\x1b]112\x07");
}

/// Look up and apply a named theme. Checks user themes first, then built-in
/// themes (including aliases).
///
/// Returns `true` if a matching theme was found and applied, `false` otherwise.
pub fn apply_named_theme(name: &str) -> bool {
    // Try user theme first
    if let Some(colors) = load_user_theme(name) {
        let refs: [&str; 19] = std::array::from_fn(|i| colors[i].as_str());
        send_theme(&refs);
        return true;
    }

    // Resolve alias
    let canonical = resolve_alias(name);

    // Search built-in table
    for (theme_name, colors) in BUILTIN_THEMES {
        if *theme_name == canonical {
            send_theme(colors);
            return true;
        }
    }

    false
}

/// Load a user-defined `.theme` file from `~/.config/tabbing-on/themes/{name}.theme`.
///
/// File format (key=value, one per line, `#` comments):
/// ```text
/// bg=#1E1E2E
/// fg=#CDD6F4
/// cursor=#F5E0DC
/// color0=#45475A
/// ...
/// color15=#A6ADC8
/// ```
///
/// Returns `None` if the file doesn't exist or is missing required `bg`/`fg`.
pub fn load_user_theme(name: &str) -> Option<[String; 19]> {
    let path = theme_dir().join(format!("{}.theme", name));
    let contents = fs::read_to_string(&path).ok()?;

    let mut bg = String::new();
    let mut fg = String::new();
    let mut cursor = String::new();
    let mut palette: [String; 16] = Default::default();

    for line in contents.lines() {
        let line = line.trim();
        // Skip comments and blank lines
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        // Strip inline comments
        let line = line.split('#').next().unwrap_or(line).trim();
        let Some((key, val)) = line.split_once('=') else {
            continue;
        };
        let key = key.trim();
        let val = val.trim().trim_matches(|c| c == '"' || c == '\'');

        match key {
            "bg" | "background" => bg = val.to_string(),
            "fg" | "foreground" => fg = val.to_string(),
            "cursor" => cursor = val.to_string(),
            k if k.starts_with("color") => {
                if let Ok(idx) = k[5..].parse::<usize>() {
                    if idx < 16 {
                        palette[idx] = val.to_string();
                    }
                }
            }
            _ => {}
        }
    }

    // bg and fg are required
    if bg.is_empty() || fg.is_empty() {
        return None;
    }

    // Default cursor to fg if not set
    if cursor.is_empty() {
        cursor = fg.clone();
    }

    // Default unset palette entries
    for i in 0..16 {
        if palette[i].is_empty() {
            palette[i] = if i == 0 || i == 8 {
                bg.clone()
            } else {
                fg.clone()
            };
        }
    }

    // Build the 19-element array: [bg, fg, cursor, c0..c15]
    let result: [String; 19] = [
        bg,
        fg,
        cursor,
        palette[0].clone(),
        palette[1].clone(),
        palette[2].clone(),
        palette[3].clone(),
        palette[4].clone(),
        palette[5].clone(),
        palette[6].clone(),
        palette[7].clone(),
        palette[8].clone(),
        palette[9].clone(),
        palette[10].clone(),
        palette[11].clone(),
        palette[12].clone(),
        palette[13].clone(),
        palette[14].clone(),
        palette[15].clone(),
    ];

    Some(result)
}

/// Print a categorized list of available themes to stdout.
pub fn theme_list() {
    println!("Available themes:");

    // Editor Dark
    println!("\n  Dark:");
    print_themes_filtered("editor", "dark");

    // Editor Light
    println!("\n  Light:");
    print_themes_filtered("editor", "light");

    // Chromatic Dark
    println!("\n  Chromatic Dark (colored backgrounds):");
    print_themes_filtered("chromatic", "dark");

    // Chromatic Light
    println!("\n  Chromatic Light (tinted backgrounds):");
    print_themes_filtered("chromatic", "light");

    // Semantic
    println!("\n  Semantic:");
    println!("    danger (production)  safe (development)");
    let semantic: Vec<&str> = THEME_META
        .iter()
        .filter(|m| m.kind == "semantic" && m.label != "danger" && m.label != "safe")
        .map(|m| m.label)
        .collect();
    if !semantic.is_empty() {
        // Print in rows of 4
        for chunk in semantic.chunks(4) {
            print!("   ");
            for name in chunk {
                print!(" {:<16}", name);
            }
            println!();
        }
    }

    // User themes
    let td = theme_dir();
    if td.is_dir() {
        let mut user_themes: Vec<String> = Vec::new();
        if let Ok(entries) = fs::read_dir(&td) {
            for entry in entries.flatten() {
                let path = entry.path();
                if path.extension().and_then(|e| e.to_str()) == Some("theme") {
                    if let Some(stem) = path.file_stem().and_then(|s| s.to_str()) {
                        user_themes.push(stem.to_string());
                    }
                }
            }
        }
        user_themes.sort();
        if !user_themes.is_empty() {
            println!("\n  User (~/.config/tabbing-on/themes/):");
            for name in &user_themes {
                println!("    {}", name);
            }
        }
    }
}

/// Return the user theme directory path: `~/.config/tabbing-on/themes/`
///
/// Respects `XDG_CONFIG_HOME` if set.
pub fn theme_dir() -> PathBuf {
    let base = std::env::var("XDG_CONFIG_HOME")
        .ok()
        .filter(|s| !s.is_empty())
        .map(PathBuf::from)
        .or_else(|| dirs::home_dir().map(|h| h.join(".config")))
        .unwrap_or_else(|| PathBuf::from(".config"));
    base.join("tabbing-on").join("themes")
}

// ============================================================================
// Internal helpers
// ============================================================================

/// Resolve a theme alias to its canonical name (public for theme_picker).
pub fn resolve_alias_pub(name: &str) -> &str {
    resolve_alias(name)
}

/// Resolve a theme alias to its canonical name.
fn resolve_alias(name: &str) -> &str {
    for (alias, canonical) in THEME_ALIASES {
        if *alias == name {
            return canonical;
        }
    }
    name
}

/// Print built-in theme names matching a kind and variant, formatted in rows.
fn print_themes_filtered(kind: &str, variant: &str) {
    let names: Vec<&str> = THEME_META
        .iter()
        .filter(|m| m.kind == kind && m.variant == variant)
        .map(|m| m.label)
        .collect();
    for chunk in names.chunks(4) {
        print!("   ");
        for name in chunk {
            print!(" {:<20}", name);
        }
        println!();
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_resolve_alias_known() {
        assert_eq!(resolve_alias("catppuccin-mocha"), "catppuccin");
        assert_eq!(resolve_alias("gruvbox-dark"), "gruvbox");
        assert_eq!(resolve_alias("production"), "danger");
        assert_eq!(resolve_alias("development"), "safe");
    }

    #[test]
    fn test_resolve_alias_passthrough() {
        assert_eq!(resolve_alias("dracula"), "dracula");
        assert_eq!(resolve_alias("nonexistent"), "nonexistent");
    }

    #[test]
    fn test_builtin_themes_all_have_19_colors() {
        for (name, colors) in BUILTIN_THEMES {
            assert_eq!(
                colors.len(),
                19,
                "Theme '{}' has {} colors, expected 19",
                name,
                colors.len()
            );
        }
    }

    #[test]
    fn test_builtin_themes_all_hex() {
        for (name, colors) in BUILTIN_THEMES {
            for (i, color) in colors.iter().enumerate() {
                assert!(
                    color.starts_with('#') && color.len() == 7,
                    "Theme '{}' color[{}] = '{}' is not a valid #RRGGBB hex",
                    name,
                    i,
                    color
                );
            }
        }
    }

    #[test]
    fn test_theme_meta_matches_builtin_count() {
        assert_eq!(
            THEME_META.len(),
            BUILTIN_THEMES.len(),
            "THEME_META and BUILTIN_THEMES should have the same count"
        );
    }

    #[test]
    fn test_theme_dir_returns_path() {
        let dir = theme_dir();
        assert!(dir.to_string_lossy().contains("tabbing-on"));
        assert!(dir.to_string_lossy().contains("themes"));
    }
}
