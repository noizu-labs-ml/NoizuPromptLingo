# seqdiag

**Category**: Sequence Diagram Generation
**Type**: Text-to-Diagram
**Output**: PNG, SVG, PDF sequence diagrams

## Description

seqdiag is part of the blockdiag toolkit that generates UML sequence diagrams from simple text descriptions. It provides a minimalist syntax for creating clean, professional sequence diagrams without complex markup.

**Links**:
- [blockdiag.com](http://blockdiag.com/en/seqdiag/)
- [Documentation](http://blockdiag.com/en/seqdiag/examples.html)
- [GitHub Repository](https://github.com/blockdiag/seqdiag)

## Installation

```bash
pip install seqdiag
```

Optional imaging dependencies:
```bash
pip install pillow reportlab
```

## Basic Syntax

```seqdiag
seqdiag {
  // Actors
  browser; server; database;

  // Interactions
  browser -> server [label = "HTTP Request"];
  server -> database [label = "Query"];
  database -> server [label = "Results"];
  server -> browser [label = "HTTP Response"];
}
```

### Advanced Features

```seqdiag
seqdiag {
  activation = none;

  user; app; auth; db;

  user -> app [label = "login"];
  app -> auth [label = "authenticate"];
  auth -> db [label = "verify"];
  db -> auth [return = "user data"];
  auth -> app [return = "token"];
  app -> user [return = "success"];

  user -> app [label = "request"];
  app -> db [label = "query", activate];
  db -> app [return = "data", deactivate];
  app -> user [return = "response"];
}
```

## Strengths

- **Simple Syntax**: Minimal markup for quick diagram creation
- **Clean Output**: Professional-looking UML sequence diagrams
- **Multiple Formats**: PNG, SVG, PDF output options
- **Lightweight**: Fast rendering for simple sequences
- **Standard UML**: Follows UML sequence diagram conventions

## Limitations

- **Basic Styling**: Limited customization options
- **No Web Rendering**: Requires image generation, no interactive output
- **Simple Features**: Lacks advanced UML features like fragments
- **Python Dependency**: Requires Python environment
- **Static Output**: No interactive or animated sequences

## Best For

- **UML Documentation**: Creating standard UML sequence diagrams
- **API Documentation**: Illustrating request/response flows
- **System Design**: Documenting component interactions
- **Quick Prototyping**: Rapid sequence diagram creation
- **Print Documentation**: Generating diagrams for static documents

## NPL-FIM Integration

```npl
seqdiag_sequence: ⟪
  actors: [user, server, database]
  interactions: [
    user→server: "request",
    server→database: "query",
    database→server: "data",
    server→user: "response"
  ]
⟫
```

**Rendering**: `seqdiag input.seq -T svg -o output.svg`
**Use Case**: UML sequence documentation in technical specifications