# Typst Modern Typesetting

## Description
Typst is a modern markup-based typesetting system designed as a LaTeX alternative.
Learn more at https://typst.app

## Setup
```bash
# Install via package manager
curl -fsSL https://typst.app/assets/typst-x86_64-unknown-linux-musl.tar.xz | tar xz
mv typst /usr/local/bin/

# macOS
brew install typst

# Web editor available at https://typst.app
```

## Basic Document
```typst
#set document(title: "Research Paper", author: "Author Name")
#set page(paper: "a4")
#set text(font: "Linux Libertine", size: 11pt)

= Introduction
This is a modern typesetting example with inline math: $E = m c^2$

== Equations
The quadratic formula:
$ x = (-b plus.minus sqrt(b^2 - 4 a c)) / (2a) $

== Matrix Example
$ mat(
  1, 2, 3;
  4, 5, 6;
) $

#figure(
  table(columns: 3,
    [Item], [Quantity], [Price],
    [Apple], [5], [$2.50],
  ),
  caption: "Sample Table"
)
```

## CLI Usage
```bash
# Compile to PDF
typst compile document.typ

# Watch mode for live preview
typst watch document.typ

# Export to PNG
typst compile document.typ output.png --format png
```

## NPL-FIM Integration
```typescript
// Convert NPL to Typst syntax
const equation = npl.parse("∫₀^∞ e^(-x²) dx");
const typst = equation.toTypst(); // "integral_0^infinity e^(-x^2) d x"

// Generate Typst document from NPL template
npl.compile({
  format: 'typst',
  template: 'academic-paper',
  content: nplDocument
});
```

## Strengths
- **Fast compilation**: 10-100x faster than LaTeX
- **Modern syntax**: Intuitive markup without backslashes
- **Live preview**: Incremental compilation for instant feedback
- **Built-in scripting**: Full programming language for automation
- **Error messages**: Clear, helpful error diagnostics

## Limitations
- **New ecosystem**: Fewer packages than LaTeX (growing rapidly)
- **Template compatibility**: Cannot directly use LaTeX templates
- **Bibliography**: Less mature citation management
- **Academic adoption**: Still gaining acceptance in journals

## Best For
- Academic papers and theses
- Technical documentation
- Presentation slides
- Mathematical documents
- Students learning typesetting