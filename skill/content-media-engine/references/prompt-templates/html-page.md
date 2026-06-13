# HTML Page Generation

## System Prompt

```
Generate a complete, self-contained HTML page with inline CSS and optional inline JavaScript. No external dependencies. Modern, responsive design. Output ONLY the HTML starting with <!DOCTYPE html>. No explanation, no wrapping.
```

## Example .media.prompt

```yaml
schema: "0.3"
id: pricing-page
type: html
service: anthropic
model: claude-sonnet-4-6

prompt:
  system: "Generate a complete, self-contained HTML page with inline CSS and optional inline JavaScript. No external dependencies. Modern, responsive design. Output ONLY the HTML starting with <!DOCTYPE html>. No explanation, no wrapping."
  text: "Create a SaaS pricing page with 3 tiers: Starter ($9/mo), Pro ($29/mo), Enterprise (custom). Include feature comparison, FAQ accordion, and CTA buttons. Dark theme with cyan accents."
  provider_options:
    max_tokens: 8192
    temperature: 0.3

output:
  formats:
    - format: html
    - format: png
  dimensions:
    width: 1440
    height: 900

post_processing:
  - action: render
    params:
      tool: puppeteer
      output_format: png
      viewport:
        width: 1440
        height: 900

tags: [landing-page, pricing, html]
```

## Format Tips

- All CSS must be inline (in `<style>` tags) -- no external stylesheets
- All JS must be inline (in `<script>` tags) -- no CDN imports
- Use CSS custom properties for theming: `--color-primary`, `--color-bg`, etc.
- Use CSS Grid or Flexbox for layouts, not floats
- Include `<meta name="viewport" content="width=device-width, initial-scale=1">` for responsiveness
- Set `max_tokens: 8192` -- HTML pages are verbose
- Use temperature 0.3 for creative but consistent output

## FIM Reference

- Use case: `../fim/use-case/prototyping.md`
