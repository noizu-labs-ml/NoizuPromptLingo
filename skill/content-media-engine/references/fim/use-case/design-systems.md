# Design Systems
Create component libraries, style guides, and design system documentation.
[Design Tokens](https://design-tokens.github.io/community-group/) | [Storybook](https://storybook.js.org/)

## WWHW
**What**: Generate design system components, style guides, and documentation
**Why**: Ensure design consistency, streamline development, improve maintainability
**How**: Create design tokens, component libraries, style documentation, usage guidelines
**When**: Design system creation, component standardization, brand consistency enforcement

## When to Use
- Building scalable design systems
- Creating component library documentation
- Standardizing design tokens and variables
- Generating style guide documentation

## Key Outputs
`design-tokens`, `component-library`, `style-guides`, `documentation-sites`

## Quick Example
```css
/* Design tokens */
:root {
  --color-primary-500: #2196f3;
  --font-family-sans: 'Inter', sans-serif;
  --font-size-base: 1rem;
  --space-sm: 0.5rem;
  --space-md: 1rem;
}

/* Component styles */
.btn {
  font-family: var(--font-family-sans);
  font-size: var(--font-size-base);
  padding: var(--space-sm) var(--space-md);
  background-color: var(--color-primary-500);
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
```

```jsx
// Component documentation
export const Button = ({ variant = 'primary', children, ...props }) => (
  <button className={`btn btn--${variant}`} {...props}>
    {children}
  </button>
);

Button.args = { children: 'Button', variant: 'primary' };
```