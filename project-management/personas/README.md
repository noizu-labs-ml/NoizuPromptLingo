# TheRobotPaints — User Personas

## Primary Personas (drive core design decisions)

| # | Name | Archetype | Primary Media | Key Need |
|---|------|-----------|---------------|----------|
| 1 | [Maya Chen](01-maya-chen.md) | Digital Illustrator | Watercolor | Authentic flow dynamics and paper interaction |
| 2 | [David Okafor](02-david-okafor.md) | Traditional Painter Going Digital | Oil | Impasto depth and absorptive color mixing |
| 3 | [Lena Vasquez](03-lena-vasquez.md) | Concept Artist | Mixed media | Fast multi-media iteration at 4K |

## Secondary Personas (inform but don't drive)

| # | Name | Archetype | Primary Media | Key Need |
|---|------|-----------|---------------|----------|
| 4 | [James Whitfield](04-james-whitfield.md) | Art Educator | Watercolor | Inspectable simulation for teaching |
| 5 | [Suki Tanaka](05-suki-tanaka.md) | Hobbyist / Therapeutic | Any | Zero-friction, minimal UI, mouse/trackpad |
| 6 | [Alex Kirchner](06-alex-kirchner.md) | Technical Artist / Shader Dev | Custom | Modifiable shader source, debug viz |
| 7 | [Priya Sharma](07-priya-sharma.md) | Plein Air Sketch Artist | Charcoal + wash | Sub-16ms latency, compact UI |

## Design Tensions

These personas surface real trade-offs:

- **Power vs simplicity** — Lena/Alex want parameters exposed; Suki wants them hidden
- **Fidelity vs speed** — David wants slow-drying oil realism; Priya wants instant-dry shortcuts
- **Teaching vs creating** — James wants step-through simulation; Maya wants uninterrupted flow
- **Professional vs casual** — Maya/Lena need 4K export; Suki shares screenshots

## Coverage Map

| App Feature | Maya | David | Lena | James | Suki | Alex | Priya |
|-------------|:----:|:-----:|:----:|:-----:|:----:|:----:|:-----:|
| Watercolor physics | **P** | | S | **P** | S | | S |
| Oil / impasto | | **P** | S | | S | | |
| Acrylic | | S | **P** | | S | | |
| Charcoal / pastel | | | **P** | | S | | **P** |
| Cross-media interaction | | | **P** | S | | S | S |
| Canvas material props | **P** | S | S | **P** | | | |
| Impasto lighting | S | **P** | S | S | | | |
| Absorption color model | **P** | **P** | S | S | | S | |
| 4K performance | S | | **P** | | | S | |
| Minimal / simple UI | | | | | **P** | | **P** |
| Debug visualization | | | | S | | **P** | |
| Shader extensibility | | | | | | **P** | |

**P** = primary need, **S** = secondary benefit
