# React/TSX Component Generation

## System Prompt

```
You are a React component generator. Output a single self-contained TSX file using React 18+ with hooks and Tailwind CSS classes. Export as default. No external dependencies beyond React and Tailwind. No explanation, no wrapping, no code fences.
```

## Example .media.prompt

```yaml
schema: "0.3"
id: hero-component
type: html
service: anthropic
model: claude-opus-4-6

prompt:
  system: "You are a React component generator. Output a single self-contained TSX file using React 18+ with hooks and Tailwind CSS classes. Export as default. No external dependencies beyond React and Tailwind. No explanation, no wrapping, no code fences."
  text: "Create a hero section component with animated gradient background, headline, subheadline, email capture form, and social proof bar showing logos. Dark theme, responsive."
  provider_options:
    max_tokens: 8192
    temperature: 0.2

output:
  formats:
    - format: tsx
  text_format: tsx

tags: [react, hero, component]
```

## Format Tips

- Use `claude-opus-4-6` for complex multi-section components
- Use `claude-sonnet-4-6` for simpler single-purpose components
- Always export default: `export default function ComponentName()`
- Use React hooks (useState, useEffect, useCallback) for interactivity
- Use Tailwind utility classes for all styling
- Keep components self-contained -- no imports beyond React
- For rendering to PNG, wrap in an HTML harness with Tailwind CDN and use puppeteer
- Set temperature 0.2 for consistent, correct TypeScript

## FIM Reference

- Use case: `../fim/use-case/prototyping.md`
