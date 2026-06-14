# R Markdown

## Description
R Markdown combines R code with markdown to create reproducible documents and reports. Integrates code execution with narrative text for data analysis workflows.

**Documentation**: https://rmarkdown.rstudio.com
**Package**: https://cran.r-project.org/package=rmarkdown
**Gallery**: https://rmarkdown.rstudio.com/gallery.html

## Installation
```r
# Install from CRAN
install.packages("rmarkdown")

# Optional: Install development version
devtools::install_github("rstudio/rmarkdown")
```

## Basic Example
```rmd
---
title: "Analysis Report"
output: html_document
---

## Data Analysis

```{r setup, include=FALSE}
library(tidyverse)
knitr::opts_chunk$set(echo = TRUE)
```

```{r analysis}
# Load and summarize data
data <- read.csv("data.csv")
summary(data)
```

```{r plot, fig.width=8}
# Create visualization
ggplot(data, aes(x = x, y = y)) +
  geom_point() +
  theme_minimal()
```
```

## Strengths
- **Reproducible Research**: Code and results in single document
- **Multiple Outputs**: HTML, PDF, Word, presentations
- **R Integration**: Native R code chunks with full ecosystem
- **Caching**: Chunk-level caching for long computations
- **Parameters**: Parameterized reports for automation

## Limitations
- **R-Centric**: Primarily designed for R workflows
- **Build Time**: Can be slow for complex documents
- **Dependencies**: Requires R and pandoc installation
- **Version Control**: Binary outputs challenge Git workflows

## Best For
- Statistical analysis reports
- Research papers with embedded analysis
- Data science documentation
- Reproducible scientific workflows
- Automated reporting systems

## NPL-FIM Integration
```yaml
fim_type: r-markdown
capabilities:
  - code_execution: r
  - output_formats: [html, pdf, word, slides]
  - interactive: shiny
  - caching: enabled
```