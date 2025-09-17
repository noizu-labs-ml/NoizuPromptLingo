# Pandoc Document Processing - NPL-FIM Complete Implementation Guide

⌜document-processing|pandoc|NPL-FIM@1.0⌝
# Pandoc Document Processing Mastery
🔄 @pandoc universal-converter multi-format enterprise-ready

A comprehensive Pandoc implementation framework for enterprise document processing, featuring advanced format conversion, template management, automated pipelines, and production-grade document transformation workflows.

## Direct Implementation Framework

### Instant Production Setup
```bash
#!/bin/bash
# Complete Pandoc document processing environment setup
# Dependencies: pandoc, texlive-full, wkhtmltopdf, librsvg2-bin

# Core installation
sudo apt-get update
sudo apt-get install -y pandoc texlive-full wkhtmltopdf librsvg2-bin

# Extended format support
sudo apt-get install -y pandoc-citeproc pandoc-crossref
pip3 install pandocfilters pypandoc

# Validation
pandoc --version
pdflatex --version
```

### Enterprise Document Processor Class
```python
#!/usr/bin/env python3
"""
Pandoc Document Processing Framework
Production-ready document transformation engine
"""

import os
import subprocess
import json
import logging
from pathlib import Path
from typing import Dict, List, Optional, Union
from dataclasses import dataclass, field
from enum import Enum

class OutputFormat(Enum):
    """Supported output formats with optimization profiles"""
    PDF = "pdf"
    HTML = "html"
    DOCX = "docx"
    LATEX = "latex"
    EPUB = "epub"
    ODT = "odt"
    RTF = "rtf"
    MARKDOWN = "markdown"
    REVEALJS = "revealjs"
    BEAMER = "beamer"
    PPTX = "pptx"

class InputFormat(Enum):
    """Supported input formats"""
    MARKDOWN = "markdown"
    HTML = "html"
    LATEX = "latex"
    DOCX = "docx"
    ODT = "odt"
    EPUB = "epub"
    RST = "rst"
    TEXTILE = "textile"
    DOCBOOK = "docbook"
    JATS = "jats"

@dataclass
class ProcessingOptions:
    """Document processing configuration"""
    # Core conversion settings
    input_format: InputFormat = InputFormat.MARKDOWN
    output_format: OutputFormat = OutputFormat.PDF
    pdf_engine: str = "xelatex"

    # Template and styling
    template: Optional[str] = None
    css: Optional[str] = None
    reference_doc: Optional[str] = None

    # Content processing
    toc: bool = False
    toc_depth: int = 3
    number_sections: bool = False

    # Bibliography and citations
    bibliography: Optional[str] = None
    csl: Optional[str] = None
    citation_abbreviations: Optional[str] = None

    # Mathematical content
    mathjax: bool = False
    mathml: bool = False
    katex: bool = False

    # Advanced features
    filters: List[str] = field(default_factory=list)
    metadata: Dict[str, str] = field(default_factory=dict)
    variables: Dict[str, str] = field(default_factory=dict)

    # Output customization
    standalone: bool = True
    self_contained: bool = False

    # Processing behavior
    fail_if_warnings: bool = False
    verbose: bool = False

class PandocProcessor:
    """Advanced Pandoc document processing engine"""

    def __init__(self, base_templates_dir: str = "templates"):
        self.base_templates_dir = Path(base_templates_dir)
        self.logger = self._setup_logging()
        self._validate_environment()

    def _setup_logging(self) -> logging.Logger:
        """Configure comprehensive logging"""
        logger = logging.getLogger("pandoc_processor")
        logger.setLevel(logging.INFO)

        if not logger.handlers:
            handler = logging.StreamHandler()
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            handler.setFormatter(formatter)
            logger.addHandler(handler)

        return logger

    def _validate_environment(self):
        """Validate Pandoc installation and dependencies"""
        try:
            result = subprocess.run(
                ["pandoc", "--version"],
                capture_output=True,
                text=True,
                check=True
            )
            version = result.stdout.split('\n')[0]
            self.logger.info(f"Pandoc validated: {version}")
        except (subprocess.CalledProcessError, FileNotFoundError):
            raise RuntimeError("Pandoc not found. Please install Pandoc.")

    def process_document(
        self,
        input_path: Union[str, Path],
        output_path: Union[str, Path],
        options: ProcessingOptions
    ) -> bool:
        """
        Process document with comprehensive error handling

        Args:
            input_path: Source document path
            output_path: Target document path
            options: Processing configuration

        Returns:
            bool: Success status
        """
        try:
            input_path = Path(input_path)
            output_path = Path(output_path)

            # Validate input
            if not input_path.exists():
                raise FileNotFoundError(f"Input file not found: {input_path}")

            # Create output directory
            output_path.parent.mkdir(parents=True, exist_ok=True)

            # Build Pandoc command
            cmd = self._build_command(input_path, output_path, options)

            # Execute conversion
            self.logger.info(f"Converting {input_path} -> {output_path}")
            self.logger.debug(f"Command: {' '.join(cmd)}")

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True
            )

            if options.verbose:
                self.logger.info(f"Pandoc output: {result.stdout}")

            # Validate output
            if not output_path.exists():
                raise RuntimeError("Output file was not created")

            self.logger.info(f"Conversion successful: {output_path}")
            return True

        except subprocess.CalledProcessError as e:
            self.logger.error(f"Pandoc conversion failed: {e.stderr}")
            return False
        except Exception as e:
            self.logger.error(f"Processing error: {str(e)}")
            return False

    def _build_command(
        self,
        input_path: Path,
        output_path: Path,
        options: ProcessingOptions
    ) -> List[str]:
        """Build optimized Pandoc command"""
        cmd = ["pandoc"]

        # Input/output
        cmd.extend([str(input_path), "-o", str(output_path)])

        # Format specification
        if options.input_format:
            cmd.extend(["-f", options.input_format.value])
        if options.output_format:
            cmd.extend(["-t", options.output_format.value])

        # PDF engine for PDF output
        if options.output_format == OutputFormat.PDF and options.pdf_engine:
            cmd.extend(["--pdf-engine", options.pdf_engine])

        # Template and styling
        if options.template:
            template_path = self._resolve_template_path(options.template)
            cmd.extend(["--template", str(template_path)])

        if options.css:
            cmd.extend(["--css", options.css])

        if options.reference_doc:
            cmd.extend(["--reference-doc", options.reference_doc])

        # Table of contents
        if options.toc:
            cmd.append("--toc")
            cmd.extend(["--toc-depth", str(options.toc_depth)])

        if options.number_sections:
            cmd.append("--number-sections")

        # Bibliography and citations
        if options.bibliography:
            cmd.extend(["--bibliography", options.bibliography])

        if options.csl:
            cmd.extend(["--csl", options.csl])

        if options.citation_abbreviations:
            cmd.extend(["--citation-abbreviations", options.citation_abbreviations])

        # Mathematical content
        if options.mathjax:
            cmd.append("--mathjax")
        elif options.mathml:
            cmd.append("--mathml")
        elif options.katex:
            cmd.append("--katex")

        # Filters
        for filter_name in options.filters:
            cmd.extend(["--filter", filter_name])

        # Metadata
        for key, value in options.metadata.items():
            cmd.extend(["-M", f"{key}={value}"])

        # Variables
        for key, value in options.variables.items():
            cmd.extend(["-V", f"{key}={value}"])

        # Output options
        if options.standalone:
            cmd.append("--standalone")

        if options.self_contained:
            cmd.append("--self-contained")

        # Processing behavior
        if options.fail_if_warnings:
            cmd.append("--fail-if-warnings")

        if options.verbose:
            cmd.append("--verbose")

        return cmd

    def _resolve_template_path(self, template: str) -> Path:
        """Resolve template path with fallback options"""
        # Try absolute path first
        if Path(template).is_absolute() and Path(template).exists():
            return Path(template)

        # Try relative to base templates directory
        template_path = self.base_templates_dir / template
        if template_path.exists():
            return template_path

        # Try with common extensions
        for ext in [".tex", ".html", ".latex"]:
            extended_path = self.base_templates_dir / f"{template}{ext}"
            if extended_path.exists():
                return extended_path

        # Return original if not found (let Pandoc handle)
        return Path(template)

    def batch_process(
        self,
        input_dir: Union[str, Path],
        output_dir: Union[str, Path],
        options: ProcessingOptions,
        file_pattern: str = "*.md"
    ) -> Dict[str, bool]:
        """
        Batch process multiple documents

        Args:
            input_dir: Source directory
            output_dir: Target directory
            options: Processing configuration
            file_pattern: Input file pattern

        Returns:
            Dict mapping input files to success status
        """
        input_dir = Path(input_dir)
        output_dir = Path(output_dir)
        results = {}

        for input_file in input_dir.glob(file_pattern):
            # Generate output filename
            output_file = output_dir / f"{input_file.stem}.{options.output_format.value}"

            # Process document
            success = self.process_document(input_file, output_file, options)
            results[str(input_file)] = success

        return results

# Template Management System
class TemplateManager:
    """Advanced template management for document processing"""

    def __init__(self, templates_dir: str = "templates"):
        self.templates_dir = Path(templates_dir)
        self.templates_dir.mkdir(exist_ok=True)

    def create_latex_template(self, template_name: str, **kwargs) -> str:
        """Create customized LaTeX template"""
        template_content = f"""
\\documentclass[{{$fontsize$}}]{{$documentclass$}}

% Packages
\\usepackage[utf8]{{inputenc}}
\\usepackage[T1]{{fontenc}}
\\usepackage{{lmodern}}
\\usepackage{{microtype}}
\\usepackage{{geometry}}
\\usepackage{{fancyhdr}}
\\usepackage{{graphicx}}
\\usepackage{{longtable}}
\\usepackage{{booktabs}}
\\usepackage{{array}}
\\usepackage{{parskip}}
\\usepackage{{xcolor}}
\\usepackage{{hyperref}}

% Geometry
\\geometry{{
    $if(geometry)$
    $geometry$
    $else$
    margin=1in
    $endif$
}}

% Header/Footer
\\pagestyle{{fancy}}
\\fancyhf{{}}
\\rhead{{$if(title)$$title$$endif$}}
\\lhead{{$if(author)$$author$$endif$}}
\\cfoot{{\\thepage}}

% Title formatting
$if(title)$
\\title{{$title$}}
$endif$
$if(author)$
\\author{{$author$}}
$endif$
$if(date)$
\\date{{$date$}}
$endif$

% Hyperref setup
\\hypersetup{{
    colorlinks=true,
    linkcolor=blue,
    filecolor=magenta,
    urlcolor=cyan,
    pdftitle={{$if(title)$$title$$endif$}},
    pdfauthor={{$if(author)$$author$$endif$}},
}}

\\begin{{document}}

$if(title)$
\\maketitle
$endif$

$if(toc)$
\\tableofcontents
\\newpage
$endif$

$body$

\\end{{document}}
"""

        template_path = self.templates_dir / f"{template_name}.tex"
        template_path.write_text(template_content.strip())
        return str(template_path)

    def create_html_template(self, template_name: str, **kwargs) -> str:
        """Create customized HTML template"""
        template_content = f"""
<!DOCTYPE html>
<html lang="$if(lang)$$lang$$else$en$endif$">
<head>
    <meta charset="utf-8">
    <meta name="generator" content="pandoc">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    $if(title)$
    <title>$title$</title>
    $endif$

    $if(author)$
    <meta name="author" content="$author$">
    $endif$

    $if(date)$
    <meta name="date" content="$date$">
    $endif$

    <style>
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            color: #333;
        }}

        h1, h2, h3, h4, h5, h6 {{
            color: #2c3e50;
            margin-top: 2em;
        }}

        h1 {{
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
        }}

        code {{
            background-color: #f8f9fa;
            padding: 2px 4px;
            border-radius: 3px;
            font-family: 'SF Mono', Monaco, 'Cascadia Code', monospace;
        }}

        pre {{
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
            border-left: 4px solid #3498db;
        }}

        blockquote {{
            border-left: 4px solid #bdc3c7;
            margin-left: 0;
            padding-left: 20px;
            color: #7f8c8d;
        }}

        table {{
            border-collapse: collapse;
            width: 100%;
            margin: 20px 0;
        }}

        th, td {{
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }}

        th {{
            background-color: #f8f9fa;
            font-weight: 600;
        }}

        .toc {{
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
        }}

        .toc h2 {{
            margin-top: 0;
            color: #2c3e50;
        }}
    </style>

    $for(css)$
    <link rel="stylesheet" href="$css$">
    $endfor$

    $if(math)$
    <script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
    <script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
    $endif$
</head>
<body>

$if(title)$
<header>
    <h1>$title$</h1>
    $if(author)$
    <p class="author">$author$</p>
    $endif$
    $if(date)$
    <p class="date">$date$</p>
    $endif$
</header>
$endif$

$if(toc)$
<nav class="toc">
    <h2>Table of Contents</h2>
    $toc$
</nav>
$endif$

<main>
$body$
</main>

</body>
</html>
"""

        template_path = self.templates_dir / f"{template_name}.html"
        template_path.write_text(template_content.strip())
        return str(template_path)

# Document Pipeline Automation
class DocumentPipeline:
    """Automated document processing pipeline"""

    def __init__(self, config_file: Optional[str] = None):
        self.processor = PandocProcessor()
        self.template_manager = TemplateManager()
        self.config = self._load_config(config_file) if config_file else {}

    def _load_config(self, config_file: str) -> Dict:
        """Load pipeline configuration"""
        with open(config_file, 'r') as f:
            return json.load(f)

    def create_multi_format_pipeline(
        self,
        source_file: str,
        formats: List[OutputFormat],
        base_options: Optional[ProcessingOptions] = None
    ) -> Dict[str, bool]:
        """Generate multiple output formats from single source"""
        if not base_options:
            base_options = ProcessingOptions()

        results = {}
        source_path = Path(source_file)

        for format in formats:
            # Create format-specific options
            options = ProcessingOptions(
                input_format=base_options.input_format,
                output_format=format,
                pdf_engine=base_options.pdf_engine,
                template=base_options.template,
                toc=base_options.toc,
                bibliography=base_options.bibliography,
                mathjax=base_options.mathjax
            )

            # Generate output path
            output_path = source_path.parent / f"{source_path.stem}.{format.value}"

            # Process document
            success = self.processor.process_document(source_file, output_path, options)
            results[format.value] = success

        return results

# Usage Examples and Workflows
def create_engineering_report_pipeline():
    """Complete engineering report processing workflow"""

    # Initialize processor
    processor = PandocProcessor()
    template_manager = TemplateManager()

    # Create custom templates
    latex_template = template_manager.create_latex_template("engineering_report")
    html_template = template_manager.create_html_template("engineering_report")

    # Define processing options for PDF
    pdf_options = ProcessingOptions(
        input_format=InputFormat.MARKDOWN,
        output_format=OutputFormat.PDF,
        pdf_engine="xelatex",
        template=latex_template,
        toc=True,
        number_sections=True,
        bibliography="references.bib",
        filters=["pandoc-crossref"],
        metadata={
            "title": "Engineering Report",
            "author": "Engineering Team",
            "date": "\\today"
        }
    )

    # Define processing options for HTML
    html_options = ProcessingOptions(
        input_format=InputFormat.MARKDOWN,
        output_format=OutputFormat.HTML,
        template=html_template,
        toc=True,
        mathjax=True,
        self_contained=True,
        bibliography="references.bib"
    )

    # Process documents
    processor.process_document("report.md", "report.pdf", pdf_options)
    processor.process_document("report.md", "report.html", html_options)

if __name__ == "__main__":
    # Demo usage
    create_engineering_report_pipeline()
```

## Advanced Configuration Profiles

### Enterprise PDF Generation
```yaml
# pandoc-config.yaml - Enterprise PDF profile
pdf_enterprise:
  pdf_engine: "xelatex"
  template: "corporate-report.tex"
  toc: true
  toc_depth: 4
  number_sections: true
  bibliography: "corporate.bib"
  csl: "ieee.csl"
  filters:
    - "pandoc-crossref"
    - "pandoc-citeproc"
  variables:
    documentclass: "report"
    fontsize: "11pt"
    geometry: "margin=1in"
    mainfont: "Times New Roman"
    sansfont: "Arial"
    monofont: "Courier New"
  metadata:
    company: "TechCorp Industries"
    confidentiality: "Internal Use Only"
    version: "1.0"
```

### Web Documentation Profile
```yaml
html_documentation:
  output_format: "html5"
  template: "documentation.html"
  toc: true
  mathjax: true
  self_contained: true
  css:
    - "documentation.css"
    - "syntax-highlighting.css"
  filters:
    - "pandoc-include-code"
    - "pandoc-plantuml"
  variables:
    theme: "corporate"
    highlight_style: "github"
    toc_float: true
```

### Presentation Generation Profile
```yaml
presentation_revealjs:
  output_format: "revealjs"
  template: "reveal-corporate.html"
  standalone: true
  variables:
    theme: "corporate"
    transition: "slide"
    controls: true
    progress: true
    center: true
    hash: true
  filters:
    - "pandoc-include-code"
```

## Production Template Library

### Corporate LaTeX Template
```latex
% corporate-report.tex - Enterprise LaTeX template
\documentclass[$fontsize$]{$documentclass$}

% Corporate packages
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{fontspec}
\usepackage{geometry}
\usepackage{fancyhdr}
\usepackage{titlesec}
\usepackage{graphicx}
\usepackage{longtable}
\usepackage{booktabs}
\usepackage{xcolor}
\usepackage{hyperref}
\usepackage{tcolorbox}
\usepackage{enumitem}

% Corporate colors
\definecolor{corporateblue}{RGB}{0, 82, 155}
\definecolor{corporategray}{RGB}{128, 128, 128}
\definecolor{lightgray}{RGB}{245, 245, 245}

% Font configuration
$if(mainfont)$
\setmainfont{$mainfont$}
$endif$
$if(sansfont)$
\setsansfont{$sansfont$}
$endif$
$if(monofont)$
\setmonofont{$monofont$}
$endif$

% Page geometry
\geometry{
    $if(geometry)$
    $geometry$
    $else$
    top=1in,
    bottom=1in,
    left=1.25in,
    right=1in
    $endif$
}

% Header and footer styling
\pagestyle{fancy}
\fancyhf{}
\renewcommand{\headrulewidth}{0.5pt}
\renewcommand{\footrulewidth}{0.5pt}
\fancyhead[L]{\color{corporateblue}\textbf{$if(company)$$company$$endif$}}
\fancyhead[R]{\color{corporateblue}$if(title)$$title$$endif$}
\fancyfoot[L]{\color{corporategray}$if(confidentiality)$$confidentiality$$endif$}
\fancyfoot[C]{\color{corporategray}\thepage}
\fancyfoot[R]{\color{corporategray}$if(version)$v$version$$endif$}

% Title formatting
\titleformat{\section}
  {\color{corporateblue}\Large\bfseries}
  {\thesection}{1em}{}
  [\titlerule]

\titleformat{\subsection}
  {\color{corporateblue}\large\bfseries}
  {\thesubsection}{1em}{}

% Custom environments
\newtcolorbox{corporatebox}[1][]{
    colback=lightgray,
    colframe=corporateblue,
    boxrule=1pt,
    arc=3pt,
    #1
}

% Hyperref configuration
\hypersetup{
    colorlinks=true,
    linkcolor=corporateblue,
    filecolor=corporateblue,
    urlcolor=corporateblue,
    pdftitle={$if(title)$$title$$endif$},
    pdfauthor={$if(author)$$author$$endif$},
    pdfsubject={$if(subject)$$subject$$endif$},
    pdfkeywords={$if(keywords)$$keywords$$endif$}
}

% Document metadata
$if(title)$
\title{\color{corporateblue}\textbf{$title$}}
$endif$
$if(author)$
\author{$author$}
$endif$
$if(date)$
\date{$date$}
$endif$

\begin{document}

% Title page
$if(title)$
\begin{titlepage}
    \centering
    \vspace*{2cm}

    {\Huge\color{corporateblue}\textbf{$title$}\par}
    \vspace{1cm}

    $if(subtitle)$
    {\Large\color{corporategray}$subtitle$\par}
    \vspace{1cm}
    $endif$

    $if(author)$
    {\large\textbf{$author$}\par}
    \vspace{0.5cm}
    $endif$

    $if(company)$
    {\large\color{corporateblue}$company$\par}
    \vspace{2cm}
    $endif$

    $if(date)$
    {\large$date$\par}
    $endif$

    \vfill

    $if(confidentiality)$
    {\color{corporategray}\textbf{$confidentiality$}\par}
    $endif$
\end{titlepage}
$endif$

% Table of contents
$if(toc)$
\tableofcontents
\newpage
$endif$

% Document body
$body$

\end{document}
```

### Modern Web Documentation CSS
```css
/* documentation.css - Modern web documentation styling */
:root {
    --primary-color: #2c3e50;
    --secondary-color: #3498db;
    --accent-color: #e74c3c;
    --background-color: #ffffff;
    --surface-color: #f8f9fa;
    --text-color: #2c3e50;
    --text-secondary: #6c757d;
    --border-color: #dee2e6;
    --code-background: #f8f9fa;
    --shadow: 0 2px 4px rgba(0,0,0,0.1);
}

* {
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
    line-height: 1.6;
    color: var(--text-color);
    background-color: var(--background-color);
    margin: 0;
    padding: 0;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
    display: grid;
    grid-template-columns: 250px 1fr;
    grid-gap: 40px;
    min-height: 100vh;
}

/* Navigation sidebar */
.sidebar {
    background-color: var(--surface-color);
    padding: 20px;
    border-radius: 8px;
    box-shadow: var(--shadow);
    position: sticky;
    top: 20px;
    height: fit-content;
}

.sidebar h2 {
    color: var(--primary-color);
    margin-top: 0;
    border-bottom: 2px solid var(--secondary-color);
    padding-bottom: 10px;
}

.sidebar ul {
    list-style: none;
    padding: 0;
    margin: 0;
}

.sidebar li {
    margin: 8px 0;
}

.sidebar a {
    color: var(--text-color);
    text-decoration: none;
    padding: 5px 10px;
    border-radius: 4px;
    display: block;
    transition: background-color 0.2s;
}

.sidebar a:hover {
    background-color: var(--secondary-color);
    color: white;
}

/* Main content */
.content {
    padding: 20px 0;
}

h1, h2, h3, h4, h5, h6 {
    color: var(--primary-color);
    margin-top: 2em;
    margin-bottom: 0.5em;
    font-weight: 600;
}

h1 {
    font-size: 2.5em;
    border-bottom: 3px solid var(--secondary-color);
    padding-bottom: 15px;
    margin-top: 0;
}

h2 {
    font-size: 2em;
    border-bottom: 2px solid var(--border-color);
    padding-bottom: 10px;
}

h3 {
    font-size: 1.5em;
    color: var(--secondary-color);
}

/* Code styling */
code {
    background-color: var(--code-background);
    padding: 2px 6px;
    border-radius: 4px;
    font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', monospace;
    font-size: 0.9em;
    border: 1px solid var(--border-color);
}

pre {
    background-color: var(--code-background);
    padding: 20px;
    border-radius: 8px;
    overflow-x: auto;
    border-left: 4px solid var(--secondary-color);
    box-shadow: var(--shadow);
    margin: 20px 0;
}

pre code {
    background: none;
    padding: 0;
    border: none;
    font-size: 0.95em;
}

/* Tables */
table {
    border-collapse: collapse;
    width: 100%;
    margin: 20px 0;
    box-shadow: var(--shadow);
    border-radius: 8px;
    overflow: hidden;
}

th, td {
    padding: 12px 15px;
    text-align: left;
    border-bottom: 1px solid var(--border-color);
}

th {
    background-color: var(--primary-color);
    color: white;
    font-weight: 600;
}

tr:nth-child(even) {
    background-color: var(--surface-color);
}

/* Blockquotes */
blockquote {
    border-left: 4px solid var(--secondary-color);
    margin: 20px 0;
    padding: 15px 20px;
    background-color: var(--surface-color);
    border-radius: 0 8px 8px 0;
    font-style: italic;
}

/* Lists */
ul, ol {
    padding-left: 30px;
    margin: 15px 0;
}

li {
    margin: 8px 0;
}

/* Links */
a {
    color: var(--secondary-color);
    text-decoration: none;
    border-bottom: 1px solid transparent;
    transition: border-color 0.2s;
}

a:hover {
    border-bottom-color: var(--secondary-color);
}

/* Callout boxes */
.callout {
    padding: 15px 20px;
    margin: 20px 0;
    border-radius: 8px;
    border-left: 4px solid;
    box-shadow: var(--shadow);
}

.callout.info {
    background-color: #e3f2fd;
    border-left-color: #2196f3;
}

.callout.warning {
    background-color: #fff3e0;
    border-left-color: #ff9800;
}

.callout.error {
    background-color: #ffebee;
    border-left-color: #f44336;
}

.callout.success {
    background-color: #e8f5e8;
    border-left-color: #4caf50;
}

/* Responsive design */
@media (max-width: 768px) {
    .container {
        grid-template-columns: 1fr;
        grid-gap: 20px;
    }

    .sidebar {
        position: static;
        order: 2;
    }

    .content {
        order: 1;
    }
}
```

## Complete Workflow Automation Scripts

### Multi-Format Document Generator
```bash
#!/bin/bash
# document-generator.sh - Complete document processing automation

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/pandoc-config.yaml"
TEMPLATES_DIR="${SCRIPT_DIR}/templates"
OUTPUT_DIR="${SCRIPT_DIR}/output"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Validate environment
validate_environment() {
    log "Validating environment..."

    local missing_tools=()

    # Check required tools
    for tool in pandoc pdflatex xelatex; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -ne 0 ]; then
        error "Missing required tools: ${missing_tools[*]}"
        error "Please install missing tools and try again."
        exit 1
    fi

    # Check Pandoc version
    local pandoc_version=$(pandoc --version | head -n1 | cut -d' ' -f2)
    log "Pandoc version: $pandoc_version"

    success "Environment validation complete"
}

# Setup directories
setup_directories() {
    log "Setting up directories..."

    mkdir -p "$OUTPUT_DIR"/{pdf,html,docx,epub}
    mkdir -p "$TEMPLATES_DIR"

    success "Directories created"
}

# Generate PDF with LaTeX
generate_pdf() {
    local input_file="$1"
    local output_name="$2"
    local template="${3:-corporate-report}"

    log "Generating PDF: $output_name"

    local output_file="$OUTPUT_DIR/pdf/${output_name}.pdf"

    pandoc "$input_file" \
        -o "$output_file" \
        --pdf-engine=xelatex \
        --template="$TEMPLATES_DIR/${template}.tex" \
        --toc \
        --toc-depth=3 \
        --number-sections \
        --filter=pandoc-crossref \
        --bibliography=references.bib \
        --csl=ieee.csl \
        -V documentclass=report \
        -V fontsize=11pt \
        -V geometry="margin=1in" \
        -V mainfont="Times New Roman" \
        -V sansfont="Arial" \
        -V monofont="Courier New" \
        -M company="TechCorp Industries" \
        -M confidentiality="Internal Use Only" \
        -M version="1.0" \
        --fail-if-warnings

    if [ -f "$output_file" ]; then
        success "PDF generated: $output_file"
        return 0
    else
        error "PDF generation failed"
        return 1
    fi
}

# Generate HTML documentation
generate_html() {
    local input_file="$1"
    local output_name="$2"
    local template="${3:-documentation}"

    log "Generating HTML: $output_name"

    local output_file="$OUTPUT_DIR/html/${output_name}.html"

    pandoc "$input_file" \
        -o "$output_file" \
        -t html5 \
        --template="$TEMPLATES_DIR/${template}.html" \
        --toc \
        --toc-depth=3 \
        --mathjax \
        --self-contained \
        --css="$TEMPLATES_DIR/documentation.css" \
        --filter=pandoc-include-code \
        -V theme=corporate \
        -V highlight_style=github \
        -V toc_float=true \
        --fail-if-warnings

    if [ -f "$output_file" ]; then
        success "HTML generated: $output_file"
        return 0
    else
        error "HTML generation failed"
        return 1
    fi
}

# Generate Word document
generate_docx() {
    local input_file="$1"
    local output_name="$2"
    local reference_doc="${3:-}"

    log "Generating DOCX: $output_name"

    local output_file="$OUTPUT_DIR/docx/${output_name}.docx"
    local cmd=(pandoc "$input_file" -o "$output_file" --toc --toc-depth=3)

    if [ -n "$reference_doc" ] && [ -f "$TEMPLATES_DIR/$reference_doc" ]; then
        cmd+=(--reference-doc="$TEMPLATES_DIR/$reference_doc")
    fi

    cmd+=(--fail-if-warnings)

    "${cmd[@]}"

    if [ -f "$output_file" ]; then
        success "DOCX generated: $output_file"
        return 0
    else
        error "DOCX generation failed"
        return 1
    fi
}

# Generate EPUB
generate_epub() {
    local input_file="$1"
    local output_name="$2"

    log "Generating EPUB: $output_name"

    local output_file="$OUTPUT_DIR/epub/${output_name}.epub"

    pandoc "$input_file" \
        -o "$output_file" \
        --toc \
        --toc-depth=3 \
        --epub-cover-image=cover.jpg \
        -M title="$output_name" \
        -M author="TechCorp Industries" \
        --fail-if-warnings

    if [ -f "$output_file" ]; then
        success "EPUB generated: $output_file"
        return 0
    else
        error "EPUB generation failed"
        return 1
    fi
}

# Process single file to all formats
process_file() {
    local input_file="$1"
    local base_name=$(basename "$input_file" .md)

    log "Processing file: $input_file"

    local formats=("pdf" "html" "docx" "epub")
    local success_count=0

    for format in "${formats[@]}"; do
        case "$format" in
            pdf)
                if generate_pdf "$input_file" "$base_name"; then
                    ((success_count++))
                fi
                ;;
            html)
                if generate_html "$input_file" "$base_name"; then
                    ((success_count++))
                fi
                ;;
            docx)
                if generate_docx "$input_file" "$base_name"; then
                    ((success_count++))
                fi
                ;;
            epub)
                if generate_epub "$input_file" "$base_name"; then
                    ((success_count++))
                fi
                ;;
        esac
    done

    log "Processed $success_count/${#formats[@]} formats for $base_name"
}

# Batch process directory
batch_process() {
    local input_dir="$1"
    local pattern="${2:-*.md}"

    log "Batch processing directory: $input_dir"
    log "File pattern: $pattern"

    local processed_count=0

    while IFS= read -r -d '' file; do
        process_file "$file"
        ((processed_count++))
    done < <(find "$input_dir" -name "$pattern" -type f -print0)

    success "Batch processing complete: $processed_count files processed"
}

# Generate report
generate_report() {
    local report_file="$OUTPUT_DIR/processing-report.html"

    log "Generating processing report..."

    cat > "$report_file" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Document Processing Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background: #f4f4f4; padding: 20px; border-radius: 5px; }
        .stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin: 20px 0; }
        .stat-box { background: #e3f2fd; padding: 15px; border-radius: 5px; text-align: center; }
        .file-list { background: #f9f9f9; padding: 20px; border-radius: 5px; }
        .success { color: #4caf50; }
        .error { color: #f44336; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Document Processing Report</h1>
        <p>Generated on: $(date)</p>
    </div>

    <div class="stats">
        <div class="stat-box">
            <h3>PDF Files</h3>
            <p>$(find "$OUTPUT_DIR/pdf" -name "*.pdf" | wc -l)</p>
        </div>
        <div class="stat-box">
            <h3>HTML Files</h3>
            <p>$(find "$OUTPUT_DIR/html" -name "*.html" | wc -l)</p>
        </div>
        <div class="stat-box">
            <h3>DOCX Files</h3>
            <p>$(find "$OUTPUT_DIR/docx" -name "*.docx" | wc -l)</p>
        </div>
        <div class="stat-box">
            <h3>EPUB Files</h3>
            <p>$(find "$OUTPUT_DIR/epub" -name "*.epub" | wc -l)</p>
        </div>
    </div>

    <div class="file-list">
        <h2>Generated Files</h2>
EOF

    # Add file listings
    for format in pdf html docx epub; do
        echo "<h3>$format Files</h3><ul>" >> "$report_file"
        find "$OUTPUT_DIR/$format" -type f | while read -r file; do
            local size=$(du -h "$file" | cut -f1)
            echo "<li>$(basename "$file") ($size)</li>" >> "$report_file"
        done
        echo "</ul>" >> "$report_file"
    done

    cat >> "$report_file" << 'EOF'
    </div>
</body>
</html>
EOF

    success "Report generated: $report_file"
}

# Main execution
main() {
    local action="${1:-help}"

    case "$action" in
        setup)
            validate_environment
            setup_directories
            ;;
        file)
            local input_file="$2"
            if [ ! -f "$input_file" ]; then
                error "Input file not found: $input_file"
                exit 1
            fi
            validate_environment
            setup_directories
            process_file "$input_file"
            generate_report
            ;;
        batch)
            local input_dir="${2:-.}"
            local pattern="${3:-*.md}"
            validate_environment
            setup_directories
            batch_process "$input_dir" "$pattern"
            generate_report
            ;;
        report)
            generate_report
            ;;
        help|*)
            cat << 'EOF'
Document Generator - Advanced Pandoc automation

Usage:
    ./document-generator.sh setup              Setup environment and directories
    ./document-generator.sh file <input>       Process single file to all formats
    ./document-generator.sh batch [dir] [pattern]  Batch process directory
    ./document-generator.sh report             Generate processing report

Examples:
    ./document-generator.sh setup
    ./document-generator.sh file report.md
    ./document-generator.sh batch docs/ "*.md"
    ./document-generator.sh batch . "technical-*.md"

EOF
            ;;
    esac
}

# Execute main function
main "$@"
```

## Real-World Implementation Examples

### Technical Documentation Pipeline
```python
#!/usr/bin/env python3
"""
Technical Documentation Processing Pipeline
Enterprise-grade document automation for technical teams
"""

import os
import shutil
from pathlib import Path
from typing import List, Dict
import subprocess
import yaml

class TechnicalDocPipeline:
    """Complete technical documentation processing pipeline"""

    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.docs_dir = self.project_root / "docs"
        self.output_dir = self.project_root / "output"
        self.templates_dir = self.project_root / "templates"

        # Create necessary directories
        self.output_dir.mkdir(exist_ok=True)
        self.templates_dir.mkdir(exist_ok=True)

        # Initialize processor
        from pandoc_processor import PandocProcessor, ProcessingOptions, OutputFormat
        self.processor = PandocProcessor(str(self.templates_dir))

    def setup_api_documentation(self):
        """Setup API documentation processing"""

        # API documentation options
        html_options = ProcessingOptions(
            output_format=OutputFormat.HTML,
            template="api-docs.html",
            toc=True,
            toc_depth=4,
            self_contained=True,
            mathjax=True,
            filters=["pandoc-include-code"],
            css="api-docs.css",
            variables={
                "theme": "api",
                "highlight_style": "github",
                "include_search": "true"
            }
        )

        # Process API documentation
        api_files = list(self.docs_dir.glob("api/**/*.md"))
        for api_file in api_files:
            output_file = self.output_dir / "api" / f"{api_file.stem}.html"
            output_file.parent.mkdir(parents=True, exist_ok=True)

            self.processor.process_document(
                str(api_file),
                str(output_file),
                html_options
            )

    def setup_user_manual(self):
        """Setup user manual processing"""

        # PDF manual options
        pdf_options = ProcessingOptions(
            output_format=OutputFormat.PDF,
            template="user-manual.tex",
            toc=True,
            toc_depth=3,
            number_sections=True,
            pdf_engine="xelatex",
            filters=["pandoc-crossref"],
            variables={
                "documentclass": "book",
                "fontsize": "11pt",
                "geometry": "margin=1in",
                "mainfont": "Times New Roman"
            },
            metadata={
                "title": "User Manual",
                "author": "Technical Documentation Team",
                "company": "TechCorp"
            }
        )

        # Process user manual
        manual_file = self.docs_dir / "user-manual" / "manual.md"
        if manual_file.exists():
            output_file = self.output_dir / "user-manual.pdf"

            self.processor.process_document(
                str(manual_file),
                str(output_file),
                pdf_options
            )

    def setup_presentations(self):
        """Setup presentation processing"""

        # Reveal.js presentation options
        presentation_options = ProcessingOptions(
            output_format=OutputFormat.REVEALJS,
            template="corporate-presentation.html",
            standalone=True,
            variables={
                "theme": "corporate",
                "transition": "slide",
                "controls": "true",
                "progress": "true",
                "center": "true",
                "hash": "true"
            }
        )

        # Process presentations
        presentation_files = list(self.docs_dir.glob("presentations/**/*.md"))
        for pres_file in presentation_files:
            output_file = self.output_dir / "presentations" / f"{pres_file.stem}.html"
            output_file.parent.mkdir(parents=True, exist_ok=True)

            self.processor.process_document(
                str(pres_file),
                str(output_file),
                presentation_options
            )

    def run_full_pipeline(self):
        """Execute complete documentation pipeline"""
        print("Starting technical documentation pipeline...")

        # Process different document types
        self.setup_api_documentation()
        self.setup_user_manual()
        self.setup_presentations()

        print("Documentation pipeline complete!")

        # Generate index page
        self._generate_index_page()

    def _generate_index_page(self):
        """Generate master index page for all documentation"""

        index_content = """
# Technical Documentation Index

## API Documentation
- [API Reference](api/index.html)
- [Authentication Guide](api/auth.html)
- [Endpoints](api/endpoints.html)

## User Manual
- [Complete Manual (PDF)](user-manual.pdf)

## Presentations
- [Architecture Overview](presentations/architecture.html)
- [Getting Started](presentations/getting-started.html)

Generated on: {date}
"""

        from datetime import datetime
        index_content = index_content.format(date=datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

        index_file = self.output_dir / "index.md"
        index_file.write_text(index_content)

        # Convert to HTML
        html_options = ProcessingOptions(
            output_format=OutputFormat.HTML,
            template="index.html",
            standalone=True,
            css="index.css"
        )

        self.processor.process_document(
            str(index_file),
            str(self.output_dir / "index.html"),
            html_options
        )

# Example usage
if __name__ == "__main__":
    pipeline = TechnicalDocPipeline("/path/to/project")
    pipeline.run_full_pipeline()
```

## Advanced Feature Implementations

### Bibliography Management System
```python
#!/usr/bin/env python3
"""
Advanced Bibliography Management for Pandoc
Automated citation and reference management
"""

import json
import bibtexparser
from pathlib import Path
from typing import Dict, List, Optional

class BibliographyManager:
    """Advanced bibliography and citation management"""

    def __init__(self, bib_dir: str = "bibliography"):
        self.bib_dir = Path(bib_dir)
        self.bib_dir.mkdir(exist_ok=True)

        # Standard bibliography databases
        self.corporate_bib = self.bib_dir / "corporate.bib"
        self.ieee_bib = self.bib_dir / "ieee.bib"
        self.custom_bib = self.bib_dir / "custom.bib"

        # CSL styles
        self.csl_dir = self.bib_dir / "csl"
        self.csl_dir.mkdir(exist_ok=True)

        self._setup_default_styles()

    def _setup_default_styles(self):
        """Setup common CSL citation styles"""

        # IEEE style
        ieee_csl = """<?xml version="1.0" encoding="utf-8"?>
<style xmlns="http://purl.org/net/xbiblio/csl" class="in-text" version="1.0" demote-non-dropping-particle="sort-only">
  <info>
    <title>IEEE</title>
    <id>http://www.zotero.org/styles/ieee</id>
    <link href="http://www.zotero.org/styles/ieee" rel="self"/>
    <link href="https://www.ieee.org/content/dam/ieee-org/ieee/web/org/conferences/style_references_manual.pdf" rel="documentation"/>
    <author>
      <name>Michael Berkowitz</name>
      <email>mberkowi@gmu.edu</email>
    </author>
    <category citation-format="numeric"/>
    <category field="engineering"/>
    <category field="generic-base"/>
    <updated>2020-06-11T08:23:41+00:00</updated>
    <rights license="http://creativecommons.org/licenses/by-sa/3.0/">This work is licensed under a Creative Commons Attribution-ShareAlike 3.0 License</rights>
  </info>
  <!-- Citation format and bibliography macros -->
</style>"""

        ieee_csl_file = self.csl_dir / "ieee.csl"
        ieee_csl_file.write_text(ieee_csl)

    def create_corporate_bibliography(self, entries: List[Dict]) -> str:
        """Create corporate bibliography from entries"""

        bib_entries = []
        for entry in entries:
            bib_entry = f"""@{entry['type']}{{{entry['key']},
    title = {{{entry['title']}}},
    author = {{{entry['author']}}},
    year = {{{entry['year']}}},
    organization = {{{entry.get('organization', 'TechCorp')}}},
    note = {{{entry.get('note', 'Internal document')}}}
}}"""
            bib_entries.append(bib_entry)

        bibliography_content = "\n\n".join(bib_entries)
        self.corporate_bib.write_text(bibliography_content)

        return str(self.corporate_bib)

    def merge_bibliographies(self, bib_files: List[str], output_file: str) -> str:
        """Merge multiple bibliography files"""

        merged_entries = []

        for bib_file in bib_files:
            if Path(bib_file).exists():
                with open(bib_file, 'r') as f:
                    parser = bibtexparser.bparser.BibTexParser()
                    bib_database = bibtexparser.load(f, parser)
                    merged_entries.extend(bib_database.entries)

        # Write merged bibliography
        merged_db = bibtexparser.bibdatabase.BibDatabase()
        merged_db.entries = merged_entries

        output_path = self.bib_dir / output_file
        with open(output_path, 'w') as f:
            bibtexparser.dump(merged_db, f)

        return str(output_path)

    def validate_citations(self, markdown_file: str) -> Dict[str, List[str]]:
        """Validate citations in markdown file"""

        with open(markdown_file, 'r') as f:
            content = f.read()

        import re

        # Find all citations
        citations = re.findall(r'@(\w+)', content)

        # Load bibliography
        if self.corporate_bib.exists():
            with open(self.corporate_bib, 'r') as f:
                parser = bibtexparser.bparser.BibTexParser()
                bib_database = bibtexparser.load(f, parser)
                bib_keys = [entry['ID'] for entry in bib_database.entries]
        else:
            bib_keys = []

        # Validate citations
        valid_citations = [cite for cite in citations if cite in bib_keys]
        invalid_citations = [cite for cite in citations if cite not in bib_keys]

        return {
            'valid': valid_citations,
            'invalid': invalid_citations,
            'total': len(citations)
        }

# Cross-reference management
class CrossReferenceManager:
    """Advanced cross-reference management for Pandoc"""

    def __init__(self):
        self.figure_counter = 0
        self.table_counter = 0
        self.equation_counter = 0
        self.section_counter = 0

    def setup_crossref_filter(self) -> str:
        """Setup pandoc-crossref configuration"""

        crossref_config = {
            'figureTitle': 'Figure',
            'tableTitle': 'Table',
            'listingTitle': 'Listing',
            'figPrefix': 'Figure',
            'eqnPrefix': 'Equation',
            'tblPrefix': 'Table',
            'secPrefix': 'Section',
            'autoSectionLabels': True,
            'numberSections': True,
            'sectionsDepth': 3,
            'figureTemplate': '$$figureTitle$$ $$i$$: $$t$$',
            'tableTemplate': '$$tableTitle$$ $$i$$: $$t$$',
            'listingTemplate': '$$listingTitle$$ $$i$$: $$t$$'
        }

        config_file = Path("crossref-config.yaml")
        with open(config_file, 'w') as f:
            yaml.dump(crossref_config, f)

        return str(config_file)

    def add_figure_reference(self, image_path: str, caption: str, label: str) -> str:
        """Add figure with cross-reference"""

        figure_md = f"""
![{caption}]({image_path}){{#{label}}}
"""
        return figure_md

    def add_table_reference(self, table_content: str, caption: str, label: str) -> str:
        """Add table with cross-reference"""

        table_md = f"""
{table_content}

: {caption} {{#{label}}}
"""
        return table_md
```

## Production Deployment Templates

### Docker Container for Document Processing
```dockerfile
# Dockerfile - Production Pandoc document processing container
FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    pandoc \
    texlive-full \
    texlive-xetex \
    texlive-luatex \
    wkhtmltopdf \
    librsvg2-bin \
    python3 \
    python3-pip \
    curl \
    wget \
    git \
    make \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip3 install \
    pandocfilters \
    pypandoc \
    bibtexparser \
    pyyaml \
    jinja2

# Install additional Pandoc filters
RUN pip3 install \
    pandoc-include-code \
    pandoc-plantuml \
    pandoc-crossref

# Create working directories
WORKDIR /documents
RUN mkdir -p /documents/{input,output,templates,scripts}

# Copy processing scripts
COPY scripts/ /documents/scripts/
COPY templates/ /documents/templates/

# Make scripts executable
RUN chmod +x /documents/scripts/*.sh

# Set default command
CMD ["/documents/scripts/document-generator.sh", "help"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pandoc --version || exit 1
```

### GitHub Actions Workflow
```yaml
# .github/workflows/document-processing.yml
name: Document Processing Pipeline

on:
  push:
    branches: [ main, develop ]
    paths: [ 'docs/**', 'templates/**' ]
  pull_request:
    branches: [ main ]
    paths: [ 'docs/**', 'templates/**' ]

jobs:
  process-documents:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Setup Pandoc environment
      run: |
        sudo apt-get update
        sudo apt-get install -y pandoc texlive-full wkhtmltopdf
        pip3 install pandocfilters pypandoc

    - name: Validate document structure
      run: |
        # Check for required files
        test -f docs/index.md
        test -d templates/

        # Validate markdown syntax
        find docs/ -name "*.md" -exec pandoc {} -t html -o /dev/null \;

    - name: Process documents
      run: |
        ./scripts/document-generator.sh batch docs/ "*.md"

    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: processed-documents
        path: output/
        retention-days: 30

    - name: Deploy to GitHub Pages
      if: github.ref == 'refs/heads/main'
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./output/html
```

## Troubleshooting and Optimization

### Common Issues and Solutions
```python
#!/usr/bin/env python3
"""
Pandoc Troubleshooting and Optimization Guide
Common issues, solutions, and performance optimizations
"""

import subprocess
import logging
from pathlib import Path
from typing import Dict, List, Optional

class PandocTroubleshooter:
    """Comprehensive Pandoc troubleshooting and optimization"""

    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.common_issues = {
            'latex_not_found': {
                'symptoms': ['! LaTeX Error', 'pdflatex not found'],
                'solution': 'Install TeXLive: sudo apt-get install texlive-full',
                'prevention': 'Validate LaTeX installation before processing'
            },
            'template_not_found': {
                'symptoms': ['template not found', 'Could not find'],
                'solution': 'Check template path and ensure file exists',
                'prevention': 'Use absolute paths and validate templates'
            },
            'bibliography_errors': {
                'symptoms': ['bibliography not found', 'citeproc error'],
                'solution': 'Validate bibliography file format and citations',
                'prevention': 'Use validated .bib files and test citations'
            },
            'unicode_errors': {
                'symptoms': ['Unicode error', 'encoding issue'],
                'solution': 'Use UTF-8 encoding and proper font configuration',
                'prevention': 'Set explicit encoding in templates'
            },
            'memory_issues': {
                'symptoms': ['out of memory', 'killed'],
                'solution': 'Process files individually or increase memory',
                'prevention': 'Optimize document size and use batch processing'
            }
        }

    def diagnose_error(self, error_output: str) -> Dict[str, str]:
        """Diagnose Pandoc error and suggest solutions"""

        for issue_type, issue_info in self.common_issues.items():
            for symptom in issue_info['symptoms']:
                if symptom.lower() in error_output.lower():
                    return {
                        'issue_type': issue_type,
                        'solution': issue_info['solution'],
                        'prevention': issue_info['prevention']
                    }

        return {
            'issue_type': 'unknown',
            'solution': 'Check Pandoc documentation and log files',
            'prevention': 'Enable verbose logging for detailed error information'
        }

    def optimize_processing(self, file_size_mb: float) -> Dict[str, str]:
        """Provide optimization recommendations based on file size"""

        if file_size_mb < 1:
            return {
                'strategy': 'standard',
                'recommendations': [
                    'Use default processing options',
                    'Enable all features as needed'
                ]
            }
        elif file_size_mb < 10:
            return {
                'strategy': 'optimized',
                'recommendations': [
                    'Consider disabling self-contained for HTML',
                    'Use external CSS and JavaScript',
                    'Process in batches if multiple files'
                ]
            }
        else:
            return {
                'strategy': 'chunked',
                'recommendations': [
                    'Split large documents into chapters',
                    'Process sections individually',
                    'Use external resources instead of embedding',
                    'Consider increasing system memory'
                ]
            }

    def validate_environment(self) -> Dict[str, bool]:
        """Comprehensive environment validation"""

        checks = {}

        # Check Pandoc installation
        try:
            result = subprocess.run(['pandoc', '--version'],
                                  capture_output=True, text=True, check=True)
            checks['pandoc_installed'] = True
            self.logger.info(f"Pandoc version: {result.stdout.split()[1]}")
        except:
            checks['pandoc_installed'] = False

        # Check LaTeX installation
        try:
            subprocess.run(['pdflatex', '--version'],
                          capture_output=True, check=True)
            checks['latex_installed'] = True
        except:
            checks['latex_installed'] = False

        # Check filters
        filters_to_check = ['pandoc-crossref', 'pandoc-citeproc']
        for filter_name in filters_to_check:
            try:
                subprocess.run(['pandoc', '--filter', filter_name, '--help'],
                              capture_output=True, check=True)
                checks[f'{filter_name}_available'] = True
            except:
                checks[f'{filter_name}_available'] = False

        # Check Python packages
        python_packages = ['pandocfilters', 'pypandoc']
        for package in python_packages:
            try:
                __import__(package)
                checks[f'{package}_installed'] = True
            except ImportError:
                checks[f'{package}_installed'] = False

        return checks

    def performance_test(self, test_file: str) -> Dict[str, float]:
        """Run performance tests on document processing"""

        import time

        test_results = {}

        # Test different output formats
        formats = ['html', 'pdf', 'docx']
        test_path = Path(test_file)

        for format in formats:
            output_file = f"test_output.{format}"

            start_time = time.time()
            try:
                cmd = ['pandoc', str(test_path), '-o', output_file]
                subprocess.run(cmd, check=True, capture_output=True)
                end_time = time.time()

                test_results[f'{format}_processing_time'] = end_time - start_time

                # Clean up
                Path(output_file).unlink(missing_ok=True)

            except subprocess.CalledProcessError:
                test_results[f'{format}_processing_time'] = -1  # Error

        return test_results

# Performance optimization utilities
class PerformanceOptimizer:
    """Pandoc performance optimization utilities"""

    @staticmethod
    def optimize_latex_template(template_path: str) -> str:
        """Optimize LaTeX template for faster processing"""

        optimizations = [
            # Remove unnecessary packages
            r'\usepackage{package_name}  % Remove if not needed',

            # Optimize geometry
            r'\geometry{margin=1in}  % Simpler geometry',

            # Reduce font loading
            r'% \setmainfont{font}  % Comment out if default is sufficient',

            # Disable microtype for speed
            r'% \usepackage{microtype}  % Comment for faster processing'
        ]

        with open(template_path, 'r') as f:
            content = f.read()

        # Apply optimizations (this is a simplified example)
        # In practice, you'd implement specific optimization logic

        optimized_path = template_path.replace('.tex', '_optimized.tex')
        with open(optimized_path, 'w') as f:
            f.write(content)

        return optimized_path

    @staticmethod
    def create_processing_profile(document_type: str) -> Dict:
        """Create optimized processing profile for document type"""

        profiles = {
            'api_docs': {
                'formats': ['html'],
                'features': ['toc', 'mathjax', 'syntax_highlighting'],
                'optimizations': ['self_contained_false', 'external_css']
            },
            'technical_manual': {
                'formats': ['pdf', 'html'],
                'features': ['toc', 'number_sections', 'crossref', 'bibliography'],
                'optimizations': ['chunked_processing', 'external_resources']
            },
            'presentation': {
                'formats': ['revealjs'],
                'features': ['transitions', 'controls'],
                'optimizations': ['minimal_template', 'cdn_resources']
            },
            'report': {
                'formats': ['pdf', 'docx'],
                'features': ['toc', 'tables', 'figures', 'bibliography'],
                'optimizations': ['template_optimization', 'image_compression']
            }
        }

        return profiles.get(document_type, profiles['technical_manual'])
```

## Integration with Development Workflows

### VS Code Integration
```json
{
    "name": "Pandoc Document Processing",
    "version": "1.0.0",
    "description": "VS Code tasks for Pandoc document processing",
    "tasks": [
        {
            "label": "Generate PDF",
            "type": "shell",
            "command": "pandoc",
            "args": [
                "${file}",
                "-o",
                "${fileDirname}/${fileBasenameNoExtension}.pdf",
                "--pdf-engine=xelatex",
                "--template=corporate-report.tex",
                "--toc",
                "--number-sections"
            ],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "problemMatcher": []
        },
        {
            "label": "Generate HTML",
            "type": "shell",
            "command": "pandoc",
            "args": [
                "${file}",
                "-o",
                "${fileDirname}/${fileBasenameNoExtension}.html",
                "--template=documentation.html",
                "--toc",
                "--mathjax",
                "--self-contained"
            ],
            "group": "build"
        },
        {
            "label": "Process All Formats",
            "dependsOrder": "sequence",
            "dependsOn": ["Generate PDF", "Generate HTML"]
        }
    ]
}
```

This comprehensive NPL-FIM implementation guide provides everything needed for immediate, production-ready Pandoc document processing. The 950+ lines cover complete workflows, advanced features, troubleshooting, and integration patterns that eliminate false starts and deliver professional document transformation capabilities from the first prompt.

⌞document-processing⌟