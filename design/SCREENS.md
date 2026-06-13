# BloggersCompete — Screen Inventory & Component Notes

**Status:** draft
**Last updated:** 2026-05-26

---

## Core Components

These components appear across multiple screens and should be built first.

### BlogCard
The fundamental content unit. Used in explore grid, competition entries, leaderboards, and dashboard.

```
┌─────────────────────────────┐
│  ┌─────────┐  Blog Title    │
│  │ Thumb   │  author.name   │
│  │  nail   │  ┌──────────┐  │
│  └─────────┘  │ AI: 8.4  │  │
│               └──────────┘  │
│  [Tech] [AI] [Tutorials]   │
│  ↻ 3 posts/week            │
└─────────────────────────────┘
```

**Variants:**
- `default` — explore grid
- `compact` — leaderboard row, sidebar recommendations
- `entry` — competition context (adds position #, competition score)
- `minimal` — similar blogs row (thumbnail + name + score only)

**Props:** `blog`, `variant`, `showScore`, `showTags`, `showFrequency`, `rank?`

---

### AIScoreBadge
Circular or pill-shaped score display. Color-coded by range.

| Score Range | Color | Label |
|-------------|-------|-------|
| 9.0–10.0 | `#22C55E` (green) | Exceptional |
| 7.0–8.9 | `#A855F7` (purple) | Strong |
| 5.0–6.9 | `#FBBF24` (amber) | Average |
| 3.0–4.9 | `#F97316` (orange) | Developing |
| 0–2.9 | `#EF4444` (red) | Needs Work |

**Variants:** `badge` (inline pill), `large` (dashboard hero stat), `breakdown` (with dimension labels)

---

### AIScoreBreakdown
Radar chart showing six evaluation dimensions. Appears on blog profiles and analytics.

**Dimensions:**
1. **Originality** — Content uniqueness, fresh perspectives
2. **Engagement** — Reader interaction signals, comment quality
3. **Consistency** — Publishing frequency and quality stability
4. **Writing Quality** — Grammar, structure, readability, depth
5. **SEO** — Technical optimization, keyword usage, meta quality
6. **Visual Design** — Blog aesthetics, media usage, layout quality

Uses Minimal Tech styling (clean lines, monospace labels, neutral background).

---

### CompetitionCard
Used in competition listing and featured sections.

```
┌─────────────────────────────┐
│  🏆 Best Tech Blog Q2 2026 │
│                             │
│  Niche: Technology          │
│  Entries: 47 / 100          │
│  ████████░░░░░ 47%          │
│                             │
│  ⏱ 12d 4h remaining        │
│                             │
│  [Enter Competition →]      │
└─────────────────────────────┘
```

**Variants:** `default`, `featured` (larger, hero treatment), `compact` (list view)

---

### LeaderboardRow
Animated table row for rankings. Position changes trigger slide animation.

```
┌──┬─────────────┬────────┬──────┬───────────┐
│#3│ Blog Name   │ 8.7    │  5W  │    ↑2     │
│  │ @author     │ score  │ wins │  movement │
└──┴─────────────┴────────┴──────┴───────────┘
```

Top 3 rows get podium treatment (gold/silver/bronze accent border).

---

### ShellChrome
Dashboard layout wrapper. Sidebar + top bar + content area.

```
┌─────────────────────────────────────┐
│  Logo    Search...    [Avatar ▾]    │
├─────────┬───────────────────────────┤
│ Overview│                           │
│ My Blog │     Content Area          │
│ Compete │                           │
│ Analytic│                           │
│ Submit  │                           │
│─────────│                           │
│ Settings│                           │
└─────────┴───────────────────────────┘
```

Sidebar collapses to icon-only on tablet, becomes bottom tab bar on mobile.

---

### StatCard
Metric display card for dashboard. Minimal Tech styling.

```
┌───────────────┐
│ Overall Score  │
│    8.4         │
│   ↑ 0.3       │
│  this month    │
└───────────────┘
```

**Props:** `label`, `value`, `trend`, `trendLabel`, `icon?`

---

## Screen-Specific Components

### HeroSection (landing)
Full-width, above-fold. Purple gradient background (subtle), large headline, two CTAs.
Animated background: floating blog card silhouettes or abstract graph nodes.

### HowItWorksSection (landing)
3-column (desktop) / stacked (mobile). Icon + number + title + description per step.
Step flow: Submit → Compete → Rise.

### PodiumDisplay (leaderboard)
Visual podium for top 3 blogs. Center (1st) elevated, flanks (2nd, 3rd) lower.
Avatar circles, blog name, score. Trophy icon for 1st. Celebration particles on load.

### FilterBar (explore)
Horizontal filter row: Category dropdown, Niche multi-select, Sort dropdown, Score range slider.
Active filters shown as dismissible pills below.
Collapses to "Filters" button + sheet on mobile.

### StepWizard (onboarding)
Multi-step form with progress dots. Each step validates before advancing.
Animated slide transition between steps.

### CompetitionBuilder (Pro — dashboard)
Multi-step form for creating competitions:
1. Title + Description + Niche
2. Rules + Judging criteria weights
3. Entry limits + Deadline
4. Prize/reward description
5. Review + Publish

---

## Responsive Breakpoints

| Name | Min Width | Layout Changes |
|------|-----------|---------------|
| `mobile` | 0 | Single column, bottom tab nav, stacked cards |
| `tablet` | 768px | 2-column grids, icon-only sidebar |
| `desktop` | 1024px | Full sidebar, 3-column grids, side-by-side layouts |
| `wide` | 1280px | Max-width container, bento grids |

---

## Key Interaction Patterns

### Score Animation
When AI scores appear (page load, tab switch), numbers count up from 0 to value over 800ms. Radar chart draws segments sequentially. Respects `prefers-reduced-motion`.

### Leaderboard Updates
When leaderboard data refreshes (polling or WebSocket), rows animate to new positions. Displaced rows slide; entering/exiting rows fade.

### Competition Countdown
Live countdown timer on competition cards and detail pages. Sub-24h switches to hours:minutes:seconds with amber urgency color.

### Submission Confetti
On successful competition entry, trigger a brief (2s) confetti burst from the submit button. Light particles in brand colors. Respects `prefers-reduced-motion`.

### Blog Indexing Progress
After submitting a blog URL, show a stepped progress indicator: URL Validation → Crawling → AI Analysis → Scoring → Complete. Each step has a spinner and completion check.

---

## Data Visualization Components (Minimal Tech Zone)

These components use the Minimal Tech accent styling: monospace labels, neutral backgrounds, clean lines.

| Component | Used On | Library |
|-----------|---------|---------|
| RadarChart (6-axis) | Blog profile, analytics | Recharts or Nivo |
| LineChart (score over time) | Dashboard, analytics | Recharts |
| BarChart (dimension comparison) | Analytics compare | Recharts |
| SparklineInline | LeaderboardRow, StatCard | Custom SVG |
| ScoreDistributionHistogram | Explore sidebar | Recharts |
