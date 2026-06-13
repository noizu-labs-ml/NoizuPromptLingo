---
name: NetworkX
description: Python library for creation, manipulation, and analysis of complex networks
docs: https://networkx.org/documentation/stable/
examples: https://networkx.org/documentation/stable/auto_examples/index.html
---

# NetworkX

Comprehensive Python package for network analysis with algorithms for graph theory and visualization.

## Install/Setup
```bash
pip install networkx matplotlib
# For additional layouts
pip install pygraphviz pydot
```

## Basic Usage
```python
import networkx as nx
import matplotlib.pyplot as plt

# Create graph
G = nx.Graph()

# Add nodes
G.add_nodes_from([1, 2, 3, 4, 5])
G.add_node(6, color='red', size=300)

# Add edges
G.add_edges_from([(1, 2), (1, 3), (2, 4), (3, 4), (4, 5), (5, 6)])

# Analyze
print(f"Density: {nx.density(G)}")
print(f"Shortest path 1->6: {nx.shortest_path(G, 1, 6)}")
print(f"Clustering coefficient: {nx.average_clustering(G)}")

# Visualize
pos = nx.spring_layout(G, k=0.5, iterations=50)
nx.draw(G, pos,
        node_color='lightblue',
        node_size=500,
        with_labels=True,
        font_size=16,
        font_weight='bold',
        edge_color='gray')

plt.title("Network Graph")
plt.axis('off')
plt.show()
```

## Strengths
- Extensive graph algorithms
- Multiple layout options
- Scientific computing integration
- Active development
- Great documentation

## Limitations
- Python-only
- Basic visualization
- Not for real-time rendering

## Best For
Network analysis, graph algorithms, scientific research, data science workflows