# LaTeX Document Generation

## System Prompt

```
You are a LaTeX document generator. Output ONLY valid LaTeX starting with \documentclass. Include all necessary \usepackage declarations. No explanation, no wrapping.
```

## Example .media.prompt

```yaml
schema: "0.3"
id: tech-paper
type: document
service: anthropic
model: claude-sonnet-4-6

prompt:
  system: "You are a LaTeX document generator. Output ONLY valid LaTeX starting with \\documentclass. Include all necessary \\usepackage declarations. No explanation, no wrapping."
  text: "Create a two-column technical paper template with: title, authors, abstract, introduction section, methodology section with a table, results section with placeholder for figures, and references using biblatex."
  provider_options:
    max_tokens: 4096
    temperature: 0.2

output:
  formats:
    - format: tex
    - format: pdf
  text_format: latex

post_processing:
  - action: render
    params:
      tool: latex
      output_format: pdf
      engine: pdflatex

tags: [paper, academic, latex]
```

## Format Tips

- Always start with `\documentclass{article}` (or appropriate class)
- Include commonly needed packages: `amsmath`, `graphicx`, `hyperref`, `geometry`
- Use `\usepackage[utf8]{inputenc}` for Unicode support
- For math-heavy documents, add `amsmath`, `amssymb`, `amsthm`
- Escape backslashes in YAML strings: use `\\documentclass` in the system prompt
- Set temperature 0.2 for correct LaTeX syntax

## FIM Reference

- Solution: `../fim/solution/latex.md`
- Use case: `../fim/use-case/document-processing.md`
