# Research Prompts

Complete prompt library for trend research, keyword mining, topic validation, and idea generation.

---

## 1. Research Overview

All research prompts follow the same pattern: define the search scope, execute structured queries, compile results into tables for prioritization. Replace `[TOPIC]`, `[NICHE]`, `[TECHNOLOGY]`, etc. with your specific domain.

---

## 2. Trend Research

### 2.1 Web Search Research

```
## Content Research: [TOPIC AREA]

I need to research content opportunities in: [e.g., "AI/ML engineering", "DevOps", "React"]

### Search Tasks

**1. Trending Topics**
Search for:
- "[topic] trends 2025"
- "[topic] news this week"
- "new [topic] tools"
- Reddit r/[relevant-subreddit] top posts this month

**2. Common Problems**
Search for:
- "[topic] common errors"
- "[topic] troubleshooting"
- "how to [topic]" site:stackoverflow.com
- "[topic] best practices"

**3. Search Volume Indicators**
Search for:
- Google Trends: [topic] related queries
- "People also ask" for [topic]
- Related searches at bottom of Google results

**4. Content Gaps**
Search for:
- "[specific subtopic]" - check if well-covered
- "[problem] tutorial" - quality of existing content
- "[tool] vs [tool]" comparisons

### Compile Results

**Trending Topics Found:**
| Topic | Source | Trend Direction | Timeliness |
|-------|--------|-----------------|------------|
| | | ↑/→/↓ | Hot/Warm/Evergreen |

**High-Search Problems:**
| Problem | Search Evidence | Existing Content Quality |
|---------|-----------------|-------------------------|
| | | Poor/Medium/Good |

**Content Gaps Identified:**
| Gap | Opportunity | Difficulty to Fill |
|-----|-------------|---------------------|
| | | Easy/Medium/Hard |

**Keyword Opportunities:**
| Keyword/Phrase | Estimated Volume | Competition |
|----------------|------------------|-------------|
| | High/Med/Low | High/Med/Low |
```

### 2.2 Hacker News & Reddit Mining

```
## Mine Developer Communities for Content Opportunities

Research active discussions in [NICHE].

### Hacker News
- Search: "[TOPIC]" in past month
- Note: Posts with 100+ points
- Identify: Debates, questions, misconceptions

### Reddit
- r/programming, r/webdev, r/[SPECIFIC_TECH], r/ExperiencedDevs

Search for:
- "How do I..." posts
- "Why does..." posts
- Comparison requests
- Rant threads (pain points = content opportunities)

### Document

| Discussion | Platform | Engagement | Content Opportunity |
|------------|----------|------------|---------------------|
| [Title] | HN/Reddit | [upvotes/comments] | [Article angle] |

### Look for patterns
- Questions asked repeatedly
- Misconceptions corrected often
- Strong opinions (controversy = engagement)
- Requests for resources/guides
```

### 2.3 Twitter/X Tech Discussions

```
## Twitter/X Trend Analysis for [NICHE]

### Search Strategies
1. "[TECHNOLOGY] thread" — educational threads to expand
2. "TIL [TECHNOLOGY]" — learning moments
3. "[TECHNOLOGY] tip" — quick-win content
4. "[TECHNOLOGY] vs" — comparison debates
5. "#[TECHNOLOGY]" — hashtag trends

### Influencer Mining
- Identify top voices in [NICHE]
- Note their most engaged posts
- Find gaps they haven't covered

### Document

| Topic | Engagement | Type | Our Angle |
|-------|------------|------|-----------|
| | likes/RTs | Thread/Debate/Question | |

### Content Opportunities
- Threads to expand into articles
- Debates to provide balanced analysis
- Questions to answer definitively
```

### 2.4 YouTube & Podcast Mining

```
## Video/Audio Content Mining for [NICHE]

### YouTube Search
- "[TOPIC] tutorial" — What's getting views?
- Sort by: Upload date (recent), View count
- Note: High views + poor quality = opportunity

### Podcast Research
- Search [NICHE] podcasts on Spotify/Apple
- Note frequently discussed topics
- Identify debates without resolution

### Document

| Content | Platform | Views/Downloads | Written Content Gap |
|---------|----------|-----------------|---------------------|
| [Title] | YT/Pod | | [What article could add] |

### Opportunities
- Popular videos that need written companion
- Podcast discussions lacking definitive guide
- Outdated content needing update
```

### 2.5 Platform-Specific Research

```
## Platform Research: [PLATFORM] for [TOPIC]

### Dev.to Analysis
Search: site:dev.to [topic]
- Top performing articles (by reactions)
- Common formats that work
- Gaps in coverage

### Medium Analysis
Search: site:medium.com [topic]
- Publication opportunities
- Successful article patterns
- Monetization evidence

### Substack Analysis
Search: [topic] substack
- Successful newsletters in space
- Pricing patterns
- Content frequency

### Compile Platform Strategy

**Best Platform for Topic:** [Platform]
**Reasoning:** [Why]

**Cross-Posting Strategy:**
1. Primary: [Platform] — [Reason]
2. Syndicate to: [Platform] — [Timing]
3. Repurpose for: [Platform] — [Format change]
```

---

## 3. Keyword Research

### 3.1 Developer Query Analysis

```
## Keyword Research for [TOPIC]

### Search Tools
- Google Autocomplete
- Google "People also ask"
- AnswerThePublic
- Ahrefs/Semrush (if available)
- Google Search Console (existing site)

### Query Categories

**"How to" Queries** — Search: "how to [TOPIC]"
| Query | Estimated Intent | Competition |
|-------|------------------|-------------|
| | | High/Med/Low |

**"What is" Queries** — Search: "what is [TOPIC]"
[Same format]

**"Best" Queries** — Search: "best [TOPIC]"
[Same format]

**"[Topic] vs" Queries** — Search: "[TOPIC] vs"
[Same format]

**Error/Problem Queries** — Search: "[TOPIC] error", "[TOPIC] not working"
[Same format]

### Prioritization Matrix
| Query | Search Volume | Competition | Intent Match | Priority |
|-------|---------------|-------------|--------------|----------|
| | High/Med/Low | High/Med/Low | High/Med/Low | 1-5 |
```

### 3.2 Long-Tail Keyword Mining

```
## Long-Tail Keywords for [TOPIC]

### Patterns
- "[TOPIC] in [LANGUAGE/FRAMEWORK]"
- "[TOPIC] for [USE_CASE]"
- "[TOPIC] [YEAR]"
- "[TOPIC] [SPECIFIC_PROBLEM]"
- "[TOPIC] without [COMMON_TOOL]"

### Process
1. Start with head term: "[TOPIC]"
2. Add modifiers from autocomplete
3. Check "People also ask" boxes
4. Expand each question

### Document
| Long-Tail Keyword | Specificity | Competition | Article Potential |
|-------------------|-------------|-------------|-------------------|
| "[full query]" | Very specific | Low/Med | Exact match article |

### Cluster by Topic
Group keywords one article could target:

**Cluster 1: [Theme]**
- Primary: [keyword]
- Secondary: [keyword], [keyword]
- Article angle: [concept]
```

### 3.3 Problem-Based Keywords

```
## Problem Keywords for [TECHNOLOGY]

### Search Patterns
- "[TECHNOLOGY] error [CODE]"
- "[TECHNOLOGY] not working"
- "cannot [ACTION] in [TECHNOLOGY]"
- "[TECHNOLOGY] [PROBLEM] fix"
- "why is [TECHNOLOGY] [BEHAVIOR]"

### Stack Overflow Mining
- Search: "[TECHNOLOGY]" tagged questions
- Sort by: Votes, Recent
- Note: High-vote questions = common problems

### GitHub Issues Mining
- Search: "[TECHNOLOGY] issues"
- Note: Frequently reported issues
- Look for: Workarounds in comments

### Document
| Problem | Frequency | Existing Solutions | Article Opportunity |
|---------|-----------|-------------------|---------------------|
| | Common/Rare | Good/Poor/None | Definitive guide needed |

### Prioritize problems that
- Occur frequently
- Have poor existing documentation
- You can solve definitively
- Drive ongoing search traffic
```

---

## 4. Topic Validation

### 4.1 Demand Validation

```
## Validate Topic Demand: [TOPIC]

### Search Volume
- [ ] Google Trends shows stable/growing interest
- [ ] Related keywords have search volume
- [ ] Autocomplete suggests variations

### Community Interest
- [ ] Recent HN/Reddit discussions (past 3 months)
- [ ] Stack Overflow questions (past 6 months)
- [ ] Twitter discussions

### Competition Analysis
- [ ] Top 5 ranking articles reviewed
- [ ] Quality gaps identified
- [ ] Differentiation angle found

### Demand Score
| Factor | Score (1-5) | Notes |
|--------|-------------|-------|
| Search volume | | |
| Community activity | | |
| Competition quality | | |
| Timing relevance | | |
| **Total** | /20 | |

**Threshold:** >12 = proceed, 8-12 = refine angle, <8 = skip
```

### 4.2 Competitive Gap Analysis

```
## Analyze Competing Content: [TOPIC]

### Top 5 Ranking Articles
| # | Title | Source | Word Count | Quality | Gap |
|---|-------|--------|------------|---------|-----|
| 1 | | | | /10 | |
| 2 | | | | /10 | |
| 3 | | | | /10 | |
| 4 | | | | /10 | |
| 5 | | | | /10 | |

### Common Patterns
- What do all top articles include?
- What do they all miss?
- What's the typical depth level?

### Differentiation Opportunities
1. **Depth:** Go deeper on [specific aspect]
2. **Recency:** More current information
3. **Angle:** Different perspective ([ANGLE])
4. **Format:** Better examples/visuals
5. **Audience:** Target [SPECIFIC_SEGMENT]

### Our Unique Angle
[Define specific differentiation that justifies new article]
```

---

## 5. Idea Generation

### 5.1 Batch Idea Generation

```
## Generate Article Ideas

**Niche:** [Your specialty]
**Target Reader:** [Who you're writing for]
**Goal:** [Authority building / SEO traffic / Paid conversion]

Generate 10 article ideas. For each:

**Title:** [SEO-optimized, compelling title]

**Type:** Tutorial | Explainer | Opinion | Comparison | List | Case Study | News Analysis

**Search Intent:** [What someone would search to find this]
**Keywords:** [Primary] | [Secondary keywords]
**Platform:** [Best platform for this content]
**Evergreen Score:** [1-10, 10 = timeless]
**Effort:** [Hours to write]
**Conversion Potential:** [How this leads to paid subscribers]
**Abstract:** [2-3 sentence summary]

**Outline Preview:**
1. [Section 1]
2. [Section 2]
3. [Section 3]

---

### Categorize Ideas

**Publish This Week (Timely):**
- [Idea]

**Publish This Month (Planned):**
- [Idea]

**Evergreen Backlog:**
- [Idea]
```

### 5.2 Problem-Solution Mining

```
## Problem-Solution Article Mining

**Domain:** [e.g., Python, Kubernetes, React]

### Step 1: Find Problems
Search Stack Overflow, Reddit, GitHub Issues for:
- Most upvoted questions this month
- Frequently repeated questions
- Questions with unsatisfying answers

### Step 2: Evaluate
| Problem | Frequency | Existing Solutions | Can I Add Value? |
|---------|-----------|-------------------|------------------|
| | | | Yes/No/Maybe |

### Step 3: Generate Articles
For each viable problem:

**Problem:** [Description]
**Article Title:** [SEO title]
**Hook:** [Why reader should care]
**Solution Approach:** [Your unique angle]
**Keywords:** [Search terms]

**Content Structure:**
1. Problem explanation (with empathy)
2. Why common solutions fail
3. Better approach (your solution)
4. Step-by-step implementation
5. Edge cases / troubleshooting
6. Conclusion + next steps
```
