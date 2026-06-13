# Readability Metrics

Practical readability assessment for technical documentation. These metrics supplement human judgment — they don't replace it.

## Key Metrics

### Flesch-Kincaid Grade Level

The most widely used readability formula. Estimates the US school grade level needed to understand the text.

**Formula:** `0.39 × (words/sentences) + 11.8 × (syllables/words) - 15.59`

| Grade Level | Audience Match | Technical Docs Target |
|-------------|---------------|----------------------|
| 6-8 | General public, new users | Onboarding guides, READMEs |
| 8-10 | Educated general audience | Tutorials, how-to guides |
| 10-12 | Technical audience | API docs, architecture docs |
| 12-14 | Specialist audience | Internal design docs, RFCs |
| 14+ | Academic/research | Usually too high for any docs |

**Target for most technical docs: Grade 8-10.** Lower is almost always better — it means the reader spends cognitive energy on the *content*, not on parsing the *prose*.

### Gunning Fog Index

Penalizes complex words (3+ syllables). Useful for catching unnecessarily formal language.

**Formula:** `0.4 × ((words/sentences) + 100 × (complex_words/words))`

| Score | Readability |
|-------|------------|
| < 8 | Easy |
| 8-12 | Ideal for technical docs |
| 12-17 | Difficult |
| 17+ | Very difficult |

### Practical Heuristics (No Formula Needed)

These catch readability problems faster than any formula:

| Metric | Target | Check |
|--------|--------|-------|
| Average sentence length | 15-20 words | Count words in 5 random sentences |
| Paragraph length | 3-4 sentences max | Visual scan |
| Header frequency | Every 150-200 words | Count sections / word count |
| Passive voice | < 10% of sentences | Search for "is/was/been + past participle" |
| Jargon density | < 5% of unique words undefined | Count terms a new reader wouldn't know |
| Nested list depth | ≤ 2 levels | Visual scan |

## How to Assess Without Tools

### The Scan Test (30 seconds)

Skim the document reading only headers, bold text, and the first sentence of each section. Ask:

1. Can I tell what this document is about?
2. Can I find the section I need?
3. Do the headers describe content (not just label it)?

**If any answer is "no":** Structure needs work before prose editing.

### The Cold Read Test

Read the first 3 paragraphs as if you've never seen the project. Ask:

1. Do I know what this tool does?
2. Do I know who it's for?
3. Do I know what to do next?

**If any answer is "no" after 3 paragraphs:** The opening needs rewriting.

### The Copy-Paste Test

Take the first code example. Paste it into a terminal/editor. Ask:

1. Does it run without modification?
2. Is the output what the doc says it should be?
3. If it fails, does the doc tell me why?

**If any answer is "no":** Accuracy problems need fixing before anything else.

## Common Readability Problems in Technical Docs

### Problem: Noun Stacks

Technical writing attracts noun stacks — multiple nouns jammed together.

```
✗ "The user authentication token refresh configuration endpoint"
✓ "The endpoint that configures how auth tokens are refreshed"
```

### Problem: Passive Voice

Passive voice hides the actor and adds words.

```
✗ "The configuration file should be updated by the administrator"
✓ "Update the configuration file"
```

### Problem: Nominalizations

Turning verbs into nouns makes sentences longer and weaker.

```
✗ "Perform an investigation of the error"
✓ "Investigate the error"

✗ "Make a modification to the config"
✓ "Modify the config"
```

### Problem: Hedge Words

Hedging erodes confidence without adding precision.

```
✗ "This should probably work in most standard configurations"
✓ "This works with default configuration"
  — or if uncertain: "Tested with default config. Custom setups may need adjustment — see troubleshooting."
```

## When Metrics Don't Apply

Readability formulas are calibrated for prose. They break down for:

- **Code blocks** — Exclude from word count
- **Tables** — The structure carries meaning, not the sentence length
- **Command references** — Terse by design; low readability score is fine
- **Error messages** — Brevity and precision matter more than grade level

**Rule:** Apply readability metrics to the prose sections. Judge structured content (tables, code, commands) by whether it's scannable and accurate, not by formula scores.
