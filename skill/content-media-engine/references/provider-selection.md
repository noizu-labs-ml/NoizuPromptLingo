# Provider Selection Guide

Decision tree for choosing which LLM provider and model to use for each media format.

## Quick Reference

| Format | Recommended | Model | Why | Alternative |
|--------|------------|-------|-----|-------------|
| Mermaid | anthropic | claude-sonnet-4-6 | Best at structured markup, follows system prompts precisely | gemini-chat (gemini-2.5-flash) |
| PlantUML | anthropic | claude-sonnet-4-6 | Accurate UML syntax generation | gemini-chat |
| Graphviz | anthropic | claude-sonnet-4-6 | Clean DOT output, handles complex graphs | gemini-chat |
| Draw.io | anthropic | claude-sonnet-4-6 | Precise XML structure generation | openai-chat |
| SVG illustration | anthropic | claude-sonnet-4-6 | Best SVG generation quality, clean paths | openai-chat |
| HTML pages | anthropic | claude-sonnet-4-6 | Strong full-page HTML with inline CSS | z.ai |
| React/TSX | anthropic | claude-opus-4-6 | Best at complex component architecture | openai-chat |
| LaTeX | anthropic | claude-sonnet-4-6 | Strong math/document formatting | gemini-chat |
| Typst | anthropic | claude-sonnet-4-6 | Good Typst syntax knowledge | gemini-chat |
| ABC notation | gemini-chat | gemini-2.5-flash | Good at following notation syntax, fast | anthropic |
| LilyPond | gemini-chat | gemini-2.5-flash | Decent notation output, cost-effective | anthropic |
| WaveDrom | anthropic | claude-sonnet-4-6 | Precise JSON structure generation | gemini-chat |
| KaTeX | anthropic | claude-sonnet-4-6 | Strong LaTeX math knowledge | gemini-chat |

## Decision Tree

```
What are you generating?
|
+-- Structured diagram (Mermaid, PlantUML, Graphviz, Draw.io)?
|   --> anthropic / claude-sonnet-4-6
|       temperature: 0.2 (deterministic output)
|
+-- SVG illustration or logo?
|   --> anthropic / claude-sonnet-4-6
|       temperature: 0.3 (slight creativity)
|
+-- HTML page or dashboard?
|   --> anthropic / claude-sonnet-4-6 (complex pages)
|   --> z.ai (simpler pages, fast iteration)
|       temperature: 0.3
|
+-- React/TSX component?
|   --> anthropic / claude-opus-4-6 (complex components)
|   --> anthropic / claude-sonnet-4-6 (simple components)
|       temperature: 0.2
|
+-- LaTeX/Typst document?
|   --> anthropic / claude-sonnet-4-6
|       temperature: 0.2
|
+-- Music notation (ABC, LilyPond)?
|   --> gemini-chat / gemini-2.5-flash
|       temperature: 0.7 (creative output)
|
+-- Simple diagram, budget-sensitive?
|   --> gemini-chat / gemini-2.5-flash
|       Fast, cheap, good enough for simple diagrams
|
+-- WaveDrom timing diagram?
    --> anthropic / claude-sonnet-4-6
        temperature: 0.2
```

## Provider Configuration

### anthropic
```yaml
service: anthropic
model: claude-sonnet-4-6     # or claude-opus-4-6 for complex tasks
prompt:
  provider_options:
    max_tokens: 4096          # 8192 for HTML/TSX
    temperature: 0.2          # 0.3 for creative, 0.7 for music
```

### gemini-chat
```yaml
service: gemini-chat
model: gemini-2.5-flash       # or gemini-2.5-pro for quality
prompt:
  provider_options:
    max_tokens: 4096
    temperature: 0.3
```

### openai-chat
```yaml
service: openai-chat
model: gpt-4o
prompt:
  provider_options:
    max_tokens: 4096
    temperature: 0.2
```

### z.ai
```yaml
service: z.ai
model: grok-3
prompt:
  provider_options:
    max_tokens: 4096
    temperature: 0.3
```

## Temperature Guidelines

| Use Case | Temperature | Rationale |
|----------|-------------|-----------|
| Structured markup (diagrams, XML) | 0.1-0.2 | Deterministic, syntax-correct output |
| Visual design (SVG, HTML) | 0.2-0.4 | Slight creativity within constraints |
| Creative content (music, illustration) | 0.5-0.7 | Allow variation and expressiveness |
| Iteration/refinement | 0.1 | Minimize drift from previous output |
