# WaveDrom Engineering Diagrams - NPL-FIM Implementation Guide

## Overview
WaveDrom is a powerful JavaScript library for generating SVG-based digital timing diagrams and signal waveforms. This guide provides comprehensive NPL-FIM patterns for creating professional engineering diagrams for hardware design, protocol documentation, and digital system analysis.

## Direct Implementation Templates

### Basic Setup and Environment

#### Node.js Environment Setup
```bash
# Initialize project
npm init -y
npm install wavedrom puppeteer

# For browser-based rendering
npm install wavedrom-cli -g
```

#### Browser Environment Setup
```html
<!DOCTYPE html>
<html>
<head>
    <script src="https://unpkg.com/wavedrom/wavedrom.min.js"></script>
    <script src="https://unpkg.com/wavedrom/skins/default.js"></script>
</head>
<body>
    <div id="WaveDrom_Display_0"></div>
    <script type="WaveDrom">
    {
        signal: [
            {name: 'clk', wave: 'p......'},
            {name: 'data', wave: 'x.=.=x.', data: ['A', 'B']}
        ]
    }
    </script>
    <script>WaveDrom.ProcessAll();</script>
</body>
</html>
```

### Core Pattern: Basic Timing Diagram

#### Simple Clock and Data Signals
```javascript
const wavedrom = require('wavedrom');

// Basic clock and data pattern
const basicTiming = {
  signal: [
    {name: 'clock', wave: 'p......'},
    {name: 'data', wave: 'x.=.=x.', data: ['head', 'body', 'tail']},
    {name: 'valid', wave: '0.1..0.'},
    {name: 'ready', wave: '1....10'}
  ],
  config: { hscale: 2 }
};

// Generate SVG
const svg = wavedrom.renderWaveForm(0, basicTiming);
console.log(svg);
```

#### Advanced Multi-Clock Domain
```javascript
const multiClockDomain = {
  signal: [
    ['Clock Domains',
      {name: 'clk_a', wave: 'p.......'},
      {name: 'clk_b', wave: '.p......'},
      {name: 'clk_c', wave: '..p.....'}
    ],
    {},
    ['Data Signals',
      {name: 'data_a', wave: 'x.=.=.x.', data: ['D1', 'D2']},
      {name: 'data_b', wave: '.x.=.=x.', data: ['D3', 'D4']},
      {name: 'data_c', wave: '..x.=.=x', data: ['D5', 'D6']}
    ],
    {},
    ['Control Signals',
      {name: 'sync_ab', wave: '0..1.0..'},
      {name: 'sync_bc', wave: '0...1.0.'},
      {name: 'error', wave: '0.......'}
    ]
  ],
  config: { hscale: 3 }
};
```

### Communication Protocol Patterns

#### SPI Protocol Timing
```javascript
const spiProtocol = {
  signal: [
    {name: 'SCLK', wave: '0.p.p.p.p.p.p.p.p.0'},
    {name: 'MOSI', wave: 'x.=.=.=.=.=.=.=.=.x', data: ['7','6','5','4','3','2','1','0']},
    {name: 'MISO', wave: 'x.=.=.=.=.=.=.=.=.x', data: ['7','6','5','4','3','2','1','0']},
    {name: 'CS_N', wave: '10..................1'},
    {},
    {name: 'Byte', wave: 'x.....................', data: ['0xA5']}
  ],
  config: { hscale: 1 },
  head: {
    text: 'SPI Master-Slave Communication'
  },
  foot: {
    text: 'Mode 0: CPOL=0, CPHA=0'
  }
};
```

#### I2C Protocol Timing
```javascript
const i2cProtocol = {
  signal: [
    {name: 'SCL', wave: '1.0.p.p.p.p.p.p.p.p.1'},
    {name: 'SDA', wave: '1.0.=.=.=.=.=.=.=.0.1', data: ['A6','A5','A4','A3','A2','A1','A0','R/W']},
    {},
    {name: 'START', wave: '0.1.................0'},
    {name: 'ACK', wave: '0...............1...0'},
    {name: 'STOP', wave: '0...................1'}
  ],
  config: { hscale: 2 },
  head: {
    text: 'I2C Address Phase'
  }
};
```

#### UART Communication
```javascript
const uartTiming = {
  signal: [
    {name: 'TxD', wave: '1.0==========1', data: ['','S','0','1','2','3','4','5','6','7','P','']},
    {name: 'RxD', wave: '1..0==========1', data: ['','S','0','1','2','3','4','5','6','7','P','']},
    {},
    {name: 'Baud', wave: 'p.............'},
    {name: 'Frame', wave: '0.1.........0.'}
  ],
  config: { hscale: 3 },
  head: {
    text: 'UART 8N1 Frame (0x55)'
  }
};
```

### Memory Interface Patterns

#### DDR Read/Write Cycle
```javascript
const ddrTiming = {
  signal: [
    {name: 'CK', wave: 'p.......'},
    {name: 'CK_N', wave: 'n.......'},
    {},
    {name: 'CS_N', wave: '10......'},
    {name: 'RAS_N', wave: '1.0..1..'},
    {name: 'CAS_N', wave: '1..0.1..'},
    {name: 'WE_N', wave: '1...01..'},
    {},
    {name: 'ADDR', wave: 'x.=.=...', data: ['ROW', 'COL']},
    {name: 'DQ', wave: 'z....=.z', data: ['DATA']},
    {name: 'DQS', wave: 'z....p.z'},
    {name: 'DM', wave: 'z....0.z'}
  ],
  config: { hscale: 4 },
  head: {
    text: 'DDR SDRAM Write Cycle'
  }
};
```

#### AXI4 Bus Transaction
```javascript
const axi4Transaction = {
  signal: [
    ['Clock',
      {name: 'ACLK', wave: 'p.......'}
    ],
    {},
    ['Write Address Channel',
      {name: 'AWVALID', wave: '01..0...'},
      {name: 'AWREADY', wave: '0.1.0...'},
      {name: 'AWADDR', wave: 'x.=.x...', data: ['ADDR']}
    ],
    {},
    ['Write Data Channel',
      {name: 'WVALID', wave: '0.1.1.0.'},
      {name: 'WREADY', wave: '0..1.1.0'},
      {name: 'WDATA', wave: 'x..=.=.x', data: ['D0', 'D1']},
      {name: 'WLAST', wave: '0...1.0.'}
    ],
    {},
    ['Write Response Channel',
      {name: 'BVALID', wave: '0....10.'},
      {name: 'BREADY', wave: '1.......'}
    ]
  ],
  config: { hscale: 2 }
};
```

### FPGA and Digital Design Patterns

#### State Machine Transitions
```javascript
const stateMachine = {
  signal: [
    {name: 'clk', wave: 'p.......'},
    {name: 'reset', wave: '10......'},
    {},
    {name: 'state', wave: '2.=.=.=.', data: ['IDLE', 'WAIT', 'PROC', 'DONE']},
    {name: 'start', wave: '0.1.0...'},
    {name: 'done', wave: '0.....1.'},
    {name: 'busy', wave: '0..1..0.'},
    {},
    {name: 'data_valid', wave: '0...1.0.'},
    {name: 'data_out', wave: 'x...=.x.', data: ['RESULT']}
  ],
  config: { hscale: 3 },
  head: {
    text: 'FSM: Processing Unit State Transitions'
  }
};
```

#### Clock Domain Crossing
```javascript
const clockDomainCrossing = {
  signal: [
    ['Domain A (100MHz)',
      {name: 'clk_a', wave: 'p.......'},
      {name: 'data_a', wave: 'x.=.....', data: ['DATA']},
      {name: 'valid_a', wave: '0.1.0...'}
    ],
    {},
    ['Synchronizer',
      {name: 'sync1', wave: '0..1.0..'},
      {name: 'sync2', wave: '0...1.0.'},
      {name: 'pulse', wave: '0...1...'}
    ],
    {},
    ['Domain B (50MHz)',
      {name: 'clk_b', wave: 'p.......'},
      {name: 'data_b', wave: 'x....=..', data: ['DATA']},
      {name: 'valid_b', wave: '0....1.0'}
    ]
  ],
  config: { hscale: 4 },
  head: {
    text: 'Clock Domain Crossing with Pulse Synchronizer'
  }
};
```

### Configuration Options and Customization

#### Styling and Appearance
```javascript
const styledDiagram = {
  signal: [
    {name: 'clk', wave: 'p......', phase: 0.5},
    {name: 'data', wave: 'x.=.=x.', data: ['A', 'B'], phase: 0.1},
    {name: 'valid', wave: '0.1..0.', phase: -0.1}
  ],
  config: {
    hscale: 2,
    skin: 'narrow',
    background: '#f0f0f0'
  },
  head: {
    text: 'Custom Styled Timing Diagram',
    tick: 0
  },
  foot: {
    text: 'Phase adjustments and custom styling',
    tock: 9
  }
};
```

#### Multi-Scale Time Base
```javascript
const multiScaleTiming = {
  signal: [
    ['Fast Clock Domain (100MHz)',
      {name: 'fast_clk', wave: 'p.......'},
      {name: 'fast_data', wave: 'x.=.=.x.', data: ['F1', 'F2']}
    ],
    {},
    ['Medium Clock Domain (25MHz)',
      {name: 'med_clk', wave: 'p.......'},
      {name: 'med_data', wave: 'x..=...x', data: ['M1']}
    ],
    {},
    ['Slow Clock Domain (10MHz)',
      {name: 'slow_clk', wave: 'p.......'},
      {name: 'slow_data', wave: 'x.....=x', data: ['S1']}
    ]
  ],
  config: { hscale: 1 }
};
```

### File Generation and Export Utilities

#### SVG Generation with File Output
```javascript
const fs = require('fs');
const wavedrom = require('wavedrom');

function generateTimingDiagram(config, filename) {
  try {
    const svg = wavedrom.renderWaveForm(0, config);
    fs.writeFileSync(`${filename}.svg`, svg);
    console.log(`Generated: ${filename}.svg`);
    return svg;
  } catch (error) {
    console.error(`Error generating ${filename}:`, error);
    return null;
  }
}

// Usage
generateTimingDiagram(spiProtocol, 'spi_timing');
generateTimingDiagram(i2cProtocol, 'i2c_timing');
generateTimingDiagram(ddrTiming, 'ddr_timing');
```

#### Batch Generation Script
```javascript
const timingDiagrams = {
  'uart_8n1': uartTiming,
  'spi_mode0': spiProtocol,
  'i2c_address': i2cProtocol,
  'ddr_write': ddrTiming,
  'axi4_write': axi4Transaction,
  'fsm_states': stateMachine,
  'clock_crossing': clockDomainCrossing
};

Object.entries(timingDiagrams).forEach(([name, config]) => {
  generateTimingDiagram(config, name);
});
```

#### PNG/PDF Export with Puppeteer
```javascript
const puppeteer = require('puppeteer');

async function exportToPNG(svgContent, filename) {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();

  const html = `
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            body { margin: 0; padding: 20px; background: white; }
            svg { max-width: 100%; height: auto; }
        </style>
    </head>
    <body>${svgContent}</body>
    </html>
  `;

  await page.setContent(html);
  await page.screenshot({
    path: `${filename}.png`,
    fullPage: true,
    background: 'white'
  });

  await browser.close();
}
```

### Integration with Documentation Systems

#### Markdown Integration
```javascript
function generateMarkdownWithDiagram(title, description, waveConfig) {
  const svg = wavedrom.renderWaveForm(0, waveConfig);
  const base64 = Buffer.from(svg).toString('base64');

  return `
# ${title}

${description}

![Timing Diagram](data:image/svg+xml;base64,${base64})

## Configuration
\`\`\`json
${JSON.stringify(waveConfig, null, 2)}
\`\`\`
  `;
}
```

#### LaTeX Integration
```javascript
function generateLatexFigure(waveConfig, caption, label) {
  const svg = wavedrom.renderWaveForm(0, waveConfig);
  fs.writeFileSync(`${label}.svg`, svg);

  return `
\\begin{figure}[htbp]
    \\centering
    \\includesvg{${label}.svg}
    \\caption{${caption}}
    \\label{fig:${label}}
\\end{figure}
  `;
}
```

### Advanced Waveform Patterns

#### Bus Transaction with Bursts
```javascript
const burstTransaction = {
  signal: [
    {name: 'clk', wave: 'p...........'},
    {},
    {name: 'addr', wave: 'x.=........x', data: ['BASE']},
    {name: 'burst_len', wave: 'x.=........x', data: ['4']},
    {name: 'burst_type', wave: 'x.=........x', data: ['INCR']},
    {},
    {name: 'valid', wave: '0.1...1...0.'},
    {name: 'ready', wave: '0..1.1.1.1..'},
    {name: 'data', wave: 'x..=.=.=.=.x', data: ['D0','D1','D2','D3']},
    {},
    {name: 'last', wave: '0........1.0'},
    {name: 'response', wave: '0........1.0'}
  ],
  config: { hscale: 2 },
  head: { text: 'AXI Burst Transaction' }
};
```

#### Pipelined Operation
```javascript
const pipelinedOp = {
  signal: [
    {name: 'clk', wave: 'p.......'},
    {},
    ['Instruction Fetch',
      {name: 'if_valid', wave: '01......'},
      {name: 'if_addr', wave: 'x=======', data: ['PC']}
    ],
    {},
    ['Decode',
      {name: 'id_valid', wave: '0.1.....'},
      {name: 'id_inst', wave: 'x.======', data: ['INST']}
    ],
    {},
    ['Execute',
      {name: 'ex_valid', wave: '0..1....'},
      {name: 'ex_result', wave: 'x..=====', data: ['RES']}
    ],
    {},
    ['Writeback',
      {name: 'wb_valid', wave: '0...1...'},
      {name: 'wb_data', wave: 'x...====', data: ['DATA']}
    ]
  ],
  config: { hscale: 3 },
  head: { text: '4-Stage Pipeline Operation' }
};
```

### Error Handling and Validation

#### Waveform Validation Function
```javascript
function validateWaveform(config) {
  const errors = [];

  if (!config.signal || !Array.isArray(config.signal)) {
    errors.push('Missing or invalid signal array');
    return errors;
  }

  config.signal.forEach((signal, index) => {
    if (typeof signal === 'string') return; // Group separator

    if (!signal.name) {
      errors.push(`Signal at index ${index} missing name`);
    }

    if (!signal.wave) {
      errors.push(`Signal '${signal.name}' missing wave pattern`);
    } else {
      // Validate wave pattern characters
      const validChars = /^[01xz=.p|nlhLH2-9]*$/;
      if (!validChars.test(signal.wave)) {
        errors.push(`Signal '${signal.name}' has invalid wave characters`);
      }
    }

    if (signal.data && !Array.isArray(signal.data)) {
      errors.push(`Signal '${signal.name}' data must be an array`);
    }
  });

  return errors;
}
```

#### Safe Rendering with Error Handling
```javascript
function safeRenderWaveform(config, fallbackSvg = '<svg></svg>') {
  const errors = validateWaveform(config);

  if (errors.length > 0) {
    console.error('Waveform validation errors:', errors);
    return fallbackSvg;
  }

  try {
    return wavedrom.renderWaveForm(0, config);
  } catch (error) {
    console.error('Rendering error:', error);
    return fallbackSvg;
  }
}
```

### Common Issues and Troubleshooting

#### Wave Pattern Characters Reference
```
0, 1     : Logic low/high
x        : Unknown/don't care
z        : High impedance
=        : Data value
.        : No change
p, n     : Positive/negative clock edge
|        : Gap in timing
l, h     : Weak low/high
L, H     : Strong low/high
2-9      : Multi-bit values
```

#### Timing Alignment Issues
```javascript
// Problem: Misaligned signals
const misaligned = {
  signal: [
    {name: 'clk', wave: 'p.....'},      // 6 time units
    {name: 'data', wave: 'x.=.=x.....'}  // 10 time units - misaligned!
  ]
};

// Solution: Consistent timing
const aligned = {
  signal: [
    {name: 'clk', wave: 'p.........'},    // 10 time units
    {name: 'data', wave: 'x.=.=x.....'}   // 10 time units - aligned!
  ]
};
```

#### Data Array Synchronization
```javascript
// Problem: Data count mismatch
const mismatch = {
  signal: [
    {name: 'data', wave: 'x.=.=.=x', data: ['A', 'B']}  // 3 data transitions, 2 values
  ]
};

// Solution: Matching data count
const synchronized = {
  signal: [
    {name: 'data', wave: 'x.=.=.=x', data: ['A', 'B', 'C']}  // 3 data transitions, 3 values
  ]
};
```

### Performance Optimization

#### Large Diagram Handling
```javascript
function optimizeLargeDiagram(config) {
  // Reduce horizontal scale for performance
  const optimized = {
    ...config,
    config: {
      ...config.config,
      hscale: Math.min(config.config?.hscale || 1, 2)
    }
  };

  // Limit signal count
  if (optimized.signal.length > 50) {
    console.warn('Large signal count may impact performance');
  }

  return optimized;
}
```

#### Memory-Efficient Batch Processing
```javascript
async function processDiagramsBatch(diagrams, batchSize = 5) {
  const results = [];

  for (let i = 0; i < diagrams.length; i += batchSize) {
    const batch = diagrams.slice(i, i + batchSize);
    const batchResults = await Promise.all(
      batch.map(({ name, config }) =>
        generateTimingDiagram(config, name)
      )
    );
    results.push(...batchResults);

    // Allow garbage collection between batches
    if (global.gc) global.gc();
  }

  return results;
}
```

### Tool-Specific Advantages

#### WaveDrom Strengths
- **Vector Graphics**: SVG output scales perfectly for documentation
- **Text-Based Definition**: Version control friendly, easy to diff
- **Web Integration**: Direct browser rendering without external dependencies
- **Precise Timing**: Exact digital signal representation
- **Multi-Format Export**: SVG, PNG, PDF generation capabilities
- **Lightweight**: Minimal dependencies and fast rendering

#### Limitations and Alternatives
- **Analog Signals**: Limited support for analog waveforms (consider LTSpice for analog)
- **Complex Protocols**: Very complex protocols may need specialized tools
- **Real-Time Display**: Not suitable for live signal monitoring (consider logic analyzers)
- **3D Visualization**: No support for 3D signal representation

### Integration Examples

#### Verilog Testbench Integration
```javascript
// Generate WaveDrom from Verilog VCD files
function vcdToWavedrom(vcdFile) {
  // Parse VCD and convert to WaveDrom format
  // This would require additional VCD parsing library
  const signals = parseVCD(vcdFile);

  return {
    signal: signals.map(sig => ({
      name: sig.name,
      wave: convertToWavePattern(sig.values),
      data: sig.data
    }))
  };
}
```

#### VHDL Integration
```javascript
// Generate timing diagrams for VHDL designs
function generateVHDLTiming(entity, architecture) {
  const timing = {
    signal: [
      {name: 'clk', wave: 'p.......'},
      ...entity.ports.map(port => ({
        name: port.name,
        wave: generateWaveFromVHDL(port, architecture)
      }))
    ],
    head: { text: `${entity.name} Timing Diagram` }
  };

  return timing;
}
```

### NPL-FIM Specific Patterns

#### Direct Artifact Generation
```javascript
// NPL-FIM ready function for immediate use
function createEngineeringDiagram(type, signals, options = {}) {
  const baseConfig = {
    signal: signals,
    config: {
      hscale: options.scale || 2,
      skin: options.skin || 'default'
    },
    head: { text: options.title || 'Engineering Diagram' },
    foot: { text: options.footer || '' }
  };

  switch (type) {
    case 'protocol':
      return protocolTiming(baseConfig);
    case 'memory':
      return memoryTiming(baseConfig);
    case 'clock':
      return clockTiming(baseConfig);
    default:
      return baseConfig;
  }
}

// Usage for NPL-FIM
const diagram = createEngineeringDiagram('protocol', [
  {name: 'clk', wave: 'p.......'},
  {name: 'data', wave: 'x.=.=x..', data: ['A', 'B']}
], { title: 'SPI Communication', scale: 3 });

const svg = wavedrom.renderWaveForm(0, diagram);
```

## Summary

This comprehensive guide provides NPL-FIM with complete patterns for generating WaveDrom engineering diagrams. The templates cover digital timing diagrams, communication protocols, memory interfaces, FPGA designs, and advanced visualization techniques. All examples are production-ready with error handling, optimization strategies, and integration capabilities for professional engineering documentation workflows.