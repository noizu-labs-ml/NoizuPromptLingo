# Gadfly.jl

Statistical plotting library for Julia based on the Grammar of Graphics, providing ggplot2-like syntax for data visualization.

## Links
- **Documentation**: [gadflyjl.org](http://gadflyjl.org)
- **Repository**: [github.com/GiovineItalia/Gadfly.jl](https://github.com/GiovineItalia/Gadfly.jl)
- **Gallery**: [gadflyjl.org/gallery.html](http://gadflyjl.org/gallery.html)

## Installation

```julia
using Pkg
Pkg.add("Gadfly")
```

## Grammar of Graphics Example

```julia
using Gadfly, DataFrames, RDatasets

# Load sample data
iris = dataset("datasets", "iris")

# Create layered plot with grammar of graphics
plot(iris,
     x=:SepalLength, y=:SepalWidth, color=:Species,
     Geom.point, Geom.smooth,
     Guide.xlabel("Sepal Length (cm)"),
     Guide.ylabel("Sepal Width (cm)"),
     Guide.title("Iris Dataset Analysis"),
     Theme(default_color="darkblue"))
```

## Advanced Statistical Plots

```julia
# Faceted plots
plot(iris, x=:PetalLength, y=:PetalWidth,
     color=:Species, xgroup=:Species,
     Geom.subplot_grid(Geom.point))

# Box plots with violin overlay
plot(iris, x=:Species, y=:SepalLength,
     Geom.boxplot, Geom.violin)
```

## Strengths
- **ggplot2-like syntax**: Familiar grammar of graphics approach
- **Statistical focus**: Built-in statistical transformations and plots
- **Layered graphics**: Composable plot elements and themes
- **Publication quality**: Vector output with fine-grained control
- **Julia integration**: Native performance with DataFrame support

## Limitations
- **Performance**: Slower rendering compared to Plots.jl for large datasets
- **Maintenance**: Less active development and smaller community
- **Backend limitations**: Limited interactive features
- **Learning curve**: Requires understanding of grammar of graphics concepts
- **Memory usage**: Can be memory-intensive for complex plots

## Best For
- Statistical data analysis and visualization
- Publication-quality static plots
- Exploratory data analysis with layered graphics
- Users familiar with ggplot2 syntax
- Academic and research applications

## NPL-FIM Integration

```markdown
## Gadfly.jl Statistical Plot
```julia
using Gadfly, DataFrames

# Generate statistical visualization
plot(data, x=:variable1, y=:variable2, color=:category,
     Geom.point, Geom.smooth(method=:lm),
     Scale.color_discrete_manual("blue", "red", "green"))
```

**Capabilities**: Grammar of graphics, statistical layers, faceting, themes
**Output**: SVG, PNG, PDF statistical plots
**Use case**: {{statistical_analysis_context}}
```

**FIM Context**: Statistical plotting with grammar of graphics for Julia data analysis workflows.