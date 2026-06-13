# App Store Optimization (ASO)

Systematic approach to improving App Store visibility, conversion rate,
and organic downloads. ASO is the iOS equivalent of SEO — ongoing work,
not a one-time setup.

---

## ASO Fundamentals

Two goals:
1. **Visibility** — rank higher in App Store search results
2. **Conversion** — turn impressions into downloads

Apple's algorithm considers: keyword relevance, download velocity, ratings,
update frequency, and engagement metrics. You control the first three directly.

---

## Keyword Research

### Where Keywords Matter

| Field | Indexed | Visible to Users | Char Limit |
|-------|---------|-----------------|------------|
| App Name | Yes | Yes | 30 |
| Subtitle | Yes | Yes | 30 |
| Keyword Field | Yes | No | 100 |
| In-App Purchase names | Yes | Yes | 30 each |
| Developer Name | Partially | Yes | -- |
| Description | No (Apple) | Yes | 4000 |

Apple does NOT index the description for search. Google Play does.
This is the most common ASO mistake people carry over from Android.

### Research Process

1. **Seed list** — brainstorm 50-100 terms users might search
2. **Competitor analysis** — what keywords do top 10 competitors rank for
3. **Search suggestions** — type partial queries in App Store search bar
4. **Volume estimation** — use tools (AppTweak, Sensor Tower, AppFollow)
5. **Difficulty scoring** — high volume + low competition = best targets
6. **Long-tail keywords** — less competitive, higher intent

### Tools

| Tool | Free Tier | Best For |
|------|-----------|----------|
| App Store search suggestions | Yes | Discovery, long-tail ideas |
| AppTweak | Limited | Keyword volume, difficulty scores |
| Sensor Tower | Limited | Competitor keyword spy |
| AppFollow | Limited | Review mining for keyword ideas |
| Apple Search Ads (basic) | Yes | Actual search volume data |

### Keyword Selection Framework

```
Score = (Search Volume x Relevance) / Competition

Priority:
  A-tier: High volume, high relevance, low competition (rare — grab these)
  B-tier: Medium volume, high relevance, medium competition (bread and butter)
  C-tier: High volume, medium relevance, high competition (aspirational)
  Skip:   Low relevance regardless of volume
```

---

## Title and Subtitle Optimization

### App Name (30 characters)

- Lead with brand name if established, otherwise lead with keyword
- Include one high-value keyword naturally
- Avoid keyword stuffing — Apple rejects blatant "AppName - Keyword Keyword Keyword"

**Examples:**
```
Good:  "Pocket Budget — Expense Track"
Good:  "Meditate: Daily Mindfulness"
Bad:   "Budget App Free Money Tracker Finance Manager"
```

### Subtitle (30 characters)

- Complement the name — do not repeat the same keywords
- Describe the core value proposition
- Use action-oriented language

**Examples:**
```
Name:     "FitLog"
Subtitle: "Workout Tracker & Planner"    (adds keywords not in name)

Name:     "Recipease"
Subtitle: "Meal Planning Made Simple"     (value prop + keywords)
```

### Iteration

Update title and subtitle with each version release. Track ranking changes
for 2 weeks after each update before making further changes. Never change
both simultaneously — isolate variables.

---

## Keyword Field (100 Characters)

### Rules

- Comma-separated, no spaces after commas
- Do NOT repeat words already in name or subtitle (Apple indexes them)
- Use singular forms only (Apple matches both singular and plural)
- Do NOT include "app," "free," your brand name, or competitor names
- No special characters or numbers (unless part of a real keyword)
- Apple combines words: "budget,tracker" matches "budget tracker"

### Example

```
Name:     "FitLog"
Subtitle: "Workout Tracker & Planner"

Keywords: exercise,gym,weight,training,routine,health,muscle,
          cardio,strength,progress,goals,personal,daily,log
```

Total: 100 characters. Each word is unique. No overlap with name/subtitle.

### Localization Trick

If your app is English-only, you still get keyword fields for every
localization. The English (US) and English (UK) fields are both indexed
for US searches. Use the UK field for 100 additional keyword characters.

Similarly, use English (Australia) for the UK store. Check Apple's
localization indexing rules — they change occasionally.

---

## Screenshot Design

Screenshots are the single biggest conversion lever. Most users decide
to download (or not) based on the first 3 screenshots visible in search.

### Design Principles

1. **First screenshot = hero shot** — show the core value instantly
2. **Each screenshot = one feature** — do not cram multiple features
3. **Captions above or below** — large, readable text explaining the benefit
4. **Consistent style** — same background, typography, device frames
5. **Show real content** — not placeholder data or Lorem Ipsum
6. **Dark backgrounds convert better** — test this for your category

### Screenshot Sequence

```
1. Hero — core value proposition (this appears in search results)
2. Key feature A — the thing users want most
3. Key feature B — differentiator from competitors
4. Social proof — "500K users" or app review quotes (if applicable)
5. Secondary feature — nice-to-have that adds value
6-10. Additional features, settings, customization options
```

### Sizing

Create for the largest required device first, then scale down:

| Device | Size (portrait) |
|--------|----------------|
| iPhone 6.9" | 1320 x 2868 |
| iPhone 6.7" | 1290 x 2796 |
| iPhone 6.5" | 1284 x 2778 |
| iPad 13" | 2064 x 2752 |

Use Figma, Sketch, or a screenshot generator (AppMockUp, Screenshots Pro)
for consistent device frames and layouts.

### Common Mistakes

- Text too small to read in search results (thumbnails are tiny)
- Feature-focused instead of benefit-focused captions
- Too much negative space — fill the frame
- Inconsistent visual style across screenshots
- Not updating screenshots when the UI changes

---

## App Preview Videos

### Specifications

- 15-30 seconds (30 recommended — use every second)
- Up to 3 per localization
- Must show actual app footage (screen recordings)
- First frame = poster frame (shown as thumbnail)
- No hands, taps, or device chrome required

### Production Tips

1. Record on device using screen recording (Control Center)
2. Edit in iMovie, Final Cut, or ScreenFlow
3. Add text overlays for context (same style as screenshot captions)
4. Show the value in the first 5 seconds — autoplay is muted
5. End with a call to action or brand moment

### Do Videos Help?

Videos increase conversion rate by 10-25% on average in competitive categories.
For simple utility apps, screenshots alone may suffice. For apps with
animations, interactions, or visual appeal — videos are worth the investment.

---

## Ratings and Reviews Strategy

### Why They Matter

- Apps with 4.5+ stars convert significantly better
- Rating count signals trust (more ratings = more downloads)
- Apple's algorithm weighs recent rating velocity

### Requesting Reviews

Use `SKStoreReviewController.requestReview()`:

```swift
import StoreKit

// Call after a positive moment (completed a task, reached a goal)
if let scene = UIApplication.shared.connectedScenes
    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
    SKStoreReviewController.requestReview(in: scene)
}
```

**Timing rules:**
- Apple shows the prompt max 3 times per 365-day period
- Do NOT show on first launch — wait for a success moment
- Do NOT show after errors, crashes, or purchases
- Do NOT gate features behind reviews (App Store rejection)

### Managing Negative Reviews

- Respond to every 1-2 star review in App Store Connect
- Be helpful, not defensive — offer to fix their issue
- Fix common complaints and mention it in release notes
- Use `currentVersion` reset on major updates (resets displayed rating)

---

## Localization for ASO

### High-Impact Languages

| Language | Market Size | Competition |
|----------|------------|-------------|
| English (US) | Largest | Highest |
| Japanese | 2nd largest iOS market | Medium |
| Chinese (Simplified) | Huge volume | High |
| Korean | Strong iOS adoption | Medium |
| German | Largest European market | Medium |
| French | Multi-country reach | Medium |
| Spanish | Multi-country reach | Lower |
| Portuguese (Brazil) | Growing market | Lower |

### What to Localize

Minimum: app name, subtitle, keywords, description, screenshots
Full: the app itself (strings, date formats, currency)

For ASO-only localization (metadata without app translation), focus on
keywords and screenshots. Users who find you via localized keywords
but encounter an English-only app will still convert if the value is clear.

### Localization Workflow

1. Research keywords in each target language (do not translate English keywords)
2. Hire native speakers or use localization services (Gengo, OneSky)
3. Create localized screenshots (even just swapping caption text helps)
4. Submit localized metadata with your next update
5. Monitor ranking in each locale separately

---

## Product Page Optimization (A/B Testing)

### Apple's Built-In A/B Testing

App Store Connect > Product Page Optimization lets you test:
- App icon (up to 3 variants)
- Screenshots (up to 3 variants)
- App preview videos (up to 3 variants)

### Running a Test

1. App Store Connect > your app > Product Page Optimization > Create Test
2. Choose what to test (icon, screenshots, or video)
3. Upload variants
4. Set traffic split (Apple recommends equal split)
5. Run for minimum 7 days (14 recommended for statistical significance)
6. Apply the winner

### What to Test

| Element | Impact | Test Ideas |
|---------|--------|------------|
| Icon | High | Color variations, symbol vs character, detail level |
| Screenshot 1 | Highest | Different hero features, caption text, backgrounds |
| Screenshot order | Medium | Reorder to lead with different features |
| Video vs no video | Medium | Does adding a video improve conversion? |

### Testing Discipline

- Change one variable at a time
- Run tests to statistical significance (minimum 1000 impressions per variant)
- Document results in a test log
- Winners compound: test icon, then screenshots, then order
- Seasonal testing: holiday themes, back-to-school, etc.

---

## ASO Calendar

Treat ASO as an ongoing practice, not a launch task.

| Frequency | Action |
|-----------|--------|
| Every release | Update keywords based on latest research |
| Monthly | Review search rankings, adjust keyword strategy |
| Quarterly | Refresh screenshots, run A/B tests |
| Biannually | Full keyword audit, competitor analysis |
| Annually | Refresh app preview video |
| Ongoing | Respond to reviews within 48 hours |

---

## Metrics to Track

| Metric | Source | Target |
|--------|--------|--------|
| Impressions | App Analytics | Growing month-over-month |
| Conversion rate | App Analytics | Category average or better (varies 20-40%) |
| Keyword rankings | ASO tool | Top 10 for 5+ high-volume terms |
| Rating | App Store Connect | 4.5+ stars |
| Rating count | App Store Connect | Growing; 100+ for credibility |
| Download velocity | App Analytics | Stable or growing weekly |
