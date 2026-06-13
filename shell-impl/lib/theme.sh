#!/bin/sh
# lib/theme.sh — Interactive theme picker and .envrc writer
# Pure shell TUI for browsing, previewing, cloning, and editing themes.
# Depends on: render.sh (for _tabbing_apply_named_theme, _tabbing_clear_theme, etc.)

# ---------------------------------------------------------------------------
# Built-in theme registry: name|category|variant
# category: editor, semantic    variant: dark, light
# ---------------------------------------------------------------------------
_tabbing_builtin_themes() {
  cat <<'THEMES'
catppuccin|editor|dark
catppuccin-latte|editor|light
catppuccin-frappe|editor|dark
catppuccin-macchiato|editor|dark
dracula|editor|dark
nord|editor|dark
nord-light|editor|light
tokyo-night|editor|dark
tokyo-night-light|editor|light
gruvbox|editor|dark
gruvbox-light|editor|light
monokai|editor|dark
one-dark|editor|dark
one-light|editor|light
solarized-dark|editor|dark
solarized-light|editor|light
rose-pine|editor|dark
rose-pine-moon|editor|dark
rose-pine-dawn|editor|light
kanagawa|editor|dark
kanagawa-lotus|editor|light
everforest-dark|editor|dark
everforest-light|editor|light
github-dark|editor|dark
github-light|editor|light
ayu-dark|editor|dark
ayu-light|editor|light
ayu-mirage|editor|dark
material-dark|editor|dark
material-light|editor|light
papercolor-light|editor|light
pencil-light|editor|light
alabaster|editor|light
amethyst|chromatic|dark
cobalt|chromatic|dark
merlot|chromatic|dark
emerald|chromatic|dark
copper|chromatic|dark
indigo-night|chromatic|dark
plum|chromatic|dark
tundra|chromatic|dark
mahogany|chromatic|dark
olive-dusk|chromatic|dark
storm|chromatic|dark
volcanic|chromatic|dark
terracotta|chromatic|light
sage-mist|chromatic|light
lavender-mist|chromatic|light
coral-sand|chromatic|light
arctic|chromatic|light
seafoam|chromatic|light
champagne|chromatic|light
blush|chromatic|light
danger|semantic|dark
safe|semantic|dark
ocean|semantic|dark
ocean-light|semantic|light
forest|semantic|dark
forest-light|semantic|light
sunset|semantic|dark
dawn|semantic|light
ivory|semantic|light
slate|semantic|dark
THEMES
}

# ---------------------------------------------------------------------------
# Collect all themes: built-in + user, with metadata
# Output: name|category|variant per line
# ---------------------------------------------------------------------------
_tabbing_all_themes() {
  _tabbing_builtin_themes

  local theme_dir
  theme_dir="$(_tabbing_theme_dir)"
  if [ -d "$theme_dir" ]; then
    for f in "$theme_dir"/*.theme; do
      [ -f "$f" ] || continue
      local name
      name="$(basename "$f" .theme)"

      # Check if bg is light or dark by reading the file
      local bg=""
      bg="$(sed -n 's/^bg=//p; s/^background=//p' "$f" | head -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
      local variant="dark"
      if [ -n "$bg" ]; then
        # Crude lightness check: if first hex digit > 9, probably light
        local first
        first="$(echo "$bg" | sed 's/^#//' | cut -c1)"
        case "$first" in
          [A-Fa-f]) variant="light" ;;
        esac
      fi
      printf '%s|user|%s\n' "$name" "$variant"
    done
  fi
}

# ---------------------------------------------------------------------------
# Extract theme data to a .theme file format string
# For built-in themes, we parse the case statement data from render.sh
# ---------------------------------------------------------------------------
_tabbing_export_builtin_theme() {
  local name="$1"
  local args=""

  # Capture the OSC output by temporarily redirecting
  # We need to extract the hex values from the theme definition
  # Instead, we'll parse the built-in data directly
  case "$name" in
    catppuccin|catppuccin-mocha)
      args="#1E1E2E #CDD6F4 #F5E0DC #45475A #F38BA8 #A6E3A1 #F9E2AF #89B4FA #F5C2E7 #94E2D5 #BAC2DE #585B70 #F38BA8 #A6E3A1 #F9E2AF #89B4FA #F5C2E7 #94E2D5 #A6ADC8" ;;
    catppuccin-latte)
      args="#EFF1F5 #4C4F69 #DC8A78 #BCC0CC #D20F39 #40A02B #DF8E1D #1E66F5 #EA76CB #179299 #5C5F77 #ACB0BE #D20F39 #40A02B #DF8E1D #1E66F5 #EA76CB #179299 #6C6F85" ;;
    catppuccin-frappe)
      args="#303446 #C6D0F5 #F2D5CF #292C3C #E78284 #A6D189 #E5C890 #8CAAEE #F4B8E4 #81C8BE #B5BFE2 #414559 #E78284 #A6D189 #E5C890 #8CAAEE #F4B8E4 #81C8BE #A5ADCE" ;;
    catppuccin-macchiato)
      args="#24273A #CAD3F5 #F4DBD6 #1E2030 #ED8796 #A6DA95 #EED49F #8AADF4 #F5BDE6 #8BD5CA #B8C0E0 #494D64 #ED8796 #A6DA95 #EED49F #8AADF4 #F5BDE6 #8BD5CA #A5ADCB" ;;
    dracula)
      args="#282A36 #F8F8F2 #F8F8F2 #21222C #FF5555 #50FA7B #F1FA8C #BD93F9 #FF79C6 #8BE9FD #F8F8F2 #6272A4 #FF6E6E #69FF94 #FFFFA5 #D6ACFF #FF92DF #A4FFFF #FFFFFF" ;;
    nord)
      args="#2E3440 #D8DEE9 #D8DEE9 #3B4252 #BF616A #A3BE8C #EBCB8B #81A1C1 #B48EAD #88C0D0 #E5E9F0 #4C566A #BF616A #A3BE8C #EBCB8B #81A1C1 #B48EAD #8FBCBB #ECEFF4" ;;
    nord-light)
      args="#ECEFF4 #2E3440 #4C566A #D8DEE9 #BF616A #A3BE8C #EBCB8B #5E81AC #B48EAD #88C0D0 #3B4252 #E5E9F0 #BF616A #A3BE8C #EBCB8B #5E81AC #B48EAD #8FBCBB #2E3440" ;;
    tokyo-night)
      args="#1A1B26 #C0CAF5 #C0CAF5 #15161E #F7768E #9ECE6A #E0AF68 #7AA2F7 #BB9AF7 #7DCFFF #A9B1D6 #414868 #F7768E #9ECE6A #E0AF68 #7AA2F7 #BB9AF7 #7DCFFF #C0CAF5" ;;
    tokyo-night-light)
      args="#D5D6DB #343B59 #343B59 #C4C5CB #8C4351 #33635C #8F5E15 #34548A #5A4A78 #0F4B6E #343B59 #9699A3 #8C4351 #33635C #8F5E15 #34548A #5A4A78 #0F4B6E #343B59" ;;
    gruvbox|gruvbox-dark)
      args="#282828 #EBDBB2 #EBDBB2 #282828 #CC241D #98971A #D79921 #458588 #B16286 #689D6A #A89984 #928374 #FB4934 #B8BB26 #FABD2F #83A598 #D3869B #8EC07C #EBDBB2" ;;
    gruvbox-light)
      args="#FBF1C7 #3C3836 #3C3836 #FBF1C7 #CC241D #98971A #D79921 #458588 #B16286 #689D6A #7C6F64 #928374 #9D0006 #79740E #B57614 #076678 #8F3F71 #427B58 #3C3836" ;;
    solarized-dark)
      args="#002B36 #839496 #839496 #073642 #DC322F #859900 #B58900 #268BD2 #D33682 #2AA198 #EEE8D5 #002B36 #CB4B16 #586E75 #657B83 #839496 #6C71C4 #93A1A1 #FDF6E3" ;;
    solarized-light)
      args="#FDF6E3 #657B83 #657B83 #EEE8D5 #DC322F #859900 #B58900 #268BD2 #D33682 #2AA198 #073642 #FDF6E3 #CB4B16 #93A1A1 #839496 #657B83 #6C71C4 #586E75 #002B36" ;;
    monokai)
      args="#272822 #F8F8F2 #F8F8F0 #272822 #F92672 #A6E22E #F4BF75 #66D9EF #AE81FF #A1EFE4 #F8F8F2 #75715E #F92672 #A6E22E #F4BF75 #66D9EF #AE81FF #A1EFE4 #F9F8F5" ;;
    one-dark)
      args="#282C34 #ABB2BF #528BFF #282C34 #E06C75 #98C379 #E5C07B #61AFEF #C678DD #56B6C2 #ABB2BF #545862 #E06C75 #98C379 #E5C07B #61AFEF #C678DD #56B6C2 #C8CCD4" ;;
    one-light)
      args="#FAFAFA #383A42 #526FFF #F0F0F0 #E45649 #50A14F #C18401 #4078F2 #A626A4 #0184BC #383A42 #A0A1A7 #E45649 #50A14F #C18401 #4078F2 #A626A4 #0184BC #383A42" ;;
    rose-pine)
      args="#191724 #E0DEF4 #524F67 #26233A #EB6F92 #31748F #F6C177 #9CCFD8 #C4A7E7 #EBBCBA #E0DEF4 #6E6A86 #EB6F92 #31748F #F6C177 #9CCFD8 #C4A7E7 #EBBCBA #E0DEF4" ;;
    rose-pine-moon)
      args="#232136 #E0DEF4 #59546D #2A273F #EB6F92 #3E8FB0 #F6C177 #9CCFD8 #C4A7E7 #EA9A97 #E0DEF4 #6E6A86 #EB6F92 #3E8FB0 #F6C177 #9CCFD8 #C4A7E7 #EA9A97 #E0DEF4" ;;
    rose-pine-dawn)
      args="#FAF4ED #575279 #286983 #F2E9E1 #B4637A #56949F #EA9D34 #286983 #907AA9 #D7827E #575279 #9893A5 #B4637A #56949F #EA9D34 #286983 #907AA9 #D7827E #575279" ;;
    kanagawa)
      args="#1F1F28 #DCD7BA #C8C093 #16161D #C34043 #76946A #C0A36E #7E9CD8 #957FB8 #6A9589 #C8C093 #727169 #E82424 #98BB6C #E6C384 #7FB4CA #938AA9 #7AA89F #DCD7BA" ;;
    kanagawa-lotus)
      args="#F2ECBC #545464 #43436C #E7DBA0 #C84053 #6F894E #77713F #4D699B #624C83 #597B75 #545464 #8A8980 #E82424 #98BB6C #E6C384 #7FB4CA #938AA9 #7AA89F #545464" ;;
    everforest-dark)
      args="#2D353B #D3C6AA #D3C6AA #343F44 #E67E80 #A7C080 #DBBC7F #7FBBB3 #D699B6 #83C092 #D3C6AA #475258 #E67E80 #A7C080 #DBBC7F #7FBBB3 #D699B6 #83C092 #D3C6AA" ;;
    everforest-light)
      args="#FDF6E3 #5C6A72 #5C6A72 #F3EAD3 #F85552 #8DA101 #DFA000 #3A94C5 #DF69BA #35A77C #5C6A72 #E0DCC7 #F85552 #8DA101 #DFA000 #3A94C5 #DF69BA #35A77C #5C6A72" ;;
    github-dark)
      args="#0D1117 #C9D1D9 #C9D1D9 #161B22 #FF7B72 #7EE787 #D29922 #79C0FF #D2A8FF #A5D6FF #C9D1D9 #21262D #FFA198 #56D364 #E3B341 #79C0FF #D2A8FF #A5D6FF #F0F6FC" ;;
    github-light)
      args="#FFFFFF #24292F #0969DA #F6F8FA #CF222E #116329 #4D2D00 #0550AE #8250DF #1B7C83 #24292F #D0D7DE #A40E26 #1A7F37 #633C01 #0969DA #8250DF #2AA198 #24292F" ;;
    ayu-dark)
      args="#0B0E14 #BFBDB6 #E6B450 #11151C #F07178 #AAD94C #E6B450 #399EE6 #D2A6FF #95E6CB #BFBDB6 #636A72 #FF8F40 #AAD94C #FFB454 #59C2FF #D2A6FF #95E6CB #C5C5C5" ;;
    ayu-light)
      args="#FAFAFA #5C6166 #FF9940 #F0F0F0 #F07178 #86B300 #F29718 #36A3D9 #A37ACC #4CBF99 #5C6166 #E7E8E9 #FF3333 #86B300 #F29718 #36A3D9 #A37ACC #4CBF99 #5C6166" ;;
    ayu-mirage)
      args="#1F2430 #CBCCC6 #FFCC66 #232834 #F28779 #BAE67E #FFD580 #73D0FF #D4BFFF #95E6CB #CBCCC6 #707A8C #FF3333 #BAE67E #FFD580 #73D0FF #D4BFFF #95E6CB #F3F4F5" ;;
    material-dark)
      args="#263238 #EEFFFF #FFCC00 #2C3B41 #FF5370 #C3E88D #FFCB6B #82AAFF #C792EA #89DDFF #EEFFFF #37474F #FF5370 #C3E88D #FFCB6B #82AAFF #C792EA #89DDFF #FFFFFF" ;;
    material-light)
      args="#FAFAFA #546E7A #272727 #F2F2F2 #FF5370 #91B859 #FFB62C #6182B8 #7C4DFF #39ADB5 #546E7A #E7E7E8 #E53935 #91B859 #F6A434 #6182B8 #7C4DFF #39ADB5 #272727" ;;
    papercolor-light)
      args="#EEEEEE #444444 #444444 #E4E4E4 #AF0000 #008700 #D75F00 #005FAF #AF00AF #005F87 #444444 #BCBCBC #D70000 #5FAF00 #D78700 #0087AF #D787D7 #00AFAF #005F87" ;;
    pencil-light)
      args="#F1F1F1 #424242 #20BBFC #E0E0E0 #C30771 #10A778 #A89C14 #008EC4 #523C79 #20A5BA #424242 #B8B8B8 #E32791 #5FD7A7 #F3E430 #20BBFC #6855DE #4FB8CC #212121" ;;
    alabaster)
      args="#F7F7F7 #434343 #007ACC #ECECEC #AA3731 #448C27 #CB9000 #325CC0 #7A3E9D #0083B2 #434343 #DCDCDC #D91A1A #448C27 #CB9000 #325CC0 #7A3E9D #0083B2 #434343" ;;
    amethyst)
      args="#2A1B3D #D8D0E8 #E8C050 #1E1030 #E06070 #80C070 #E8C050 #8080D0 #D070B0 #60B0B8 #D0C8E0 #382850 #F07080 #90D080 #F0D060 #9090E0 #E080C0 #70C0C8 #E0D8F0" ;;
    cobalt)
      args="#0D1B30 #C8D8E8 #E8A030 #081420 #E06060 #60C080 #E8A030 #5090D0 #B070C0 #50B0C0 #C0D0E0 #1A2840 #F07070 #70D090 #F0B040 #60A0E0 #C080D0 #60C0D0 #D8E0F0" ;;
    merlot)
      args="#2E1018 #E8D0D0 #50C0A0 #200810 #E05050 #50C0A0 #D8A050 #7090C0 #C060A0 #40B0A0 #E0D0D0 #401828 #F06060 #60D0B0 #E8B060 #80A0D0 #D070B0 #50C0B0 #F0E0E0" ;;
    emerald)
      args="#0C2818 #C0D8C0 #E07080 #061A0F #E07080 #60C060 #C0B050 #5090B0 #B070A0 #50B098 #B8D0B8 #183820 #F08090 #70D070 #D0C060 #60A0C0 #C080B0 #60C0A8 #D0E8D0" ;;
    copper)
      args="#2C1808 #E8D8C0 #5098D0 #1A1005 #E06040 #90B060 #D8A040 #5098D0 #C070A0 #50A8B8 #E0D0B8 #402818 #F07050 #A0C070 #E8B050 #60A8E0 #D080B0 #60B8C8 #F0E8D0" ;;
    indigo-night)
      args="#181038 #C8C0E0 #E88060 #100828 #E88060 #A0C050 #E0B040 #7080D0 #C068C0 #60A8C0 #C0B8D8 #281848 #F89070 #B0D060 #F0C050 #8090E0 #D078D0 #70B8D0 #D8D0F0" ;;
    plum)
      args="#281028 #D8C0D8 #B0D050 #1C081C #E06080 #B0D050 #D0A840 #8080C0 #D060C0 #60B0A0 #D0B8D0 #381838 #F070A0 #C0E060 #E0B850 #9090D0 #E070D0 #70C0B0 #E8D0E8" ;;
    tundra)
      args="#0C2028 #C0D8E0 #70C0D0 #081820 #D06868 #60C0A0 #C0B060 #5898C0 #A078B0 #70C0D0 #B8D0D8 #183038 #E07878 #70D0B0 #D0C070 #68A8D0 #B088C0 #80D0E0 #D0E8F0" ;;
    mahogany)
      args="#2E1510 #E8D8C8 #D08050 #200E08 #D85040 #90A860 #D08050 #7090B0 #C06090 #60A090 #E0D0C0 #402820 #E86050 #A0B870 #E09060 #80A0C0 #D070A0 #70B0A0 #F0E0D0" ;;
    olive-dusk)
      args="#1A2010 #D0D8B8 #C0B060 #101808 #D06860 #80B050 #C0B060 #6090B0 #A878A0 #60A890 #C8D0B0 #283018 #E07870 #90C060 #D0C070 #70A0C0 #B888B0 #70B8A0 #E0E8C8" ;;
    storm)
      args="#2E3848 #D0D8E0 #E8B050 #202830 #E06868 #70C080 #E8B050 #6098D0 #B078C0 #60B0C0 #C8D0D8 #3E4858 #F07878 #80D090 #F0C060 #70A8E0 #C088D0 #70C0D0 #E0E8F0" ;;
    volcanic)
      args="#281818 #E0D0C0 #E06040 #1A1010 #E06040 #90A860 #D0A040 #7090B8 #C06890 #60A898 #D8C8B8 #382828 #F07050 #A0B870 #E0B050 #80A0C8 #D078A0 #70B8A8 #F0E0D0" ;;
    terracotta)
      args="#F2E0D0 #4A3020 #1A8080 #E0D0C0 #B83030 #1A8080 #A07010 #3060A0 #883880 #107070 #4A3020 #D0C0B0 #D04040 #209090 #B08020 #4070B0 #984890 #208080 #3A2010" ;;
    sage-mist)
      args="#E4EDD8 #2A3820 #904880 #D4DCC8 #A83030 #307030 #887020 #3060A0 #904880 #207868 #2A3820 #C4D0B8 #C04040 #408040 #988030 #4070B0 #A05890 #308878 #1A2810" ;;
    lavender-mist)
      args="#EAE0F2 #302840 #B89020 #DAD0E2 #A83040 #408030 #B89020 #4060B0 #804090 #207888 #302840 #C8C0D8 #C04050 #509040 #C8A030 #5070C0 #9050A0 #308898 #201830" ;;
    coral-sand)
      args="#F5E2D8 #3A2820 #206898 #E4D0C8 #B03030 #308868 #A07818 #206898 #883880 #1A7878 #3A2820 #D4C0B8 #C84040 #409878 #B08828 #3078A8 #984890 #2A8888 #2A1810" ;;
    arctic)
      args="#E2ECF5 #1A2840 #C05040 #D2DCE4 #C05040 #308860 #A08020 #2860A0 #804090 #187880 #1A2840 #C0D0E0 #D06050 #409870 #B09030 #3870B0 #9050A0 #288890 #0A1830" ;;
    seafoam)
      args="#E0F0E8 #1A3028 #B84060 #D0E0D8 #B84060 #208860 #888820 #3068A0 #884088 #107868 #1A3028 #C0D4CC #C85070 #309870 #989830 #4078B0 #985098 #208878 #0A2018" ;;
    champagne)
      args="#F5EDE2 #302818 #2858A8 #E4DCD0 #B03030 #408838 #A07818 #2858A8 #883088 #187078 #302818 #D0C8B8 #C84040 #509848 #B08828 #3868B8 #984098 #288088 #201808" ;;
    blush)
      args="#F5E5E8 #382030 #208858 #E4D4D8 #B03040 #208858 #907820 #3060A0 #883880 #187870 #382030 #D4C4C8 #C84050 #309868 #A08830 #4070B0 #984890 #288880 #281020" ;;
    danger|production)
      args="#2C0B0E #FFCCCC #FF6666 #1A0608 #FF4444 #CC6666 #FFAA66 #CC8888 #FF6688 #CC9999 #FFCCCC #663333 #FF6666 #DD8888 #FFBB88 #DDAAAA #FF88AA #DDBBBB #FFE0E0" ;;
    safe|development)
      args="#0B2B1A #CCFFCC #66FF66 #061A0F #66CC66 #44FF44 #AAFF66 #66CCAA #88CC66 #44DDAA #CCFFCC #336633 #88DD88 #66FF66 #CCFF88 #88DDCC #AADD88 #66FFCC #E0FFE0" ;;
    ocean)
      args="#0A1628 #B0C4DE #87CEEB #051020 #CD5C5C #66CDAA #F0E68C #6495ED #9370DB #48D1CC #B0C4DE #2F4F6F #E07070 #7CE0BE #F5EEA0 #7CAAF0 #A888E0 #5CE0D8 #D0E0F0" ;;
    forest)
      args="#0B2B1A #A8C8A8 #8FBC8F #061A0F #CD6060 #6B8E23 #BDB76B #5F9EA0 #8B7B8B #66CDAA #A8C8A8 #2E5E3E #D87070 #7BA833 #CDC87B #6FB8B0 #9B8B9B #76DDBA #C0E0C0" ;;
    sunset)
      args="#2C1810 #F0D0B0 #E8A060 #1A0E0A #E06040 #B8A040 #F0C060 #C08060 #D06080 #C0A080 #F0D0B0 #604030 #F07050 #C8B050 #F0D070 #D09070 #E07090 #D0B090 #F8E0C8" ;;
    ocean-light)
      args="#F0F5FA #1A3A5C #2E6B9E #E0EAF2 #C04040 #2E8B57 #B8860B #2E6B9E #7B68AE #1A8A8A #1A3A5C #CADAE8 #D04040 #358B5B #C89020 #3878B0 #8878BE #2A9A9A #0D2040" ;;
    forest-light)
      args="#F4F8F0 #2B4020 #4A7030 #E8F0E0 #B04040 #3A7A20 #9A8020 #4070A0 #7A5A90 #2A8A6A #2B4020 #D0DCC8 #C05050 #4A8A30 #AA9030 #5080B0 #8A6AA0 #3A9A7A #1A2A10" ;;
    dawn)
      args="#FAF5F0 #5C4A3A #D09050 #F0E8E0 #C05040 #6A8A40 #C09030 #4A70A0 #8A5A90 #3A8A7A #5C4A3A #E0D8D0 #D06050 #7A9A50 #D0A040 #5A80B0 #9A6AA0 #4A9A8A #3A2A1A" ;;
    ivory)
      args="#FFFFF0 #3A3A30 #8A7A60 #F5F5E8 #B84040 #5A8A30 #A08A20 #4A6AA0 #7A5090 #2A7A70 #3A3A30 #E8E8D8 #C85050 #6A9A40 #B09A30 #5A7AB0 #8A60A0 #3A8A80 #1A1A10" ;;
    slate)
      args="#1E2832 #C0C8D0 #88A0B8 #283440 #E07070 #80B880 #D0B870 #70A0D0 #A080C0 #60B0B0 #C0C8D0 #384858 #F08080 #90C890 #E0C880 #80B0E0 #B090D0 #70C0C0 #E0E8F0" ;;
    *) return 1 ;;
  esac

  # Parse space-separated hex values into .theme format
  set -- $args
  printf 'bg=%s\n' "$1"
  printf 'fg=%s\n' "$2"
  printf 'cursor=%s\n' "$3"
  local i=0
  shift 3
  while [ $# -gt 0 ]; do
    printf 'color%d=%s\n' "$i" "$1"
    i=$((i + 1))
    shift
  done
}

# ---------------------------------------------------------------------------
# Clone a theme (built-in or user) to user theme dir with a new name
# ---------------------------------------------------------------------------
_tabbing_clone_theme() {
  local src="$1" dest="$2"
  local theme_dir
  theme_dir="$(_tabbing_theme_dir)"
  mkdir -p "$theme_dir"

  local dest_file="${theme_dir}/${dest}.theme"

  # Check if source is a user theme file
  local src_file="${theme_dir}/${src}.theme"
  if [ -f "$src_file" ]; then
    cp "$src_file" "$dest_file"
    printf 'Cloned user theme "%s" → "%s"\n' "$src" "$dest"
    printf '  %s\n' "$dest_file"
    return 0
  fi

  # Try to export built-in theme
  local data
  data="$(_tabbing_export_builtin_theme "$src")" || {
    printf 'Unknown theme: %s\n' "$src" >&2
    return 1
  }

  printf '%s\n' "$data" > "$dest_file"
  printf 'Cloned built-in theme "%s" → "%s"\n' "$src" "$dest"
  printf '  %s\n' "$dest_file"
}

# ---------------------------------------------------------------------------
# Edit a user theme in $EDITOR
# ---------------------------------------------------------------------------
_tabbing_edit_theme() {
  local name="$1"
  local theme_dir
  theme_dir="$(_tabbing_theme_dir)"
  local file="${theme_dir}/${name}.theme"

  if [ ! -f "$file" ]; then
    printf 'Theme "%s" is not a user theme.\n' "$name" >&2
    printf 'Clone it first: tabbing-theme clone %s my-%s\n' "$name" "$name" >&2
    return 1
  fi

  "${EDITOR:-vi}" "$file"

  printf 'Preview updated theme? [Y/n] '
  local answer
  read -r answer
  case "$answer" in
    [Nn]*) ;;
    *) _tabbing_apply_named_theme "$name" && printf 'Theme "%s" applied.\n' "$name" ;;
  esac
}

# ---------------------------------------------------------------------------
# Delete a user theme
# ---------------------------------------------------------------------------
_tabbing_delete_theme() {
  local name="$1"
  local theme_dir
  theme_dir="$(_tabbing_theme_dir)"
  local file="${theme_dir}/${name}.theme"

  if [ ! -f "$file" ]; then
    printf 'No user theme "%s" found.\n' "$name" >&2
    return 1
  fi

  printf 'Delete theme "%s"? [y/N] ' "$name"
  local answer
  read -r answer
  case "$answer" in
    [Yy]*) rm "$file"; printf 'Deleted.\n' ;;
    *) printf 'Cancelled.\n' ;;
  esac
}

# ---------------------------------------------------------------------------
# Prompt user: save to .envrc or just apply to current env?
# ---------------------------------------------------------------------------
_tabbing_prompt_save_theme() {
  local theme="$1"
  printf 'Theme "%s" applied to current session.\n' "$theme"
  printf 'Save to .envrc for this directory? [y/N] '
  local answer
  read -r answer
  case "$answer" in
    [Yy]*)
      _tabbing_save_theme_envrc "$theme" "."
      ;;
    *)
      printf 'Theme active for this session only (export TAB_THEME=%s).\n' "$theme"
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Save current theme to .envrc in a given directory
# ---------------------------------------------------------------------------
_tabbing_save_theme_envrc() {
  local theme="$1"
  local dir="${2:-.}"
  local envrc="${dir}/.envrc"

  if [ -z "$theme" ]; then
    printf 'No theme specified.\n' >&2
    return 1
  fi

  # Verify theme exists
  _tabbing_apply_named_theme "$theme" >/dev/null 2>&1 || {
    printf 'Unknown theme: %s\n' "$theme" >&2
    return 1
  }
  _tabbing_clear_theme 2>/dev/null

  # Check if .envrc already has a TAB_THEME export
  if [ -f "$envrc" ]; then
    if grep -q '^export TAB_THEME=' "$envrc" 2>/dev/null; then
      sed -i.bak 's/^export TAB_THEME=.*/export TAB_THEME='"$theme"'/' "$envrc"
      rm -f "${envrc}.bak"
      printf 'Updated TAB_THEME=%s in %s\n' "$theme" "$envrc"
    else
      printf '\nexport TAB_THEME=%s\n' "$theme" >> "$envrc"
      printf 'Added TAB_THEME=%s to %s\n' "$theme" "$envrc"
    fi
  else
    printf 'export TAB_THEME=%s\n' "$theme" > "$envrc"
    printf 'Created %s with TAB_THEME=%s\n' "$envrc" "$theme"
  fi

  # Remind about direnv
  if command -v direnv >/dev/null 2>&1; then
    printf 'Run "direnv allow" to activate.\n'
  fi
}

# ---------------------------------------------------------------------------
# Render a color swatch bar for a theme (inline ANSI preview)
# Shows bg/fg and a few palette colors as colored blocks
# ---------------------------------------------------------------------------
_tabbing_theme_swatch() {
  local name="$1"
  local data
  data="$(_tabbing_export_builtin_theme "$name" 2>/dev/null)"

  if [ -z "$data" ]; then
    local theme_dir
    theme_dir="$(_tabbing_theme_dir)"
    local file="${theme_dir}/${name}.theme"
    [ -f "$file" ] && data="$(cat "$file")" || return 1
  fi

  # Extract bg and fg
  local bg fg
  bg="$(echo "$data" | sed -n 's/^bg=//p' | head -1)"
  fg="$(echo "$data" | sed -n 's/^fg=//p' | head -1)"

  # Use OSC 8-bit color approximation for inline display
  # Show colored unicode blocks representing key palette entries
  local c1 c2 c4 c5 c6
  c1="$(echo "$data" | sed -n 's/^color1=//p' | head -1)"
  c2="$(echo "$data" | sed -n 's/^color2=//p' | head -1)"
  c4="$(echo "$data" | sed -n 's/^color4=//p' | head -1)"
  c5="$(echo "$data" | sed -n 's/^color5=//p' | head -1)"
  c6="$(echo "$data" | sed -n 's/^color6=//p' | head -1)"

  # Print using truecolor escapes if terminal supports it
  _tabbing_swatch_block "$bg"
  _tabbing_swatch_block "$fg"
  _tabbing_swatch_block "$c1"
  _tabbing_swatch_block "$c2"
  _tabbing_swatch_block "$c4"
  _tabbing_swatch_block "$c5"
  _tabbing_swatch_block "$c6"
  printf '\033[0m'
}

# Print a single colored block using truecolor
_tabbing_swatch_block() {
  local hex="$1"
  [ -z "$hex" ] && return
  hex="${hex#\#}"
  [ ${#hex} -ne 6 ] && return
  local r g b
  r=$((16#${hex:0:2}))
  g=$((16#${hex:2:2}))
  b=$((16#${hex:4:2}))
  printf '\033[48;2;%d;%d;%dm  \033[0m' "$r" "$g" "$b"
}

# ---------------------------------------------------------------------------
# Interactive theme picker TUI — two-column layout
# Left/Right arrows switch between Dark and Light columns
# Up/Down arrows navigate within a column
# Semantic and User themes appear below the two-column grid
# ---------------------------------------------------------------------------
_tabbing_theme_picker() {
  local original_theme="${TAB_THEME:-}"
  local themes_data
  themes_data="$(_tabbing_all_themes)"

  # Build arrays by group
  local -a dark_arr=() light_arr=() semantic_arr=() user_arr=()
  local -a chrom_dark_arr=() chrom_light_arr=()

  while IFS='|' read -r name cat var; do
    [ -z "$name" ] && continue
    case "$cat" in
      editor)
        case "$var" in
          dark)  dark_arr+=("$name") ;;
          light) light_arr+=("$name") ;;
        esac ;;
      chromatic)
        case "$var" in
          dark)  chrom_dark_arr+=("$name") ;;
          light) chrom_light_arr+=("$name") ;;
        esac ;;
      semantic) semantic_arr+=("$name") ;;
      user)     user_arr+=("$name") ;;
    esac
  done <<EOF
$themes_data
EOF

  # Flatten all themes into a single navigable list with region markers
  # Regions: 0=dark column, 1=light column, 2=chrom-dark, 3=chrom-light,
  #          4=semantic, 5=user
  local -a all_names=()   # theme name
  local -a all_region=()  # which region
  local -a all_index=()   # index within region

  local i
  for i in "${!dark_arr[@]}"; do
    all_names+=("${dark_arr[$i]}")
    all_region+=(0)
    all_index+=("$i")
  done
  for i in "${!light_arr[@]}"; do
    all_names+=("${light_arr[$i]}")
    all_region+=(1)
    all_index+=("$i")
  done
  for i in "${!chrom_dark_arr[@]}"; do
    all_names+=("${chrom_dark_arr[$i]}")
    all_region+=(2)
    all_index+=("$i")
  done
  for i in "${!chrom_light_arr[@]}"; do
    all_names+=("${chrom_light_arr[$i]}")
    all_region+=(3)
    all_index+=("$i")
  done
  for i in "${!semantic_arr[@]}"; do
    all_names+=("${semantic_arr[$i]}")
    all_region+=(4)
    all_index+=("$i")
  done
  for i in "${!user_arr[@]}"; do
    all_names+=("${user_arr[$i]}")
    all_region+=(5)
    all_index+=("$i")
  done

  local total=${#all_names[@]}
  [ "$total" -eq 0 ] && { echo "No themes found."; return 1; }

  local cursor=0
  local dark_count=${#dark_arr[@]}
  local light_count=${#light_arr[@]}
  local chrom_dark_count=${#chrom_dark_arr[@]}
  local chrom_light_count=${#chrom_light_arr[@]}
  local semantic_count=${#semantic_arr[@]}
  local user_count=${#user_arr[@]}
  local col_rows=$(( dark_count > light_count ? dark_count : light_count ))
  local chrom_col_rows=$(( chrom_dark_count > chrom_light_count ? chrom_dark_count : chrom_light_count ))

  local term_lines term_cols
  term_lines=$(tput lines 2>/dev/null || echo 24)
  term_cols=$(tput cols 2>/dev/null || echo 80)
  local col_width=$(( (term_cols - 4) / 2 ))
  [ $col_width -lt 30 ] && col_width=30

  stty -echo -icanon 2>/dev/null
  printf '\033[?25l'
  printf '\033[?1049h'

  local selected="" action="" running=1
  local filter_mode=0 filter_text=""
  local -a filtered_pos=()  # indices into all_names matching filter

  # Given a region + index, find the position in all_names
  _tabbing_find_pos() {
    local r="$1" idx="$2" p=0
    while [ $p -lt $total ]; do
      if [ "${all_region[$p]}" -eq "$r" ] && [ "${all_index[$p]}" -eq "$idx" ]; then
        echo "$p"; return
      fi
      p=$((p + 1))
    done
    echo "-1"
  }

  _tabbing_apply_filter() {
    filtered_pos=()
    local i=0 lc_filter
    lc_filter="$(echo "$filter_text" | tr '[:upper:]' '[:lower:]')"
    while [ $i -lt $total ]; do
      local lc_name
      lc_name="$(echo "${all_names[$i]}" | tr '[:upper:]' '[:lower:]')"
      case "$lc_name" in
        *"$lc_filter"*) filtered_pos+=("$i") ;;
      esac
      i=$((i + 1))
    done
  }

  _tabbing_render_filtered() {
    printf '\033[H\033[2J'
    printf '\033[1m  tabbing-theme\033[0m — filter: \033[33m%s\033[0m  (type to refine, esc to clear)\n' "$filter_text"
    printf '  ─────────────────────────────────────────────────────────\n'

    local fcount=${#filtered_pos[@]}
    if [ $fcount -eq 0 ]; then
      printf '\n  \033[2mNo themes match "%s"\033[0m\n' "$filter_text"
    else
      local visible_rows=$((term_lines - 7))
      [ $visible_rows -lt 3 ] && visible_rows=3

      # Find cursor position within filtered list
      local filter_cursor=0
      local fi=0
      while [ $fi -lt $fcount ]; do
        [ "${filtered_pos[$fi]}" -eq "$cursor" ] && { filter_cursor=$fi; break; }
        fi=$((fi + 1))
      done

      local scroll=0
      if [ $filter_cursor -ge $((scroll + visible_rows)) ]; then
        scroll=$((filter_cursor - visible_rows + 1))
      fi

      local ri=$scroll rendered=0
      while [ $ri -lt $fcount ] && [ $rendered -lt $visible_rows ]; do
        local pos=${filtered_pos[$ri]}
        local name="${all_names[$pos]}"
        local region=${all_region[$pos]}
        local tag=""
        case $region in
          0) tag="\033[2m[dark]\033[0m" ;;
          1) tag="\033[2m[light]\033[0m" ;;
          2) tag="\033[2m[chromatic-dark]\033[0m" ;;
          3) tag="\033[2m[chromatic-light]\033[0m" ;;
          4) tag="\033[2m[semantic]\033[0m" ;;
          5) tag="\033[2m[user]\033[0m" ;;
        esac

        if [ "$pos" -eq "$cursor" ]; then
          printf '  \033[7m▸ %-24s\033[0m ' "$name"
          printf "$tag "
          _tabbing_theme_swatch "$name" 2>/dev/null
          printf '\n'
        else
          printf '    %-24s ' "$name"
          printf "$tag "
          _tabbing_theme_swatch "$name" 2>/dev/null
          printf '\n'
        fi
        ri=$((ri + 1))
        rendered=$((rendered + 1))
      done
    fi

    printf '\n  \033[2m%d matches\033[0m\n' "${#filtered_pos[@]}"
  }

  _tabbing_picker_render() {
    if [ $filter_mode -eq 1 ]; then
      _tabbing_render_filtered
      return
    fi
    printf '\033[H\033[2J'

    printf '\033[1m  tabbing-theme\033[0m — ←/→ dark/light  ↑/↓ browse  enter apply\n'
    printf '  [c]lone  [e]dit  [d]elete  [s]ave to .envrc  [q]uit  [r]eset\n'
    printf '  ─────────────────────────────────────────────────────────\n'

    # Column headers
    printf '  \033[1;33m%-*s\033[0m \033[1;33m%s\033[0m\n' "$col_width" "■ Dark" "☀ Light"

    local cur_region=${all_region[$cursor]}
    local cur_idx=${all_index[$cursor]}

    # Compute scroll window for the two-column section
    local visible_rows=$((term_lines - 9))
    [ $visible_rows -lt 5 ] && visible_rows=5

    # Determine scroll offset based on cursor row in columns
    local cursor_row=-1
    if [ "$cur_region" -le 1 ]; then
      cursor_row=$cur_idx
    fi

    local scroll_top=0
    if [ $cursor_row -ge 0 ]; then
      if [ $cursor_row -ge $((scroll_top + visible_rows)) ]; then
        scroll_top=$((cursor_row - visible_rows + 1))
      fi
      if [ $cursor_row -lt $scroll_top ]; then
        scroll_top=$cursor_row
      fi
    fi

    # Render two-column grid
    local row=$scroll_top
    local rendered=0
    while [ $row -lt $col_rows ] && [ $rendered -lt $visible_rows ]; do
      local left_name="" right_name=""
      [ $row -lt $dark_count ] && left_name="${dark_arr[$row]}"
      [ $row -lt $light_count ] && right_name="${light_arr[$row]}"

      # Left column (dark)
      if [ -n "$left_name" ]; then
        if [ "$cur_region" -eq 0 ] && [ "$cur_idx" -eq "$row" ]; then
          printf '  \033[7m▸ %-*s' $((col_width - 2)) "$left_name"
          printf '\033[0m'
        else
          printf '   %-*s' $((col_width - 2)) "$left_name"
        fi
      else
        printf '  %-*s' $((col_width - 1)) ""
      fi

      printf ' '

      # Right column (light)
      if [ -n "$right_name" ]; then
        if [ "$cur_region" -eq 1 ] && [ "$cur_idx" -eq "$row" ]; then
          printf '\033[7m▸ %s\033[0m' "$right_name"
        else
          printf '  %s' "$right_name"
        fi
      fi

      printf '\n'
      row=$((row + 1))
      rendered=$((rendered + 1))
    done

    # Scroll indicators
    if [ $scroll_top -gt 0 ]; then
      printf '\033[4;%dH\033[2m↑ more\033[0m' $((col_width + 2))
    fi
    if [ $((scroll_top + visible_rows)) -lt $col_rows ]; then
      printf '\033[2m  ↓ more (%d hidden)\033[0m\n' $((col_rows - scroll_top - visible_rows))
    else
      printf '\n'
    fi

    # Chromatic themes (two-column, below editor themes)
    if [ $chrom_dark_count -gt 0 ] || [ $chrom_light_count -gt 0 ]; then
      printf '  \033[1;35m%-*s\033[0m \033[1;35m%s\033[0m\n' "$col_width" "◆ Chromatic Dark" "◇ Chromatic Light"
      local crow=0
      while [ $crow -lt $chrom_col_rows ]; do
        local cl_name="" cr_name=""
        [ $crow -lt $chrom_dark_count ] && cl_name="${chrom_dark_arr[$crow]}"
        [ $crow -lt $chrom_light_count ] && cr_name="${chrom_light_arr[$crow]}"

        if [ -n "$cl_name" ]; then
          if [ "$cur_region" -eq 2 ] && [ "$cur_idx" -eq "$crow" ]; then
            printf '  \033[7m▸ %-*s' $((col_width - 2)) "$cl_name"
            printf '\033[0m'
          else
            printf '   %-*s' $((col_width - 2)) "$cl_name"
          fi
        else
          printf '  %-*s' $((col_width - 1)) ""
        fi

        printf ' '

        if [ -n "$cr_name" ]; then
          if [ "$cur_region" -eq 3 ] && [ "$cur_idx" -eq "$crow" ]; then
            printf '\033[7m▸ %s\033[0m' "$cr_name"
          else
            printf '  %s' "$cr_name"
          fi
        fi

        printf '\n'
        crow=$((crow + 1))
      done
    fi

    # Semantic themes (single row, below columns)
    if [ $semantic_count -gt 0 ]; then
      printf '  \033[1;33m── Semantic ──\033[0m '
      for i in "${!semantic_arr[@]}"; do
        if [ "$cur_region" -eq 4 ] && [ "$cur_idx" -eq "$i" ]; then
          printf ' \033[7m %s \033[0m' "${semantic_arr[$i]}"
        else
          printf ' %s' "${semantic_arr[$i]}"
        fi
      done
      printf '\n'
    fi

    # User themes
    if [ $user_count -gt 0 ]; then
      printf '  \033[1;33m── User ──\033[0m '
      for i in "${!user_arr[@]}"; do
        if [ "$cur_region" -eq 5 ] && [ "$cur_idx" -eq "$i" ]; then
          printf ' \033[7m %s \033[0m' "${user_arr[$i]}"
        else
          printf ' %s' "${user_arr[$i]}"
        fi
      done
      printf '\n'
    fi

    # Swatch preview of current selection
    local cur_name="${all_names[$cursor]}"
    printf '\n  '
    _tabbing_theme_swatch "$cur_name" 2>/dev/null
    printf '  \033[1m%s\033[0m' "$cur_name"
    printf '\n  \033[2mApplied: %s\033[0m\n' "${TAB_THEME:-(none)}"
  }

  _tabbing_picker_render

  while [ $running -eq 1 ]; do
    local ch
    ch="$(dd bs=1 count=1 2>/dev/null)" || continue

    case "$ch" in
      q|Q)
        if [ -n "$original_theme" ]; then
          _tabbing_apply_named_theme "$original_theme" 2>/dev/null
        else
          _tabbing_clear_theme 2>/dev/null
        fi
        running=0
        ;;

      "")
        # Enter
        selected="${all_names[$cursor]}"
        export TAB_THEME="$selected"
        _tabbing_apply_named_theme "$selected" 2>/dev/null
        action="applied"
        running=0
        ;;

      $'\033'|"$(printf '\033')")
        local seq1 seq2
        seq1="$(dd bs=1 count=1 2>/dev/null)" || continue
        seq2="$(dd bs=1 count=1 2>/dev/null)" || continue

        case "${seq1}${seq2}" in
          "[A") # Up
            local r=${all_region[$cursor]} idx=${all_index[$cursor]}
            if [ $idx -gt 0 ]; then
              local p; p=$(_tabbing_find_pos "$r" $((idx - 1)))
              [ "$p" -ge 0 ] && cursor=$p
            elif [ "$r" -eq 2 ] && [ $dark_count -gt 0 ]; then
              local p; p=$(_tabbing_find_pos 0 $((dark_count - 1)))
              [ "$p" -ge 0 ] && cursor=$p
            elif [ "$r" -eq 3 ] && [ $light_count -gt 0 ]; then
              local p; p=$(_tabbing_find_pos 1 $((light_count - 1)))
              [ "$p" -ge 0 ] && cursor=$p
            elif [ "$r" -eq 4 ] && [ $chrom_dark_count -gt 0 ]; then
              local p; p=$(_tabbing_find_pos 2 $((chrom_dark_count - 1)))
              [ "$p" -ge 0 ] && cursor=$p
            elif [ "$r" -eq 5 ] && [ $semantic_count -gt 0 ]; then
              local p; p=$(_tabbing_find_pos 4 $((semantic_count - 1)))
              [ "$p" -ge 0 ] && cursor=$p
            fi
            ;;

          "[B") # Down
            local r=${all_region[$cursor]} idx=${all_index[$cursor]}
            if [ "$r" -eq 0 ]; then
              if [ $((idx + 1)) -lt $dark_count ]; then
                local p; p=$(_tabbing_find_pos 0 $((idx + 1)))
                [ "$p" -ge 0 ] && cursor=$p
              elif [ $chrom_dark_count -gt 0 ]; then
                local p; p=$(_tabbing_find_pos 2 0)
                [ "$p" -ge 0 ] && cursor=$p
              elif [ $semantic_count -gt 0 ]; then
                local p; p=$(_tabbing_find_pos 4 0)
                [ "$p" -ge 0 ] && cursor=$p
              fi
            elif [ "$r" -eq 1 ]; then
              if [ $((idx + 1)) -lt $light_count ]; then
                local p; p=$(_tabbing_find_pos 1 $((idx + 1)))
                [ "$p" -ge 0 ] && cursor=$p
              elif [ $chrom_light_count -gt 0 ]; then
                local p; p=$(_tabbing_find_pos 3 0)
                [ "$p" -ge 0 ] && cursor=$p
              elif [ $semantic_count -gt 0 ]; then
                local p; p=$(_tabbing_find_pos 4 0)
                [ "$p" -ge 0 ] && cursor=$p
              fi
            elif [ "$r" -eq 2 ]; then
              if [ $((idx + 1)) -lt $chrom_dark_count ]; then
                local p; p=$(_tabbing_find_pos 2 $((idx + 1)))
                [ "$p" -ge 0 ] && cursor=$p
              elif [ $semantic_count -gt 0 ]; then
                local p; p=$(_tabbing_find_pos 4 0)
                [ "$p" -ge 0 ] && cursor=$p
              fi
            elif [ "$r" -eq 3 ]; then
              if [ $((idx + 1)) -lt $chrom_light_count ]; then
                local p; p=$(_tabbing_find_pos 3 $((idx + 1)))
                [ "$p" -ge 0 ] && cursor=$p
              elif [ $semantic_count -gt 0 ]; then
                local p; p=$(_tabbing_find_pos 4 0)
                [ "$p" -ge 0 ] && cursor=$p
              fi
            elif [ "$r" -eq 4 ]; then
              if [ $((idx + 1)) -lt $semantic_count ]; then
                local p; p=$(_tabbing_find_pos 4 $((idx + 1)))
                [ "$p" -ge 0 ] && cursor=$p
              elif [ $user_count -gt 0 ]; then
                local p; p=$(_tabbing_find_pos 5 0)
                [ "$p" -ge 0 ] && cursor=$p
              fi
            elif [ "$r" -eq 5 ]; then
              if [ $((idx + 1)) -lt $user_count ]; then
                local p; p=$(_tabbing_find_pos 5 $((idx + 1)))
                [ "$p" -ge 0 ] && cursor=$p
              fi
            fi
            ;;

          "[C") # Right — switch columns or advance in horizontal sections
            local r=${all_region[$cursor]} idx=${all_index[$cursor]}
            if [ "$r" -eq 0 ] && [ $light_count -gt 0 ]; then
              local target_idx=$idx
              [ $target_idx -ge $light_count ] && target_idx=$((light_count - 1))
              local p; p=$(_tabbing_find_pos 1 $target_idx)
              [ "$p" -ge 0 ] && cursor=$p
            elif [ "$r" -eq 2 ] && [ $chrom_light_count -gt 0 ]; then
              local target_idx=$idx
              [ $target_idx -ge $chrom_light_count ] && target_idx=$((chrom_light_count - 1))
              local p; p=$(_tabbing_find_pos 3 $target_idx)
              [ "$p" -ge 0 ] && cursor=$p
            elif [ "$r" -eq 4 ]; then
              if [ $((idx + 1)) -lt $semantic_count ]; then
                local p; p=$(_tabbing_find_pos 4 $((idx + 1)))
                [ "$p" -ge 0 ] && cursor=$p
              fi
            elif [ "$r" -eq 5 ]; then
              if [ $((idx + 1)) -lt $user_count ]; then
                local p; p=$(_tabbing_find_pos 5 $((idx + 1)))
                [ "$p" -ge 0 ] && cursor=$p
              fi
            fi
            ;;

          "[D") # Left — switch columns or retreat in horizontal sections
            local r=${all_region[$cursor]} idx=${all_index[$cursor]}
            if [ "$r" -eq 1 ] && [ $dark_count -gt 0 ]; then
              local target_idx=$idx
              [ $target_idx -ge $dark_count ] && target_idx=$((dark_count - 1))
              local p; p=$(_tabbing_find_pos 0 $target_idx)
              [ "$p" -ge 0 ] && cursor=$p
            elif [ "$r" -eq 3 ] && [ $chrom_dark_count -gt 0 ]; then
              local target_idx=$idx
              [ $target_idx -ge $chrom_dark_count ] && target_idx=$((chrom_dark_count - 1))
              local p; p=$(_tabbing_find_pos 2 $target_idx)
              [ "$p" -ge 0 ] && cursor=$p
            elif [ "$r" -eq 4 ]; then
              if [ $idx -gt 0 ]; then
                local p; p=$(_tabbing_find_pos 4 $((idx - 1)))
                [ "$p" -ge 0 ] && cursor=$p
              fi
            elif [ "$r" -eq 5 ]; then
              if [ $idx -gt 0 ]; then
                local p; p=$(_tabbing_find_pos 5 $((idx - 1)))
                [ "$p" -ge 0 ] && cursor=$p
              fi
            fi
            ;;

          "[5") # Page Up
            dd bs=1 count=1 2>/dev/null >/dev/null
            local r=${all_region[$cursor]} idx=${all_index[$cursor]}
            local new_idx=$((idx - 8))
            [ $new_idx -lt 0 ] && new_idx=0
            local p; p=$(_tabbing_find_pos "$r" $new_idx)
            [ "$p" -ge 0 ] && cursor=$p
            ;;

          "[6") # Page Down
            dd bs=1 count=1 2>/dev/null >/dev/null
            local r=${all_region[$cursor]} idx=${all_index[$cursor]}
            local max_idx=0
            case $r in
              0) max_idx=$((dark_count - 1)) ;;
              1) max_idx=$((light_count - 1)) ;;
              2) max_idx=$((chrom_dark_count - 1)) ;;
              3) max_idx=$((chrom_light_count - 1)) ;;
              4) max_idx=$((semantic_count - 1)) ;;
              5) max_idx=$((user_count - 1)) ;;
            esac
            local new_idx=$((idx + 8))
            [ $new_idx -gt $max_idx ] && new_idx=$max_idx
            local p; p=$(_tabbing_find_pos "$r" $new_idx)
            [ "$p" -ge 0 ] && cursor=$p
            ;;
        esac

        # Live preview
        _tabbing_apply_named_theme "${all_names[$cursor]}" 2>/dev/null
        _tabbing_picker_render
        ;;

      c|C)
        local src="${all_names[$cursor]}"
        printf '\033[?1049l'
        stty echo icanon 2>/dev/null
        printf 'Clone "%s" as: ' "$src"
        local clone_name
        read -r clone_name
        if [ -n "$clone_name" ]; then
          _tabbing_clone_theme "$src" "$clone_name"
          # Rebuild user array
          user_arr=()
          local td; td="$(_tabbing_all_themes)"
          while IFS='|' read -r n c v; do
            [ "$c" = "user" ] && user_arr+=("$n")
          done <<EOFR
$td
EOFR
          user_count=${#user_arr[@]}
          # Rebuild all_ arrays
          all_names=() all_region=() all_index=()
          for i in "${!dark_arr[@]}"; do all_names+=("${dark_arr[$i]}"); all_region+=(0); all_index+=("$i"); done
          for i in "${!light_arr[@]}"; do all_names+=("${light_arr[$i]}"); all_region+=(1); all_index+=("$i"); done
          for i in "${!chrom_dark_arr[@]}"; do all_names+=("${chrom_dark_arr[$i]}"); all_region+=(2); all_index+=("$i"); done
          for i in "${!chrom_light_arr[@]}"; do all_names+=("${chrom_light_arr[$i]}"); all_region+=(3); all_index+=("$i"); done
          for i in "${!semantic_arr[@]}"; do all_names+=("${semantic_arr[$i]}"); all_region+=(4); all_index+=("$i"); done
          for i in "${!user_arr[@]}"; do all_names+=("${user_arr[$i]}"); all_region+=(5); all_index+=("$i"); done
          total=${#all_names[@]}
          printf 'Press any key to continue...'
          read -rsn1
        fi
        stty -echo -icanon 2>/dev/null
        printf '\033[?1049h'
        _tabbing_picker_render
        ;;

      e|E)
        local edit_target="${all_names[$cursor]}"
        printf '\033[?1049l'
        printf '\033[?25h'
        stty echo icanon 2>/dev/null
        _tabbing_edit_theme "$edit_target"
        stty -echo -icanon 2>/dev/null
        printf '\033[?25l'
        printf '\033[?1049h'
        _tabbing_picker_render
        ;;

      d|D)
        local del_target="${all_names[$cursor]}"
        printf '\033[?1049l'
        stty echo icanon 2>/dev/null
        _tabbing_delete_theme "$del_target"
        printf 'Press any key to continue...'
        read -rsn1
        stty -echo -icanon 2>/dev/null
        printf '\033[?1049h'
        _tabbing_picker_render
        ;;

      s|S)
        local save_target="${all_names[$cursor]}"
        printf '\033[?1049l'
        stty echo icanon 2>/dev/null
        printf 'Save theme "%s" to .envrc in directory [.]: ' "$save_target"
        local save_dir
        read -r save_dir
        [ -z "$save_dir" ] && save_dir="."
        _tabbing_save_theme_envrc "$save_target" "$save_dir"
        printf 'Press any key to continue...'
        read -rsn1
        stty -echo -icanon 2>/dev/null
        printf '\033[?1049h'
        _tabbing_picker_render
        ;;

      r|R)
        _tabbing_clear_theme 2>/dev/null
        unset TAB_THEME
        _tabbing_picker_render
        ;;

      /)
        # Enter filter mode
        filter_mode=1
        filter_text=""
        _tabbing_apply_filter
        if [ ${#filtered_pos[@]} -gt 0 ]; then
          cursor=${filtered_pos[0]}
        fi
        _tabbing_picker_render

        # Filter input loop
        while [ $filter_mode -eq 1 ] && [ $running -eq 1 ]; do
          local fch
          fch="$(dd bs=1 count=1 2>/dev/null)" || continue

          case "$fch" in
            $'\033'|"$(printf '\033')")
              # Check for arrow keys vs bare escape
              local fs1 fs2
              fs1="$(dd bs=1 count=1 2>/dev/null)" || continue
              fs2="$(dd bs=1 count=1 2>/dev/null)" || continue

              case "${fs1}${fs2}" in
                "[A") # Up in filter
                  if [ ${#filtered_pos[@]} -gt 0 ]; then
                    local fi=0 fcount=${#filtered_pos[@]}
                    while [ $fi -lt $fcount ]; do
                      [ "${filtered_pos[$fi]}" -eq "$cursor" ] && break
                      fi=$((fi + 1))
                    done
                    [ $fi -gt 0 ] && cursor=${filtered_pos[$((fi - 1))]}
                    _tabbing_apply_named_theme "${all_names[$cursor]}" 2>/dev/null
                  fi
                  ;;
                "[B") # Down in filter
                  if [ ${#filtered_pos[@]} -gt 0 ]; then
                    local fi=0 fcount=${#filtered_pos[@]}
                    while [ $fi -lt $fcount ]; do
                      [ "${filtered_pos[$fi]}" -eq "$cursor" ] && break
                      fi=$((fi + 1))
                    done
                    [ $((fi + 1)) -lt $fcount ] && cursor=${filtered_pos[$((fi + 1))]}
                    _tabbing_apply_named_theme "${all_names[$cursor]}" 2>/dev/null
                  fi
                  ;;
                *)
                  # Bare escape — exit filter mode
                  filter_mode=0
                  filter_text=""
                  ;;
              esac
              _tabbing_picker_render
              ;;

            "") # Enter — apply from filter
              if [ ${#filtered_pos[@]} -gt 0 ]; then
                selected="${all_names[$cursor]}"
                export TAB_THEME="$selected"
                _tabbing_apply_named_theme "$selected" 2>/dev/null
                action="applied"
                running=0
                filter_mode=0
              fi
              ;;

            $'\177'|$'\010') # Backspace (DEL or BS)
              if [ -n "$filter_text" ]; then
                filter_text="${filter_text%?}"
                _tabbing_apply_filter
                if [ ${#filtered_pos[@]} -gt 0 ]; then
                  cursor=${filtered_pos[0]}
                  _tabbing_apply_named_theme "${all_names[$cursor]}" 2>/dev/null
                fi
              else
                filter_mode=0
                filter_text=""
              fi
              _tabbing_picker_render
              ;;

            *)
              # Printable character — append to filter
              filter_text="${filter_text}${fch}"
              _tabbing_apply_filter
              if [ ${#filtered_pos[@]} -gt 0 ]; then
                cursor=${filtered_pos[0]}
                _tabbing_apply_named_theme "${all_names[$cursor]}" 2>/dev/null
              fi
              _tabbing_picker_render
              ;;
          esac
        done
        ;;
    esac
  done

  printf '\033[?1049l'
  printf '\033[?25h'
  stty echo icanon 2>/dev/null

  if [ -n "$selected" ] && [ "$action" = "applied" ]; then
    _tabbing_apply_named_theme "$selected" >/dev/null 2>&1
    _tabbing_prompt_save_theme "$selected"
  fi
}

# ---------------------------------------------------------------------------
# Main entry point for tabbing-theme command
# ---------------------------------------------------------------------------
_tabbing_theme_cmd() {
  case "${1:-}" in
    ""|pick|select)
      _tabbing_theme_picker
      ;;
    list|ls)
      _tabbing_theme_list
      ;;
    apply|set)
      [ -z "${2:-}" ] && { echo "Usage: tabbing-theme apply <name>" >&2; return 1; }
      if _tabbing_apply_named_theme "$2"; then
        export TAB_THEME="$2"
        _tabbing_prompt_save_theme "$2"
      else
        printf 'Unknown theme: %s\n' "$2" >&2
        return 1
      fi
      ;;
    clone|copy)
      [ -z "${2:-}" ] && { echo "Usage: tabbing-theme clone <source> <new-name>" >&2; return 1; }
      [ -z "${3:-}" ] && { echo "Usage: tabbing-theme clone <source> <new-name>" >&2; return 1; }
      _tabbing_clone_theme "$2" "$3"
      ;;
    edit)
      [ -z "${2:-}" ] && { echo "Usage: tabbing-theme edit <name>" >&2; return 1; }
      _tabbing_edit_theme "$2"
      ;;
    delete|rm)
      [ -z "${2:-}" ] && { echo "Usage: tabbing-theme delete <name>" >&2; return 1; }
      _tabbing_delete_theme "$2"
      ;;
    save|envrc)
      local theme="${2:-${TAB_THEME:-}}"
      local dir="${3:-.}"
      [ -z "$theme" ] && { echo "Usage: tabbing-theme save [theme] [directory]" >&2; return 1; }
      _tabbing_save_theme_envrc "$theme" "$dir"
      ;;
    export)
      [ -z "${2:-}" ] && { echo "Usage: tabbing-theme export <name>" >&2; return 1; }
      _tabbing_export_builtin_theme "$2" || {
        local theme_dir
        theme_dir="$(_tabbing_theme_dir)"
        local file="${theme_dir}/${2}.theme"
        if [ -f "$file" ]; then
          cat "$file"
        else
          printf 'Unknown theme: %s\n' "$2" >&2
          return 1
        fi
      }
      ;;
    reset|clear)
      _tabbing_clear_theme 2>/dev/null
      unset TAB_THEME
      printf 'Theme cleared. Terminal reset to defaults.\n'
      ;;
    preview)
      [ -z "${2:-}" ] && { echo "Usage: tabbing-theme preview <name>" >&2; return 1; }
      if _tabbing_apply_named_theme "$2"; then
        export TAB_THEME="$2"
        printf 'Previewing theme "%s" — use "tabbing-theme reset" to undo.\n' "$2"
      else
        printf 'Unknown theme: %s\n' "$2" >&2
        return 1
      fi
      ;;
    help|--help|-h)
      _tabbing_theme_help
      ;;
    *)
      # Try as theme name (shorthand for apply)
      if _tabbing_apply_named_theme "$1" 2>/dev/null; then
        export TAB_THEME="$1"
        _tabbing_prompt_save_theme "$1"
      else
        printf 'Unknown subcommand or theme: %s\n' "$1" >&2
        _tabbing_theme_help
        return 1
      fi
      ;;
  esac
}

_tabbing_theme_help() {
  cat <<'HELP'
tabbing-theme — browse, apply, and manage terminal themes

Usage:
  tabbing-theme               Interactive theme picker (arrow keys)
  tabbing-theme <name>        Apply a theme by name
  tabbing-theme list           List all available themes
  tabbing-theme apply <name>   Apply a theme
  tabbing-theme preview <name> Preview a theme (same as apply)
  tabbing-theme clone <src> <name>  Clone theme to user themes
  tabbing-theme edit <name>    Edit a user theme in $EDITOR
  tabbing-theme delete <name>  Delete a user theme
  tabbing-theme export <name>  Print theme as .theme file format
  tabbing-theme save [name] [dir]   Write TAB_THEME to .envrc
  tabbing-theme reset          Clear theme, restore terminal defaults

Interactive picker keys:
  ←/→        Switch between Dark and Light columns
  ↑/↓        Navigate within column (live preview)
  /          Filter/search themes by name
  Enter      Apply selected theme and exit
  c          Clone selected theme
  e          Edit selected theme (user themes only)
  d          Delete selected theme (user themes only)
  s          Save selected theme to .envrc
  r          Reset to terminal defaults
  q          Quit (restore original theme)
HELP
}
