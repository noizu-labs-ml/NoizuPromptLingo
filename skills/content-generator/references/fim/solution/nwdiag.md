# nwdiag

## Description
nwdiag generates network diagrams from simple text descriptions. Part of the blockdiag family of tools, it specializes in visualizing network topologies with clean, structured layouts.

**Official Documentation**: http://blockdiag.com/en/nwdiag/

## Installation
```bash
pip install nwdiag
```

## Basic Network Topology Example
```nwdiag
nwdiag {
  network dmz {
    address = "210.x.x.x/24"
    web01 [address = "210.x.x.1"];
    web02 [address = "210.x.x.2"];
  }
  network internal {
    address = "192.168.x.x/24";
    web01 [address = "192.168.x.1"];
    web02 [address = "192.168.x.2"];
    db01;
    db02;
  }
}
```

## Advanced Network Example
```nwdiag
nwdiag {
  inet [shape = cloud];
  inet -- router;

  network dmz {
    router;
    web01;
    web02;
  }
  network internal {
    web01;
    web02;
    db01;
  }
  network mgmt {
    router;
    db01;
    monitor;
  }
}
```

## Strengths
- **Network-specific**: Purpose-built for network architecture diagrams
- **Multiple subnets**: Handles complex multi-network topologies
- **Node grouping**: Groups devices by network segments automatically
- **Clean output**: Produces professional network documentation
- **Simple syntax**: Easy to learn and maintain

## Limitations
- **Layout constraints**: Limited control over node positioning
- **Visual styling**: Basic styling options compared to modern tools
- **Python dependency**: Requires Python runtime environment
- **Limited interactivity**: Static output only

## Best Use Cases
- Network architecture documentation
- Infrastructure diagrams for documentation
- System administration workflows
- DevOps network planning
- Technical specification illustrations

## NPL-FIM Integration
```npl
⟪nwdiag-network⟫ :: diagram-type
↦ syntax: nwdiag text format
↦ output: network topology visualization
↦ use-case: infrastructure documentation
⟪/nwdiag-network⟫
```

## Output Formats
- PNG (default)
- SVG
- PDF
- PostScript

## Related Tools
- blockdiag (generic block diagrams)
- seqdiag (sequence diagrams)
- actdiag (activity diagrams)
- Graphviz (general graph visualization)