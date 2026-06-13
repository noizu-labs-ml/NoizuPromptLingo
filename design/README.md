# IoTGo Design Directions

Three style guides for the same platform. Pick a world to operate in.

---

## At a Glance

| | Direction A | Direction B | Direction C |
|---|---|---|---|
| **Name** | Dark Ops Console | Trust + Precision | Signal Mesh |
| **File** | [direction-a](direction-a-dark-ops.md) | [direction-b](direction-b-trust-precision.md) | [direction-c](direction-c-signal-mesh.md) |
| **One-liner** | Your fleet is the interface | Autonomous agents, enterprise trust | Infrastructure, not interface |
| **System** | Minimal Tech 100% | MT 80% + Corporate Enterprise 20% | Bold Expressive (industrial) |
| **Primary font** | Geist (sans) | Inter (sans) + Source Serif 4 (headings) | Space Mono (mono everywhere) |
| **Accent** | Teal `#14B8A6` | Muted Teal `#0D9488` + Navy `#1E3A5F` | Electric Green `#00E676` |
| **Border radius** | 6-8px | 4-8px | 0px |
| **Border weight** | 1px | 1px | 2px |
| **Navigation** | Sidebar, collapsible | Sidebar + trust status bar | Top tabs (no sidebar) |
| **Body font** | Sans 16px | Sans 16px (1.7 line-height) | Mono 14px |
| **Health colors** | Standard saturated | Standard saturated | Industrial neon |
| **Motion** | Subtle, 150ms | Deliberate, 200ms | Abrupt, 100ms or instant |
| **Data density** | High | High (with more breathing room) | Maximum |
| **Risk level** | Low (safe industry default) | Low (additive trust signals) | High (polarizing, memorable) |

---

## Decision Framework

```
Who is the primary buyer?
├── Engineers (build, ship, operate)
│   ├── Want it to feel like their other tools (Linear, Vercel)?
│   │   └── Direction A (industry-default, Datadog energy)
│   └── Want it to feel like nothing else?
│       └── Direction C (Bloomberg Terminal energy)
└── Enterprise (evaluate, procure, approve)
    └── Direction B (enterprise trust without legacy aesthetic)

Is the fleet view a control room / NOC screen?
├── Yes, 24/7 operations ──── Direction A or C
└── Sometimes, also used in meetings/reports ──── Direction B
```

---

## Mixing Directions

These aren't mutually exclusive:

- **A → B evolution:** Start with A for v1 (engineer-focused), adopt B's trust elements when enterprise sales begin
- **C for marketing, A for product:** Signal Mesh landing page (memorable, differentiating) with Dark Ops Console for the actual app
- **C's accent on A's structure:** Keep A's layout but swap teal for electric green and tighten spacing (a lighter industrial nod)

---

## What's Not Covered Here

- Responsive behavior (all three need mobile adaptation, though IoT dashboards are primarily desktop)
- Fleet topology rendering technology (react-flow, d3, deck.gl, mapbox)
- Agent reasoning visualization (needs its own design exploration)
- CLI tool output styling
- Marketing site / landing page design (separate effort)

---

## Next Steps

1. **React to these directions** — which world feels right for iotgo.io?
2. **Select or mix** — pure direction or hybrid
3. **Wireframes** — apply selected style to IoTGo screens (Overview, Fleet, Agent Studio, Playbook Editor)
4. **Component library** — build out the full component set
5. **Landing page** — design the iotgo.io marketing site
