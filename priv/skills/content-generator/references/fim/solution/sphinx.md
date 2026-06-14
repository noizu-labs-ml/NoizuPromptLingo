# NPL-FIM: sphinx
📚 Documentation generator for Python projects

## Description
[Sphinx](https://www.sphinx-doc.org) is a powerful documentation tool that generates intelligent and beautiful documentation from source code. Originally created for Python documentation, it supports multiple output formats including HTML, PDF, ePub, and man pages.

## Installation
```bash
pip install sphinx
# With autodoc and themes
pip install sphinx sphinx-autobuild sphinx-rtd-theme
```

## Quickstart
```bash
# Initialize new documentation
sphinx-quickstart docs
# Build HTML documentation
cd docs && make html
# Auto-rebuild on changes
sphinx-autobuild . _build/html
```

## Basic conf.py
```python
project = 'MyProject'
copyright = '2024, Your Name'
author = 'Your Name'

extensions = [
    'sphinx.ext.autodoc',       # Extract docstrings
    'sphinx.ext.napoleon',      # Google/NumPy docstrings
    'sphinx.ext.viewcode',      # Source code links
    'sphinx.ext.intersphinx',   # Link to other docs
]

html_theme = 'sphinx_rtd_theme'
autodoc_member_order = 'bysource'

# Intersphinx mapping
intersphinx_mapping = {
    'python': ('https://docs.python.org/3', None),
}
```

## Strengths
- **Autodoc**: Automatically extracts documentation from Python docstrings
- **Multiple outputs**: HTML, PDF, ePub, LaTeX, man pages, plain text
- **Cross-references**: Automatic linking between modules, classes, functions
- **Extensible**: Rich plugin ecosystem for custom functionality
- **Themes**: Professional documentation themes available
- **Search**: Built-in search functionality for HTML output

## Limitations
- Python-centric: Best suited for Python projects
- Learning curve: reStructuredText syntax can be complex
- Build times: Large projects can have slow build times
- Configuration: Initial setup can be overwhelming

## Best For
- **API documentation**: Comprehensive Python API reference
- **Technical manuals**: Multi-format technical documentation
- **Library docs**: Open source Python libraries and frameworks
- **Academic papers**: Scientific and mathematical documentation

## NPL-FIM Integration
```npl
⟪sphinx-doc⟫ ::= {
  source: "*.rst | *.py",
  output: "html | pdf | epub",
  autodoc: true,
  theme: "rtd | alabaster | custom"
}
```

## FIM Context
Industry-standard Python documentation generator with rich ecosystem