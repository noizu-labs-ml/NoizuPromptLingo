# Go — bubbletea + lipgloss + bubbles

## Overview

**Bubbletea** implements the Elm Architecture in Go: your app is a `Model` with `Init`, `Update`, and `View` methods. The framework owns the event loop. **Lipgloss** handles styling (colors, borders, padding). **Bubbles** provides pre-built components. All from the Charm ecosystem.

Key packages:
- `github.com/charmbracelet/bubbletea` — framework
- `github.com/charmbracelet/lipgloss` — styling
- `github.com/charmbracelet/bubbles` — components (list, table, textinput, viewport, etc.)
- `github.com/charmbracelet/glamour` — markdown rendering
- `github.com/charmbracelet/gum` — standalone CLI (see shell-gum.md)

## Project Setup

```bash
mkdir my-tui && cd my-tui
go mod init github.com/user/my-tui
go get github.com/charmbracelet/bubbletea@latest
go get github.com/charmbracelet/lipgloss@latest
go get github.com/charmbracelet/bubbles@latest
```

```
my-tui/
├── go.mod
├── go.sum
├── main.go          # Entry point, tea.NewProgram
├── model.go         # Model struct, Init, Update, View
├── styles.go        # lipgloss styles
└── components/      # Custom bubble components (optional)
```

## Architecture

### The Model Interface

```go
type Model struct {
    choices  []string
    cursor   int
    selected map[int]struct{}
    width    int
    height   int
    quitting bool
}

func (m Model) Init() tea.Cmd {
    return nil // no initial command
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.KeyMsg:
        switch msg.String() {
        case "q", "ctrl+c":
            m.quitting = true
            return m, tea.Quit
        case "up", "k":
            if m.cursor > 0 { m.cursor-- }
        case "down", "j":
            if m.cursor < len(m.choices)-1 { m.cursor++ }
        case "enter", " ":
            if _, ok := m.selected[m.cursor]; ok {
                delete(m.selected, m.cursor)
            } else {
                m.selected[m.cursor] = struct{}{}
            }
        }
    case tea.WindowSizeMsg:
        m.width = msg.Width
        m.height = msg.Height
    }
    return m, nil
}

func (m Model) View() string {
    if m.quitting { return "" }
    s := "What should we buy?\n\n"
    for i, choice := range m.choices {
        cursor := " "
        if m.cursor == i { cursor = "▶" }
        checked := " "
        if _, ok := m.selected[i]; ok { checked = "×" }
        s += fmt.Sprintf("%s [%s] %s\n", cursor, checked, choice)
    }
    s += "\nPress q to quit.\n"
    return s
}
```

### Program Entry

```go
func main() {
    m := Model{
        choices:  []string{"Carrots", "Celery", "Ice Cream"},
        selected: make(map[int]struct{}),
    }
    p := tea.NewProgram(m, tea.WithAltScreen())
    if _, err := p.Run(); err != nil {
        fmt.Fprintf(os.Stderr, "Error: %v\n", err)
        os.Exit(1)
    }
}
```

**Program options:**
- `tea.WithAltScreen()` — use alternate screen buffer
- `tea.WithMouseCellMotion()` — enable mouse tracking
- `tea.WithMouseAllMotion()` — enable all mouse events
- `tea.WithOutput(w)` — custom output writer

### Commands (Cmd)

```go
// One-shot command
func fetchData() tea.Msg {
    resp, _ := http.Get("https://api.example.com/data")
    // ...
    return dataMsg{items: items}
}

// Return from Update:
return m, fetchData

// Tick command (recurring)
func tickCmd() tea.Cmd {
    return tea.Tick(time.Second, func(t time.Time) tea.Msg {
        return tickMsg(t)
    })
}

// Batch commands
return m, tea.Batch(cmd1, cmd2, cmd3)
```

## Bubbles Catalog

| Component | Import | Purpose |
|-----------|--------|---------|
| `list` | `bubbles/list` | Filterable, paginated list with fuzzy search |
| `table` | `bubbles/table` | Sortable data table |
| `textinput` | `bubbles/textinput` | Single-line text input with placeholder |
| `textarea` | `bubbles/textarea` | Multi-line text editor |
| `spinner` | `bubbles/spinner` | Animated spinner |
| `progress` | `bubbles/progress` | Progress bar with gradient |
| `paginator` | `bubbles/paginator` | Dot or number pagination |
| `viewport` | `bubbles/viewport` | Scrollable content viewport |
| `filepicker` | `bubbles/filepicker` | File system browser |
| `help` | `bubbles/help` | Keybinding help view |
| `key` | `bubbles/key` | Keybinding definitions |
| `timer` | `bubbles/timer` | Countdown timer |
| `stopwatch` | `bubbles/stopwatch` | Elapsed time counter |

### Using a Bubble (list example)

```go
import "github.com/charmbracelet/bubbles/list"

type item struct{ title, desc string }
func (i item) Title() string       { return i.title }
func (i item) Description() string { return i.desc }
func (i item) FilterValue() string { return i.title }

items := []list.Item{
    item{"Ratatouille", "A French classic"},
    item{"Pad Thai", "Thai street food"},
}

l := list.New(items, list.NewDefaultDelegate(), 30, 15)
l.Title = "Recipes"
```

## Lipgloss Styling

```go
import "github.com/charmbracelet/lipgloss"

var style = lipgloss.NewStyle().
    Bold(true).
    Foreground(lipgloss.Color("205")).      // 256-color
    Background(lipgloss.Color("#7D56F4")).   // hex truecolor
    PaddingTop(1).
    PaddingLeft(2).
    Width(22).
    Align(lipgloss.Center).
    Border(lipgloss.RoundedBorder()).
    BorderForeground(lipgloss.Color("63"))

output := style.Render("Hello, TUI!")

// Adaptive colors (light/dark terminal detection)
var adaptive = lipgloss.NewStyle().
    Foreground(lipgloss.AdaptiveColor{Light: "236", Dark: "248"})

// Composing layouts
lipgloss.JoinHorizontal(lipgloss.Top, leftPanel, rightPanel)
lipgloss.JoinVertical(lipgloss.Left, header, body, footer)
lipgloss.Place(width, height, lipgloss.Center, lipgloss.Center, content)
```

## Composing Models

```go
type MainModel struct {
    tabs     []string
    activeTab int
    pages    []tea.Model  // sub-models
    width    int
    height   int
}

func (m MainModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.KeyMsg:
        switch msg.String() {
        case "tab":
            m.activeTab = (m.activeTab + 1) % len(m.tabs)
            return m, nil
        }
    }
    // Delegate to active page
    var cmd tea.Cmd
    m.pages[m.activeTab], cmd = m.pages[m.activeTab].Update(msg)
    return m, cmd
}

func (m MainModel) View() string {
    tabs := renderTabs(m.tabs, m.activeTab)
    content := m.pages[m.activeTab].View()
    return lipgloss.JoinVertical(lipgloss.Left, tabs, content)
}
```

## Testing

```go
import "github.com/charmbracelet/x/exp/teatest"

func TestModel(t *testing.T) {
    m := NewModel()
    tm := teatest.NewTestModel(t, m, teatest.WithInitialTermSize(80, 24))

    tm.Send(tea.KeyMsg{Type: tea.KeyDown})
    tm.Send(tea.KeyMsg{Type: tea.KeyEnter})
    tm.Send(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune("q")})

    tm.WaitFinished(t, teatest.WithFinalTimeout(time.Second))

    // Golden file comparison
    out := tm.FinalOutput(t)
    teatest.RequireEqualOutput(t, out) // compares to testdata/*.golden
}

// Update golden files: go test -update
```

## Build & Release

```bash
# Dev
go run .

# Build
go build -o my-tui .

# Version injection
go build -ldflags "-X main.version=1.0.0 -X main.commit=$(git rev-parse --short HEAD)" .

# Cross-compilation
GOOS=linux GOARCH=amd64 go build -o my-tui-linux .
GOOS=darwin GOARCH=arm64 go build -o my-tui-mac .
GOOS=windows GOARCH=amd64 go build -o my-tui.exe .

# Static linking (no CGO)
CGO_ENABLED=0 go build -o my-tui .
```

### goreleaser

```yaml
# .goreleaser.yml
version: 2
builds:
  - env: [CGO_ENABLED=0]
    goos: [linux, darwin, windows]
    goarch: [amd64, arm64]
    ldflags:
      - -s -w
      - -X main.version={{.Version}}

archives:
  - format_overrides:
      - goos: windows
        format: zip

brews:
  - repository:
      owner: your-org
      name: homebrew-tap
    homepage: https://github.com/your-org/my-tui
    description: My TUI application
```

```bash
goreleaser init        # generate config
goreleaser check       # validate
goreleaser release --snapshot --clean  # local test
# CI: push tag → goreleaser GitHub Action
```

## Starter Template

```go
package main

import (
    "fmt"
    "os"

    tea "github.com/charmbracelet/bubbletea"
    "github.com/charmbracelet/lipgloss"
)

var (
    titleStyle    = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("205"))
    selectedStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("212"))
    normalStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("248"))
)

type model struct {
    items    []string
    cursor   int
    quitting bool
}

func initialModel() model {
    return model{items: []string{"Build a TUI", "Learn Go", "Ship it"}}
}

func (m model) Init() tea.Cmd { return nil }

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.KeyMsg:
        switch msg.String() {
        case "q", "ctrl+c":
            m.quitting = true
            return m, tea.Quit
        case "up", "k":
            if m.cursor > 0 { m.cursor-- }
        case "down", "j":
            if m.cursor < len(m.items)-1 { m.cursor++ }
        }
    }
    return m, nil
}

func (m model) View() string {
    if m.quitting { return "" }
    s := titleStyle.Render("My TUI") + "\n\n"
    for i, item := range m.items {
        if i == m.cursor {
            s += selectedStyle.Render("▶ " + item) + "\n"
        } else {
            s += normalStyle.Render("  " + item) + "\n"
        }
    }
    s += "\n" + lipgloss.NewStyle().Faint(true).Render("q: quit • ↑/↓: navigate")
    return s
}

func main() {
    if _, err := tea.NewProgram(initialModel(), tea.WithAltScreen()).Run(); err != nil {
        fmt.Fprintf(os.Stderr, "Error: %v\n", err)
        os.Exit(1)
    }
}
```
