# Content Publishing Agent

> Generates article ideas, performs trend/keyword research, and creates abstracts for Substack, Medium, and Dev.to publishing. Integrates web search for data-driven ideation.

---

## Agent Role Definition

```yaml
role: Technical Content Strategist
persona: |
  You are a content strategist specializing in technical and developer content.
  You understand SEO, trending topics, and what drives engagement on each platform.
  You balance evergreen value with timely relevance.
  You write for authority-building that converts to paid subscribers.
  
capabilities:
  - Trend analysis via web search
  - Keyword research and gap identification
  - Article ideation with SEO focus
  - Abstract/outline generation
  - Platform-specific optimization
  - Content calendar planning

platforms:
  primary:
    - Dev.to (SEO, developer credibility)
    - Substack (monetization, community)
  secondary:
    - Medium (broader reach)
    - Hashnode (technical authority)
    - LinkedIn (professional network)

constraints:
  - Prioritize searchable, evergreen topics (70%)
  - Include timely/trending topics (30%)
  - Focus on problems developers actually search for
  - Build toward paid Substack conversion
```

---

## 1. Trend & Keyword Research Prompt

### 1.1 Web Search Research Prompt

```markdown
## Content Research: [TOPIC AREA]

I need to research content opportunities in: [e.g., "AI/ML engineering", "DevOps", "Frontend development"]

### Search Tasks

**1. Trending Topics**
Search for:
- "[topic] trends 2025"
- "[topic] news this week"
- "new [topic] tools"
- Reddit r/[relevant-subreddit] top posts this month

**2. Common Developer Problems**
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

**High-Search Developer Problems:**
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

### 1.2 Platform-Specific Research

```markdown
## Platform Research: [PLATFORM]

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
1. Primary: [Platform] - [Reason]
2. Syndicate to: [Platform] - [Timing]
3. Repurpose for: [Platform] - [Format change]
```

---

## 2. Article Idea Generation Prompt

### 2.1 Batch Idea Generation

```markdown
## Generate Article Ideas

**Niche:** [Your technical specialty]
**Target Reader:** [Who you're writing for]
**Goal:** [Authority building / SEO traffic / Paid conversion]

Based on research (or perform research first), generate 10 article ideas:

### For Each Idea Provide:

**Title:** [SEO-optimized, compelling title]

**Type:** 
- [ ] Tutorial (how-to)
- [ ] Explainer (concept deep-dive)
- [ ] Opinion/Hot take
- [ ] Comparison (X vs Y)
- [ ] List (Top 10, Best practices)
- [ ] Case study
- [ ] News analysis

**Search Intent:** [What someone would search to find this]

**Keywords:** [Primary keyword] | [Secondary keywords]

**Platform:** [Best platform for this content]

**Evergreen Score:** [1-10, 10 = timeless]

**Effort:** [Hours to write]

**Conversion Potential:** [How this leads to paid subscribers]

**Abstract:** [2-3 sentence summary of the article]

**Outline Preview:**
1. [Section 1]
2. [Section 2]
3. [Section 3]

---

### Categorize Ideas:

**Publish This Week (Timely):**
- [Idea]

**Publish This Month (Planned):**
- [Idea]
- [Idea]

**Evergreen Backlog:**
- [Idea]
- [Idea]
```

### 2.2 Problem-Solution Idea Mining

```markdown
## Problem-Solution Article Mining

**Domain:** [e.g., Python, Kubernetes, React]

### Step 1: Find Problems
Search Stack Overflow, Reddit, GitHub Issues for:
- Most upvoted questions this month
- Frequently repeated questions
- Questions with unsatisfying answers

### Step 2: Evaluate Each Problem

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

---

## 3. Abstract Generation Prompt

```markdown
## Generate Article Abstract

**Title:** [Article title]
**Platform:** [Target platform]
**Word Count Target:** [e.g., 1500-2000 words]

### Generate:

**Hook (First 2 sentences):**
[Grab attention, state the problem/opportunity]

**Abstract (150-200 words):**
[Full summary covering: problem, solution, what reader will learn, why it matters]

**Key Takeaways (3-5 bullets):**
- [Takeaway 1]
- [Takeaway 2]
- [Takeaway 3]

**Target Keywords:**
- Primary: [keyword]
- Secondary: [keyword], [keyword]

**Meta Description (155 chars):**
[For SEO]

**Social Teaser (280 chars for Twitter):**
[Hook for social sharing]

**Detailed Outline:**

## Introduction
- Hook: [Specific hook]
- Context: [Why this matters now]
- Promise: [What reader will gain]

## Section 1: [Name]
- Point 1.1
- Point 1.2
- Code example / visual

## Section 2: [Name]
- Point 2.1
- Point 2.2
- Code example / visual

## Section 3: [Name]
- Point 3.1
- Point 3.2
- Practical application

## Conclusion
- Summary of key points
- Call to action
- Next steps for reader

**Research Needed:**
- [ ] [Research item 1]
- [ ] [Research item 2]

**Assets Needed:**
- [ ] Code examples
- [ ] Diagrams
- [ ] Screenshots

**Estimated Time to Write:** [X hours]
```

---

## 4. Content Calendar Prompt

```markdown
## Monthly Content Calendar: [MONTH YEAR]

**Publishing Cadence:** [e.g., 2 articles/week]
**Primary Platform:** [Platform]
**Goal:** [e.g., Reach 1000 subscribers]

### Generate Calendar:

**Week 1:**
| Day | Title | Type | Platform | Keywords | Status |
|-----|-------|------|----------|----------|--------|
| Mon | | | | | |
| Thu | | | | | |

**Week 2:**
| Day | Title | Type | Platform | Keywords | Status |
|-----|-------|------|----------|----------|--------|
| Mon | | | | | |
| Thu | | | | | |

**Week 3:**
| Day | Title | Type | Platform | Keywords | Status |
|-----|-------|------|----------|----------|--------|
| Mon | | | | | |
| Thu | | | | | |

**Week 4:**
| Day | Title | Type | Platform | Keywords | Status |
|-----|-------|------|----------|----------|--------|
| Mon | | | | | |
| Thu | | | | | |

### Content Mix:
- Tutorials: [X]
- Explainers: [X]
- Opinion: [X]
- Timely: [X]

### Cross-Posting Schedule:
| Original | Original Date | Cross-Post To | Cross-Post Date |
|----------|---------------|---------------|-----------------|
| | | | |

### Promotion Plan:
| Article | Twitter | LinkedIn | Reddit | Other |
|---------|---------|----------|--------|-------|
| | | | | |
```

---

## 5. Platform-Specific Optimization

### 5.1 Dev.to Optimization

```markdown
## Dev.to Article Optimization

**Title:** [Article title]

### Optimize For Dev.to:

**Tags (max 4):**
1. [primary tag]
2. [secondary tag]
3. [tertiary tag]
4. [optional tag]

**Cover Image:**
- Style: [Clean, illustrative, meme-worthy]
- Text overlay: [Yes/No]
- Suggested concept: [Description]

**Series:** [If part of series]

**Canonical URL:** [If cross-posting]

**Opening Hook:**
[Dev.to audiences respond to: personal stories, relatable frustration, bold claims]

**Code Formatting:**
- Use ```language for syntax highlighting
- Keep examples concise
- Add comments explaining non-obvious parts

**Engagement Hooks:**
- Ask question at end
- Include "What do you think?" or "Have you tried this?"
- Controversial-but-defensible take

**Best Posting Times:**
- Tuesday-Thursday
- 8-10 AM EST
- Avoid weekends
```

### 5.2 Substack Optimization

```markdown
## Substack Article Optimization

**Title:** [Article title]
**Subtitle:** [Substack subtitle]

### Optimize For Substack:

**Newsletter Section:** [Free / Paid only / Teaser]

**Email Subject Line:**
[Often different from title - more personal]

**Preview Text:**
[First ~100 chars that show in email preview]

**Opening:**
[Personal, conversational, like writing to a friend]

**Paid Conversion Points:**
- Teaser for paid content: [What to tease]
- CTA placement: [Where in article]
- CTA copy: [Specific ask]

**Community Engagement:**
- Question to prompt comments
- Call for reader experiences
- Poll/survey if applicable

**Cross-Promotion:**
- Link to relevant past posts
- Mention upcoming content
- Reference other newsletters (network building)
```

### 5.3 Medium Optimization

```markdown
## Medium Article Optimization

**Title:** [Article title]
**Subtitle:** [Medium subtitle]

### Optimize For Medium:

**Publication:** [Target publication or self-publish]

**Tags (max 5):**
1. [tag]
2. [tag]
3. [tag]
4. [tag]
5. [tag]

**Kicker:** [Short text above title]

**Preview Image:**
- Should work at small size
- Eye-catching but professional

**Reading Time Target:** [X min] (7-10 min optimal)

**Structure for Medium:**
- Short paragraphs (2-3 sentences)
- Subheadings every 300 words
- Pull quotes for key insights
- Images/code breaking up text

**Member-Only:** [Yes/No]
[Member-only gets into algorithm better but limits reach]
```

---

## 6. Conversion Strategy Prompts

### 6.1 Free-to-Paid Funnel

```markdown
## Content Funnel Design

**Goal:** Convert free readers to paid Substack subscribers

### Funnel Stages:

**Top of Funnel (Discovery):**
Platform: Dev.to, Medium, SEO
Content type: Tutorials, explainers
Goal: Build awareness, capture email

Sample titles:
- 
- 

**Middle of Funnel (Engagement):**
Platform: Free Substack
Content type: Deeper insights, exclusive tips
Goal: Build trust, demonstrate expertise

Sample titles:
- 
- 

**Bottom of Funnel (Conversion):**
Platform: Paid Substack teasers
Content type: Advanced content, community access
Goal: Convert to paid

Sample teasers:
- 
- 

### Conversion Hooks:
1. [What makes paid worth it]
2. [Exclusive benefit]
3. [Community value]
```

---

## 7. Article Series Planning

```markdown
## Article Series: [SERIES NAME]

**Topic:** [Overarching topic]
**Total Articles:** [Number]
**Publishing Cadence:** [e.g., weekly]

### Series Overview:

**Part 1: [Title]**
- Focus: [Introduction / Foundation]
- Key concepts: [List]
- Leads to: [Part 2 hook]

**Part 2: [Title]**
- Focus: [Building on Part 1]
- Key concepts: [List]
- Leads to: [Part 3 hook]

**Part 3: [Title]**
- Focus: [Advanced / Practical]
- Key concepts: [List]
- Conclusion of series

### Series Promotion:
- Announce series before starting
- Link between all parts
- Create summary post at end
- Consider bundling for paid content
```

---

## 8. High-Potential Topic Areas

Based on developer search patterns:

### Evergreen (Always Relevant)

| Topic | Search Volume | Competition | Notes |
|-------|---------------|-------------|-------|
| Git workflows | High | Medium | Always new devs learning |
| Docker basics | High | Medium | Practical tutorials win |
| API design | Medium | Low | Underserved niche |
| Testing strategies | Medium | Medium | Opinion pieces do well |
| Career advice | High | High | Personal angle needed |

### Trending (Time-Sensitive)

| Topic | Window | Notes |
|-------|--------|-------|
| New language/framework releases | 2-4 weeks | First-mover advantage |
| AI/LLM development | Ongoing | High interest, fast-moving |
| Cloud provider updates | 1-2 weeks | AWS/GCP/Azure changes |
| Security vulnerabilities | Days | Quick turnaround needed |

### Underserved (Low Competition)

| Topic | Why Underserved | Opportunity |
|-------|-----------------|-------------|
| Niche tool tutorials | Small audience | Loyal following |
| Legacy system modernization | Not "sexy" | High enterprise need |
| Debugging specific errors | Seems basic | High search volume |
| Cost optimization | Boring | High value |

---

## References

- `PROJECT-TRACKER.md` - Article pipeline tracking
- `KEYWORD-RESEARCH.md` - SEO methodology
- `../INDEX.md` - Overall strategy

---

*Version: 0.1.0*
