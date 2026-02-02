# Textual TUI Implementation Guide

> Terminal User Interface patterns using Textual (Python) for CLI applications, developer tools, and terminal-based products.

---

## 1. When to Use Textual

### 1.1 Best Use Cases

| Use Case | Why Textual |
|----------|-------------|
| Developer tools | Native terminal environment |
| CLI dashboards | Real-time data display |
| System monitors | Low resource overhead |
| Data pipelines | Interactive configuration |
| SSH-accessible UIs | Works over remote connections |
| Accessibility | Screen reader compatible |

### 1.2 When NOT to Use

- Consumer products (use web instead)
- Image-heavy interfaces
- Complex form wizards (consider web)
- Non-technical users (unfamiliar with terminal)

---

## 2. Setup

### 2.1 Installation

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # or `venv\Scripts\activate` on Windows

# Install Textual
pip install textual

# Development mode (hot reload)
pip install textual-dev
```

### 2.2 Project Structure

```
my_tui/
├── __init__.py
├── app.py           # Main application
├── screens/         # Screen classes
│   ├── __init__.py
│   ├── home.py
│   ├── settings.py
│   └── detail.py
├── components/      # Reusable widgets
│   ├── __init__.py
│   ├── header.py
│   ├── sidebar.py
│   └── data_table.py
├── styles/          # CSS files
│   ├── app.tcss     # Global styles
│   └── components.tcss
└── utils/
    └── __init__.py
```

---

## 3. Basic Application

### 3.1 Starter Template

```python
# app.py
from textual.app import App, ComposeResult
from textual.containers import Container, Horizontal, Vertical
from textual.widgets import Header, Footer, Static, Button, Input
from textual.binding import Binding


class MyApp(App):
    """Main application."""
    
    CSS_PATH = "styles/app.tcss"
    BINDINGS = [
        Binding("q", "quit", "Quit"),
        Binding("d", "toggle_dark", "Toggle Dark Mode"),
        Binding("?", "help", "Help"),
    ]
    
    def compose(self) -> ComposeResult:
        yield Header()
        yield Container(
            Sidebar(id="sidebar"),
            MainContent(id="main"),
            id="app-grid",
        )
        yield Footer()
    
    def action_toggle_dark(self) -> None:
        self.dark = not self.dark
    
    def action_help(self) -> None:
        self.push_screen("help")


class Sidebar(Static):
    """Navigation sidebar."""
    
    def compose(self) -> ComposeResult:
        yield Static("Navigation", classes="sidebar-title")
        yield Button("Dashboard", id="nav-dashboard", variant="primary")
        yield Button("Settings", id="nav-settings")
        yield Button("About", id="nav-about")
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "nav-dashboard":
            self.app.query_one("#main").update_content("dashboard")
        elif event.button.id == "nav-settings":
            self.app.query_one("#main").update_content("settings")


class MainContent(Static):
    """Main content area."""
    
    def compose(self) -> ComposeResult:
        yield Static("Welcome to MyApp", id="content-title")
        yield Static("Select an option from the sidebar.", id="content-body")
    
    def update_content(self, section: str) -> None:
        title = self.query_one("#content-title", Static)
        body = self.query_one("#content-body", Static)
        
        if section == "dashboard":
            title.update("Dashboard")
            body.update("Your dashboard content here...")
        elif section == "settings":
            title.update("Settings")
            body.update("Settings options here...")


if __name__ == "__main__":
    app = MyApp()
    app.run()
```

### 3.2 Basic Styles

```css
/* styles/app.tcss */

Screen {
    background: $surface;
}

#app-grid {
    layout: grid;
    grid-size: 2;
    grid-columns: 1fr 3fr;
    height: 100%;
}

#sidebar {
    width: 100%;
    height: 100%;
    background: $panel;
    border-right: solid $primary;
    padding: 1;
}

.sidebar-title {
    text-style: bold;
    color: $text;
    padding-bottom: 1;
    border-bottom: solid $primary-darken-2;
    margin-bottom: 1;
}

#sidebar Button {
    width: 100%;
    margin-bottom: 1;
}

#main {
    padding: 2;
}

#content-title {
    text-style: bold;
    color: $primary;
    padding-bottom: 1;
}
```

---

## 4. Components

### 4.1 Data Table

```python
# components/data_table.py
from textual.widgets import DataTable
from textual.app import ComposeResult


class StyledDataTable(DataTable):
    """Pre-styled data table."""
    
    DEFAULT_CSS = """
    StyledDataTable {
        height: auto;
        max-height: 20;
        border: solid $primary;
    }
    
    StyledDataTable > .datatable--header {
        background: $primary;
        color: $text;
        text-style: bold;
    }
    
    StyledDataTable > .datatable--cursor {
        background: $primary 30%;
    }
    """
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.cursor_type = "row"
        self.zebra_stripes = True


# Usage
class Dashboard(Static):
    def compose(self) -> ComposeResult:
        table = StyledDataTable(id="users-table")
        table.add_columns("ID", "Name", "Email", "Status")
        table.add_rows([
            ("1", "Alice", "alice@example.com", "Active"),
            ("2", "Bob", "bob@example.com", "Pending"),
            ("3", "Charlie", "charlie@example.com", "Active"),
        ])
        yield table
```

### 4.2 Card Component

```python
# components/card.py
from textual.widgets import Static
from textual.app import ComposeResult
from textual.containers import Vertical


class Card(Static):
    """Card container with title."""
    
    DEFAULT_CSS = """
    Card {
        border: solid $primary;
        padding: 1 2;
        margin: 1;
        background: $surface;
    }
    
    Card > .card-title {
        text-style: bold;
        color: $primary;
        padding-bottom: 1;
        border-bottom: dashed $primary-darken-2;
        margin-bottom: 1;
    }
    
    Card > .card-content {
        color: $text;
    }
    """
    
    def __init__(self, title: str, content: str, **kwargs):
        super().__init__(**kwargs)
        self.title = title
        self.content = content
    
    def compose(self) -> ComposeResult:
        yield Static(self.title, classes="card-title")
        yield Static(self.content, classes="card-content")


# Usage
yield Card("Server Status", "All systems operational ✓")
```

### 4.3 Stats Widget

```python
# components/stats.py
from textual.widgets import Static
from textual.containers import Horizontal


class StatWidget(Static):
    """Single stat display."""
    
    DEFAULT_CSS = """
    StatWidget {
        width: auto;
        padding: 1 2;
        background: $panel;
        border: solid $primary-darken-2;
        margin: 0 1;
    }
    
    StatWidget .stat-value {
        text-style: bold;
        color: $primary;
    }
    
    StatWidget .stat-label {
        color: $text-muted;
    }
    """
    
    def __init__(self, label: str, value: str, **kwargs):
        super().__init__(**kwargs)
        self.label = label
        self.value = value
    
    def compose(self):
        yield Static(self.value, classes="stat-value")
        yield Static(self.label, classes="stat-label")


class StatsRow(Horizontal):
    """Row of stat widgets."""
    
    DEFAULT_CSS = """
    StatsRow {
        height: auto;
        padding: 1;
    }
    """
    
    def __init__(self, stats: list[tuple[str, str]], **kwargs):
        super().__init__(**kwargs)
        self.stats = stats
    
    def compose(self):
        for label, value in self.stats:
            yield StatWidget(label, value)


# Usage
yield StatsRow([
    ("Total Users", "1,234"),
    ("Active Now", "56"),
    ("Revenue", "$12.3K"),
    ("Growth", "+23%"),
])
```

### 4.4 Progress Indicator

```python
# components/progress.py
from textual.widgets import Static, ProgressBar
from textual.containers import Vertical


class LabeledProgress(Static):
    """Progress bar with label."""
    
    DEFAULT_CSS = """
    LabeledProgress {
        height: auto;
        margin: 1 0;
    }
    
    LabeledProgress .progress-label {
        margin-bottom: 1;
    }
    """
    
    def __init__(self, label: str, progress: float = 0, **kwargs):
        super().__init__(**kwargs)
        self.label = label
        self._progress = progress
    
    def compose(self):
        yield Static(f"{self.label}: {int(self._progress * 100)}%", classes="progress-label")
        yield ProgressBar(total=100, show_eta=False)
    
    def on_mount(self):
        self.query_one(ProgressBar).update(progress=self._progress * 100)
    
    def update_progress(self, progress: float):
        self._progress = progress
        self.query_one(".progress-label", Static).update(
            f"{self.label}: {int(progress * 100)}%"
        )
        self.query_one(ProgressBar).update(progress=progress * 100)
```

---

## 5. Forms

### 5.1 Input Form

```python
# components/form.py
from textual.app import ComposeResult
from textual.widgets import Static, Input, Button
from textual.containers import Vertical, Horizontal
from textual.validation import Length, Regex


class FormField(Vertical):
    """Labeled form field."""
    
    DEFAULT_CSS = """
    FormField {
        height: auto;
        margin-bottom: 1;
    }
    
    FormField > .field-label {
        margin-bottom: 0;
    }
    
    FormField > Input {
        margin-top: 0;
    }
    
    FormField > .field-error {
        color: $error;
        margin-top: 0;
    }
    """
    
    def __init__(
        self,
        label: str,
        field_id: str,
        placeholder: str = "",
        password: bool = False,
        validators: list = None,
        **kwargs
    ):
        super().__init__(**kwargs)
        self.label = label
        self.field_id = field_id
        self.placeholder = placeholder
        self.password = password
        self.validators = validators or []
    
    def compose(self) -> ComposeResult:
        yield Static(self.label, classes="field-label")
        yield Input(
            placeholder=self.placeholder,
            password=self.password,
            validators=self.validators,
            id=self.field_id,
        )
        yield Static("", classes="field-error")


class LoginForm(Static):
    """Login form example."""
    
    DEFAULT_CSS = """
    LoginForm {
        width: 50;
        height: auto;
        padding: 2;
        border: solid $primary;
        background: $surface;
    }
    
    LoginForm .form-title {
        text-style: bold;
        text-align: center;
        padding-bottom: 2;
    }
    
    LoginForm .form-actions {
        margin-top: 2;
        align: center middle;
    }
    """
    
    def compose(self) -> ComposeResult:
        yield Static("Login", classes="form-title")
        yield FormField(
            label="Email",
            field_id="email",
            placeholder="you@example.com",
            validators=[Regex(r"^[\w\.-]+@[\w\.-]+\.\w+$", "Invalid email")],
        )
        yield FormField(
            label="Password",
            field_id="password",
            placeholder="••••••••",
            password=True,
            validators=[Length(minimum=8, failure_description="Min 8 characters")],
        )
        yield Horizontal(
            Button("Cancel", variant="default"),
            Button("Login", variant="primary", id="submit"),
            classes="form-actions",
        )
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "submit":
            email = self.query_one("#email", Input).value
            password = self.query_one("#password", Input).value
            self.post_message(self.Submitted(email, password))
    
    class Submitted:
        def __init__(self, email: str, password: str):
            self.email = email
            self.password = password
```

---

## 6. Screens & Navigation

### 6.1 Multiple Screens

```python
# screens/home.py
from textual.screen import Screen
from textual.widgets import Static, Button
from textual.app import ComposeResult


class HomeScreen(Screen):
    """Home screen."""
    
    BINDINGS = [("escape", "app.pop_screen", "Back")]
    
    def compose(self) -> ComposeResult:
        yield Static("Home Screen", id="title")
        yield Button("Go to Settings", id="go-settings")
        yield Button("Go to Detail", id="go-detail")
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "go-settings":
            self.app.push_screen("settings")
        elif event.button.id == "go-detail":
            self.app.push_screen("detail")


# screens/settings.py
class SettingsScreen(Screen):
    """Settings screen."""
    
    BINDINGS = [("escape", "app.pop_screen", "Back")]
    
    def compose(self) -> ComposeResult:
        yield Static("Settings", id="title")
        yield Static("Configure your preferences here...")
        yield Button("Back", id="back")
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "back":
            self.app.pop_screen()


# app.py - Register screens
class MyApp(App):
    SCREENS = {
        "home": HomeScreen,
        "settings": SettingsScreen,
    }
    
    def on_mount(self) -> None:
        self.push_screen("home")
```

### 6.2 Modal Dialogs

```python
# components/modal.py
from textual.screen import ModalScreen
from textual.widgets import Static, Button
from textual.containers import Vertical, Horizontal
from textual.app import ComposeResult


class ConfirmModal(ModalScreen[bool]):
    """Confirmation dialog."""
    
    DEFAULT_CSS = """
    ConfirmModal {
        align: center middle;
    }
    
    ConfirmModal > Vertical {
        width: 50;
        height: auto;
        padding: 2;
        background: $surface;
        border: solid $primary;
    }
    
    ConfirmModal .modal-title {
        text-style: bold;
        padding-bottom: 1;
    }
    
    ConfirmModal .modal-actions {
        margin-top: 2;
        align: right middle;
    }
    """
    
    def __init__(self, title: str, message: str, **kwargs):
        super().__init__(**kwargs)
        self.title = title
        self.message = message
    
    def compose(self) -> ComposeResult:
        with Vertical():
            yield Static(self.title, classes="modal-title")
            yield Static(self.message)
            with Horizontal(classes="modal-actions"):
                yield Button("Cancel", id="cancel")
                yield Button("Confirm", variant="primary", id="confirm")
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        self.dismiss(event.button.id == "confirm")


# Usage
async def delete_item(self):
    confirmed = await self.app.push_screen_wait(
        ConfirmModal("Delete Item", "Are you sure you want to delete this item?")
    )
    if confirmed:
        # Do deletion
        pass
```

---

## 7. Real-Time Updates

### 7.1 Reactive Data

```python
from textual.app import App
from textual.reactive import reactive
from textual.widgets import Static


class StatusWidget(Static):
    """Widget that updates reactively."""
    
    status = reactive("idle")
    count = reactive(0)
    
    def watch_status(self, status: str) -> None:
        self.update(f"Status: {status}")
    
    def watch_count(self, count: int) -> None:
        # Called when count changes
        pass


class MyApp(App):
    def compose(self):
        yield StatusWidget(id="status")
    
    async def on_mount(self):
        # Simulate updates
        import asyncio
        widget = self.query_one("#status", StatusWidget)
        
        for i in range(10):
            await asyncio.sleep(1)
            widget.count = i
            widget.status = f"Processing {i}/10"
```

### 7.2 Workers for Background Tasks

```python
from textual.app import App
from textual.widgets import Static, Button, ProgressBar
from textual.worker import Worker, get_current_worker


class DownloadApp(App):
    def compose(self):
        yield Static("Download Progress")
        yield ProgressBar(total=100, id="progress")
        yield Button("Start Download", id="start")
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "start":
            self.download_file()
    
    @work(exclusive=True)
    async def download_file(self) -> None:
        """Background download task."""
        import asyncio
        
        progress = self.query_one("#progress", ProgressBar)
        worker = get_current_worker()
        
        for i in range(101):
            if worker.is_cancelled:
                return
            
            progress.update(progress=i)
            await asyncio.sleep(0.05)
        
        self.notify("Download complete!")
```

---

## 8. Design Token Integration

### 8.1 Custom Theme

```css
/* styles/app.tcss */

/* Define custom colors */
$primary: #3B82F6;
$primary-darken-1: #2563EB;
$primary-darken-2: #1D4ED8;
$secondary: #64748B;
$success: #22C55E;
$warning: #F59E0B;
$error: #EF4444;

$surface: #FFFFFF;
$surface-darken-1: #F8FAFC;
$panel: #F1F5F9;

$text: #1E293B;
$text-muted: #64748B;

/* Dark mode overrides */
$dark-primary: #60A5FA;
$dark-surface: #0F172A;
$dark-panel: #1E293B;
$dark-text: #F8FAFC;
```

### 8.2 Component Variants

```css
/* Buttons */
Button {
    background: $secondary;
    color: $text;
    border: none;
    padding: 0 2;
}

Button:hover {
    background: $secondary 80%;
}

Button.-primary {
    background: $primary;
    color: white;
}

Button.-primary:hover {
    background: $primary-darken-1;
}

Button.-success {
    background: $success;
}

Button.-error {
    background: $error;
}
```

---

## 9. Testing

### 9.1 Unit Tests

```python
# tests/test_app.py
import pytest
from textual.pilot import Pilot

from my_tui.app import MyApp


@pytest.mark.asyncio
async def test_navigation():
    app = MyApp()
    async with app.run_test() as pilot:
        # Check initial state
        assert app.screen.id == "home"
        
        # Click navigation button
        await pilot.click("#nav-settings")
        
        # Verify navigation occurred
        assert "settings" in app.query_one("#main").content


@pytest.mark.asyncio
async def test_form_submission():
    app = MyApp()
    async with app.run_test() as pilot:
        # Fill form
        await pilot.click("#email")
        await pilot.type("test@example.com")
        
        await pilot.click("#password")
        await pilot.type("password123")
        
        # Submit
        await pilot.click("#submit")
        
        # Check result
        assert app.submitted_email == "test@example.com"
```

### 9.2 Snapshot Tests

```python
# tests/test_snapshots.py
from textual.pilot import Pilot


@pytest.mark.asyncio
async def test_home_screen_snapshot(snap_compare):
    assert snap_compare("my_tui/app.py")
```

---

## 10. Distribution

### 10.1 PyPI Package

```toml
# pyproject.toml
[project]
name = "my-tui"
version = "0.1.0"
description = "A terminal UI application"
requires-python = ">=3.8"
dependencies = [
    "textual>=0.40.0",
]

[project.scripts]
my-tui = "my_tui.app:main"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

### 10.2 Binary Distribution (PyInstaller)

```bash
# Install PyInstaller
pip install pyinstaller

# Create binary
pyinstaller --onefile --name my-tui app.py

# Output in dist/my-tui
```

---

## References

- Textual documentation: https://textual.textualize.io/
- `CORE.md` - Design principles
- `WIREFRAMES.md` - ASCII wireframes for planning
- `PATTERNS/components.md` - Component patterns

---

*Version: 0.1.0*
