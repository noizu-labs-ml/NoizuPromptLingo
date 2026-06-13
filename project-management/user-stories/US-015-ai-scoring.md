---
id: US-015
title: "AI Scoring on 6 Dimensions"
slug: "ai-scoring"
personas: [P-001, P-002, P-003, P-007]
epic: "Blog Indexing & Scoring"
priority: "must-have"
complexity: "XL"
tags: [ai, scoring, originality, engagement, consistency, writing-quality, seo, visual-design]
---

# US-015: AI Scoring on 6 Dimensions

## User Story

**As a** blogger (P-001),
**I want to** receive an AI-generated score across 6 dimensions after my blog is indexed,
**So that** I understand how my blog performs and can compare against other bloggers in competitions.

## Acceptance Criteria

- [ ] Given crawl is complete, when AI scoring is triggered, then each of the 6 dimensions is evaluated: Originality (0–100), Engagement (0–100), Consistency (0–100), Writing Quality (0–100), SEO (0–100), Visual Design (0–100)
- [ ] Given scoring is run, when the Originality score is computed, then it reflects: topic uniqueness relative to the blog's niche corpus, avoidance of boilerplate/templated content, and evidence of distinct perspective or voice
- [ ] Given scoring is run, when the Engagement score is computed, then it reflects: use of questions, calls to action, storytelling hooks, comment prompts, and estimated readability (Flesch-Kincaid)
- [ ] Given scoring is run, when the Consistency score is computed, then it reflects: posting frequency regularity (coefficient of variation of publish dates), brand voice consistency across posts, and topic coherence within declared niches
- [ ] Given scoring is run, when the Writing Quality score is computed, then it reflects: grammar and spelling error rate, sentence variety, vocabulary richness, and structure (appropriate use of headings, paragraphs, lists)
- [ ] Given scoring is run, when the SEO score is computed, then it reflects: presence of meta descriptions, heading hierarchy (H1/H2/H3), image alt text coverage, internal linking, and keyword focus per post
- [ ] Given scoring is run, when the Visual Design score is computed, then it reflects: image-to-text ratio, image quality signals (resolution metadata if available), use of visual breaks (images, pull quotes, subheadings) per 500 words
- [ ] Given all 6 dimension scores are computed, when scoring completes, then an overall composite score is calculated as a weighted average (weights defined in platform config) and stored with a scored_at timestamp
- [ ] Given scoring completes, when the user views their dashboard, then all 6 scores plus the composite are displayed and the "Scoring in progress" indicator is replaced with the actual scores

## Notes

AI scoring should use a combination of rule-based analysis (SEO, Consistency) and LLM-based evaluation (Originality, Engagement, Writing Quality, Visual Design). Scoring a blog should complete within 10 minutes of crawl completion. Scores should be versioned so algorithm changes can be tracked. Related: US-016 (view score breakdown), US-019 (score history), US-020 (improvement suggestions).
