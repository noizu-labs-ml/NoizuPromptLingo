# Document Processing
Transform structured data into formatted documents, reports, and publications. [Documentation](https://github.com/noizu/npl-fim/docs/document-processing)

## When to Use
- Converting data analysis results into formatted reports
- Generating documentation from code annotations or metadata
- Creating multi-format publications from single source content
- Building parameterized documents with dynamic content insertion
- Producing standardized reports from variable data sources

## Key Outputs
- **Documents**: PDF, DOCX, ODT, RTF, EPUB
- **Markup**: HTML, Markdown, reStructuredText, AsciiDoc
- **Structured**: LaTeX, DocBook XML, JATS, TEI
- **Presentation**: PPTX, reveal.js, Beamer slides
- **Data Reports**: CSV summaries, JSON metadata, YAML configs

## Quick Example
```yaml
document:
  type: quarterly_sales_report
  template: corporate_standard

inputs:
  - data: q4_revenue.json
    sample: {revenue: "$4.2M", growth: "+18%", units: 42750}
  - metadata: company_info.yaml
    fields: [logo, address, fiscal_year: "2024"]
  - content: sections/executive_summary.md

outputs:
  - format: pdf
    style: boardroom_presentation
    features: [toc, charts, watermark]
  - format: html
    style: interactive_dashboard
    features: [drill_down, live_data]
  - format: docx
    style: editable_draft
    features: [track_changes, comments]
```