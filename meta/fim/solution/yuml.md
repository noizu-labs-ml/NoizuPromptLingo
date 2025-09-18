# yUML
Simple online UML diagram service using text descriptions. [Docs](https://yuml.me/) | [Syntax Guide](https://yuml.me/diagram/scruffy/class/samples)

## Basic Usage
```text
# Class Diagram
[Customer]<>-orders*>[Order]
[Order]++-1>[LineItem]
[Order]-[note: Aggregate root{bg:wheat}]

# Use Case Diagram
[Customer]-(Login)
[Customer]-(Browse Products)
(Browse Products)<(View Details)
(Login)<(Reset Password)
```

## API Usage
```html
<!-- Direct embedding -->
<img src="https://yuml.me/diagram/scruffy/class/[Customer]->[Order]">

<!-- With styling -->
<img src="https://yuml.me/diagram/nofunky/usecase/(Customer)-(Login)">
```

## Strengths
- No installation or setup required
- Direct URL-based diagram generation
- Simple, intuitive syntax
- Embeddable in any HTML/Markdown via image tags
- Multiple visual styles (scruffy, plain, nofunky)

## Limitations
- Limited to class, activity, and use case diagrams
- No sequence diagrams
- Basic styling options only
- No local rendering (requires internet)
- Limited to simple relationships

## Best For
`quick-sketches`, `documentation`, `teaching`, `blog-posts`, `README-diagrams`

## NPL-FIM Integration
```yaml
fim_mode: yuml_diagram
request: |
  Generate a class diagram showing:
  - User entity with email, password
  - Post entity with title, content
  - One-to-many relationship
response: |
  [User|email;password]1-*>[Post|title;content;created_at]
  [Post]->[note: Blog posts{bg:cornsilk}]
render_url: https://yuml.me/diagram/scruffy/class/[diagram]
```

## Quick Examples
```text
# Activity Diagram
(start)-><a>[kettle empty]->(Fill Kettle)->|b|
<a>[kettle full]->|b|->(Boil Water)->(end)

# Styled Class Diagram
[User|+name;+email|login();logout(){bg:steelblue}]
[Admin]^[User]
[Guest]^[User]
```