# Kino.JS

**Category**: Interactive Widgets
**Complexity**: Advanced
**Documentation**: [Kino.JS on Hexdocs](https://hexdocs.pm/kino/Kino.JS.html)

## Description

Kino.JS enables creation of custom JavaScript widgets for LiveBook notebooks. Provides full control over widget behavior, appearance, and interactivity through custom JavaScript and CSS.

## Installation

Add to LiveBook notebook cell:
```elixir
Mix.install([{:kino, "~> 0.12"}])
```

## Custom Widget Example

```elixir
content = """
<div id="custom-widget">
  <h3>Interactive Counter</h3>
  <button id="increment">+</button>
  <span id="count">0</span>
  <button id="decrement">-</button>
</div>
"""

js = """
let count = 0;
const countEl = document.getElementById('count');
const incrementBtn = document.getElementById('increment');
const decrementBtn = document.getElementById('decrement');

incrementBtn.addEventListener('click', () => {
  count++;
  countEl.textContent = count;
  ctx.pushEvent("count_changed", {value: count});
});

decrementBtn.addEventListener('click', () => {
  count--;
  countEl.textContent = count;
  ctx.pushEvent("count_changed", {value: count});
});

ctx.handleEvent("reset", () => {
  count = 0;
  countEl.textContent = count;
});
"""

css = """
#custom-widget {
  text-align: center;
  padding: 20px;
  border: 2px solid #007acc;
  border-radius: 8px;
}
#custom-widget button {
  margin: 0 10px;
  padding: 5px 15px;
  font-size: 18px;
}
"""

Kino.JS.new(content, js: js, css: css)
|> Kino.render()
```

## Strengths

- Complete customization freedom
- Full JavaScript ecosystem access
- Event handling and interactivity
- Direct DOM manipulation
- Custom styling with CSS
- Two-way communication with Elixir

## Limitations

- Requires JavaScript knowledge
- No built-in security sandboxing
- Complex setup for simple widgets
- Browser compatibility considerations
- Debugging complexity

## Best For

- Custom data visualizations
- Interactive dashboards
- Specialized input controls
- Complex user interfaces
- Prototype testing
- JavaScript library integration

## NPL-FIM Integration

```npl
⟪kino-js-widget⟫ →
  content: ⟪html-structure⟫
  js: ⟪widget-behavior⟫
  css: ⟪widget-styling⟫
  events: ⟪elixir-js-communication⟫
⟪/kino-js-widget⟫

Usage: @fim Create custom widget for [purpose] using Kino.JS
```

**Related**: [Kino.Mermaid](kino-mermaid.md), [Kino.Plotly](kino-plotly.md), [Kino.DataTable](kino-datatable.md)