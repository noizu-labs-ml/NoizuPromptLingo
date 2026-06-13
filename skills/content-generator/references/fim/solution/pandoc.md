# Pandoc
Universal document converter supporting 40+ formats. [Official Site](https://pandoc.org) | [Documentation](https://pandoc.org/MANUAL.html)

## Install
```bash
# Ubuntu/Debian
apt-get install pandoc

# macOS
brew install pandoc

# Windows (Chocolatey)
choco install pandoc

# Or download from https://pandoc.org/installing.html
```

## Common Conversions
```bash
# Markdown to PDF (requires LaTeX)
pandoc input.md -o output.pdf

# Markdown to HTML with standalone template
pandoc input.md -s -o output.html

# Markdown to Word document
pandoc input.md -o output.docx

# Multiple files to single output
pandoc chapter*.md -o book.pdf

# With custom template
pandoc input.md --template=custom.html -o output.html
```

## Advanced Features
```bash
# With bibliography and citations
pandoc paper.md --citeproc --bibliography=refs.bib -o paper.pdf

# Custom CSS for HTML output
pandoc input.md -s --css=style.css -o output.html

# Lua filters for custom transformations
pandoc input.md --lua-filter=filter.lua -o output.pdf
```

## Strengths
- **Universal converter**: MD, HTML, LaTeX, DOCX, EPUB, PDF, RST, Wiki formats
- **Academic features**: Citations, bibliography, cross-references
- **Extensible**: Lua filters, custom templates, metadata
- **Preserves structure**: Tables, footnotes, math formulas
- **Batch processing**: Convert entire documentation sets

## Limitations
- Large installation size (~200MB with LaTeX)
- PDF generation requires LaTeX distribution (1-3GB)
- Complex layouts may need manual adjustments
- Limited control over visual design compared to dedicated tools

## Best For
`document-conversion`, `academic-writing`, `publishing-workflows`, `format-migration`, `book-generation`

## NPL-FIM Integration
```typescript
// Generate multiple output formats from NPL documentation
const nplDoc = fim.parseNPL("npl-spec.md");
await fim.pandoc(nplDoc, {
  outputs: ['pdf', 'html', 'epub'],
  template: 'npl-template',
  metadata: { author: 'NPL Team', version: '1.0' }
});
```