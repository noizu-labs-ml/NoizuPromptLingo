# C/C++ — FTXUI + ncurses

## Part 1: FTXUI (Modern C++17)

### Overview

**FTXUI** is a declarative, functional TUI library for C++17. It has two layers:
- **Elements** — immutable DOM-like tree for static rendering
- **Components** — interactive widgets with focus, events, and state

No dependencies beyond a C++17 compiler. Header-only option available.

### Project Setup

```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.14)
project(my-tui LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FetchContent)
FetchContent_Declare(
  ftxui
  GIT_REPOSITORY https://github.com/ArthurSonzogni/FTXUI
  GIT_TAG v5.0.0
)
FetchContent_MakeAvailable(ftxui)

add_executable(my-tui src/main.cpp)
target_link_libraries(my-tui
  PRIVATE ftxui::screen
  PRIVATE ftxui::dom
  PRIVATE ftxui::component
)
```

```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

### Element Catalog

```cpp
#include <ftxui/dom/elements.hpp>
using namespace ftxui;

// Text
auto doc = text("Hello");
auto doc = paragraph("Long text that wraps automatically at boundaries");

// Layout
auto doc = hbox({text("left"), separator(), text("right")});
auto doc = vbox({text("top"), separator(), text("bottom")});
auto doc = gridbox({{text("a"), text("b")}, {text("c"), text("d")}});

// Decoration
auto doc = text("boxed") | border;
auto doc = text("bold") | bold;
auto doc = text("dim") | dim;
auto doc = text("colored") | color(Color::Cyan);
auto doc = text("bg") | bgcolor(Color::Blue);

// Sizing
auto doc = text("fixed") | size(WIDTH, EQUAL, 20);
auto doc = text("flex") | flex;
auto doc = text("flex_grow") | flex_grow;

// Gauge
auto doc = gauge(0.75f);  // 75% progress bar
auto doc = gaugeRight(0.5f);

// Separators
auto doc = vbox({text("a"), separator(), text("b")});
auto doc = vbox({text("a"), separatorLight(), text("b")});
auto doc = vbox({text("a"), separatorHeavy(), text("b")});
auto doc = vbox({text("a"), separatorDouble(), text("b")});
```

### Component Catalog

```cpp
#include <ftxui/component/component.hpp>
using namespace ftxui;

// Input
std::string content;
auto input = Input(&content, "placeholder");

// Menu (vertical selection)
int selected = 0;
std::vector<std::string> entries = {"Option 1", "Option 2", "Option 3"};
auto menu = Menu(&entries, &selected);

// Toggle (horizontal selection)
int toggle_selected = 0;
std::vector<std::string> toggle_entries = {"On", "Off"};
auto toggle = Toggle(&toggle_entries, &toggle_selected);

// Checkbox
bool checked = false;
auto checkbox = Checkbox("Enable feature", &checked);

// Radiobox
int radio_selected = 0;
std::vector<std::string> radio_entries = {"A", "B", "C"};
auto radiobox = Radiobox(&radio_entries, &radio_selected);

// Slider
int value = 50;
auto slider = Slider("Volume:", &value, 0, 100, 1);

// Button
auto button = Button("Click me", [] { /* action */ });

// Dropdown
int dropdown_selected = 0;
auto dropdown = Dropdown(&entries, &dropdown_selected);
```

### Interactive Application

```cpp
#include <ftxui/component/screen_interactive.hpp>

int main() {
    auto screen = ScreenInteractive::Fullscreen();
    // or: ScreenInteractive::TerminalOutput();
    // or: ScreenInteractive::FitComponent();

    int selected = 0;
    std::vector<std::string> entries = {"Build", "Test", "Deploy"};
    auto menu = Menu(&entries, &selected);

    auto renderer = Renderer(menu, [&] {
        return vbox({
            text("My TUI") | bold | center,
            separator(),
            menu->Render() | flex,
            separator(),
            text("Selected: " + entries[selected]) | dim,
        }) | border;
    });

    // Add event handling
    auto component = CatchEvent(renderer, [&](Event event) {
        if (event == Event::Character('q')) {
            screen.Exit();
            return true;
        }
        return false;
    });

    screen.Loop(component);
    return 0;
}
```

### Styling

```cpp
// ANSI colors
color(Color::Red)
color(Color::Green)
bgcolor(Color::Blue)

// 256-color
color(Color::Palette256(208))

// True color
color(Color::RGB(255, 165, 0))

// Modifiers
bold
dim
underlined
blink
inverted
strikethrough
```

### Testing

```cpp
#include <ftxui/screen/screen.hpp>

void test_rendering() {
    auto doc = text("hello") | border;
    auto screen = Screen::Create(Dimension::Fixed(20), Dimension::Fixed(5));
    Render(screen, doc);
    std::string output = screen.ToString();
    // Compare output string against expected
    assert(output.find("hello") != std::string::npos);
}
```

---

## Part 2: ncurses (C)

### Overview

**ncurses** is the standard Unix terminal control library. Low-level, imperative, and universally available. You manage windows, draw characters, and handle input manually.

### Project Setup

```makefile
# Makefile
CC = gcc
CFLAGS = -Wall -Wextra $(shell pkg-config --cflags ncurses)
LDFLAGS = $(shell pkg-config --libs ncurses)

my-tui: main.c
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

clean:
	rm -f my-tui
```

For wide character support (Unicode): use `ncursesw` instead of `ncurses`.

### Core API

```c
#include <ncurses.h>

int main() {
    // Setup
    initscr();            // initialize screen
    cbreak();             // disable line buffering
    noecho();             // don't echo typed characters
    keypad(stdscr, TRUE); // enable arrow keys
    curs_set(0);          // hide cursor

    // Drawing
    mvprintw(0, 0, "Hello, ncurses!");        // print at (row, col)
    mvaddch(1, 0, ACS_DIAMOND);               // add special character
    attron(A_BOLD);                            // enable bold
    mvprintw(2, 0, "Bold text");
    attroff(A_BOLD);                           // disable bold

    refresh();            // update physical screen

    // Input
    int ch = getch();     // wait for keypress

    // Cleanup
    endwin();
    return 0;
}
```

### Window Management

```c
// Create a window
WINDOW *win = newwin(height, width, start_y, start_x);
box(win, 0, 0);                // draw border
mvwprintw(win, 1, 1, "Content"); // print inside window
wrefresh(win);                 // refresh this window

// Subwindow (shares memory with parent)
WINDOW *sub = derwin(win, h, w, y, x);

// Delete window
delwin(win);
```

### Color

```c
if (has_colors()) {
    start_color();
    use_default_colors();  // allow -1 for default terminal colors

    init_pair(1, COLOR_RED, -1);        // red on default bg
    init_pair(2, COLOR_GREEN, COLOR_BLACK);
    init_pair(3, COLOR_CYAN, -1);

    attron(COLOR_PAIR(1));
    mvprintw(0, 0, "Red text");
    attroff(COLOR_PAIR(1));

    // Extended colors (ncurses 6.1+)
    if (can_change_color()) {
        init_color(COLOR_RED, 1000, 0, 0);  // redefine red (0-1000 range)
    }
}
```

### Input Handling

```c
keypad(stdscr, TRUE);
nodelay(stdscr, FALSE);  // blocking input (TRUE for non-blocking)
// timeout(100);          // alternative: wait 100ms then return ERR

int ch;
while ((ch = getch()) != 'q') {
    switch (ch) {
        case KEY_UP:    move_up();    break;
        case KEY_DOWN:  move_down();  break;
        case KEY_LEFT:  move_left();  break;
        case KEY_RIGHT: move_right(); break;
        case '\n':      select();     break;
        case 27:        cancel();     break; // ESC
        case KEY_RESIZE: handle_resize(); break;
    }
    refresh();
}
```

### Starter Template

```c
#include <ncurses.h>
#include <string.h>

#define NUM_ITEMS 3

int main() {
    const char *items[] = {"Build", "Test", "Deploy"};
    int current = 0;

    initscr();
    cbreak();
    noecho();
    keypad(stdscr, TRUE);
    curs_set(0);

    if (has_colors()) {
        start_color();
        use_default_colors();
        init_pair(1, COLOR_CYAN, -1);
        init_pair(2, COLOR_YELLOW, -1);
    }

    int max_y, max_x;
    getmaxyx(stdscr, max_y, max_x);
    WINDOW *win = newwin(max_y - 2, max_x - 4, 1, 2);
    keypad(win, TRUE);

    int ch;
    do {
        werase(win);
        box(win, 0, 0);

        wattron(win, COLOR_PAIR(1) | A_BOLD);
        mvwprintw(win, 1, 2, "My TUI");
        wattroff(win, COLOR_PAIR(1) | A_BOLD);

        mvwhline(win, 2, 1, ACS_HLINE, max_x - 6);

        for (int i = 0; i < NUM_ITEMS; i++) {
            if (i == current) {
                wattron(win, COLOR_PAIR(2) | A_BOLD);
                mvwprintw(win, 4 + i, 3, "> %s", items[i]);
                wattroff(win, COLOR_PAIR(2) | A_BOLD);
            } else {
                mvwprintw(win, 4 + i, 3, "  %s", items[i]);
            }
        }

        mvwprintw(win, max_y - 4, 2, "q: quit | up/down: navigate");
        wrefresh(win);

        ch = wgetch(win);
        switch (ch) {
            case KEY_UP:   if (current > 0) current--; break;
            case KEY_DOWN: if (current < NUM_ITEMS - 1) current++; break;
        }
    } while (ch != 'q');

    delwin(win);
    endwin();
    return 0;
}
```

---

## Part 3: Build Systems

### CMake for FTXUI (find_package alternative)

If FTXUI is installed system-wide:

```cmake
find_package(ftxui REQUIRED)
target_link_libraries(my-tui PRIVATE ftxui::dom ftxui::screen ftxui::component)
```

### Cross-Compilation

**FTXUI (static):**
```bash
cmake .. -DCMAKE_BUILD_TYPE=Release -DFTXUI_BUILD_EXAMPLES=OFF -DBUILD_SHARED_LIBS=OFF
```

**ncurses (static linking):**
```bash
gcc main.c -o my-tui -static $(pkg-config --libs --static ncurses)
```

**musl for fully static Linux binaries:**
```bash
CC=musl-gcc cmake .. -DCMAKE_BUILD_TYPE=Release
```

### CI (GitHub Actions)

```yaml
jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - name: Install ncurses (if needed)
        if: matrix.os == 'ubuntu-latest'
        run: sudo apt-get install -y libncurses-dev
      - name: Build
        run: |
          mkdir build && cd build
          cmake .. -DCMAKE_BUILD_TYPE=Release
          make -j$(nproc)
```
