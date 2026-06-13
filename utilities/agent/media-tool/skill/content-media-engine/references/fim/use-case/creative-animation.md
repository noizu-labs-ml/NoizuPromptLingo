# Creative Animation
Generative art, procedural graphics, and dynamic visual experiences.
[Canvas API](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API) | [WebGL](https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API)

## WWHW
**What**: Creating dynamic, animated graphics through code including generative art and motion graphics.
**Why**: Produce unique visual experiences, explore algorithmic creativity, and create engaging interfaces.
**How**: Using canvas frameworks, WebGL, or SVG with NPL-FIM for data-responsive creative coding.
**When**: Digital art projects, interactive installations, UI animations, creative data visualization.

## When to Use
- Building interactive art installations or digital exhibitions
- Creating unique visual identities through algorithmic design
- Developing engaging UI animations and micro-interactions
- Exploring data through creative and artistic visualization
- Prototyping generative design systems for branding

## Key Outputs
`canvas-animation`, `svg-motion`, `shader-art`, `interactive-sketches`

## Quick Example
```pseudocode
// Conceptual generative animation with NPL-FIM
initialize_canvas(width: 800, height: 600)

animation_loop:
    clear_background()

    // Data-driven particle system
    for each particle in data_points:
        position = calculate_flow(particle.id, time)
        color = map_data_to_hue(particle.value)
        draw_element(position, color, opacity: 0.7)

    // NPL-FIM responds to data changes
    on_data_update: refresh_particles(new_data)