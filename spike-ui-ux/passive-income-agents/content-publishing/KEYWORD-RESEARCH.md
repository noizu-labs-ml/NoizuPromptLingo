# Keyword Research Framework

> Systematic approach to finding high-value keywords and content opportunities for developer/technical content.

---

## Research Methodology

### Step 1: Seed Keyword Expansion

Start with broad topics in your expertise:

```markdown
## Seed Keyword Expansion

**Primary Topic:** [e.g., "Kubernetes"]

**Expand to:**

1. **Core Concepts:**
   - [topic] basics
   - [topic] tutorial
   - [topic] for beginners
   - what is [topic]
   - [topic] explained

2. **How-To Variations:**
   - how to [action] in [topic]
   - how to [action] with [topic]
   - [topic] [action] guide

3. **Problem/Error Keywords:**
   - [topic] [error message]
   - [topic] not working
   - [topic] troubleshooting
   - fix [topic] [problem]

4. **Comparison Keywords:**
   - [topic] vs [alternative]
   - [topic] or [alternative]
   - best [topic] for [use case]

5. **Long-tail Specifics:**
   - [topic] [specific tool/version]
   - [topic] [specific use case]
   - [topic] [specific industry]
```

### Step 2: Search Intent Classification

For each keyword, classify the intent:

| Intent | Description | Content Type | Example |
|--------|-------------|--------------|---------|
| **Informational** | Learning/understanding | Tutorial, explainer | "what is kubernetes" |
| **Navigational** | Finding specific thing | Landing page, docs | "kubernetes documentation" |
| **Commercial** | Evaluating options | Comparison, review | "kubernetes vs docker swarm" |
| **Transactional** | Ready to act/buy | Guide, tool | "kubernetes hosting best" |

### Step 3: Difficulty Assessment

```markdown
## Keyword Difficulty Assessment

**Keyword:** [keyword]

**SERP Analysis:**
- Position 1-3: [Who ranks? Authority level]
- Content type ranking: [Tutorials? Lists? Docs?]
- Content length: [Word count of top results]
- Content quality: [Comprehensive? Outdated?]

**Competition Signals:**
- Domain authority of rankers: High / Medium / Low
- Content freshness: Recent / Dated
- Content depth: Thorough / Surface

**Opportunity Score:**
- [ ] Top results are outdated (6+ months)
- [ ] Top results are thin/incomplete
- [ ] Top results from low-authority domains
- [ ] Gap in specific angle/approach
- [ ] Your unique expertise applies

**Difficulty:** Easy / Medium / Hard / Don't Compete
```

---

## Research Tools & Techniques

### Free Tools

| Tool | Best For | How to Use |
|------|----------|------------|
| **Google Autocomplete** | Seed expansion | Type partial query, note suggestions |
| **Google "People Also Ask"** | Question discovery | Expand PAA boxes, note questions |
| **Google Related Searches** | Lateral ideas | Check bottom of SERP |
| **AnswerThePublic** | Question mapping | Limited free searches |
| **AlsoAsked** | PAA tree mapping | Shows PAA relationships |
| **Keyword Surfer** | Volume estimates | Chrome extension, free |
| **Ubersuggest** | Basic metrics | Limited free tier |

### Platform-Specific Research

**Stack Overflow:**
```
site:stackoverflow.com [topic]
Sort by: Votes (most popular problems)
Look for: Frequent questions, outdated answers
```

**Reddit:**
```
site:reddit.com [topic] + [subreddit]
Sort by: Top (this month/year)
Look for: Complaints, questions, recommendations
```

**GitHub:**
```
github.com/search?type=issues [topic] + [problem]
Look for: Common issues, feature requests
```

**Hacker News:**
```
hn.algolia.com - search [topic]
Look for: Discussion trends, hot takes, debates
```

---

## Keyword Templates

### Tutorial Keywords

```
how to [action] in [technology]
[technology] [action] tutorial
[technology] [action] guide
[technology] [action] step by step
[technology] [action] for beginners
[technology] [action] example
```

### Troubleshooting Keywords

```
[technology] [error message]
[technology] [problem] fix
[technology] not [expected behavior]
[technology] [action] not working
why [technology] [unexpected behavior]
[technology] [problem] solution
```

### Comparison Keywords

```
[technology A] vs [technology B]
[technology A] or [technology B]
[technology A] vs [technology B] [year]
[technology A] vs [technology B] for [use case]
best [category] [year]
[technology] alternatives
```

### Best Practices Keywords

```
[technology] best practices
[technology] [action] best practices
[technology] tips
[technology] mistakes to avoid
[technology] dos and donts
[technology] patterns
```

---

## Content Gap Analysis

### Process

```markdown
## Content Gap Analysis: [TOPIC]

**Step 1: Map Existing Content**
Search: site:[your-domain] [topic]
List all your existing content on this topic.

**Step 2: Map Competitor Content**
For top 3 competitors, search: site:[competitor] [topic]
List their content.

**Step 3: Identify Gaps**

| Subtopic | You | Comp 1 | Comp 2 | Comp 3 | Gap? |
|----------|-----|--------|--------|--------|------|
| [subtopic] | ✓/✗ | ✓/✗ | ✓/✗ | ✓/✗ | Yes/No |

**Step 4: Prioritize Gaps**

| Gap | Search Volume | Difficulty | Priority |
|-----|---------------|------------|----------|
| | High/Med/Low | Easy/Med/Hard | 1/2/3 |
```

---

## Keyword Tracking Template

### Target Keywords

| Keyword | Volume | Difficulty | Target Article | Status | Rank |
|---------|--------|------------|----------------|--------|------|
| | H/M/L | E/M/H | [Article ID] | Draft/Live/None | #/- |

### Ranking Progress

| Keyword | M1 | M2 | M3 | M4 | M5 | M6 | Trend |
|---------|----|----|----|----|----|----|-------|
| | - | - | #50 | #32 | #18 | #12 | ↑ |

---

## Quick Research Prompts

### For Claude/ChatGPT

```markdown
I'm writing technical content about [TOPIC].

Please help me identify:

1. **Common questions** developers ask about [TOPIC] (10-15 questions)

2. **Common problems/errors** they encounter (5-10 problems)

3. **Comparison topics** they might search for (5 comparisons)

4. **Underserved subtopics** - areas with less comprehensive content available

5. **Trending aspects** - what's new or changing in [TOPIC]

For each, estimate relative search volume (High/Medium/Low) and content competition (High/Medium/Low).
```

### For Web Search

```markdown
Search queries to run:

1. "[topic] tutorial" - check what's ranking, identify gaps
2. "[topic] vs" - autocomplete shows what people compare
3. "[topic] how to" - autocomplete shows common tasks
4. "[topic] error" - autocomplete shows common problems
5. site:reddit.com/r/[relevant-sub] [topic] - community questions
6. site:stackoverflow.com [topic] - developer problems
7. "[topic]" site:dev.to - what's popular on Dev.to
```

---

## Seasonal/Trending Keyword Calendar

### Annual Patterns

| Month | Trend | Content Opportunity |
|-------|-------|---------------------|
| January | New year, planning | "Best [tools] 2025", Setup guides |
| March | Tax season (US) | Financial tools for devs |
| May-June | Graduation | Career content, learning paths |
| September | Back to work | Productivity, new tools |
| October-November | Black Friday | Tool comparisons, deals |
| December | Year-end | Retrospectives, predictions |

### React to Events

- **Major releases:** Be first with "[Tool] [Version] features guide"
- **Security issues:** Quick explainer + fix guides
- **Conferences:** Summary posts, key takeaways
- **Company news:** Impact analysis (acquisitions, pivots)

---

## Validation Checklist

Before committing to a keyword:

- [ ] Search volume exists (some signal of demand)
- [ ] Competition is winnable (not all DR 90+ sites)
- [ ] Intent matches my content type
- [ ] I have expertise or can develop it
- [ ] Fits my content strategy/funnel
- [ ] Can create better content than what ranks

---

*Version: 0.1.0*
