# packetdiag

## Description
Python tool for generating packet format diagrams. Part of the blockdiag suite for creating network protocol documentation with visual packet structure representations.

## Links
- Official: http://blockdiag.com/en/packetdiag/
- Documentation: http://blockdiag.com/en/packetdiag/introduction.html
- Repository: https://github.com/blockdiag/packetdiag

## Installation
```bash
pip install packetdiag
```

## Basic Usage
```bash
# Generate PNG diagram
packetdiag packet.diag

# Generate SVG
packetdiag -T svg packet.diag
```

## Example
```packetdiag
packetdiag {
  colwidth = 32
  node_height = 72

  0-15: Source Port
  16-31: Destination Port
  32-63: Sequence Number
  64-95: Acknowledgment Number
  96-99: Data Offset
  100-105: Reserved
  106: URG
  107: ACK
  108: PSH
  109: RST
  110: SYN
  111: FIN
  112-127: Window Size
  128-143: Checksum
  144-159: Urgent Pointer
  160-191: Options (optional)
}
```

## Strengths
- Clear packet layout visualization
- Bit-level field precision
- Protocol documentation standard
- Customizable field formatting
- Multiple output formats (PNG, SVG, PDF)

## Limitations
- Niche networking use case
- Limited layout customization
- Requires understanding of packet structures
- Text-based syntax learning curve

## Best For
- Network protocol specifications
- Technical documentation
- Protocol analysis reports
- Educational network materials
- RFC-style documentation

## NPL-FIM Integration
```npl
packetdiag {
  protocol: {{protocol_name}}
  fields: {{packet_fields}}
  colwidth: {{bit_width}}
  output: {{format}}
}
```

Use for network protocol documentation requiring precise bit-field visualization and technical accuracy.