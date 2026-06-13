# NPL-FIM: Plots.jl
📊 Julia's unified plotting interface with multiple backend support

## Description
Unified plotting API for Julia supporting multiple backends (GR, PlotlyJS, PyPlot, etc.)
- Documentation: https://docs.juliaplots.org
- GitHub: https://github.com/JuliaPlots/Plots.jl

## Installation
```julia
using Pkg
Pkg.add("Plots")
# Optional backends
Pkg.add("GR")        # Default backend
Pkg.add("PlotlyJS")  # Interactive plots
Pkg.add("PyPlot")    # Matplotlib backend
```

## Basic Usage
```julia
using Plots
gr()  # Set GR backend (default)

# Line plot
x = 0:0.1:2π
y = sin.(x)
plot(x, y, title="Sine Wave", xlabel="x", ylabel="sin(x)")

# Multiple series
plot(x, [sin.(x) cos.(x)], label=["sin" "cos"])

# Scatter plot with customization
scatter(randn(100), randn(100),
        markersize=3, color=:blue, alpha=0.6)

# Subplots
p1 = plot(x, sin.(x))
p2 = scatter(randn(50), randn(50))
p3 = histogram(randn(1000))
p4 = bar(["A", "B", "C"], [1, 2, 3])
plot(p1, p2, p3, p4, layout=(2,2))
```

## Strengths
- **Backend flexibility**: Switch backends without code changes
- **Recipe system**: Extensible plotting for custom types
- **Consistent API**: Same syntax across all backends
- **Plot attributes**: Comprehensive customization options
- **Animation support**: Built-in animation framework

## Limitations
- **Compilation time**: Initial plot can be slow (JIT compilation)
- **Backend differences**: Some features vary by backend
- **Memory usage**: Can be high for complex plots

## Best For
- Scientific computing in Julia ecosystem
- Researchers needing backend flexibility
- Quick exploratory data visualization
- Integration with Julia packages

## FIM Context
Primary plotting solution for Julia, foundation for scientific visualization ecosystem