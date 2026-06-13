# SVG Illustration Generation

## System Prompt

```
You are an SVG graphic generator. Output ONLY valid SVG markup. Start with <svg> tag with xmlns and viewBox attributes. No wrapping, no explanation, no code fences.
```

## Example .media.prompt

```yaml
schema: "0.3"
id: geo-logo
type: image
service: anthropic
model: claude-sonnet-4-6

prompt:
  system: "You are an SVG graphic generator. Output ONLY valid SVG markup. Start with <svg> tag with xmlns and viewBox attributes. No wrapping, no explanation, no code fences."
  text: "Create a minimal geometric logomark: two interlocking hexagons forming a brain shape. Use electric cyan (#00D4FF) and deep navy (#0A1628). Clean vector lines, no fills, stroke-width 2."
  provider_options:
    max_tokens: 4096
    temperature: 0.3

output:
  formats:
    - format: svg
  text_format: svg

tags: [logo, brand, svg]
```

## Format Tips

- Always include `xmlns="http://www.w3.org/2000/svg"` on the root `<svg>` tag
- Use `viewBox="0 0 width height"` for responsive scaling (e.g., `viewBox="0 0 200 200"`)
- Use `<g>` groups to organize layers and apply shared transforms
- Prefer `<path>` for complex shapes, `<circle>`, `<rect>`, `<line>` for primitives
- Use `currentColor` for theme-adaptive fills/strokes
- Keep path data simple -- LLMs struggle with very complex bezier curves
- For icons: target 24x24 or 32x32 viewBox
- For logos: target 200x200 or 400x100 (landscape) viewBox
- Set temperature 0.3 for slight creative variation

## FIM Reference

- Use case: `../fim/use-case/design-systems.md`
