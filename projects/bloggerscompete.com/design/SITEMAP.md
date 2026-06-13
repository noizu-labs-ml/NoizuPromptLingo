# BloggersCompete — Site Map

> AI-powered blog discovery and competition platform for analyzing, listing, and showcasing blogs

**Domain:** bloggerscompete.com
**Status:** draft
**Last updated:** 2026-05-26

---

## Page Flow

```mermaid
graph LR
    ROOT["/ Layout"]

    ROOT -->|public| HOME["/"]
    ROOT -->|public| EXPLORE["/explore"]
    ROOT -->|public| COMP_LIST["/competitions"]
    ROOT -->|public| COMP_DETAIL["/competitions/:id"]
    ROOT -->|public| BLOG["/blog/:slug"]
    ROOT -->|public| LEADERBOARD["/leaderboard"]
    ROOT -->|public| PRICING["/pricing"]
    ROOT -->|public| ABOUT["/about"]
    ROOT -->|public| SG["/styleguide"]
    ROOT -->|public| SM["/sitemap"]

    ROOT -->|auth| LOGIN["/login"]
    ROOT -->|auth| REGISTER["/register"]
    ROOT -->|auth| ONBOARD["/onboarding"]

    ROOT -->|auth-guard| DASH["/dashboard"]
    ROOT -->|auth-guard| MY_BLOG["/dashboard/my-blog"]
    ROOT -->|auth-guard| MY_COMPS["/dashboard/competitions"]
    ROOT -->|auth-guard| ANALYTICS["/dashboard/analytics"]
    ROOT -->|auth-guard| SUBMIT["/dashboard/submit"]
    ROOT -->|auth-guard| SETTINGS["/settings"]
    ROOT -->|auth-guard| SETTINGS_BILLING["/settings/billing"]

    ROOT -->|admin-guard| ADMIN["/admin"]
    ROOT -->|admin-guard| ADMIN_COMPS["/admin/competitions"]
    ROOT -->|admin-guard| ADMIN_BLOGS["/admin/blogs"]

    HOME -->|CTA| REGISTER
    HOME -->|CTA| EXPLORE
    REGISTER -->|redirect| ONBOARD
    ONBOARD -->|redirect| DASH
    EXPLORE -->|link| BLOG
    EXPLORE -->|link| COMP_LIST
    COMP_LIST -->|link| COMP_DETAIL
    COMP_DETAIL -->|CTA| SUBMIT
    DASH -->|nav| MY_BLOG
    DASH -->|nav| MY_COMPS
    DASH -->|nav| ANALYTICS
    LEADERBOARD -->|link| BLOG
```

---

## / — Home (Landing Page)

Primary conversion page. Communicates value prop, shows social proof, drives signup.

```mermaid
graph TD
    PAGE["/ Home"]
    PAGE --> HERO["HeroSection\n'Where bloggers compete to be discovered'\nCTA: Get Started Free / Explore Blogs"]
    PAGE --> SOCIAL["SocialProofBar\n'12,000+ blogs indexed · 340 active competitions · 98% satisfaction'"]
    PAGE --> HOW["HowItWorksSection\n3-step: Submit → Compete → Rise"]
    HOW --> STEP1["StepCard\nSubmit your blog"]
    HOW --> STEP2["StepCard\nAI evaluates quality"]
    HOW --> STEP3["StepCard\nClimb the leaderboard"]
    PAGE --> FEATURED["FeaturedCompetitionsGrid\nBento grid of 3-4 active competitions"]
    PAGE --> RISING["RisingBlogsCarousel\nHorizontal scroll of trending blogs"]
    PAGE --> TESTIMONIALS["TestimonialsSection\nBlogger quotes + avatar + blog link"]
    PAGE --> PRICING_PREVIEW["PricingPreview\nFree vs Pro comparison, CTA to /pricing"]
    PAGE --> FOOTER["Footer\nLinks, newsletter signup, social"]
```

**Data:** Static content + API: featured competitions, rising blogs (cached/ISR)

---

## /explore — Explore Blogs

Discovery page for browsing indexed blogs. Filterable, searchable, infinite scroll.

```mermaid
graph TD
    PAGE["/explore"]
    PAGE --> HEADER["PageHeader\n'Discover blogs worth reading'"]
    PAGE --> FILTERS["FilterBar\nCategory · Niche · Sort · AI Score Range"]
    PAGE --> GRID["BlogCardGrid\nInfinite scroll, bento layout"]
    GRID --> CARD["BlogCard\nThumbnail · Title · Author · AI Score Badge\nNiche Tags · Post Frequency · CTA: View Profile"]
    PAGE --> SIDEBAR["FilterSidebar (desktop)\nCategory tree · Tag cloud · Score distribution"]
```

**Data:** API: `/api/blogs?filters=...` with pagination. Search via query param.

---

## /blog/:slug — Blog Profile

Public profile for an indexed blog. Shows AI evaluation, recent posts, competition history.

```mermaid
graph TD
    PAGE["/blog/:slug"]
    PAGE --> HEADER["BlogProfileHeader\nBlog name · URL · Author avatar\nOverall AI Score (large) · Niche tags"]
    PAGE --> SCORES["AIScoreBreakdown\n[Minimal Tech zone]\nRadar chart: Originality · Engagement · Consistency\nWriting Quality · SEO · Visual Design"]
    PAGE --> TABS["TabNav\nPosts · Competitions · Analytics"]
    TABS --> POSTS["RecentPostsList\nTitle · Date · Individual score · Excerpt"]
    TABS --> COMP_HIST["CompetitionHistory\nCompetition name · Placement · Date"]
    TABS --> PUBLIC_ANALYTICS["PublicAnalytics\n[Minimal Tech zone]\nPost frequency chart · Score trend line"]
    PAGE --> SIMILAR["SimilarBlogsRow\nHorizontal scroll of related blogs"]
```

**Data:** API: `/api/blogs/:slug`, `/api/blogs/:slug/posts`, `/api/blogs/:slug/competitions`

---

## /competitions — Competition Listing

Browse all competitions (open, active, completed).

```mermaid
graph TD
    PAGE["/competitions"]
    PAGE --> HEADER["PageHeader\n'Compete. Get Discovered.'"]
    PAGE --> TABS["StatusTabs\nOpen · Active · Completed"]
    PAGE --> GRID["CompetitionCardGrid"]
    GRID --> CARD["CompetitionCard\nTitle · Theme/Niche · Prize/Reward\nEntry count · Deadline countdown\nStatus badge · CTA: View / Enter"]
    PAGE --> CREATE_CTA["CreateCompetitionCTA\n'Host your own competition' → /dashboard/competitions (Pro)"]
```

**Data:** API: `/api/competitions?status=open`

---

## /competitions/:id — Competition Detail

Single competition view with rules, entries, leaderboard.

```mermaid
graph TD
    PAGE["/competitions/:id"]
    PAGE --> HEADER["CompetitionHeader\nTitle · Host · Status badge\nDeadline countdown timer\nEntry count · Prize display"]
    PAGE --> RULES["RulesSection\nEligibility · Judging criteria weights\nAI scoring methodology · Community vote %"]
    PAGE --> ENTRIES["EntryGrid\nBlogCard entries with position #\nAI Score + Community Vote composite"]
    PAGE --> LIVE_BOARD["LiveLeaderboard\nAnimated position tracking\nTop 10 with movement arrows"]
    PAGE --> SUBMIT_CTA["SubmitCTA\n'Enter this competition' → /dashboard/submit?comp=:id"]
    PAGE --> DISCUSS["DiscussionThread\nComments from participants"]
```

**Data:** API: `/api/competitions/:id`, `/api/competitions/:id/entries`, `/api/competitions/:id/leaderboard`

---

## /leaderboard — Global Leaderboard

All-time and periodic rankings.

```mermaid
graph TD
    PAGE["/leaderboard"]
    PAGE --> HEADER["PageHeader\n'Top blogs on the internet'"]
    PAGE --> PERIOD["PeriodSelector\nAll Time · This Month · This Week"]
    PAGE --> CATEGORY["CategoryFilter\nAll · Tech · Lifestyle · Finance · Creative · ..."]
    PAGE --> PODIUM["PodiumDisplay\nTop 3 with avatars, blog names, scores\nTrophy/medal visual treatment"]
    PAGE --> TABLE["LeaderboardTable\nRank · Blog · Author · AI Score · Competitions Won\nMovement indicator (↑↓—)"]
    PAGE --> PAGINATION["Pagination\nLoad more / page selector"]
```

**Data:** API: `/api/leaderboard?period=all&category=all`

---

## /pricing — Pricing

Freemium tier comparison.

```mermaid
graph TD
    PAGE["/pricing"]
    PAGE --> HEADER["PageHeader\n'Choose your plan'"]
    PAGE --> TOGGLE["BillingToggle\nMonthly · Annual (save 20%)"]
    PAGE --> CARDS["PricingCardRow"]
    CARDS --> FREE["PricingCard — Free\nBlog listing · 2 competitions/month\nBasic AI score · Public profile"]
    CARDS --> PRO["PricingCard — Pro (highlighted)\n$12/mo · Unlimited competitions\nFull AI analytics · Priority indexing\nHost competitions · Export reports"]
    CARDS --> TEAM["PricingCard — Team\n$29/mo · Multi-blog management\nTeam analytics · API access\nWhite-label competitions"]
    PAGE --> FAQ["PricingFAQ\nAccordion: common questions"]
    PAGE --> CTA["FinalCTA\n'Start free — upgrade when you're ready'"]
```

**Data:** Static content. Stripe integration for checkout.

---

## /dashboard — User Dashboard

Authenticated home. Overview of user's blog, competitions, and performance.

```mermaid
graph TD
    PAGE["/dashboard"]
    PAGE --> SHELL["ShellChrome\nSidebar: Overview · My Blog · Competitions · Analytics · Submit"]
    SHELL --> WELCOME["WelcomeHeader\n'Welcome back, {name}'\nQuick stats row"]
    SHELL --> STATS["StatCardRow\n[Minimal Tech zone]\nOverall Score · Rank · Active Competitions · Total Posts Indexed"]
    SHELL --> RECENT["RecentActivityFeed\nScore changes · New competition entries · Badge earned"]
    SHELL --> ACTIVE["ActiveCompetitions\nList of current entries with position + time remaining"]
    SHELL --> SCORE_TREND["ScoreTrendChart\n[Minimal Tech zone]\nLine chart of AI score over time"]
```

**Data:** API: `/api/me/dashboard`

---

## /dashboard/my-blog — My Blog Management

Configure and manage the user's blog listing.

```mermaid
graph TD
    PAGE["/dashboard/my-blog"]
    PAGE --> SHELL["ShellChrome"]
    SHELL --> PROFILE["BlogProfileEditor\nBlog URL · Display name · Bio · Avatar\nNiche tags · Social links"]
    SHELL --> INDEX_STATUS["IndexingStatus\nLast crawl date · Post count · Indexing health\nManual re-index button"]
    SHELL --> POSTS["PostsList\nIndexed posts with individual AI scores\nSort by date / score"]
    SHELL --> SCORE_DETAIL["ScoreDetailPanel\n[Minimal Tech zone]\nPer-post AI breakdown\nImprovement suggestions"]
```

**Data:** API: `/api/me/blog`, `/api/me/posts`

---

## /dashboard/competitions — My Competitions

View and manage competition entries.

```mermaid
graph TD
    PAGE["/dashboard/competitions"]
    PAGE --> SHELL["ShellChrome"]
    SHELL --> TABS["Tabs\nActive · Past · Hosted (Pro)"]
    TABS --> ACTIVE["ActiveEntries\nCompetition name · Position · Score\nTime remaining · Link to competition"]
    TABS --> PAST["PastEntries\nCompetition name · Final position · Prize/badge"]
    TABS --> HOSTED["HostedCompetitions (Pro)\nCompetitions created by user · Entry count · Status"]
    SHELL --> CREATE["CreateCompetitionButton (Pro)\n→ Competition builder flow"]
```

**Data:** API: `/api/me/competitions`

---

## /dashboard/analytics — Analytics

Deep performance analytics for the user's blog.

```mermaid
graph TD
    PAGE["/dashboard/analytics"]
    PAGE --> SHELL["ShellChrome"]
    SHELL --> PERIOD["PeriodSelector\n7d · 30d · 90d · 1y · All"]
    SHELL --> OVERVIEW["MetricRow\n[Minimal Tech zone]\nOverall Score · Rank · Trend · Percentile"]
    SHELL --> SCORE_CHART["ScoreOverTimeChart\nMulti-line: Overall + per-dimension"]
    SHELL --> DIMENSIONS["DimensionBreakdown\nRadar chart + per-dimension trend\nOriginality · Engagement · Consistency · Quality · SEO · Design"]
    SHELL --> COMPARE["ComparePanel (Pro)\nBenchmark against niche average\nSide-by-side radar charts"]
    SHELL --> SUGGESTIONS["AISuggestions\nPrioritized improvement recommendations\nImpact estimate per suggestion"]
```

**Data:** API: `/api/me/analytics?period=30d`

---

## /dashboard/submit — Submit to Competition

Entry submission flow.

```mermaid
graph TD
    PAGE["/dashboard/submit"]
    PAGE --> SHELL["ShellChrome"]
    SHELL --> SELECT_COMP["CompetitionSelector\nDropdown of open competitions\nOr pre-filled from ?comp= query"]
    SHELL --> SELECT_POSTS["PostSelector\nCheckbox list of eligible indexed posts\nFilter by date / score"]
    SHELL --> PREVIEW["SubmissionPreview\nSelected posts · Competition rules match check\nEstimated score range"]
    SHELL --> CONFIRM["SubmitButton\nConfirm entry · Terms acceptance"]
    SHELL --> SUCCESS["SuccessState\nConfetti animation · Link to competition page"]
```

**Data:** API: POST `/api/competitions/:id/entries`

---

## /settings — User Settings

Account and preference management.

```mermaid
graph TD
    PAGE["/settings"]
    PAGE --> SHELL["ShellChrome"]
    SHELL --> PROFILE["ProfileSection\nName · Email · Avatar · Password change"]
    SHELL --> NOTIFS["NotificationPrefs\nEmail digest frequency · Competition alerts\nScore change notifications"]
    SHELL --> PRIVACY["PrivacySettings\nPublic/private profile · Analytics visibility"]
    SHELL --> CONNECTED["ConnectedAccounts\nBlog URL management · Social links · RSS feed config"]
    SHELL --> DANGER["DangerZone\nDelete account · Export data"]
```

**Data:** API: `/api/me/settings`

---

## /settings/billing — Billing (Pro/Team)

Subscription management via Stripe Customer Portal.

```mermaid
graph TD
    PAGE["/settings/billing"]
    PAGE --> SHELL["ShellChrome"]
    SHELL --> PLAN["CurrentPlan\nPlan name · Price · Next billing date"]
    SHELL --> USAGE["UsageMetrics\nCompetitions this month · Blogs managed"]
    SHELL --> UPGRADE["UpgradeCard\nFeature comparison · Upgrade CTA"]
    SHELL --> PORTAL["StripePortalLink\n'Manage billing' → Stripe Customer Portal"]
    SHELL --> INVOICES["InvoiceHistory\nDate · Amount · Status · Download link"]
```

**Data:** API: `/api/me/billing`, Stripe Customer Portal redirect

---

## Auth Pages

### /login

```mermaid
graph TD
    PAGE["/login"]
    PAGE --> FORM["LoginForm\nEmail · Password · Remember me\nForgot password link\nOAuth buttons: Google, GitHub"]
    PAGE --> SIGNUP["SignupLink\n'No account? Sign up →'"]
```

### /register

```mermaid
graph TD
    PAGE["/register"]
    PAGE --> FORM["RegisterForm\nName · Email · Password\nOAuth buttons: Google, GitHub"]
    PAGE --> TERMS["TermsCheckbox\nAccept terms + privacy"]
    PAGE --> LOGIN["LoginLink\n'Already have an account? Log in →'"]
```

### /onboarding

```mermaid
graph TD
    PAGE["/onboarding"]
    PAGE --> STEP1["Step 1: Add Your Blog\nURL input · Auto-detect blog platform\nValidation feedback"]
    PAGE --> STEP2["Step 2: Choose Your Niches\nTag selector · 3-5 required"]
    PAGE --> STEP3["Step 3: First Competition\nSuggested competitions based on niche\nOptional — skip to dashboard"]
    PAGE --> PROGRESS["ProgressIndicator\nStep dots · 'Skip for now' link"]
```

---

## Admin Pages

### /admin

```mermaid
graph TD
    PAGE["/admin"]
    PAGE --> STATS["AdminStats\nTotal blogs · Users · Active competitions\nSignup trend · Revenue"]
    PAGE --> RECENT["RecentActivity\nNew signups · Reports · Flagged content"]
    PAGE --> ACTIONS["QuickActions\nCreate competition · Feature blog · Send announcement"]
```

### /admin/competitions & /admin/blogs

Standard CRUD admin panels with search, filter, bulk actions.

---

## Page Inventory

| Route | Purpose | Auth | Key Components | Data Sources |
|-------|---------|------|----------------|--------------|
| `/` | Landing page | Public | HeroSection, HowItWorks, FeaturedCompetitions | Static + API (cached) |
| `/explore` | Blog discovery | Public | FilterBar, BlogCardGrid, BlogCard | API: blogs |
| `/blog/:slug` | Blog profile | Public | AIScoreBreakdown, TabNav, PostsList | API: blog detail |
| `/competitions` | Competition listing | Public | StatusTabs, CompetitionCardGrid | API: competitions |
| `/competitions/:id` | Competition detail | Public | LiveLeaderboard, EntryGrid, DiscussionThread | API: competition detail |
| `/leaderboard` | Global rankings | Public | PodiumDisplay, LeaderboardTable | API: leaderboard |
| `/pricing` | Plan comparison | Public | PricingCard, BillingToggle, PricingFAQ | Static |
| `/about` | About / methodology | Public | Static content | Static |
| `/login` | Sign in | Auth | LoginForm, OAuth buttons | — |
| `/register` | Sign up | Auth | RegisterForm, OAuth buttons | — |
| `/onboarding` | New user setup | Auth | StepWizard, BlogURLInput, NicheSelector | — |
| `/dashboard` | User overview | Protected | StatCardRow, ScoreTrendChart, ActivityFeed | API: dashboard |
| `/dashboard/my-blog` | Blog management | Protected | BlogProfileEditor, IndexingStatus, PostsList | API: my blog |
| `/dashboard/competitions` | My competitions | Protected | ActiveEntries, PastEntries, HostedComps | API: my competitions |
| `/dashboard/analytics` | Performance analytics | Protected | ScoreOverTimeChart, DimensionBreakdown | API: analytics |
| `/dashboard/submit` | Competition entry | Protected | CompetitionSelector, PostSelector | API: submit |
| `/settings` | Account settings | Protected | ProfileSection, NotificationPrefs | API: settings |
| `/settings/billing` | Billing management | Protected | CurrentPlan, StripePortalLink | API: billing |
| `/admin` | Admin dashboard | Admin | AdminStats, QuickActions | API: admin |
| `/admin/competitions` | Manage competitions | Admin | CRUD table | API: admin |
| `/admin/blogs` | Manage blogs | Admin | CRUD table | API: admin |
| `/styleguide` | Design system viewer | Public | ThemeConfigProvider | Theme YAML |
| `/sitemap` | Site architecture | Public | Mermaid diagrams | Config |

---

## Navigation

### Primary Nav (top bar — public)
- Explore → `/explore`
- Competitions → `/competitions`
- Leaderboard → `/leaderboard`
- Pricing → `/pricing`
- Login / Sign Up (when unauthenticated)
- Dashboard (when authenticated)

### Dashboard Sidebar (authenticated)
- Overview → `/dashboard`
- My Blog → `/dashboard/my-blog`
- Competitions → `/dashboard/competitions`
- Analytics → `/dashboard/analytics`
- Submit → `/dashboard/submit`
- Settings → `/settings`

### Auth Gates
- `/dashboard/*` — requires authenticated session
- `/settings/*` — requires authenticated session
- `/admin/*` — requires admin role
- All other routes — public
