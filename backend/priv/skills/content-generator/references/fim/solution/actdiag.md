# actdiag

Activity diagram generator from the blockdiag family that creates process flow diagrams from simple text syntax.

## Description

actdiag is part of the blockdiag suite that generates activity diagrams from text descriptions. It focuses on process flows with activities, decisions, and transitions. The tool produces clean SVG, PNG, or PDF outputs with automatic layout management.

**Official Documentation**: http://blockdiag.com/en/actdiag/

## Installation

```bash
pip install actdiag
```

Optional dependencies for enhanced output:
```bash
pip install actdiag[pdf]  # PDF support
pip install Pillow        # PNG support
```

## Basic Syntax

```actdiag
actdiag {
  A -> B -> C;

  lane user {
    label = "User";
    A [label = "Login"];
    B [label = "Select Item"];
  }

  lane system {
    label = "System";
    C [label = "Process Order"];
    D [label = "Send Email"];
  }

  B -> D;
}
```

## Key Features

- **Automatic Layout**: Handles positioning and routing automatically
- **Lane Support**: Organize activities into swimlanes
- **Decision Points**: Diamond shapes for branching logic
- **Styling Options**: Colors, fonts, and shapes customization
- **Multiple Outputs**: SVG, PNG, PDF formats

## Strengths

- Simple text-based syntax
- Automatic layout eliminates manual positioning
- Good for standard process documentation
- Integrates well with documentation pipelines
- Consistent styling across diagrams

## Limitations

- Basic feature set compared to specialized tools
- Limited customization options
- No interactive elements
- Simple styling capabilities
- Fixed layout algorithms

## Best Use Cases

- Business process documentation
- Workflow specifications
- Simple activity flows
- Technical documentation
- Process standardization

## NPL-FIM Integration

### In NPL Prompts
```npl
⟪actdiag:workflow⟫ → Generate process flow using actdiag syntax
⟪actdiag:lanes⟫ → Create swimlane activity diagram
```

### Code Generation
```python
def generate_actdiag(process_steps):
    return f"""
actdiag {{
  {" -> ".join(process_steps)};

  lane user {{
    label = "User";
    {process_steps[0]} [label = "Start Process"];
  }}

  lane system {{
    label = "System";
    {process_steps[-1]} [label = "Complete Process"];
  }}
}}
"""
```

### Rendering Pipeline
```bash
actdiag diagram.diag -T svg -o output.svg
```

## Output Example

Input text generates clean activity diagrams with automatic layout, making it suitable for process documentation and workflow visualization in technical specifications.