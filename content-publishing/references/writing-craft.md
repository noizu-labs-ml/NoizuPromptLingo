# Writing Craft

> Hooks, structure, voice, editing, and readability. The trl-content-publishing skill plans and tracks content — this file teaches you to write it well.

---

## Table of Contents

1. [Headline Formulas](#headline-formulas)
2. [Opening Hooks](#opening-hooks)
3. [Structural Patterns](#structural-patterns)
4. [Voice Development](#voice-development)
5. [Technical Writing Specifics](#technical-writing-specifics)
6. [Editing Process](#editing-process)
7. [Readability Scoring](#readability-scoring)
8. [Common Mistakes](#common-mistakes)

---

## Headline Formulas

Your headline determines whether anyone reads further. 80% of readers never get past it.

### Formula Categories

**The Number List**
```
[Number] [Adjective] Ways to [Desirable Outcome]
"7 Underrated Ways to Speed Up Docker Builds"
"12 Debugging Techniques Senior Engineers Actually Use"
```
Works because: specific promise, scannable format, implies completeness.

**The How-To**
```
How to [Achieve Outcome] [Without/With/Using] [Constraint/Tool]
"How to Deploy Kubernetes Without Losing Your Weekends"
"How to Write Technical Docs Using AI (Without Sounding Like a Robot)"
```
Works because: promises a specific transformation with a relatable constraint.

**The Versus**
```
[Option A] vs [Option B]: [Decision Framework] in [Year]
"PostgreSQL vs MongoDB: Which to Choose for Your Next Project in 2026"
```
Works because: captures search intent, implies objectivity.

**The Confession**
```
I [Did Something Unexpected] and [Result]
"I Replaced My Entire CI/CD Pipeline with Claude and Here's What Happened"
"I Stopped Writing Tests for 6 Months. My Code Got Better."
```
Works because: personal stakes, curiosity gap, contrarian.

**The Direct Promise**
```
The [Adjective] Guide to [Topic] [Qualifier]
"The No-Bullshit Guide to Kubernetes Networking"
"The Complete Guide to API Rate Limiting (With Code)"
```
Works because: confidence signals value, qualifier adds specificity.

**The Question**
```
Why [Surprising Claim]?  /  What [Unexpected Thing] Teaches Us About [Topic]
"Why Your Microservices Are Slower Than a Monolith"
"What Video Games Teach Us About API Design"
```
Works because: activates curiosity, challenges assumptions.

### Headline Testing Checklist

- [ ] Does it promise a specific outcome or insight?
- [ ] Would you click on it if someone else wrote it?
- [ ] Is it under 70 characters (for full display in search)?
- [ ] Does it include the primary keyword naturally?
- [ ] Does it differentiate from the top 5 Google results?
- [ ] Could a skeptic read it without rolling their eyes?

### Headlines to Avoid

| Pattern | Why It Fails |
|---------|-------------|
| "Everything You Need to Know About X" | Too vague, overpromises |
| "X is Dead" | Overused, usually wrong |
| "You Won't Believe..." | Clickbait, erodes trust |
| "A Deep Dive into X" | Generic, says nothing about value |
| "X: A Comprehensive Overview" | Academic, boring |

---

## Opening Hooks

You have 3 sentences to keep the reader. If your introduction is "In this article, we will explore..." you've already lost.

### Hook Types

**The Problem Statement**
Start with the pain the reader is currently experiencing.

```markdown
Your Docker builds take 15 minutes. You push a one-line CSS change and
wait while npm install runs for the 400th time today. There's a better way.
```
Best for: tutorials, how-tos.

**The Story**
Start with a specific moment.

```markdown
It was 2 AM and our production database was returning empty results for
every query. The monitoring showed green across the board. The PagerDuty
alert that woke me up was from a customer tweet.
```
Best for: analysis, lessons learned, case studies.

**The Contrarian Claim**
Open with something the reader will disagree with.

```markdown
You don't need microservices. I know — heresy in 2026. But after
migrating three companies to microservices and migrating two of them back,
I'm convinced most teams adopt them too early.
```
Best for: opinion pieces, experience reports.

**The Statistic**
A surprising number that reframes the reader's understanding.

```markdown
73% of Kubernetes deployments in production have at least one
misconfigured security context. If you're running K8s, the odds are
your cluster is one of them.
```
Best for: security, performance, research-backed pieces.

**The Question**
Ask the question the reader is already thinking.

```markdown
When was the last time you actually read a Terraform plan before
typing 'yes'? If the answer is 'I skim it,' you're not alone — and
you're one bad plan away from a production incident.
```
Best for: engaging experienced practitioners.

**The Before/After**
Show the transformation immediately.

```markdown
Before: 47 manual steps to deploy. A full day with at least one rollback.
After: One command. 8 minutes. Zero rollbacks in 6 months.
Here's how we got there.
```
Best for: transformation stories, tooling guides.

### Hook Anti-Patterns

| Opening | Why It Fails | Fix |
|---------|-------------|-----|
| "In this article, we'll..." | Boring, tells instead of shows | Start with the problem or story |
| "According to Wikipedia..." | Signals lazy research | Use a specific, surprising stat |
| "[Technology] is a..." | Dictionary definition opening | Assume the reader knows what it is |
| "As developers, we all know..." | Condescending + assumption | State the specific situation |
| "I've been meaning to write about..." | Self-focused, reader doesn't care | Delete and start with value |

---

## Structural Patterns

Structure determines whether a reader finishes your article. Choose the right pattern for your content type.

### Pattern 1: Problem-Agitate-Solve (PAS)

**Structure:**
1. **Problem:** State the specific pain point (1-2 paragraphs)
2. **Agitate:** Make the problem feel urgent/costly (2-3 paragraphs)
3. **Solve:** Present the solution with clear steps (bulk of article)

**Best for:** Tutorials, product reviews, "how I fixed X" articles.

**Example outline:**
```
Problem:  "Database migrations in production are terrifying"
Agitate:  "Last month, a migration took down our API for 3 hours. Revenue
          lost: $12K. Customer trust: priceless."
Solve:    "Here's the zero-downtime migration strategy we use now"
          → Step 1: Shadow columns
          → Step 2: Dual-write
          → Step 3: Backfill
          → Step 4: Cut over
          → Step 5: Clean up
```

### Pattern 2: Inverted Pyramid

**Structure:**
1. **Lead:** Most important information first (answer the question)
2. **Details:** Supporting context, evidence, nuance
3. **Background:** History, alternatives, edge cases

**Best for:** News, announcements, "what changed in X" articles.

**Why it works:** Readers who leave early still got the essential information.

### Pattern 3: Listicle with Depth

**Structure:**
1. Brief intro (why this list matters)
2. List items, each with: heading, explanation, example, when to use
3. Summary with "start here" recommendation

**Best for:** Roundups, technique collections, tool comparisons.

**Key rule:** Each item must stand alone. A reader should be able to jump to item #7 and understand it fully.

### Pattern 4: Narrative Arc

**Structure:**
1. **Setup:** Situation before the change
2. **Conflict:** What went wrong / what wasn't working
3. **Journey:** What you tried (including failures)
4. **Resolution:** What ultimately worked
5. **Lesson:** Generalizable takeaway

**Best for:** Case studies, experience reports, "lessons from X" articles.

### Pattern 5: Compare and Decide

**Structure:**
1. **Context:** Why the comparison matters
2. **Criteria:** What factors matter (list explicitly)
3. **Analysis:** Each option against each criterion
4. **Recommendation:** Who should choose what

**Best for:** X vs Y articles, tool selection guides, architecture decision records.

### Pattern 6: The Pillar

**Structure:**
1. Comprehensive overview section
2. Deep-dive into each subtopic (linked sections)
3. FAQ
4. Further reading / related articles

**Best for:** Definitive guides, SEO cornerstone content, reference articles.

**Length:** 3000-5000 words. This is the article that ranks and becomes a permanent asset.

### Choosing the Right Pattern

| Content Type | Best Pattern | Typical Length |
|---|---|---|
| Tutorial / How-to | PAS or Listicle | 1500-2500 words |
| Opinion / Analysis | Narrative Arc | 1200-2000 words |
| Comparison / Review | Compare and Decide | 1500-3000 words |
| Comprehensive guide | Pillar | 3000-5000 words |
| News / Changelog | Inverted Pyramid | 500-1000 words |
| Listicle / Roundup | Listicle with Depth | 1500-3000 words |

---

## Voice Development

Your writing voice is what turns readers into subscribers. It's the reason someone reads YOU instead of the documentation.

### Finding Your Voice

Your voice sits at the intersection of three things:

```
YOUR EXPERTISE ─── what you know that others don't
     ↕
YOUR PERSONALITY ─ how you naturally explain things
     ↕
YOUR AUDIENCE ──── what they need to hear and how
```

### Voice Attributes to Choose From

Pick 3-4 attributes. More than that creates inconsistency.

| Attribute | Sounds Like | Avoid Sliding Into |
|-----------|------------|-------------------|
| **Direct** | "Here's what to do." | Terse / rude |
| **Conversational** | "So here's the thing..." | Rambling / unfocused |
| **Authoritative** | "Based on 10 years of..." | Condescending |
| **Irreverent** | "Kubernetes? More like K8s-of-pain" | Trying too hard |
| **Precise** | "Specifically, the issue is..." | Pedantic |
| **Empathetic** | "I know this is frustrating" | Patronizing |
| **Analytical** | "The data shows..." | Dry / academic |
| **Enthusiastic** | "This is genuinely exciting" | Exhausting |

### Consistency Rules

1. **Use the same level of formality throughout.** Don't open with "Yo, what's up" and close with "In conclusion, we have demonstrated..."
2. **Pick a pronoun and stick with it.** "I" for personal authority. "We" for collaborative tone. "You" for direct instruction. Avoid "one" (academic).
3. **Develop catchphrases or patterns.** Recurring structural elements (a "TL;DR" at the top, a "The real lesson" callout) become signature.
4. **Read your drafts aloud.** If it doesn't sound like you talking, rewrite until it does.

### Voice Calibration by Audience

| Audience | Voice Lean | Example |
|----------|-----------|---------|
| Junior developers | Empathetic + Direct | "Don't worry, this confused me too. Here's the fix." |
| Senior engineers | Precise + Analytical | "The tradeoff: read amplification vs write latency." |
| Mixed technical | Conversational + Authoritative | "I've seen this pattern fail in three companies. Here's why." |
| Non-technical | Enthusiastic + Empathetic | "You don't need to understand the code. Here's what it means for you." |

---

## Technical Writing Specifics

Technical content has unique requirements beyond general writing quality.

### Code Examples

**Rules:**
- Every code example must work. Copy-paste-run is the standard.
- Show the complete context (imports, setup) on first usage, abbreviated after.
- Annotate with comments explaining the "why," not the "what."
- Show input AND output (expected result).
- Include error handling — production code has errors.

**Pattern: Progression**
```
1. Minimal working example (simplest case)
2. Real-world example (with error handling, edge cases)
3. Production-ready example (with logging, monitoring, configuration)
```

### Diagrams and Visuals

- **Architecture diagrams:** Use mermaid (rendered on most platforms).
- **Sequence diagrams:** Essential for explaining async flows.
- **Before/after screenshots:** For UI changes or dashboard improvements.
- **Terminal output:** Show actual output, not "you should see something like..."

### Version Pinning

- Always specify versions of tools/libraries used.
- Date the article clearly.
- Add a "Last verified" date.
- If something is likely to change (API behavior, UI), note it.

### Prerequisites Section

Every tutorial needs a clear prerequisites section:

```markdown
## Prerequisites
- Node.js 20+ installed
- Basic familiarity with Docker (containers, images, docker-compose)
- A free Vercel account
- ~30 minutes
```

---

## Editing Process

Writing is rewriting. Plan for at least two editing passes.

### Pass 1: Structural Edit (Big Picture)

Read the full draft and ask:

- [ ] Does the headline promise something the article delivers?
- [ ] Does the opening hook grab attention in 3 sentences?
- [ ] Is the structural pattern clear and consistent?
- [ ] Does every section earn its place? (Delete sections that don't add value)
- [ ] Is there a clear conclusion/CTA?
- [ ] Would a reader who stops halfway still get value?

**Actions:** Reorder sections, cut irrelevant material, add missing context, strengthen transitions.

### Pass 2: Line Edit (Sentence Level)

Go sentence by sentence:

- [ ] Cut every word that doesn't add meaning
- [ ] Replace passive voice with active ("The error was caused by" → "A null pointer caused")
- [ ] Replace jargon with plain language (unless audience expects it)
- [ ] Break sentences longer than 25 words into two
- [ ] Vary sentence length (short sentences after complex ones for rhythm)
- [ ] Remove weasel words: "very," "really," "just," "basically," "simply," "actually"
- [ ] Replace "thing" and "stuff" with specific nouns
- [ ] Check that every paragraph starts with a strong sentence

### Pass 3: Polish (Final)

- [ ] Spell-check (including code variable names in text)
- [ ] Link check (all URLs resolve)
- [ ] Code check (all examples run)
- [ ] Formatting check (consistent heading levels, code block languages specified)
- [ ] Image alt text present
- [ ] Meta description written (155 characters)
- [ ] Read the first and last paragraphs back-to-back — do they tell a coherent story?

### The Cut Test

After editing, your article should be **20-30% shorter** than the first draft. If it isn't, you haven't cut enough.

**Things to cut:**
- Throat-clearing paragraphs ("Before we begin, let me explain why this matters...")
- Obvious statements ("Security is important")
- Repeated points (said differently doesn't mean said better)
- Qualifiers that weaken claims ("I think maybe perhaps this could possibly work")

---

## Readability Scoring

### Target Metrics

| Metric | Target | Tool |
|--------|--------|------|
| Flesch Reading Ease | 50-65 (for technical content) | Hemingway Editor, readable.com |
| Grade Level | 8-10 (Flesch-Kincaid) | Same tools |
| Average sentence length | 15-20 words | Word count / sentence count |
| Paragraph length | 3-5 sentences max | Visual check |
| Passive voice | <10% of sentences | Hemingway Editor |

### Readability Rules for Technical Content

1. **One idea per paragraph.** If you can't summarize the paragraph in one sentence, split it.
2. **Front-load sentences.** Put the important information at the start: "Docker caches layers" not "When building images, the layers that Docker creates are cached."
3. **Use lists for 3+ related items.** If you write "you need X, Y, and Z," make it a bulleted list.
4. **Use tables for comparisons.** Prose comparisons ("A is better at X but B is better at Y while C...") are unreadable. Tables are scannable.
5. **Headers every 300-500 words.** Readers scan. Give them anchor points.
6. **Bold key terms on first use.** Exactly once. Not every time.

### Scanability Checklist

A reader should be able to understand your article by reading only:
- [ ] The headline
- [ ] All headings
- [ ] The first sentence of each section
- [ ] All bold text
- [ ] Any tables/lists
- [ ] The conclusion

If those elements tell a coherent story, your article is properly scannable.

---

## Common Mistakes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| **Writing for yourself** | Assumes reader has your context | Add a "who this is for" opening |
| **Burying the lede** | Best insight is in paragraph 12 | Move it to the opening |
| **Wall of text** | No headings, no lists, no breaks | Break every 300 words |
| **Code without context** | Code block with no explanation | Explain WHAT it does AND WHY |
| **No working examples** | "In theory, you could..." | Show the actual command and output |
| **Over-qualifying** | "This might potentially help if..." | Be direct: "This fixes the problem." |
| **Assuming knowledge** | Uses acronyms without definition | Define on first use or link to docs |
| **No conclusion** | Article just stops | Summarize what was covered + next step |
| **Perfectionism** | Never publishing | Publish at 80%, iterate based on feedback |
| **Writing one long draft** | Editing is overwhelming | Write in sections, edit section by section |

---

*For content planning and calendaring, see [content-calendar.md](content-calendar.md). For topic research and SEO, see trl-market-intelligence `references/keyword-research.md`. For platform-specific publishing, see [agent-playbook.md](agent-playbook.md).*

---

*Version: 0.1.0*
