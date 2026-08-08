# DocBook

## Description
DocBook is an XML schema specifically designed for technical documentation, providing semantic markup for books, articles, and technical manuals. Originally developed at O'Reilly Media, it's now an OASIS standard widely used in enterprise documentation workflows.

**Documentation**: https://docbook.org
**Schema Reference**: https://docbook.org/xsd/5.1/docbook.xsd
**XSLT Stylesheets**: https://github.com/docbook/xslt10-stylesheets

## Basic Document Structure
```xml
<?xml version="1.0" encoding="UTF-8"?>
<book xmlns="http://docbook.org/ns/docbook" version="5.1">
  <info>
    <title>Document Title</title>
    <author><personname>Author Name</personname></author>
  </info>
  <chapter>
    <title>Chapter Title</title>
    <section>
      <title>Section Title</title>
      <para>Content paragraph with <emphasis>emphasis</emphasis>.</para>
      <programlisting language="python"><![CDATA[
def example():
    return "code sample"
      ]]></programlisting>
    </section>
  </chapter>
</book>
```

## XSLT Processing
```bash
# Transform to HTML
xsltproc --output output.html docbook-xsl/html/docbook.xsl document.xml

# Transform to PDF (via FO)
xsltproc --output document.fo docbook-xsl/fo/docbook.xsl document.xml
fop -fo document.fo -pdf document.pdf
```

## Strengths
- **Semantic Markup**: Rich vocabulary for technical content (code, equations, cross-references)
- **Single Source Publishing**: Generate HTML, PDF, EPUB, man pages from one source
- **Validation**: Strong schema validation ensures document consistency
- **Modularity**: XInclude support for document composition
- **Industry Standard**: Wide toolchain support and enterprise adoption

## Limitations
- **XML Verbosity**: Markup-heavy syntax can be cumbersome for authors
- **Learning Curve**: Complex schema requires significant training
- **Toolchain Complexity**: XSLT processing pipelines need configuration
- **Limited Styling**: Customizing output appearance requires XSLT expertise

## Best For
- Large technical manuals requiring multiple output formats
- API documentation with strict validation requirements
- Books and documentation sets with complex cross-referencing
- Organizations with established XML workflows
- Content requiring long-term archival in standard format

## NPL-FIM Integration
```yaml
format: docbook
version: "5.1"
processor: xsltproc
stylesheets: docbook-xsl-1.79.1
output_formats: [html, pdf, epub]
validation: strict
```