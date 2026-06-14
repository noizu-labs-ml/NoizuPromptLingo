---
name: Gephi
description: Open-source desktop application for interactive visualization and exploration of networks
docs: https://gephi.org/users/
examples: https://github.com/gephi/gephi/wiki/Datasets
---

# Gephi

Desktop software for interactive visualization and exploration of all kinds of networks and complex systems.

## Install/Setup
```bash
# Download from https://gephi.org/
# Or use Gephi Toolkit for Java integration
<dependency>
  <groupId>org.gephi</groupId>
  <artifactId>gephi-toolkit</artifactId>
  <version>0.10.1</version>
</dependency>
```

## Basic Usage
```java
// Using Gephi Toolkit
import org.gephi.project.api.*;
import org.gephi.graph.api.*;
import org.gephi.layout.plugin.force.StepDisplacement;
import org.gephi.layout.plugin.force.yifanHu.YifanHuLayout;

// Initialize
ProjectController pc = Lookup.getDefault().lookup(ProjectController.class);
pc.newProject();
Workspace workspace = pc.getCurrentWorkspace();

// Get graph model
GraphModel graphModel = Lookup.getDefault().lookup(GraphController.class).getGraphModel();
Graph graph = graphModel.getGraph();

// Add nodes
Node n1 = graphModel.factory().newNode("n1");
n1.setLabel("Node 1");
n1.setSize(10f);

Node n2 = graphModel.factory().newNode("n2");
n2.setLabel("Node 2");
n2.setSize(15f);

graph.addNode(n1);
graph.addNode(n2);

// Add edge
Edge e1 = graphModel.factory().newEdge(n1, n2, 1f, true);
graph.addEdge(e1);

// Apply layout
YifanHuLayout layout = new YifanHuLayout(null, new StepDisplacement(1f));
layout.setGraphModel(graphModel);
layout.initAlgo();
for (int i = 0; i < 100; i++) {
    layout.goAlgo();
}
```

## Strengths
- GUI for exploration
- Real-time visualization
- Advanced statistics
- Plugin ecosystem
- Import/export formats

## Limitations
- Desktop application
- Memory intensive
- Not web-deployable

## Best For
Research visualization, network exploration, social network analysis, large graph analytics