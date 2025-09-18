# AsciiDoc

## Description
[AsciiDoc](https://asciidoc.org) is a text document format for writing technical documentation, articles, books, and more. It offers semantic markup with extensive features for professional documentation.

## Basic Syntax
```asciidoc
= Document Title
Author Name <author@example.com>
:toc:
:numbered:

== Section Level 1

This is a paragraph with *bold* and _italic_ text.

=== Section Level 2

.Example Block Title
====
This is an example block.
====

[source,python]
----
def hello():
    print("Hello from AsciiDoc!")
----

.Table with Header
|===
| Column 1 | Column 2

| Cell 1
| Cell 2

| Cell 3
| Cell 4
|===

NOTE: This is an admonition block.

* Unordered list item
** Nested item

. Ordered list
.. Nested ordered

https://asciidoc.org[AsciiDoc Website]

image::diagram.png[Architecture Diagram]
```

## Processor Setup
```bash
# Install Asciidoctor (Ruby)
gem install asciidoctor

# Install Asciidoctor.js (Node.js)
npm install asciidoctor

# Convert to HTML
asciidoctor document.adoc

# Convert to PDF (requires asciidoctor-pdf)
asciidoctor-pdf document.adoc
```

## Strengths
- **Rich Features**: Tables, footnotes, bibliographies, indexes
- **Book Authoring**: Multi-chapter documents, cross-references
- **Semantic Markup**: Clear distinction between content and presentation
- **Multiple Output Formats**: HTML, PDF, DocBook, EPUB, man pages
- **Include Directives**: Modular documentation with file includes
- **Extensible**: Custom converters and extensions

## Limitations
- **Less Popular**: Smaller community than Markdown
- **Learning Curve**: More complex syntax than basic Markdown
- **Tool Requirements**: Needs Asciidoctor processor
- **Preview Support**: Fewer editors with native preview

## Best For
- Technical documentation and API references
- Books and long-form documentation
- Documents requiring complex tables and cross-references
- Projects needing multiple output formats
- Documentation with extensive code examples

## NPL-FIM Integration
AsciiDoc processing available through:
- Direct Asciidoctor invocation for conversion
- Pandoc integration for format conversion
- Custom NPL processors for AsciiDoc-to-HTML rendering
- Template-based documentation generation with AsciiDoc output