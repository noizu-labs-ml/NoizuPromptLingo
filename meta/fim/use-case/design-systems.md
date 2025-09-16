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
- Establishing design governance frameworks

## Key Outputs
`design-tokens`, `component-library`, `style-guides`, `documentation-sites`

## Quick Example
```css
/* Design tokens */
:root {
  /* Colors */
  --color-primary-100: #e3f2fd;
  --color-primary-500: #2196f3;
  --color-primary-900: #0d47a1;

  /* Typography */
  --font-family-sans: 'Inter', sans-serif;
  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.125rem;

  /* Spacing */
  --space-xs: 0.25rem;
  --space-sm: 0.5rem;
  --space-md: 1rem;
  --space-lg: 1.5rem;
}

/* Component styles */
.btn {
  font-family: var(--font-family-sans);
  font-size: var(--font-size-base);
  padding: var(--space-sm) var(--space-md);
  border-radius: 4px;
  border: none;
  cursor: pointer;
}

.btn--primary {
  background-color: var(--color-primary-500);
  color: white;
}
```

```jsx
// Component documentation
export const Button = ({ variant = 'primary', size = 'medium', children, ...props }) => (
  <button
    className={`btn btn--${variant} btn--${size}`}
    {...props}
  >
    {children}
  </button>
);

Button.args = {
  children: 'Button',
  variant: 'primary',
  size: 'medium'
};
```

## Extended Reference
- [Material Design System](https://material.io/design)
- [Carbon Design System](https://carbondesignsystem.com/)
- [Ant Design](https://ant.design/)
- [Design Systems by Alla Kholmatova](https://www.smashingmagazine.com/printed-books/design-systems/)
- [Atomic Design Methodology](https://bradfrost.com/blog/post/atomic-web-design/)