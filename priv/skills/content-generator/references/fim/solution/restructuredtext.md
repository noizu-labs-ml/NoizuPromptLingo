# reStructuredText (RST)

## Description
reStructuredText is an extensible markup language for Python documentation and technical writing. Originally developed as part of the [Docutils](https://docutils.sourceforge.io/) project, RST has become the standard for Python documentation through its integration with [Sphinx](https://www.sphinx-doc.org/).

## Basic Syntax Examples
```rst
Section Title
=============

Subsection
----------

**Bold text** and *italic text*

- Bullet list item
- Another item

1. Numbered list
2. Second item

.. code-block:: python

    def example():
        """Python code block"""
        return True

:doc:`Link to another document </api/module>`
:ref:`Cross-reference <label-name>`

.. note::
   This is an admonition box.

.. math::
   \alpha = \sqrt{\beta}
```

## Sphinx Integration
RST powers Sphinx documentation generator, providing:
- Automatic API documentation from docstrings
- Cross-referencing between documents
- Multiple output formats (HTML, PDF, EPUB)
- Extension system for custom directives
- Built-in theme support

## Strengths
- Python ecosystem standard
- Highly extensible through directives
- Semantic markup for technical docs
- Rich cross-referencing capabilities
- Supports complex documentation structures
- Native support for code documentation

## Limitations
- Steeper learning curve than Markdown
- Syntax can be verbose and strict
- Indentation-sensitive formatting
- Limited adoption outside Python community
- Requires Sphinx for advanced features

## Best For
- Python project documentation
- API reference documentation
- Technical manuals requiring cross-references
- Scientific and mathematical documentation
- Documentation requiring multiple output formats

## NPL-FIM Integration
```typescript
// NPL-FIM restructuredtext handler
fim.register('restructuredtext', {
  extensions: ['.rst', '.rest'],
  processor: 'docutils',
  sphinxEnabled: true,
  features: ['directives', 'roles', 'math', 'citations']
});
```

NPL agents can leverage RST's extensibility through custom directives for structured documentation generation with semantic markup preservation.