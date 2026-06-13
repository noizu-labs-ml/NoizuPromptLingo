# Worked Example: VS Code-Style Extension System

End-to-end walkthrough of designing a plugin architecture modeled on VS Code's extension system — one of the most successful plugin ecosystems in software.

## Scenario

You're building **Notepad Pro**, a desktop Markdown editor written in TypeScript/Electron. Users want:
- Custom sidebar panels (table of contents, backlinks, AI summaries)
- Custom Markdown renderers (math, diagrams, custom blocks)
- Custom export formats (PDF, EPUB, Docx)
- Theme support
- Custom keyboard shortcuts and commands

## Phase 1: Extension Point Discovery

### Data Flow Map

```
File System → File Loader → Parser (Markdown AST) → Renderer → DOM
                                    ↓
                              Sidebar Panels
                                    ↓
                              Status Bar
                                    ↓
                              Command Palette
```

### Candidate Extension Points

| Location | User Request | Pattern |
|----------|-------------|---------|
| Parser output | Custom Markdown blocks | AST Transform |
| Renderer | Custom rendering for AST nodes | Hook/Filter |
| Sidebar | Custom panels | Slot/Mount Point |
| Export | Custom output formats | Service Provider |
| Themes | Visual customization | Service Provider |
| Commands | Custom keyboard shortcuts | Event/Command |
| Status bar | Custom indicators | Slot/Mount Point |

## Phase 2: Contract Design

### Manifest (package.json style)

```json
{
  "name": "notepad-pro-math",
  "displayName": "Math Blocks",
  "version": "1.0.0",
  "description": "Renders LaTeX math in Markdown documents",
  "main": "./dist/index.js",
  "notepadPro": {
    "apiVersion": "1.0",
    "activationEvents": [
      "onLanguage:markdown"
    ],
    "contributes": {
      "markdownTransforms": [
        {
          "name": "math-block",
          "nodeTypes": ["code_block"],
          "languages": ["math", "latex"]
        }
      ],
      "commands": [
        {
          "id": "notepad-pro-math.insertBlock",
          "title": "Insert Math Block"
        }
      ],
      "configuration": {
        "notepad-pro-math.renderer": {
          "type": "string",
          "enum": ["katex", "mathjax"],
          "default": "katex"
        }
      }
    }
  }
}
```

### Extension Point Contracts

```typescript
// Markdown Transform
export interface MarkdownTransform {
  name: string;
  nodeTypes: string[];
  transform(node: MarkdownNode, context: TransformContext): MarkdownNode | null;
}

// Sidebar Panel
export interface SidebarPanel {
  id: string;
  title: string;
  icon: string;
  createView(context: PanelContext): PanelView;
}

// Export Provider
export interface ExportProvider {
  format: string;
  displayName: string;
  fileExtension: string;
  export(document: ParsedDocument, options: ExportOptions): Promise<Buffer>;
}

// Theme
export interface Theme {
  name: string;
  type: 'light' | 'dark';
  colors: Record<string, string>;
  tokenColors: TokenColorRule[];
}
```

### Plugin Context

```typescript
export interface ExtensionContext {
  // Identity
  readonly extensionId: string;
  readonly extensionVersion: string;
  readonly extensionPath: string;

  // Registration
  readonly markdownTransforms: TransformRegistry;
  readonly sidebarPanels: PanelRegistry;
  readonly exportProviders: ExportRegistry;
  readonly commands: CommandRegistry;
  readonly statusBar: StatusBarRegistry;
  readonly themes: ThemeRegistry;

  // Services
  readonly workspace: WorkspaceAPI;
  readonly documents: DocumentAPI;
  readonly storage: ExtensionStorage;
  readonly logger: Logger;

  // Lifecycle
  readonly subscriptions: Disposable[];
}
```

## Phase 3: Registry & Lifecycle

### Discovery

Hybrid approach:
- **Local:** Scan `~/.notepad-pro/extensions/` for `package.json` with `notepadPro` field
- **Marketplace:** REST API for search/download (`GET /api/extensions?q=math`)

### Activation Events

Lazy activation — plugins only load when needed:

| Event | Trigger |
|-------|---------|
| `onStartup` | Always activate on launch |
| `onLanguage:markdown` | When a .md file is opened |
| `onCommand:ext.command` | When user runs a command |
| `onView:sidebar-panel` | When sidebar panel is opened |
| `*` | Activate on everything (discouraged) |

### Lifecycle Flow

```
1. App starts → scan extensions directory
2. Parse all package.json manifests
3. Build dependency graph, topological sort
4. For each extension with activationEvent matching current state:
   a. Load extension code
   b. Call activate(context)
   c. Extension registers its contributions
5. On matching event later → activate lazy extensions
6. On deactivate: call deactivate(), dispose subscriptions
```

## Phase 4: SDK

### Create Extension CLI

```bash
npx create-notepad-pro-extension my-extension
# Prompts: extension type, name, description
# Generates: full project scaffold with types, tests, manifest
```

### Test Harness

```typescript
import { createTestHarness } from '@notepad-pro/extension-test';

test('math transform renders LaTeX', async () => {
  const harness = createTestHarness();

  // Load extension
  await harness.loadExtension('./src/index.ts');

  // Create a test document
  const doc = harness.createDocument('# Math\n```math\nx^2 + y^2 = z^2\n```');

  // Invoke the transform pipeline
  const rendered = await harness.renderDocument(doc);

  // Assert
  expect(rendered).toContain('class="katex"');
});
```

## Phase 5: Security

### Trust Model

- **Marketplace extensions:** Signed by publisher, reviewed by team
- **Local extensions:** Trusted (user explicitly installed)
- **Workspace extensions:** Semi-trusted (bundled with a project, prompted on first use)

### Sandboxing

Extensions run in the main Electron process (trusted model, like VS Code). Security relies on:
- Capability-gated APIs (extensions can't access APIs they didn't declare)
- Content Security Policy for webview panels
- Network request auditing
- Extension review process for marketplace

## Result

This architecture gives Notepad Pro:
- **6 extension point types** covering all requested customizations
- **Lazy activation** so most extensions don't load until needed
- **Typed SDK** with IDE completions and test harness
- **Marketplace-ready** manifest format with rich metadata
- **Familiar DX** for anyone who's built a VS Code extension
