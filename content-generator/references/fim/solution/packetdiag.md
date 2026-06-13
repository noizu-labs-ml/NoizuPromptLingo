# packetdiag - Network Protocol Packet Diagram Generator

## Description
Packetdiag is a powerful Python-based visualization tool for generating precise packet format diagrams, specifically designed for network protocol documentation. As part of the comprehensive blockdiag suite, it excels at creating professional-grade visual representations of packet structures with bit-level precision. The tool transforms text-based protocol descriptions into publication-ready diagrams that meet industry standards for technical documentation, RFCs, and educational materials.

Packetdiag addresses the critical need for accurate visual communication in network engineering, protocol design, and technical documentation. It bridges the gap between textual protocol specifications and visual understanding, making complex packet structures accessible to both technical and non-technical audiences.

## Version Compatibility & Requirements

### Python Version Support
- **Python 3.6+**: Full feature support
- **Python 3.7+**: Recommended for optimal performance
- **Python 3.8+**: Enhanced Unicode and font rendering
- **Python 3.9-3.11**: Latest features and security updates
- **Python 2.7**: Legacy support (deprecated, not recommended)

### Environment Requirements
**Minimum System Requirements:**
- RAM: 512MB available memory
- Storage: 50MB free disk space
- CPU: Any modern processor (ARM/x86/x64)
- OS: Linux, macOS, Windows, BSD variants

**Recommended Environment:**
- RAM: 2GB+ for complex diagrams
- Storage: 200MB+ for full blockdiag suite
- High-resolution display for diagram preview
- PDF viewer for output verification

**System Dependencies:**
```bash
# Ubuntu/Debian
sudo apt-get install python3-dev python3-pip
sudo apt-get install libjpeg-dev libfreetype6-dev

# macOS with Homebrew
brew install python3 jpeg freetype

# CentOS/RHEL
sudo yum install python3-devel python3-pip
sudo yum install libjpeg-devel freetype-devel
```

### Package Dependencies
**Core Dependencies:**
- Pillow (PIL) >= 7.0.0 - Image processing
- funcparserlib >= 0.3.6 - Parser combinators
- webcolors >= 1.11.1 - Color name handling

**Optional Dependencies:**
- reportlab >= 3.5.0 - PDF output support
- wand >= 0.6.0 - ImageMagick integration
- cairosvg >= 2.4.0 - SVG to PNG conversion

## License & Pricing

### Open Source License
**License Type:** Apache License 2.0
- **Commercial Use:** ✅ Permitted
- **Modification:** ✅ Permitted
- **Distribution:** ✅ Permitted
- **Private Use:** ✅ Permitted
- **Patent Grant:** ✅ Included
- **Liability:** ❌ No warranty provided
- **Trademark Use:** ❌ Not permitted

### Cost Structure
**Free Tier:** Complete functionality
- No usage limitations
- No watermarks or attribution requirements
- Full commercial usage rights
- Community support via GitHub issues

**Enterprise Considerations:**
- No paid tiers or premium features
- Support available through consulting services
- Custom development available from blockdiag maintainers
- Training and workshops available separately

## Links & Resources

### Official Resources
- **Project Homepage:** http://blockdiag.com/en/packetdiag/
- **Complete Documentation:** http://blockdiag.com/en/packetdiag/introduction.html
- **GitHub Repository:** https://github.com/blockdiag/packetdiag
- **PyPI Package:** https://pypi.org/project/packetdiag/

### Community & Support
- **Issue Tracker:** https://github.com/blockdiag/packetdiag/issues
- **Discussions:** https://github.com/blockdiag/packetdiag/discussions
- **Stack Overflow:** Tag `packetdiag` for questions
- **Reddit Community:** r/networkengineering, r/python

### Related Tools
- **blockdiag:** Block diagram generator
- **seqdiag:** Sequence diagram generator
- **actdiag:** Activity diagram generator
- **nwdiag:** Network diagram generator

## Installation & Setup

### Standard Installation
```bash
# Install from PyPI (recommended)
pip install packetdiag

# Install with all optional dependencies
pip install packetdiag[all]

# Install specific optional features
pip install packetdiag[pdf]      # PDF output support
pip install packetdiag[svg]      # Enhanced SVG support
pip install packetdiag[fonts]    # Additional font support
```

### Development Installation
```bash
# Clone and install development version
git clone https://github.com/blockdiag/packetdiag.git
cd packetdiag
pip install -e .

# Install development dependencies
pip install -e .[dev]
```

### Virtual Environment Setup
```bash
# Create isolated environment
python -m venv packetdiag-env
source packetdiag-env/bin/activate  # Linux/macOS
# packetdiag-env\Scripts\activate    # Windows

# Install in virtual environment
pip install packetdiag
```

### Docker Installation
```dockerfile
# Dockerfile for packetdiag environment
FROM python:3.9-slim

RUN apt-get update && apt-get install -y \
    libjpeg-dev libfreetype6-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install packetdiag

WORKDIR /diagrams
CMD ["packetdiag"]
```

### Verification
```bash
# Verify installation
packetdiag --version

# Test basic functionality
echo 'packetdiag { 0-7: Test }' | packetdiag - -T png -o test.png
```

## Comprehensive Usage Guide

### Command Line Interface
```bash
# Basic PNG generation
packetdiag diagram.diag

# Specify output format
packetdiag -T svg diagram.diag
packetdiag -T pdf diagram.diag
packetdiag -T eps diagram.diag

# Custom output filename
packetdiag -o output.png diagram.diag

# High DPI output for print
packetdiag --dpi 300 diagram.diag

# Custom font specification
packetdiag --font /path/to/font.ttf diagram.diag

# Debug mode with verbose output
packetdiag --debug diagram.diag
```

### Advanced Command Options
```bash
# Size and quality control
packetdiag --size 1920x1080 diagram.diag
packetdiag --antialias diagram.diag
packetdiag --transparency diagram.diag

# Batch processing
for file in *.diag; do
  packetdiag "$file" -T svg
done

# Integration with build systems
make diagrams:
	packetdiag protocol.diag -o docs/images/protocol.png
	packetdiag packet-format.diag -T svg -o web/assets/packet.svg
```

### Python API Usage
```python
import packetdiag
from packetdiag import DiagramDraw
from packetdiag.parser import parse_string

# Parse diagram from string
diagram_text = """
packetdiag {
  0-15: Source Port
  16-31: Destination Port
}
"""

# Generate diagram
tree = parse_string(diagram_text)
draw = DiagramDraw('PNG', tree)
draw.draw()
draw.save('output.png')

# Programmatic diagram generation
from packetdiag.elements import DiagramTree, Field

# Create diagram programmatically
fields = [
    Field(0, 15, 'Source Port'),
    Field(16, 31, 'Destination Port')
]

diagram = DiagramTree('packet', fields)
draw = DiagramDraw('SVG', diagram)
draw.save('programmatic.svg')
```

## Comprehensive Protocol Examples

### TCP Header (Transmission Control Protocol)
```packetdiag
packetdiag {
  colwidth = 32
  node_height = 72
  default_fontsize = 12

  // TCP Header - RFC 793
  0-15: Source Port [color = "lightblue"]
  16-31: Destination Port [color = "lightblue"]
  32-63: Sequence Number [color = "lightgreen"]
  64-95: Acknowledgment Number [color = "lightgreen"]
  96-99: Data Offset [color = "yellow"]
  100-105: Reserved [color = "lightgray"]
  106: URG [color = "red"]
  107: ACK [color = "red"]
  108: PSH [color = "red"]
  109: RST [color = "red"]
  110: SYN [color = "red"]
  111: FIN [color = "red"]
  112-127: Window Size [color = "orange"]
  128-143: Checksum [color = "purple"]
  144-159: Urgent Pointer [color = "pink"]
  160-191: Options (variable length) [color = "lightcyan"]
}
```

### UDP Header (User Datagram Protocol)
```packetdiag
packetdiag {
  colwidth = 32
  node_height = 80
  default_fontsize = 14

  // UDP Header - RFC 768
  0-15: Source Port [color = "#E3F2FD"]
  16-31: Destination Port [color = "#E3F2FD"]
  32-47: Length [color = "#F3E5F5"]
  48-63: Checksum [color = "#E8F5E8"]
}
```

### IPv4 Header (Internet Protocol Version 4)
```packetdiag
packetdiag {
  colwidth = 32
  node_height = 64
  default_fontsize = 11

  // IPv4 Header - RFC 791
  0-3: Version [color = "#FFEBEE"]
  4-7: IHL [color = "#FFEBEE"]
  8-13: DSCP [color = "#F3E5F5"]
  14-15: ECN [color = "#F3E5F5"]
  16-31: Total Length [color = "#E8F5E8"]
  32-47: Identification [color = "#E3F2FD"]
  48-50: Flags [color = "#FFF3E0"]
  51-63: Fragment Offset [color = "#FFF3E0"]
  64-71: Time to Live [color = "#FAFAFA"]
  72-79: Protocol [color = "#FCE4EC"]
  80-95: Header Checksum [color = "#F1F8E9"]
  96-127: Source Address [color = "#E0F2F1"]
  128-159: Destination Address [color = "#E0F2F1"]
  160-191: Options (variable) [color = "#FFF8E1"]
}
```

### IPv6 Header (Internet Protocol Version 6)
```packetdiag
packetdiag {
  colwidth = 32
  node_height = 72
  default_fontsize = 12

  // IPv6 Header - RFC 8200
  0-3: Version [color = "#E1F5FE"]
  4-11: Traffic Class [color = "#E8EAF6"]
  12-31: Flow Label [color = "#F3E5F5"]
  32-47: Payload Length [color = "#E8F5E8"]
  48-55: Next Header [color = "#FFF3E0"]
  56-63: Hop Limit [color = "#FCE4EC"]
  64-191: Source Address (128 bits) [color = "#E0F2F1"]
  192-319: Destination Address (128 bits) [color = "#E0F7FA"]
}
```

### ICMP Header (Internet Control Message Protocol)
```packetdiag
packetdiag {
  colwidth = 32
  node_height = 80

  // ICMP Header - RFC 792
  0-7: Type [color = "#FFEBEE"]
  8-15: Code [color = "#FFEBEE"]
  16-31: Checksum [color = "#E8F5E8"]
  32-63: Rest of Header [color = "#E3F2FD"]
}
```

### Ethernet Frame Header
```packetdiag
packetdiag {
  colwidth = 32
  node_height = 64

  // Ethernet II Frame - IEEE 802.3
  0-47: Destination MAC [color = "#E1F5FE"]
  48-95: Source MAC [color = "#E0F2F1"]
  96-111: EtherType/Length [color = "#FFF3E0"]
}
```

### DNS Header (Domain Name System)
```packetdiag
packetdiag {
  colwidth = 32
  node_height = 60

  // DNS Header - RFC 1035
  0-15: Transaction ID [color = "#E3F2FD"]
  16: QR [color = "#FFEBEE"]
  17-20: Opcode [color = "#FFEBEE"]
  21: AA [color = "#FFEBEE"]
  22: TC [color = "#FFEBEE"]
  23: RD [color = "#FFEBEE"]
  24: RA [color = "#F3E5F5"]
  25-27: Z [color = "#F3E5F5"]
  28-31: RCODE [color = "#F3E5F5"]
  32-47: Questions [color = "#E8F5E8"]
  48-63: Answer RRs [color = "#E8F5E8"]
  64-79: Authority RRs [color = "#FFF3E0"]
  80-95: Additional RRs [color = "#FFF3E0"]
}
```

## Styling & Customization Options

### Color Schemes
```packetdiag
packetdiag {
  // Color by hex values
  0-7: Field A [color = "#FF6B6B"]
  8-15: Field B [color = "#4ECDC4"]

  // Color by names
  16-23: Field C [color = "lightblue"]
  24-31: Field D [color = "lightgreen"]

  // Gradient effects (with additional tools)
  32-47: Field E [color = "blue", textcolor = "white"]
}
```

### Font and Typography
```packetdiag
packetdiag {
  default_fontsize = 14
  default_font = "Arial"

  // Per-field font customization
  0-15: Header [fontsize = 16, textcolor = "bold"]
  16-31: Data [fontsize = 12, textcolor = "gray"]
}
```

### Layout Customization
```packetdiag
packetdiag {
  // Column width in bits
  colwidth = 32  // Standard 32-bit width
  colwidth = 16  // 16-bit width for narrow protocols
  colwidth = 64  // 64-bit width for modern protocols

  // Row height adjustment
  node_height = 72   // Standard height
  node_height = 96   // Taller for more text

  // Spacing and margins
  span_height = 40
  span_width = 128
}
```

### Advanced Styling
```packetdiag
packetdiag {
  // Background and borders
  node_style = "filled"
  background = "white"

  // Custom shapes for special fields
  0-7: Control [shape = "roundedbox"]
  8-15: Data [shape = "box"]

  // Conditional styling
  16-23: Optional [style = "dashed", color = "lightgray"]
  24-31: Required [style = "bold", color = "black"]
}
```

## Strengths & Advantages

### Technical Precision
- **Bit-level accuracy:** Exact field positioning down to individual bits
- **Standards compliance:** Follows RFC and IEEE protocol documentation standards
- **Mathematical precision:** No ambiguity in field boundaries or overlaps
- **Scalable resolution:** Vector output maintains clarity at any zoom level

### Professional Output
- **Publication quality:** Suitable for academic papers, technical specifications
- **Multiple formats:** PNG, SVG, PDF, EPS for different use cases
- **Print optimization:** High DPI support for professional printing
- **Web integration:** SVG output perfect for web documentation

### Workflow Integration
- **Version control friendly:** Text-based source files work well with Git
- **Automation ready:** Command-line interface enables CI/CD integration
- **Template system:** Reusable patterns for protocol families
- **Batch processing:** Generate multiple diagrams programmatically

### Educational Value
- **Clear visualization:** Makes complex protocols understandable
- **Interactive learning:** Easy to modify and experiment
- **Progressive complexity:** Start simple, add detail as needed
- **Cross-reference support:** Link diagrams to protocol specifications

## Limitations & Considerations

### Learning Curve
- **Syntax familiarity:** Requires learning packetdiag-specific syntax
- **Protocol knowledge:** Users need understanding of network protocols
- **Bit manipulation:** Comfort with binary and hexadecimal numbering
- **Layout constraints:** Limited flexibility compared to GUI tools

### Specialized Use Case
- **Network focus:** Primarily designed for packet/protocol diagrams
- **Technical audience:** Not suitable for general business diagrams
- **Static output:** No interactive or animated diagram support
- **Limited graphics:** Text and basic shapes only, no icons or illustrations

### Technical Limitations
- **Memory usage:** Large diagrams can consume significant memory
- **Font dependencies:** Limited by system font availability
- **Platform variations:** Slight rendering differences across platforms
- **Legacy support:** Some older Python versions may have compatibility issues

## Best Use Cases

### Network Protocol Documentation
- **RFC specifications:** Official protocol standard documentation
- **Protocol analysis:** Detailed examination of packet structures
- **Comparison studies:** Side-by-side protocol format analysis
- **Evolution tracking:** Document protocol changes over time

### Technical Education
- **Networking courses:** Computer science and engineering curricula
- **Certification training:** CCNA, CCNP, CCIE preparation materials
- **Workshop materials:** Hands-on network protocol workshops
- **Research presentations:** Academic conference presentations

### Professional Documentation
- **System design documents:** Network architecture specifications
- **Implementation guides:** Developer documentation for protocol handling
- **Troubleshooting guides:** Network diagnostic and analysis materials
- **Compliance documentation:** Regulatory and standards compliance proof

### Integration Scenarios
- **Wiki integration:** Technical wikis and knowledge bases
- **API documentation:** RESTful API and network service docs
- **Security documentation:** Protocol security analysis and penetration testing
- **Monitoring dashboards:** Network monitoring and alerting systems

## Troubleshooting & Best Practices

### Common Issues and Solutions

#### Installation Problems
```bash
# Issue: PIL/Pillow installation fails
# Solution: Install system dependencies first
sudo apt-get install libjpeg-dev libfreetype6-dev  # Ubuntu/Debian
brew install jpeg freetype  # macOS

# Issue: Font rendering problems
# Solution: Install font packages
sudo apt-get install fonts-liberation fonts-dejavu

# Issue: Permission errors
# Solution: Use virtual environment
python -m venv venv && source venv/bin/activate
```

#### Syntax Errors
```packetdiag
// Common syntax mistakes and fixes

// Wrong: Missing quotes for multi-word labels
0-15: Source Port  // ERROR

// Correct: Quote multi-word labels
0-15: "Source Port"  // CORRECT

// Wrong: Overlapping bit ranges
0-15: Field A
10-25: Field B  // ERROR: Overlap at bits 10-15

// Correct: Non-overlapping ranges
0-15: Field A
16-31: Field B  // CORRECT
```

#### Performance Optimization
```bash
# Large diagrams may be slow - optimize with:
packetdiag --antialias=false large-diagram.diag  # Faster rendering
packetdiag --dpi=72 large-diagram.diag           # Lower resolution
packetdiag -T svg large-diagram.diag             # Vector format
```

### Best Practices

#### Diagram Organization
```packetdiag
packetdiag {
  // Use consistent bit widths
  colwidth = 32  // Standard for most protocols

  // Group related fields with colors
  0-31: "Header Fields" [color = "lightblue"]
  32-63: "Control Fields" [color = "lightgreen"]
  64-95: "Data Fields" [color = "lightyellow"]

  // Use descriptive field names
  96-103: "Version (4 bits)" [color = "white"]
  104-111: "Header Length (4 bits)" [color = "white"]
}
```

#### Documentation Integration
```markdown
<!-- Markdown integration example -->
# Protocol Specification

## Packet Format
![TCP Header](tcp-header.png)

The TCP header format shown above includes:
- **Source/Destination Ports**: Connection endpoints
- **Sequence Numbers**: Data ordering and reliability
- **Control Flags**: Connection state management
```

#### Version Control Best Practices
```bash
# Organize diagram sources
protocols/
├── layer2/
│   ├── ethernet.diag
│   └── wifi.diag
├── layer3/
│   ├── ipv4.diag
│   └── ipv6.diag
└── layer4/
    ├── tcp.diag
    └── udp.diag

# Build script for automated generation
#!/bin/bash
for diag in $(find . -name "*.diag"); do
  packetdiag "$diag" -T svg
  packetdiag "$diag" -T png --dpi 150
done
```

## Advanced NPL-FIM Integration Patterns

### Protocol Visualization Templates
```npl
⟪NPL-FIM Protocol Template⟫
packetdiag {
  // Dynamic protocol specification
  protocol: {{protocol_name}}
  version: {{protocol_version}}
  rfc: {{rfc_number}}

  // Adaptive bit width based on protocol
  colwidth = {{#if is_64bit}}64{{else}}32{{/if}}
  node_height = {{field_height | default: 72}}

  // Color scheme by protocol family
  {{#if is_transport_layer}}
  default_color = "lightblue"
  {{else if is_network_layer}}
  default_color = "lightgreen"
  {{else}}
  default_color = "lightyellow"
  {{/if}}

  // Dynamic field generation
  {{#each packet_fields}}
  {{bit_start}}-{{bit_end}}: "{{field_name}}" [color = "{{field_color}}", description = "{{field_description}}"]
  {{/each}}

  // Optional fields handling
  {{#if has_options}}
  {{options_start}}-{{options_end}}: "Options ({{options_type}})" [style = "dashed", color = "lightgray"]
  {{/if}}
}
```

### Multi-Protocol Comparison
```npl
⟪NPL-FIM Comparison Template⟫
{{#each protocols}}
packetdiag {
  title = "{{protocol_name}} Header Format"

  {{#each fields}}
  {{bit_range}}: "{{name}}" [color = "{{semantic_color}}"]
  {{/each}}
}
{{/each}}

// Generate side-by-side comparison
⟨comparison_layout⟩
{{protocols | join_horizontal | output: "protocol-comparison.svg"}}
```

### Layer-Aware Protocol Stacks
```npl
⟪NPL-FIM Stack Visualization⟫
{{#protocol_stack}}
  {{#layer_2}}
  packetdiag {
    title = "Layer 2: {{protocol_name}}"
    {{>ethernet_template}}
  }
  {{/layer_2}}

  {{#layer_3}}
  packetdiag {
    title = "Layer 3: {{protocol_name}}"
    {{>ip_template}}
  }
  {{/layer_3}}

  {{#layer_4}}
  packetdiag {
    title = "Layer 4: {{protocol_name}}"
    {{>transport_template}}
  }
  {{/layer_4}}
{{/protocol_stack}}
```

### Security-Focused Protocol Analysis
```npl
⟪NPL-FIM Security Template⟫
packetdiag {
  // Highlight security-relevant fields
  {{#each security_fields}}
  {{bit_range}}: "{{field_name}}" [
    color = "{{#if is_encrypted}}red{{else if is_authenticated}}orange{{else}}yellow{{/if}}",
    security_level = "{{security_level}}",
    vulnerability = "{{known_vulnerabilities}}"
  ]
  {{/each}}

  // Attack vector annotations
  {{#each attack_vectors}}
  annotation: "{{vector_name}}" at {{target_fields}} [color = "red", style = "bold"]
  {{/each}}
}
```

### Performance Analysis Integration
```npl
⟪NPL-FIM Performance Template⟫
packetdiag {
  // Performance-critical field highlighting
  {{#each fields}}
  {{bit_range}}: "{{field_name}}" [
    color = "{{performance_color}}",
    processing_cost = "{{processing_complexity}}",
    cache_impact = "{{cache_behavior}}"
  ]
  {{/each}}

  // Optimization annotations
  {{#performance_notes}}
  note: "{{optimization_tip}}" [position = "{{field_position}}"]
  {{/performance_notes}}
}
```

### Documentation Workflow Integration
```npl
⟪NPL-FIM Documentation Pipeline⟫

// 1. Protocol specification extraction
{{protocol_spec | extract_fields | validate_ranges}}

// 2. Diagram generation with validation
packetdiag {
  {{>protocol_template}}

  // Automatic field validation
  {{#validate_bit_ranges fields}}
  {{#if overlap_detected}}
  error: "Bit range overlap in {{field_name}}"
  {{/if}}
  {{/validate_bit_ranges}}
}

// 3. Multi-format output generation
{{#output_formats}}
generate: {{format}} {
  resolution: {{#if print_quality}}300dpi{{else}}72dpi{{/if}}
  optimization: {{#if web_use}}web{{else}}print{{/if}}
}
{{/output_formats}}

// 4. Integration with documentation systems
{{#doc_systems}}
export_to: {{system_name}} {
  format: {{preferred_format}}
  embedding: {{embedding_method}}
  cross_reference: {{cross_ref_fields}}
}
{{/doc_systems}}
```

### Interactive Protocol Explorer
```npl
⟪NPL-FIM Interactive Template⟫
protocol_explorer {
  base_diagram: packetdiag {
    {{>base_protocol_template}}
  }

  // Interactive field details
  {{#each fields}}
  field_detail: "{{field_name}}" {
    description: "{{detailed_description}}"
    possible_values: [{{value_list}}]
    examples: [{{example_values}}]
    related_fields: [{{dependencies}}]

    // Conditional highlighting
    highlight_when: {
      value_range: {{highlight_range}}
      condition: "{{highlight_condition}}"
      color: "{{highlight_color}}"
    }
  }
  {{/each}}

  // Navigation between protocol layers
  layer_navigation: {
    {{#each related_protocols}}
    link: "{{protocol_name}}" {
      relationship: "{{relationship_type}}"
      diagram: "{{diagram_file}}"
    }
    {{/each}}
  }
}
```

### Testing and Validation Integration
```npl
⟪NPL-FIM Testing Template⟫
protocol_test_suite {
  base_protocol: {{protocol_name}}

  // Packet structure validation
  validation_tests: {
    {{#each test_cases}}
    test: "{{test_name}}" {
      input_packet: "{{hex_data}}"
      expected_fields: {
        {{#each expected_values}}
        {{field_name}}: {{expected_value}}
        {{/each}}
      }

      // Visual diff generation
      diagram_comparison: {
        expected: packetdiag { {{>expected_template}} }
        actual: packetdiag { {{>actual_template}} }
        diff_highlight: {{diff_fields}}
      }
    }
    {{/each}}
  }

  // Performance benchmarking
  performance_tests: {
    {{#each perf_tests}}
    benchmark: "{{test_name}}" {
      packet_size: {{packet_size}}
      field_count: {{field_count}}
      generation_time: {{time_limit}}
      memory_usage: {{memory_limit}}
    }
    {{/each}}
  }
}
```

### Educational Progression Templates
```npl
⟪NPL-FIM Educational Template⟫
learning_progression {
  // Basic introduction
  level_1: {
    title: "Basic {{protocol_name}} Structure"
    diagram: packetdiag {
      // Simplified view with essential fields only
      {{#each essential_fields}}
      {{bit_range}}: "{{simple_name}}" [color = "{{basic_color}}"]
      {{/each}}
    }
    explanation: "{{basic_explanation}}"
  }

  // Intermediate detail
  level_2: {
    title: "Detailed {{protocol_name}} Fields"
    diagram: packetdiag {
      // All standard fields with descriptions
      {{#each standard_fields}}
      {{bit_range}}: "{{field_name}}" [
        color = "{{field_color}}",
        tooltip = "{{field_description}}"
      ]
      {{/each}}
    }
    explanation: "{{detailed_explanation}}"
  }

  // Advanced analysis
  level_3: {
    title: "Advanced {{protocol_name}} Analysis"
    diagram: packetdiag {
      // Complete view with extensions and options
      {{#each all_fields}}
      {{bit_range}}: "{{field_name}}" [
        color = "{{advanced_color}}",
        complexity = "{{field_complexity}}",
        use_cases = "{{field_use_cases}}"
      ]
      {{/each}}
    }
    explanation: "{{advanced_explanation}}"
  }
}
```

## NPL-FIM Usage Examples

### Basic Protocol Documentation
```bash
# Generate protocol family documentation
npl-fim generate --template=protocol-family \
  --input=tcp-udp-spec.yaml \
  --output=transport-protocols/

# Create interactive protocol explorer
npl-fim interactive --protocol=tcp \
  --layers=2,3,4 \
  --output=tcp-explorer.html
```

### Batch Protocol Analysis
```bash
# Analyze all protocols in specification directory
npl-fim batch-analyze --input=specs/ \
  --template=security-analysis \
  --output=security-report/

# Generate comparison matrix
npl-fim compare --protocols=tcp,udp,sctp \
  --aspects=performance,security,complexity \
  --output=protocol-comparison.pdf
```

### Educational Content Generation
```bash
# Create progressive learning materials
npl-fim educational --protocol=ipv6 \
  --levels=basic,intermediate,advanced \
  --format=html,pdf \
  --output=ipv6-course/

# Generate quiz materials
npl-fim quiz-gen --protocols=ethernet,ip,tcp \
  --question-types=identification,analysis \
  --output=networking-quiz.json
```

This comprehensive enhancement provides the depth and breadth required for NPL-FIM to effectively generate network protocol diagrams, covering everything from basic usage to advanced integration patterns, educational applications, and professional documentation workflows.