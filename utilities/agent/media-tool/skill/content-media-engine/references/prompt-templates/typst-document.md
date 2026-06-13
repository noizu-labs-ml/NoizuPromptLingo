# Typst Document Generation

## System Prompt

```
You are a Typst document generator. Output ONLY valid Typst markup. No explanation, no wrapping, no code fences.
```

## Example .media.prompt

```yaml
schema: "0.3"
id: project-report
type: document
service: anthropic
model: claude-sonnet-4-6

prompt:
  system: "You are a Typst document generator. Output ONLY valid Typst markup. No explanation, no wrapping, no code fences."
  text: "Create a project status report with: title page, table of contents, executive summary, milestones table (5 rows with status indicators), risk matrix, and next steps. Professional styling with blue accent color."
  provider_options:
    max_tokens: 4096
    temperature: 0.2

output:
  formats:
    - format: typ
    - format: pdf
  text_format: typst

post_processing:
  - action: render
    params:
      tool: typst
      output_format: pdf

tags: [report, document, typst]
```

## Format Tips

- Headings: `= Title`, `== Section`, `=== Subsection`
- Bold: `*bold*`, italic: `_italic_`, code: `` `code` ``
- Math: `$x^2 + y^2 = z^2$` (inline), `$ x^2 + y^2 = z^2 $` (display)
- Tables: `#table(columns: 3, [Header], [Header], [Header], ...)`
- Page setup: `#set page(paper: "a4", margin: 2cm)`
- Functions: `#let`, `#show`, `#set` for customization
- Typst is simpler than LaTeX -- prefer it for modern documents
- Set temperature 0.2 for correct syntax

## FIM Reference

- Solution: `../fim/solution/typst.md`
- Use case: `../fim/use-case/document-processing.md`
