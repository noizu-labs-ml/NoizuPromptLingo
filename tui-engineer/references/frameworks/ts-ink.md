# TypeScript — Ink (React for CLI)

## Overview

**Ink** lets you build CLI apps with React. You write JSX components, use hooks for state and input, and Ink renders them to the terminal as ANSI output. If you know React, you know Ink.

Key packages:
- `ink` — core framework (React renderer for terminals)
- `ink-text-input` / `ink-select-input` / `ink-spinner` / `ink-table` — community components
- `react` — peer dependency
- `tsx` — TypeScript execution without build step (dev)

## Project Setup

```bash
mkdir my-tui && cd my-tui
npm init -y
npm install ink react
npm install -D typescript @types/react tsx
```

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "nodenext",
    "moduleResolution": "nodenext",
    "jsx": "react-jsx",
    "strict": true,
    "outDir": "dist",
    "rootDir": "src",
    "esModuleInterop": true
  },
  "include": ["src"]
}
```

```json
// package.json additions
{
  "type": "module",
  "scripts": {
    "dev": "tsx src/index.tsx",
    "build": "tsc",
    "start": "node dist/index.js"
  },
  "bin": {
    "my-tui": "dist/index.js"
  }
}
```

```
my-tui/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.tsx       # Entry point with render()
│   ├── App.tsx         # Root component
│   └── components/     # UI components
```

## Architecture

### Entry Point

```tsx
#!/usr/bin/env node
import { render } from 'ink';
import { App } from './App.js';

render(<App />);
```

### Component Model

```tsx
import { useState } from 'react';
import { Box, Text, useInput, useApp } from 'ink';

export function App() {
  const [counter, setCounter] = useState(0);
  const { exit } = useApp();

  useInput((input, key) => {
    if (input === 'q') exit();
    if (key.upArrow) setCounter(c => c + 1);
    if (key.downArrow) setCounter(c => Math.max(0, c - 1));
  });

  return (
    <Box flexDirection="column" padding={1}>
      <Text bold color="cyan">Counter: {counter}</Text>
      <Text dimColor>↑/↓: change • q: quit</Text>
    </Box>
  );
}
```

## Component Catalog

### Built-in (ink)

| Component | Purpose |
|-----------|---------|
| `<Box>` | Flexbox container (div equivalent) |
| `<Text>` | Styled text output |
| `<Newline>` | Line break |
| `<Spacer>` | Flex spacer (pushes siblings apart) |
| `<Static>` | Renders items once (log-style, won't re-render) |
| `<Transform>` | Transform children string output |

### Community

```bash
npm install ink-text-input ink-select-input ink-spinner ink-table ink-gradient ink-big-text ink-link
```

| Package | Purpose |
|---------|---------|
| `ink-text-input` | Text input field with cursor |
| `ink-select-input` | Arrow-key selectable list |
| `ink-spinner` | Animated loading spinner |
| `ink-table` | Formatted data table |
| `ink-gradient` | Gradient-colored text |
| `ink-big-text` | Large ASCII text (figlet-style) |
| `ink-link` | Clickable terminal hyperlinks |
| `ink-progress-bar` | Progress bar |

### ink-select-input Example

```tsx
import SelectInput from 'ink-select-input';

const items = [
  { label: 'Build', value: 'build' },
  { label: 'Test', value: 'test' },
  { label: 'Deploy', value: 'deploy' },
];

function App() {
  const handleSelect = (item: { value: string }) => {
    console.log(`Selected: ${item.value}`);
  };
  return <SelectInput items={items} onSelect={handleSelect} />;
}
```

## Layout System

`<Box>` uses Yoga (flexbox for terminals):

```tsx
<Box flexDirection="column" width="100%" height="100%">
  {/* Header */}
  <Box height={3} borderStyle="single" justifyContent="center">
    <Text bold>My App</Text>
  </Box>

  {/* Body: two columns */}
  <Box flexGrow={1}>
    <Box width="30%" borderStyle="single" flexDirection="column">
      <Text>Sidebar</Text>
    </Box>
    <Box flexGrow={1} borderStyle="single" flexDirection="column">
      <Text>Content</Text>
    </Box>
  </Box>

  {/* Footer */}
  <Box height={1}>
    <Text dimColor>q: quit • tab: switch pane</Text>
  </Box>
</Box>
```

**Key props:** `flexDirection`, `alignItems`, `justifyContent`, `flexGrow`, `flexShrink`, `width`, `height`, `minWidth`, `minHeight`, `padding`, `paddingX`, `paddingY`, `margin`, `borderStyle` (`single`, `double`, `round`, `bold`, `classic`), `borderColor`, `gap`.

## Styling

```tsx
<Text color="green" bold>Success!</Text>
<Text color="#ff6347" italic>Custom color</Text>
<Text backgroundColor="blue" underline>Highlighted</Text>
<Text dimColor>Muted text</Text>
<Text strikethrough>Removed</Text>
<Text wrap="truncate-end">Long text that gets cut…</Text>
```

**Color values:** Named (`red`, `green`, `cyan`), hex (`#ff6347`), `rgb(255,99,71)`, ANSI 256 number.

## Input Handling

```tsx
import { useInput } from 'ink';

useInput((input, key) => {
  // Characters
  if (input === 'q') quit();
  if (input === '/') startSearch();

  // Special keys
  if (key.upArrow) moveUp();
  if (key.downArrow) moveDown();
  if (key.leftArrow) moveLeft();
  if (key.rightArrow) moveRight();
  if (key.return) confirm();
  if (key.escape) cancel();
  if (key.tab) nextFocus();
  if (key.backspace || key.delete) deleteChar();

  // Modifiers
  if (key.ctrl && input === 'c') exit();
  if (key.meta && input === 's') save();
}, { isActive: true }); // isActive controls whether this handler runs
```

### Focus Management

```tsx
import { useFocus, useFocusManager } from 'ink';

function FocusablePanel({ id, label }: { id: string; label: string }) {
  const { isFocused } = useFocus({ id });
  return (
    <Box borderStyle={isFocused ? 'double' : 'single'}
         borderColor={isFocused ? 'cyan' : 'gray'}>
      <Text>{label}</Text>
    </Box>
  );
}

function App() {
  const { focusNext, focusPrevious } = useFocusManager();
  useInput((_, key) => {
    if (key.tab) focusNext();
    if (key.shift && key.tab) focusPrevious();  // Shift+Tab not always available
  });
  return (
    <Box flexDirection="column">
      <FocusablePanel id="sidebar" label="Sidebar" />
      <FocusablePanel id="content" label="Content" />
    </Box>
  );
}
```

## Testing

```bash
npm install -D @testing-library/react jest @jest/globals ts-jest ink-testing-library
```

```tsx
import { render } from 'ink-testing-library';
import { App } from '../App.js';

test('renders initial state', () => {
  const { lastFrame } = render(<App />);
  expect(lastFrame()).toContain('Counter: 0');
});

test('increments on up arrow', () => {
  const { lastFrame, stdin } = render(<App />);
  stdin.write('\x1B[A'); // up arrow escape sequence
  expect(lastFrame()).toContain('Counter: 1');
});

test('snapshot', () => {
  const { lastFrame } = render(<App />);
  expect(lastFrame()).toMatchSnapshot();
});
```

## Build & Release

```bash
# Dev (with hot reload)
tsx watch src/index.tsx

# Type check
tsc --noEmit

# Build
tsc

# Make executable
chmod +x dist/index.js  # ensure shebang is present

# Standalone binary (pkg)
npm install -D @yao-pkg/pkg
npx pkg dist/index.js --targets node18-linux-x64,node18-macos-x64,node18-win-x64

# esbuild bundle (single file)
npx esbuild src/index.tsx --bundle --platform=node --outfile=dist/bundle.js --external:yoga-wasm-web

# npm publish
npm publish  # as a CLI package
```

### CI (GitHub Actions)

```yaml
name: Release
on:
  push:
    tags: ['v*']

jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: npm ci
      - run: npm run build
      - run: npx pkg dist/index.js --targets node20-${{ matrix.os == 'ubuntu-latest' && 'linux' || matrix.os == 'macos-latest' && 'macos' || 'win' }}-x64
```

## Starter Template

```tsx
#!/usr/bin/env node
import { render } from 'ink';
import { useState } from 'react';
import { Box, Text, useInput, useApp } from 'ink';

const items = ['Build a TUI', 'Learn TypeScript', 'Ship it'];

function App() {
  const [cursor, setCursor] = useState(0);
  const { exit } = useApp();

  useInput((input, key) => {
    if (input === 'q') exit();
    if (key.upArrow) setCursor(c => Math.max(0, c - 1));
    if (key.downArrow) setCursor(c => Math.min(items.length - 1, c + 1));
  });

  return (
    <Box flexDirection="column" padding={1} borderStyle="round" borderColor="cyan">
      <Text bold color="cyan">My TUI</Text>
      <Box flexDirection="column" marginTop={1}>
        {items.map((item, i) => (
          <Text key={item} color={i === cursor ? 'yellow' : 'white'} bold={i === cursor}>
            {i === cursor ? '▶ ' : '  '}{item}
          </Text>
        ))}
      </Box>
      <Box marginTop={1}>
        <Text dimColor>q: quit • ↑/↓: navigate</Text>
      </Box>
    </Box>
  );
}

render(<App />);
```
