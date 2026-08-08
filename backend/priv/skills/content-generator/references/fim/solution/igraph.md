---
name: igraph
description: High-performance network analysis library with bindings for R, Python, and C
docs: https://igraph.org/
examples: https://igraph.org/python/doc/tutorial/tutorial.html
---

# igraph

Fast and scalable library for network analysis with implementations in multiple languages.

## Install/Setup
```bash
# Python
pip install python-igraph cairocffi

# R
install.packages("igraph")

# C/C++
apt-get install libigraph-dev
```

## Basic Usage
```python
import igraph as ig
import matplotlib.pyplot as plt

# Create graph
g = ig.Graph()

# Add vertices
g.add_vertices(6)
g.vs["name"] = ["A", "B", "C", "D", "E", "F"]
g.vs["color"] = ["red", "blue", "green", "yellow", "orange", "purple"]

# Add edges
g.add_edges([(0,1), (0,2), (1,3), (2,3), (3,4), (4,5)])
g.es["weight"] = [1, 2, 1, 3, 2, 1]

# Analysis
print(f"Diameter: {g.diameter()}")
print(f"Betweenness: {g.betweenness()}")
print(f"PageRank: {g.pagerank()}")

# Community detection
communities = g.community_edge_betweenness().as_clustering()

# Visualization
layout = g.layout_fruchterman_reingold()
ig.plot(g,
        layout=layout,
        vertex_label=g.vs["name"],
        vertex_size=30,
        edge_width=[2*w for w in g.es["weight"]],
        bbox=(400, 400),
        margin=50)
```

## Strengths
- Excellent performance
- Rich algorithm collection
- Multi-language support
- Memory efficient
- Strong community

## Limitations
- Basic visualization
- Steeper learning curve
- Limited interactive features

## Best For
Large-scale network analysis, bioinformatics, social network analysis, graph algorithms