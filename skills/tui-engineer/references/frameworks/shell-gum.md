# Shell — gum + dialog + whiptail + ANSI

## Part 1: gum (Modern, from Charm)

### Overview

**gum** is a standalone binary from the Charm ecosystem. It provides beautiful, composable UI components you call from shell scripts. Each command reads/writes stdin/stdout, so they chain naturally with pipes.

### Installation

```bash
# macOS
brew install gum

# Debian/Ubuntu
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt update && sudo apt install gum

# Go
go install github.com/charmbracelet/gum@latest

# Binary
# Download from https://github.com/charmbracelet/gum/releases
```

### Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `gum choose` | Select from list | `gum choose "opt1" "opt2" "opt3"` |
| `gum confirm` | Yes/no confirmation | `gum confirm "Delete file?"` |
| `gum file` | File picker | `gum file .` |
| `gum filter` | Fuzzy filter list | `ls \| gum filter` |
| `gum format` | Format markdown/code | `gum format -t markdown "# Title"` |
| `gum input` | Text input | `gum input --placeholder "Name"` |
| `gum write` | Multi-line text | `gum write --placeholder "Description"` |
| `gum spin` | Spinner with command | `gum spin --title "Building..." -- make build` |
| `gum style` | Style text | `gum style --foreground 212 "styled"` |
| `gum table` | Render table from CSV | `gum table < data.csv` |
| `gum log` | Structured logging | `gum log --level info "Starting..."` |
| `gum join` | Join text blocks | `gum join --horizontal block1 block2` |
| `gum pager` | Scrollable pager | `cat file.log \| gum pager` |

### Composition Examples

```bash
#!/usr/bin/env bash

# Interactive git commit
TYPE=$(gum choose "fix" "feat" "docs" "style" "refactor" "test" "chore")
SCOPE=$(gum input --placeholder "scope")
SUMMARY=$(gum input --value "$TYPE($SCOPE): " --placeholder "Summary")
DESCRIPTION=$(gum write --placeholder "Details (optional)")

gum confirm "Commit?" && git commit -m "$SUMMARY" -m "$DESCRIPTION"

# File picker with preview
FILE=$(gum file .)
gum pager < "$FILE"

# Multi-select
PACKAGES=$(gum choose --no-limit "react" "vue" "svelte" "angular")
echo "Installing: $PACKAGES"

# Styled output
gum style \
    --border double \
    --border-foreground 212 \
    --padding "1 2" \
    --margin "1" \
    --bold \
    "Deploy Complete"

# Spinner with real command
gum spin --spinner dot --title "Running tests..." -- npm test
```

### Styling via Environment

```bash
export GUM_CHOOSE_CURSOR_FOREGROUND="212"
export GUM_CHOOSE_HEADER_FOREGROUND="99"
export GUM_CHOOSE_SELECTED_FOREGROUND="212"
export GUM_INPUT_CURSOR_FOREGROUND="212"
export GUM_INPUT_PROMPT_FOREGROUND="99"
export GUM_CONFIRM_PROMPT_FOREGROUND="212"
```

---

## Part 2: dialog / whiptail

### Overview

**dialog** uses ncurses to render dialog boxes from shell scripts. **whiptail** is a lighter alternative (uses newt) pre-installed on Debian/Ubuntu. Their CLI interfaces are nearly identical.

### Widget Types

```bash
# Message box
dialog --title "Info" --msgbox "Operation complete." 8 40

# Yes/No
dialog --title "Confirm" --yesno "Delete all files?" 8 40
if [ $? -eq 0 ]; then echo "Yes"; else echo "No"; fi

# Input box
NAME=$(dialog --title "Name" --inputbox "Enter your name:" 8 40 2>&1 >/dev/tty)

# Password
PASS=$(dialog --title "Auth" --passwordbox "Password:" 8 40 2>&1 >/dev/tty)

# Menu
CHOICE=$(dialog --title "Menu" --menu "Choose:" 15 40 5 \
    1 "Build" \
    2 "Test" \
    3 "Deploy" \
    4 "Quit" 2>&1 >/dev/tty)

# Checklist (multi-select)
SELECTED=$(dialog --title "Features" --checklist "Select:" 15 40 5 \
    "logging" "Enable logging" on \
    "metrics" "Enable metrics" off \
    "tracing" "Enable tracing" off 2>&1 >/dev/tty)

# Radio list (single-select)
ENV=$(dialog --title "Environment" --radiolist "Select:" 15 40 3 \
    "dev" "Development" on \
    "staging" "Staging" off \
    "prod" "Production" off 2>&1 >/dev/tty)

# Gauge (progress bar)
for i in $(seq 0 10 100); do
    echo $i
    sleep 0.1
done | dialog --title "Progress" --gauge "Installing..." 8 40 0

# Form
dialog --title "Config" --form "Settings:" 15 50 3 \
    "Host:" 1 1 "localhost" 1 10 30 0 \
    "Port:" 2 1 "8080"      2 10 30 0 \
    "User:" 3 1 ""           3 10 30 0 2>&1 >/dev/tty
```

### Output Capture Pattern

dialog writes user input to stderr. Capture it:

```bash
# Method 1: fd swap
RESULT=$(dialog --inputbox "Name:" 8 40 2>&1 >/dev/tty)

# Method 2: temp file
exec 3>&1
RESULT=$(dialog --inputbox "Name:" 8 40 2>&1 1>&3)
exec 3>&-

# Method 3: --output-fd
dialog --output-fd 1 --inputbox "Name:" 8 40
```

---

## Part 3: Pure ANSI / tput

### Cursor Control

```bash
# tput
tput cup 5 10      # move to row 5, col 10
tput civis         # hide cursor
tput cnorm         # show cursor
tput clear         # clear screen
tput sc            # save cursor position
tput rc            # restore cursor position
tput cols          # get terminal width
tput lines         # get terminal height

# ANSI escape codes
printf '\e[H'      # move to top-left
printf '\e[2J'     # clear screen
printf '\e[%d;%dH' "$row" "$col"  # move to position
printf '\e[?25l'   # hide cursor
printf '\e[?25h'   # show cursor
printf '\e[s'      # save position
printf '\e[u'      # restore position
```

### Colors

```bash
# tput (portable)
tput setaf 1       # foreground red (0-7: black,red,green,yellow,blue,magenta,cyan,white)
tput setab 4       # background blue
tput sgr0          # reset all attributes
tput bold          # bold
tput smul          # underline on
tput rmul          # underline off

# ANSI basic (8 colors)
printf '\e[31m'    # red fg
printf '\e[42m'    # green bg
printf '\e[0m'     # reset

# ANSI 256-color
printf '\e[38;5;208m'  # orange fg (color 208)
printf '\e[48;5;17m'   # dark blue bg

# ANSI truecolor
printf '\e[38;2;255;165;0m'  # orange fg (RGB)
printf '\e[48;2;0;0;128m'    # navy bg (RGB)
```

### Box Drawing

```bash
draw_box() {
    local y=$1 x=$2 h=$3 w=$4
    local top_left="┌" top_right="┐" bot_left="└" bot_right="┘"
    local horiz="─" vert="│"

    # Top border
    printf '\e[%d;%dH%s' "$y" "$x" "$top_left"
    printf '%*s' "$((w-2))" '' | tr ' ' "$horiz"
    printf '%s' "$top_right"

    # Sides
    for ((i=1; i<h-1; i++)); do
        printf '\e[%d;%dH%s' "$((y+i))" "$x" "$vert"
        printf '\e[%d;%dH%s' "$((y+i))" "$((x+w-1))" "$vert"
    done

    # Bottom border
    printf '\e[%d;%dH%s' "$((y+h-1))" "$x" "$bot_left"
    printf '%*s' "$((w-2))" '' | tr ' ' "$horiz"
    printf '%s' "$bot_right"
}
```

### Interactive Menu

```bash
#!/usr/bin/env bash
set -euo pipefail

items=("Build" "Test" "Deploy" "Quit")
selected=0

cleanup() { tput cnorm; tput sgr0; printf '\e[?1049l'; }
trap cleanup EXIT

printf '\e[?1049h'  # alternate screen
tput civis          # hide cursor

draw_menu() {
    tput clear
    tput bold; tput setaf 6
    printf '\e[2;3H%s' "My TUI"
    tput sgr0

    printf '\e[3;3H%s' "────────────"

    for i in "${!items[@]}"; do
        if [[ $i -eq $selected ]]; then
            tput bold; tput setaf 3
            printf '\e[%d;3H▶ %s' "$((5+i))" "${items[$i]}"
            tput sgr0
        else
            printf '\e[%d;3H  %s' "$((5+i))" "${items[$i]}"
        fi
    done

    tput setaf 8
    printf '\e[%d;3H%s' "$((5+${#items[@]}+2))" "↑/↓: navigate • Enter: select • q: quit"
    tput sgr0
}

while true; do
    draw_menu
    IFS= read -rsn1 key
    case "$key" in
        $'\e')
            read -rsn2 -t 0.1 key
            case "$key" in
                '[A') ((selected > 0)) && ((selected--)) ;;
                '[B') ((selected < ${#items[@]}-1)) && ((selected++)) ;;
            esac
            ;;
        '') echo "Selected: ${items[$selected]}"; [[ "${items[$selected]}" == "Quit" ]] && break ;;
        q) break ;;
    esac
done
```

### Resize Handling

```bash
handle_resize() {
    COLS=$(tput cols)
    LINES=$(tput lines)
    draw_menu  # redraw
}
trap handle_resize SIGWINCH
```

---

## Part 4: Packaging & Distribution

### Homebrew Tap

```ruby
# Formula/my-tui.rb
class MyTui < Formula
  desc "My terminal UI application"
  homepage "https://github.com/user/my-tui"
  url "https://github.com/user/my-tui/archive/v1.0.0.tar.gz"
  sha256 "abc123..."

  def install
    bin.install "my-tui.sh" => "my-tui"
  end

  test do
    assert_match "version", shell_output("#{bin}/my-tui --version")
  end
end
```

### Makefile

```makefile
PREFIX ?= /usr/local

install:
	install -d $(PREFIX)/bin
	install -m 755 my-tui.sh $(PREFIX)/bin/my-tui

uninstall:
	rm -f $(PREFIX)/bin/my-tui
```

### Runtime Dependency Checking

```bash
check_deps() {
    local missing=()
    command -v gum >/dev/null 2>&1 || missing+=("gum")
    command -v jq >/dev/null 2>&1 || missing+=("jq")

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Missing dependencies: ${missing[*]}"
        echo "Install with: brew install ${missing[*]}"
        exit 1
    fi
}
```

### Terminal Capability Detection

```bash
detect_capabilities() {
    COLORS=$(tput colors 2>/dev/null || echo 8)
    HAS_TRUECOLOR=false
    [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]] && HAS_TRUECOLOR=true

    HAS_UNICODE=false
    case "$LANG$LC_ALL$LC_CTYPE" in
        *UTF-8*|*utf-8*|*utf8*) HAS_UNICODE=true ;;
    esac

    if [[ -n "${NO_COLOR:-}" ]]; then
        COLORS=0
    fi
}
```

### BATS Testing

```bash
# test/menu.bats
#!/usr/bin/env bats

@test "shows version" {
    run ./my-tui.sh --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"1.0"* ]]
}

@test "checks dependencies" {
    run bash -c 'PATH="" ./my-tui.sh'
    [ "$status" -ne 0 ]
    [[ "$output" == *"Missing"* ]]
}
```

```bash
# Run: bats test/
```
