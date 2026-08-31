# SCR-43 — macOS Console Host

**Surface:** macos  
**Type:** primary  
**Category:** Desktop  
**Routes hosted:** every implemented web route in `packages/web/src/App.tsx`

## Purpose

Give llm-toolkit a native Mac window without forking the console. The SwiftUI
app starts or attaches to the local Vite + Hono stack and loads the existing
SPA in WKWebView. Feature parity with the web console is the product of
hosting that SPA, not of a second implementation.

## Layout

- NavigationSplitView sidebar: Explore, Safety Watch, Datasets, Prompts, Tags, Projects, Settings
- Toolbar: harness segmented control, search field, index badge, reload
- Detail: WKWebView of the matching web route, or a connection pane if :5173 / :3100 are down
- Settings scene: URLs, toolkit root, auto-start, native-chrome toggle
- Menus: Go (⌘1–⌘8), Harness, Conversation (view/edit/convert/continue/clone/archive), Index

## Native chrome

When `window.__LLM_TOOLKIT_NATIVE_CHROME__` is set, `Layout.tsx` hides the web
header and sidebar. The Mac sidebar and menus drive `llm-toolkit-navigate` /
`__LLM_TOOLKIT_NAVIGATE__`. Harness changes go through `llm-toolkit-set-harness`.

## Out of scope

- Merge view — not implemented on the web (`SCR-08`)
- Reimplementing markdown / Mermaid / LaTeX / the edit and convert wizards in Swift
- Mac App Store / sandbox (this is a local developer tool that launches `pnpm`)

## Related

- `apps/macos/README.md`
- `docs/layout/macos.md`
- SCR-01 … SCR-15 (the hosted web screens)
