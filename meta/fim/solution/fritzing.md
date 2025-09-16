# Fritzing

## Overview
Electronics design tool for breadboard, schematic, and PCB views. Beginner-friendly with part library.

## Installation
```bash
# Ubuntu/Debian
apt-get install fritzing

# macOS
brew install --cask fritzing

# Windows/All platforms
# Download from fritzing.org
```

## File Format
```xml
<?xml version="1.0" encoding="UTF-8"?>
<module fritzingVersion="0.9.3">
  <boards>
    <board moduleId="Arduino_Uno_Rev3"/>
  </boards>
  <parts>
    <part id="R1" type="resistor" value="10k"/>
    <part id="LED1" type="LED" color="red"/>
  </parts>
</module>
```

## Strengths
- Breadboard view
- Beginner-friendly
- Part library
- PCB export
- Arduino integration

## Limitations
- Not for complex designs
- Limited simulation
- Basic schematic capture
- Proprietary format

## NPL-FIM Integration
```yaml
renderer: fritzing
views: [breadboard, schematic, pcb]
export: svg|png|pdf|gerber
parts: fritzing_library
```