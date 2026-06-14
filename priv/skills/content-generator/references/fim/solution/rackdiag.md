# rackdiag

## Description
rackdiag generates server rack diagrams from simple text descriptions. Part of the blockdiag suite (http://blockdiag.com), it specializes in visualizing datacenter infrastructure and server rack layouts with proper U-unit positioning and equipment representation.

## Installation
```bash
pip install rackdiag
```

## Basic Usage
```bash
rackdiag diagram.rack -f PNG
```

## Example: Server Rack Layout
```
rackdiag {
  // 42U rack configuration
  1U: Load Balancer [42U];
  2U: Web Server 1 [41U];
  3U: Web Server 2 [40U];

  5U: Database Primary [38U];
  6U: Database Secondary [37U];

  8U: Storage Array [35U];
  9U: Storage Array [34U];
  10U: Storage Array [33U];

  12U: Network Switch [31U];
  13U: Firewall [30U];

  15U: Backup Server [28U];

  // Power and cooling
  40U: UPS Unit [3U];
  41U: PDU [2U];
  42U: Blank Panel [1U];

  // Rack properties
  rack_height = 42;
  rack_unit = "1U";

  // Equipment styling
  Load_Balancer [color = "lightblue"];
  Web_Server_1, Web_Server_2 [color = "lightgreen"];
  Database_Primary, Database_Secondary [color = "orange"];
  Storage_Array [color = "yellow"];
  Network_Switch, Firewall [color = "lightcoral"];
  Backup_Server [color = "lightgray"];
}
```

## Strengths
- **Datacenter Focus**: Purpose-built for server rack visualization
- **U-Unit Accuracy**: Proper rack unit positioning and sizing
- **Equipment Types**: Predefined styles for common server hardware
- **Scalable**: Handles multiple racks and complex layouts
- **Integration**: Works with blockdiag ecosystem tools

## Limitations
- **Narrow Scope**: Limited to rack diagrams only
- **Text-Based**: No interactive or real-time editing
- **Styling**: Basic appearance customization options
- **Learning Curve**: Requires understanding rack unit conventions

## Best For
- Infrastructure documentation
- Datacenter planning diagrams
- Server deployment layouts
- Capacity planning visualization
- Hardware inventory diagrams

## NPL-FIM Integration
```npl
⟪rackdiag-generator⟫ {
  input: rack_specification ↦ equipment_list
  process: text → rackdiag_syntax → diagram_generation
  output: svg|png|pdf ↦ infrastructure_visualization

  context: datacenter_standards + equipment_catalog
  constraints: u_unit_accuracy + power_requirements
}
```

Use rackdiag when generating infrastructure diagrams that require precise rack unit positioning and standard datacenter equipment representation.