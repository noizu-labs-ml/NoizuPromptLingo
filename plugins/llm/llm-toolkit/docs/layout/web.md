# packages/web — Browser UI

Vite + React + Tailwind single-page app for browsing, searching, and editing conversations.

```
web/
├── src/
│   ├── components/             # Shared UI components
│   │   ├── Layout.tsx          #   App shell — sidebar, navigation, content area (hides chrome for Mac host)
│   │   └── MarkdownView.tsx    #   Markdown renderer for conversation messages
│   ├── hostBridge.ts           # Mac-host detection + navigation/chrome flags
│   ├── context/                # React contexts
│   │   └── HarnessContext.tsx  #   Active harness selection state + desktop events
│   ├── hooks/                  # React hooks
│   │   └── useApi.ts           #   API client hook (fetch wrapper)
│   ├── pages/                  # Route-level page components
│   │   ├── Browse.tsx          #   Conversation list browser
│   │   ├── ContinueSession.tsx #   Resume a session in a harness
│   │   ├── Convert.tsx         #   JSONL file converter
│   │   ├── Dashboard.tsx       #   Overview dashboard
│   │   ├── DatasetDetail.tsx   #   Single dataset view
│   │   ├── Datasets.tsx        #   Dataset listing
│   │   ├── Edit.tsx            #   Conversation editor
│   │   ├── Explore.tsx         #   Exploratory conversation browser
│   │   ├── ProjectDetail.tsx   #   Single project detail view
│   │   ├── Projects.tsx        #   Project browser
│   │   ├── Prompts.tsx         #   Prompt extraction view
│   │   ├── SafetyWatch.tsx     #   Agent watch-dog monitoring view
│   │   ├── Search.tsx          #   Full-text + semantic search
│   │   ├── Settings.tsx        #   App settings
│   │   ├── StyleGuide.tsx      #   Design system reference
│   │   ├── Tags.tsx            #   Tag management
│   │   └── Thread.tsx          #   Single conversation thread view
│   ├── services/               # Client-side services
│   │   └── sessionWorkflow.ts  #   Continue-session orchestration
│   ├── __tests__/              # Unit tests
│   ├── App.tsx                 # Router + app root
│   ├── index.css               # Global styles (Tailwind)
│   └── main.tsx                # Vite entry point
├── public/
│   └── favicon.svg             # Site favicon
├── index.html                  # HTML shell
├── package.json
├── postcss.config.js           # PostCSS (Tailwind plugin)
├── tailwind.config.js          # Tailwind theme configuration
├── tsconfig.json
├── vite.config.ts              # Vite build config
└── vitest.config.ts            # Test runner config
```
