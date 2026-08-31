# apps/macos — Native Mac host

SwiftUI app that hosts the existing Vite console in WKWebView so every implemented web route is available on the desktop.

```
macos/
├── Package.swift
├── Makefile                    # build / test / run / app
├── Info.plist                  # com.noizu.llm-toolkit
├── README.md
├── Sources/
│   ├── LLMToolkitKit/          # Testable core
│   │   ├── ConsoleRoute.swift  #   1:1 map of packages/web/src/App.tsx
│   │   ├── Harness.swift
│   │   ├── AppPreferences.swift
│   │   ├── ToolkitLocator.swift
│   │   ├── HealthClient.swift
│   │   ├── ToolkitAPIClient.swift
│   │   └── ServerSupervisor.swift
│   └── LLMToolkit/             # App target
│       ├── LLMToolkitApp.swift
│       ├── AppModel.swift
│       ├── AppCommands.swift
│       ├── Theme/Nocturne.swift
│       └── Views/
│           ├── ContentView.swift
│           ├── SidebarView.swift
│           ├── ConsoleWebView.swift
│           ├── ConnectionPane.swift
│           └── SettingsView.swift
└── Tests/LLMToolkitTests/
```

The web package exposes `src/hostBridge.ts` plus Layout/Harness listeners so the host can hide the browser chrome, push routes, and change harness.

Brand art (Timely-style): `Assets/LLMToolkitIcon-1024.png` → `Resources/LLMToolkit.icns`; in-app `WatchdogHero.png` / `WatchdogCompanion.png` via `Branding.swift`.
