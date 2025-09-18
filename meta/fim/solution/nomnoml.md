# nomnoml
Minimalist UML sketch tool with hand-drawn aesthetic. [Docs](https://nomnoml.com) | [Examples](https://github.com/skanaar/nomnoml#examples)

## Install/Setup
```bash
# npm package
npm install nomnoml

# CDN for browser
<script src="https://unpkg.com/nomnoml"></script>

# VS Code extension
ext install doctorrokter.nomnoml

# Online editor
# https://nomnoml.com
```

## Basic Usage
```nomnoml
#direction: right
#spacing: 60
#padding: 8
#fontSize: 14
#fill: #fdf6e3; #eee8d5

[<start> User] -> [Login Screen]
[Login Screen] -> [<choice> Auth?]

[Auth?] yes -> [Dashboard]
[Auth?] no -> [Error Page]

[Dashboard] -> [<database> User Data]
[Dashboard] -> [Settings]

[<actor> User|
  name: string
  email: string|
  login()
  logout()
]

[Settings|
  theme
  language|
  save()
  reset()
]
```

## Strengths
- Clean, minimalist syntax
- Attractive hand-drawn rendering style
- Fast rendering and lightweight
- Good for quick conceptual diagrams
- Supports custom styling directives

## Limitations
- Limited diagram types (mainly class and flowchart)
- No sequence diagram support
- Basic styling options compared to other tools
- Small ecosystem and community

## Best For
`quick-sketches`, `conceptual-diagrams`, `class-diagrams`, `simple-flowcharts`, `documentation-visuals`