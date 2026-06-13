# Java — Lanterna + JLine

## Part 1: Lanterna (Full TUI Framework)

### Overview

**Lanterna** provides a Swing-like GUI for the terminal with three abstraction layers:
1. **Terminal** — raw terminal control (like ncurses)
2. **Screen** — buffered screen with double-buffering
3. **GUI** — window/component system with layout managers

### Project Setup

**Maven:**
```xml
<dependency>
    <groupId>com.googlecode.lanterna</groupId>
    <artifactId>lanterna</artifactId>
    <version>3.1.2</version>
</dependency>
```

**Gradle:**
```groovy
implementation 'com.googlecode.lanterna:lanterna:3.1.2'
```

### Architecture

```java
import com.googlecode.lanterna.gui2.*;
import com.googlecode.lanterna.screen.*;
import com.googlecode.lanterna.terminal.*;

// Layer 1: Terminal (raw)
Terminal terminal = new DefaultTerminalFactory().createTerminal();

// Layer 2: Screen (buffered)
Screen screen = new TerminalScreen(terminal);
screen.startScreen();

// Layer 3: GUI (windowed)
MultiWindowTextGUI gui = new MultiWindowTextGUI(screen, new DefaultWindowManager(),
    new EmptySpace(TextColor.ANSI.BLUE));

BasicWindow window = new BasicWindow("My TUI");
// ... add components ...
gui.addWindowAndWait(window);

screen.stopScreen();
```

### Component Catalog

| Component | Purpose | Constructor |
|-----------|---------|-------------|
| `Label` | Static text | `new Label("text")` |
| `TextBox` | Single/multi-line input | `new TextBox(new TerminalSize(20, 1))` |
| `Button` | Clickable button | `new Button("OK", () -> { })` |
| `ActionListBox` | Selectable action list | `new ActionListBox(size)` |
| `CheckBoxList<T>` | Multi-select checkboxes | `new CheckBoxList<>(size)` |
| `RadioBoxList<T>` | Single-select radio buttons | `new RadioBoxList<>(size)` |
| `ComboBox<T>` | Dropdown selection | `new ComboBox<>(items)` |
| `Table<T>` | Data table | `new Table<>("Col1", "Col2")` |
| `Panel` | Container with border | `new Panel()` |
| `Separator` | Visual divider | `new Separator(Direction.HORIZONTAL)` |
| `ProgressBar` | Progress indicator | `new ProgressBar(0, 100, 30)` |

### Layout Managers

```java
// Linear (vertical or horizontal)
Panel panel = new Panel(new LinearLayout(Direction.VERTICAL));
panel.addComponent(new Label("Name:"));
panel.addComponent(new TextBox(new TerminalSize(20, 1)));

// Grid
Panel panel = new Panel(new GridLayout(2)); // 2 columns
panel.addComponent(new Label("Name:"));
panel.addComponent(new TextBox(new TerminalSize(20, 1)));
panel.addComponent(new Label("Email:"));
panel.addComponent(new TextBox(new TerminalSize(20, 1)));

// Border
Panel panel = new Panel(new BorderLayout());
panel.addComponent(new Label("Header"), BorderLayout.Location.TOP);
panel.addComponent(new Label("Content"), BorderLayout.Location.CENTER);
panel.addComponent(new Label("Footer"), BorderLayout.Location.BOTTOM);
```

### Styling

```java
import com.googlecode.lanterna.TextColor;
import com.googlecode.lanterna.SGR;

// ANSI colors
label.setForegroundColor(TextColor.ANSI.CYAN);
label.setBackgroundColor(TextColor.ANSI.BLACK);

// 256-color
new TextColor.Indexed(208);

// RGB
new TextColor.RGB(255, 165, 0);

// SGR modifiers
label.addStyle(SGR.BOLD);
label.addStyle(SGR.UNDERLINE);
label.addStyle(SGR.ITALIC);
```

### Event Handling

```java
// Button listener
Button btn = new Button("Submit", () -> {
    MessageDialog.showMessageDialog(gui, "Info", "Submitted!");
});

// Window close listener
window.addWindowListener(new WindowListenerAdapter() {
    @Override
    public void onInput(Window baseWindow, KeyStroke keyStroke, AtomicBoolean delivered) {
        if (keyStroke.getKeyType() == KeyType.Escape) {
            window.close();
        }
    }

    @Override
    public void onResized(Window window, TerminalSize oldSize, TerminalSize newSize) {
        // handle resize
    }
});

// Key types: KeyType.ArrowUp, ArrowDown, Enter, Escape, Tab, Character, F1-F12
```

### Starter Template

```java
import com.googlecode.lanterna.gui2.*;
import com.googlecode.lanterna.gui2.dialogs.*;
import com.googlecode.lanterna.screen.*;
import com.googlecode.lanterna.terminal.*;
import com.googlecode.lanterna.*;

public class MyTui {
    public static void main(String[] args) throws Exception {
        Terminal terminal = new DefaultTerminalFactory().createTerminal();
        Screen screen = new TerminalScreen(terminal);
        screen.startScreen();

        MultiWindowTextGUI gui = new MultiWindowTextGUI(screen,
            new DefaultWindowManager(), new EmptySpace(TextColor.ANSI.BLACK));

        BasicWindow window = new BasicWindow("My TUI");
        window.setHints(java.util.Arrays.asList(Window.Hint.FULL_SCREEN));

        Panel mainPanel = new Panel(new BorderLayout());

        // Header
        Panel header = new Panel(new LinearLayout(Direction.HORIZONTAL));
        header.addComponent(new Label("My TUI Application")
            .addStyle(SGR.BOLD)
            .setForegroundColor(TextColor.ANSI.CYAN));
        mainPanel.addComponent(header, BorderLayout.Location.TOP);
        mainPanel.addComponent(new Separator(Direction.HORIZONTAL), BorderLayout.Location.TOP);

        // Content
        ActionListBox list = new ActionListBox(new TerminalSize(40, 10));
        list.addItem("Build project", () ->
            MessageDialog.showMessageDialog(gui, "Action", "Building..."));
        list.addItem("Run tests", () ->
            MessageDialog.showMessageDialog(gui, "Action", "Testing..."));
        list.addItem("Deploy", () ->
            MessageDialog.showMessageDialog(gui, "Action", "Deploying..."));
        list.addItem("Quit", window::close);
        mainPanel.addComponent(list, BorderLayout.Location.CENTER);

        // Footer
        mainPanel.addComponent(
            new Label("↑/↓: navigate • Enter: select • Esc: quit")
                .setForegroundColor(TextColor.ANSI.WHITE_BRIGHT),
            BorderLayout.Location.BOTTOM);

        window.setComponent(mainPanel);
        gui.addWindowAndWait(window);
        screen.stopScreen();
    }
}
```

---

## Part 2: JLine 3 (Line Editing & Prompts)

### Overview

**JLine 3** provides sophisticated line editing, tab completion, syntax highlighting, and history for Java CLI apps. Not a full TUI framework but excellent for REPLs and interactive prompts.

### Setup

**Maven:**
```xml
<dependency>
    <groupId>org.jline</groupId>
    <artifactId>jline</artifactId>
    <version>3.26.3</version>
</dependency>
```

### REPL Example

```java
import org.jline.reader.*;
import org.jline.reader.impl.completer.*;
import org.jline.terminal.*;

public class MyRepl {
    public static void main(String[] args) throws Exception {
        Terminal terminal = TerminalBuilder.builder()
            .system(true)
            .build();

        Completer completer = new AggregateCompleter(
            new StringsCompleter("help", "quit", "build", "test", "deploy"),
            new FileNameCompleter()
        );

        LineReader reader = LineReaderBuilder.builder()
            .terminal(terminal)
            .completer(completer)
            .history(new DefaultHistory())
            .build();

        String prompt = "my-app> ";
        while (true) {
            String line;
            try {
                line = reader.readLine(prompt);
            } catch (UserInterruptException | EndOfFileException e) {
                break;
            }

            switch (line.trim()) {
                case "quit": return;
                case "help": System.out.println("Commands: help, quit, build, test, deploy"); break;
                default: System.out.println("Unknown: " + line);
            }
        }
    }
}
```

---

## Part 3: Build & Distribution

### Maven Fat JAR

```xml
<build>
  <plugins>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-shade-plugin</artifactId>
      <version>3.6.0</version>
      <executions>
        <execution>
          <phase>package</phase>
          <goals><goal>shade</goal></goals>
          <configuration>
            <transformers>
              <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                <mainClass>com.example.MyTui</mainClass>
              </transformer>
            </transformers>
          </configuration>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
```

```bash
mvn package
java -jar target/my-tui-1.0.0.jar
```

### Gradle Shadow JAR

```groovy
plugins {
    id 'com.gradleup.shadow' version '9.0.0-beta4'
    id 'application'
}

application {
    mainClass = 'com.example.MyTui'
}

// gradle shadowJar → build/libs/my-tui-all.jar
```

### GraalVM Native Image

```bash
# Install GraalVM and native-image
gu install native-image

# Build native binary
native-image -jar target/my-tui-1.0.0.jar my-tui \
  --no-fallback \
  -H:+ReportExceptionStackTraces

# Result: ./my-tui (standalone binary, no JRE needed)
```

Add `reflect-config.json` for Lanterna's reflection usage:
```json
[
  {"name": "com.googlecode.lanterna.terminal.swing.SwingTerminalFrame", "allDeclaredConstructors": true},
  {"name": "sun.misc.SignalHandler", "allDeclaredMethods": true}
]
```

### jpackage (Platform Installer)

```bash
jpackage --input target/ \
  --name my-tui \
  --main-jar my-tui-1.0.0.jar \
  --main-class com.example.MyTui \
  --type dmg  # or msi, deb, rpm
```

### Testing

```java
// Mock terminal for unit tests
Terminal terminal = new DefaultTerminalFactory()
    .setForceTextTerminal(true)
    .createTerminal();

// Or use a virtual terminal for headless testing
VirtualTerminal vt = new DefaultVirtualTerminal(new TerminalSize(80, 24));
Screen screen = new TerminalScreen(vt);
```
