# Design Systems: NPL-FIM Generation Framework

*Comprehensive guide for generating production-ready design systems with React/TypeScript*

**Version**: 3.0
**Target**: 250-300 lines
**Focus**: Component generation with industry-standard compliance

---

## Table of Contents
1. [Technical Requirements](#technical-requirements)
2. [Token System Generation](#token-system-generation)
3. [Component Templates](#component-templates)
4. [Package Dependencies](#package-dependencies)
5. [Browser Compatibility](#browser-compatibility)
6. [Quality Metrics](#quality-metrics)
7. [Industry References](#industry-references)

---

## Technical Requirements

### Framework Versions
```json
{
  "react": "^18.2.0",
  "typescript": "^5.0.0",
  "node": ">=18.0.0",
  "npm": ">=9.0.0"
}
```

### Core Stack
- **Build**: Vite 5.0+ or Next.js 14+
- **Styling**: Tailwind CSS 3.3+ or CSS-in-JS (Emotion/Styled-Components)
- **State**: Context API or Zustand 4.4+
- **Testing**: Jest 29+ with React Testing Library 14+
- **Documentation**: Storybook 7.5+

---

## Token System Generation

### Primitive → Semantic → Component Architecture

```typescript
// tokens.ts - Complete type-safe token system
export const tokens = {
  colors: {
    // Primitives (Material Design 3 inspired)
    neutral: {
      0: '#FFFFFF',
      10: '#1C1B1F',
      20: '#313033',
      90: '#E6E1E5',
      95: '#F4EFF4',
      100: '#000000'
    },
    primary: {
      40: '#6750A4',
      80: '#D0BCFF',
      90: '#EADDFF'
    },
    // Semantic mappings
    semantic: {
      surface: 'var(--color-neutral-95)',
      onSurface: 'var(--color-neutral-10)',
      primary: 'var(--color-primary-40)',
      onPrimary: 'var(--color-neutral-100)'
    }
  },
  spacing: {
    // 8-point grid system
    scale: [0, 4, 8, 12, 16, 24, 32, 48, 64, 96, 128]
  },
  typography: {
    // IBM Plex Sans as system font
    families: {
      sans: "'IBM Plex Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
      mono: "'IBM Plex Mono', 'Courier New', monospace"
    },
    sizes: {
      xs: '12px',
      sm: '14px',
      base: '16px',
      lg: '18px',
      xl: '20px',
      '2xl': '24px',
      '3xl': '30px'
    }
  },
  breakpoints: {
    sm: '640px',
    md: '768px',
    lg: '1024px',
    xl: '1280px'
  }
} as const;
```

---

## Component Templates

### Production-Ready Button Component

```tsx
// Button.tsx - WCAG 2.1 AA compliant
import React, { forwardRef, ButtonHTMLAttributes } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        primary: 'bg-primary text-primary-foreground hover:bg-primary/90',
        secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
        outline: 'border border-input bg-background hover:bg-accent',
        ghost: 'hover:bg-accent hover:text-accent-foreground',
        link: 'text-primary underline-offset-4 hover:underline'
      },
      size: {
        sm: 'h-8 px-3 text-xs',
        md: 'h-10 px-4 py-2',
        lg: 'h-12 px-8',
        icon: 'h-10 w-10'
      }
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md'
    }
  }
);

export interface ButtonProps
  extends ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
  loading?: boolean;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, loading, children, disabled, ...props }, ref) => {
    return (
      <button
        className={buttonVariants({ variant, size, className })}
        ref={ref}
        disabled={disabled || loading}
        aria-busy={loading}
        {...props}
      >
        {loading && <span className="mr-2 h-4 w-4 animate-spin">⟳</span>}
        {children}
      </button>
    );
  }
);

Button.displayName = 'Button';
```

### Form Field Template

```tsx
// FormField.tsx - Accessible form controls
import React, { forwardRef } from 'react';

interface FormFieldProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
  hint?: string;
}

export const FormField = forwardRef<HTMLInputElement, FormFieldProps>(
  ({ label, error, hint, required, id, ...props }, ref) => {
    const fieldId = id || `field-${label.toLowerCase().replace(/\s+/g, '-')}`;

    return (
      <div className="space-y-2">
        <label htmlFor={fieldId} className="text-sm font-medium">
          {label}
          {required && <span className="text-red-500 ml-1" aria-label="required">*</span>}
        </label>
        <input
          ref={ref}
          id={fieldId}
          aria-invalid={!!error}
          aria-describedby={`${fieldId}-error ${fieldId}-hint`}
          className="w-full rounded-md border border-gray-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary"
          {...props}
        />
        {hint && <p id={`${fieldId}-hint`} className="text-sm text-gray-600">{hint}</p>}
        {error && <p id={`${fieldId}-error`} role="alert" className="text-sm text-red-600">{error}</p>}
      </div>
    );
  }
);

FormField.displayName = 'FormField';
```

---

## Package Dependencies

### Complete package.json

```json
{
  "name": "design-system",
  "version": "1.0.0",
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "class-variance-authority": "^0.7.0",
    "clsx": "^2.0.0",
    "@radix-ui/react-slot": "^1.0.2"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@vitejs/plugin-react": "^4.2.0",
    "vite": "^5.0.0",
    "tailwindcss": "^3.3.0",
    "postcss": "^8.4.31",
    "autoprefixer": "^10.4.16",
    "@testing-library/react": "^14.0.0",
    "@testing-library/jest-dom": "^6.1.0",
    "@testing-library/user-event": "^14.5.0",
    "jest": "^29.7.0",
    "jest-axe": "^8.0.0",
    "@storybook/react-vite": "^7.5.0",
    "@storybook/addon-essentials": "^7.5.0",
    "@storybook/addon-a11y": "^7.5.0",
    "eslint": "^8.53.0",
    "@typescript-eslint/parser": "^6.10.0",
    "@typescript-eslint/eslint-plugin": "^6.10.0",
    "prettier": "^3.0.3"
  }
}
```

---

## Browser Compatibility

### Support Matrix
| Browser | Minimum Version | Notes |
|---------|----------------|-------|
| Chrome | 90+ | Full support including CSS Grid |
| Firefox | 88+ | Full support |
| Safari | 14.1+ | Requires -webkit prefixes for some properties |
| Edge | 90+ | Chromium-based versions only |
| iOS Safari | 14.5+ | Touch optimizations required |
| Chrome Android | 90+ | Viewport meta tag required |

### Polyfills Required
```javascript
// polyfills.js
import 'core-js/stable';
import 'regenerator-runtime/runtime';
import 'intersection-observer';
import 'resize-observer-polyfill';
```

---

## Quality Metrics

### 100-Point Scoring System

**Architecture (40 points)**
- Token system completeness: 15pts
- Component composability: 10pts
- TypeScript coverage: 10pts
- Performance optimization: 5pts

**Accessibility (30 points)**
- WCAG 2.1 AA compliance: 15pts
- Keyboard navigation: 10pts
- Screen reader support: 5pts

**Documentation (20 points)**
- Component examples: 10pts
- API documentation: 10pts

**Testing (10 points)**
- Unit test coverage >90%: 5pts
- E2E test coverage: 5pts

### Grade Thresholds
- **A (120-150)**: Production-ready, enterprise-grade
- **B (90-119)**: Good foundation, minor improvements needed
- **C (70-89)**: Functional but needs significant work
- **D (50-69)**: Major gaps in implementation
- **F (<50)**: Not production viable

---

## Industry References

### Design System Standards
- **Material Design 3**: [m3.material.io](https://m3.material.io)
- **IBM Carbon**: [carbondesignsystem.com](https://carbondesignsystem.com)
- **Salesforce Lightning**: [lightningdesignsystem.com](https://lightningdesignsystem.com)
- **Ant Design**: [ant.design](https://ant.design)
- **Atlassian Design**: [atlassian.design](https://atlassian.design)

### Accessibility Resources
- **WCAG 2.1 Guidelines**: [w3.org/WAI/WCAG21](https://www.w3.org/WAI/WCAG21/quickref/)
- **ARIA Patterns**: [w3.org/WAI/ARIA/apg/patterns](https://www.w3.org/WAI/ARIA/apg/patterns/)
- **WebAIM**: [webaim.org](https://webaim.org)

### Performance Tools
- **Lighthouse**: Chrome DevTools built-in
- **Bundle Analyzer**: webpack-bundle-analyzer
- **Performance Budget**: [performancebudget.io](https://performancebudget.io)

---

## Generation Checklist

When generating design systems, create these files in order:

1. **tokens/index.ts** - Complete token system
2. **components/Button/Button.tsx** - Primary CTA component
3. **components/FormField/FormField.tsx** - Form building blocks
4. **components/Card/Card.tsx** - Content containers
5. **components/Modal/Modal.tsx** - Overlay patterns
6. **components/Table/Table.tsx** - Data display
7. **styles/globals.css** - CSS custom properties
8. **package.json** - All dependencies
9. **tsconfig.json** - TypeScript configuration
10. **storybook/main.js** - Documentation setup

Each component MUST include:
- TypeScript definitions
- ARIA attributes
- Keyboard handling
- Loading states
- Error states
- Test file
- Story file

---

*Framework optimized for rapid generation of production-ready design systems that meet enterprise standards while maintaining development velocity.*