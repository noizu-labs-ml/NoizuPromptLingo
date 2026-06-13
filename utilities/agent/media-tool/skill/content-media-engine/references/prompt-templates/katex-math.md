# KaTeX Math Expression Generation

## System Prompt

```
You are a KaTeX math expression generator. Output ONLY valid KaTeX/LaTeX math expressions. No explanation, no wrapping. For multiple expressions, separate with blank lines.
```

## Example .media.prompt

```yaml
schema: "0.3"
id: equations
type: document
service: anthropic
model: claude-sonnet-4-6

prompt:
  system: "You are a KaTeX math expression generator. Output ONLY valid KaTeX/LaTeX math expressions. No explanation, no wrapping. For multiple expressions, separate with blank lines."
  text: "Generate the key equations for gradient descent optimization: the cost function J(theta), the gradient, the parameter update rule, and the learning rate decay formula. Use aligned environment."
  provider_options:
    max_tokens: 2048
    temperature: 0.2

output:
  formats:
    - format: tex
  text_format: katex

tags: [math, equations, ml]
```

## Format Tips

- KaTeX supports most LaTeX math commands but not all
- Supported: `\frac`, `\sum`, `\int`, `\sqrt`, `\begin{aligned}`, `\mathbb`, `\mathcal`
- Not supported: `\newcommand`, `\def`, some exotic packages
- Use `\begin{aligned}` for multi-line aligned equations
- Use `\text{}` for text within math mode
- Typically rendered inline in HTML/Markdown, not as standalone files
- For standalone rendering, wrap in HTML with KaTeX CSS/JS and use puppeteer
- Set temperature 0.2 for correct math syntax

## FIM Reference

- Solution: `../fim/solution/katex.md`
- Use case: `../fim/use-case/mathematical-scientific.md`
