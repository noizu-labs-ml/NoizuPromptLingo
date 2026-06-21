# ggplot2

## Description
[ggplot2](https://ggplot2.tidyverse.org) is R's implementation of the grammar of graphics for creating declarative statistical visualizations. Part of the tidyverse ecosystem, it provides a coherent system for describing and building graphs layer by layer.

## Installation
```r
# From CRAN
install.packages("ggplot2")

# Development version
devtools::install_github("tidyverse/ggplot2")
```

## Basic Example
```r
library(ggplot2)

# Basic scatter plot with aesthetics
ggplot(mtcars, aes(x = wt, y = mpg, color = factor(cyl))) +
  geom_point(size = 3) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_color_brewer(palette = "Set1") +
  labs(title = "Weight vs MPG",
       x = "Weight (1000 lbs)",
       y = "Miles per Gallon",
       color = "Cylinders") +
  theme_minimal()
```

## Strengths
- **Grammar of graphics**: Coherent system for building any plot type
- **Extensive themes**: Publication-ready themes and customization
- **Faceting**: Easy multi-panel plots for data exploration
- **Statistics built-in**: Automatic statistical transformations
- **Ecosystem integration**: Works seamlessly with tidyverse packages

## Limitations
- **R-only**: Not available in other programming languages
- **Learning curve**: Grammar concepts require initial investment
- **Performance**: Can be slow with very large datasets
- **Interactive limitations**: Static plots by default (use plotly for interactivity)
- **Memory usage**: Stores full data in plot objects

## Best For
- **Statistical graphics**: Box plots, violin plots, regression visualization
- **Publication plots**: High-quality figures for journals and reports
- **Exploratory analysis**: Quick iteration through visualization options
- **Complex layouts**: Faceted and composite visualizations
- **Reproducible research**: Code-based plot generation

## NPL-FIM Integration
```yaml
fim_type: visualization
category: statistical-plotting
platform: R
interactivity: static
export_formats: [png, pdf, svg, eps]
integration_points:
  - R markdown documents
  - Shiny applications
  - Academic publications
```