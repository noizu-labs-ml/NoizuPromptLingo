# Automated Quality Checks

> Configuration and usage for automated testing tools. These checks run during development and CI/CD to catch issues early.

---

## 1. Tool Overview

| Tool | Purpose | When to Run |
|------|---------|-------------|
| **Axe** | Accessibility testing | Development, CI, Pre-launch |
| **Lighthouse** | Performance, a11y, SEO, best practices | CI, Pre-launch |
| **ESLint** | Code quality | Development, CI |
| **Stylelint** | CSS quality | Development, CI |
| **BackstopJS** | Visual regression | CI, Pre-merge |
| **Pa11y** | Accessibility CI | CI |

---

## 2. Accessibility: Axe

### 2.1 Browser Extension (Development)

**Setup:**
1. Install [axe DevTools](https://www.deque.com/axe/devtools/) for Chrome/Firefox
2. Open DevTools → axe DevTools tab
3. Click "Scan ALL of my page"

**Severity Levels:**
- **Critical:** Must fix immediately
- **Serious:** Must fix before launch
- **Moderate:** Should fix
- **Minor:** Nice to fix

### 2.2 CLI (CI/CD)

**Installation:**
```bash
npm install -g @axe-core/cli
```

**Usage:**
```bash
# Basic scan
axe https://example.com

# With specific rules
axe https://example.com --tags wcag2a,wcag2aa

# Multiple pages
axe https://example.com https://example.com/about

# Output to JSON
axe https://example.com --save results.json
```

**CI Script:**
```bash
#!/bin/bash
# axe-check.sh

URL="${1:-http://localhost:3000}"
THRESHOLD="${2:-0}"

echo "Running Axe accessibility check on $URL"

# Run axe and capture output
RESULT=$(axe "$URL" --tags wcag2a,wcag2aa --exit)
EXIT_CODE=$?

# Count violations
VIOLATIONS=$(echo "$RESULT" | grep -c "violation")

if [ "$EXIT_CODE" -ne 0 ] || [ "$VIOLATIONS" -gt "$THRESHOLD" ]; then
    echo "❌ Accessibility check failed"
    echo "$RESULT"
    exit 1
else
    echo "✅ Accessibility check passed"
    exit 0
fi
```

### 2.3 Programmatic (Jest/Testing)

**Installation:**
```bash
npm install --save-dev @axe-core/react jest-axe
```

**React Testing:**
```javascript
import React from 'react';
import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';
import { Button } from './Button';

expect.extend(toHaveNoViolations);

describe('Button accessibility', () => {
  it('should have no accessibility violations', async () => {
    const { container } = render(<Button>Click me</Button>);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  it('should have no violations when disabled', async () => {
    const { container } = render(<Button disabled>Disabled</Button>);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
});
```

### 2.4 Axe Configuration

```javascript
// axe.config.js
module.exports = {
  rules: {
    // Enforce WCAG 2.1 AA
    'color-contrast': { enabled: true },
    'link-name': { enabled: true },
    'image-alt': { enabled: true },
    'label': { enabled: true },
    'button-name': { enabled: true },
    
    // Additional rules
    'landmark-one-main': { enabled: true },
    'region': { enabled: true },
    'skip-link': { enabled: true },
  },
  
  // Tags to run
  runOnly: {
    type: 'tag',
    values: ['wcag2a', 'wcag2aa', 'wcag21aa']
  }
};
```

---

## 3. Performance: Lighthouse

### 3.1 Chrome DevTools (Development)

1. Open DevTools → Lighthouse tab
2. Select categories: Performance, Accessibility, Best Practices, SEO
3. Select device: Mobile or Desktop
4. Click "Analyze page load"

### 3.2 CLI (CI/CD)

**Installation:**
```bash
npm install -g lighthouse
```

**Usage:**
```bash
# Basic run
lighthouse https://example.com

# Output formats
lighthouse https://example.com --output html --output-path ./report.html
lighthouse https://example.com --output json --output-path ./report.json

# Mobile vs Desktop
lighthouse https://example.com --preset=desktop
lighthouse https://example.com --preset=perf  # Mobile (default)

# Specific categories
lighthouse https://example.com --only-categories=performance,accessibility
```

**CI Script:**
```bash
#!/bin/bash
# lighthouse-check.sh

URL="${1:-http://localhost:3000}"
PERF_THRESHOLD="${2:-75}"
A11Y_THRESHOLD="${3:-90}"

echo "Running Lighthouse on $URL"

# Run Lighthouse and output JSON
lighthouse "$URL" \
  --output=json \
  --output-path=./lighthouse-report.json \
  --chrome-flags="--headless --no-sandbox" \
  --only-categories=performance,accessibility,best-practices,seo

# Extract scores
PERF=$(jq '.categories.performance.score * 100' lighthouse-report.json)
A11Y=$(jq '.categories.accessibility.score * 100' lighthouse-report.json)
BP=$(jq '.categories["best-practices"].score * 100' lighthouse-report.json)
SEO=$(jq '.categories.seo.score * 100' lighthouse-report.json)

echo "Scores: Performance=$PERF, Accessibility=$A11Y, Best Practices=$BP, SEO=$SEO"

# Check thresholds
if (( $(echo "$PERF < $PERF_THRESHOLD" | bc -l) )); then
    echo "❌ Performance score $PERF below threshold $PERF_THRESHOLD"
    exit 1
fi

if (( $(echo "$A11Y < $A11Y_THRESHOLD" | bc -l) )); then
    echo "❌ Accessibility score $A11Y below threshold $A11Y_THRESHOLD"
    exit 1
fi

echo "✅ Lighthouse checks passed"
```

### 3.3 Lighthouse CI

**Installation:**
```bash
npm install -g @lhci/cli
```

**Configuration (lighthouserc.js):**
```javascript
module.exports = {
  ci: {
    collect: {
      url: [
        'http://localhost:3000/',
        'http://localhost:3000/about',
        'http://localhost:3000/pricing',
      ],
      numberOfRuns: 3,
    },
    assert: {
      assertions: {
        'categories:performance': ['error', { minScore: 0.75 }],
        'categories:accessibility': ['error', { minScore: 0.9 }],
        'categories:best-practices': ['error', { minScore: 0.9 }],
        'categories:seo': ['error', { minScore: 0.9 }],
        
        // Core Web Vitals
        'largest-contentful-paint': ['error', { maxNumericValue: 2500 }],
        'first-contentful-paint': ['error', { maxNumericValue: 1800 }],
        'cumulative-layout-shift': ['error', { maxNumericValue: 0.1 }],
        'total-blocking-time': ['error', { maxNumericValue: 300 }],
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
};
```

**GitHub Actions:**
```yaml
# .github/workflows/lighthouse.yml
name: Lighthouse CI
on: [push]

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: 18
          
      - name: Install dependencies
        run: npm ci
        
      - name: Build
        run: npm run build
        
      - name: Start server
        run: npm start &
        
      - name: Wait for server
        run: npx wait-on http://localhost:3000
        
      - name: Run Lighthouse CI
        run: |
          npm install -g @lhci/cli
          lhci autorun
```

---

## 4. Code Quality: ESLint

### 4.1 Configuration

**Installation:**
```bash
npm install --save-dev eslint eslint-plugin-jsx-a11y eslint-plugin-react
```

**Configuration (.eslintrc.js):**
```javascript
module.exports = {
  extends: [
    'eslint:recommended',
    'plugin:react/recommended',
    'plugin:jsx-a11y/recommended',
  ],
  plugins: ['jsx-a11y', 'react'],
  rules: {
    // Accessibility
    'jsx-a11y/alt-text': 'error',
    'jsx-a11y/anchor-has-content': 'error',
    'jsx-a11y/anchor-is-valid': 'error',
    'jsx-a11y/aria-props': 'error',
    'jsx-a11y/aria-role': 'error',
    'jsx-a11y/aria-unsupported-elements': 'error',
    'jsx-a11y/click-events-have-key-events': 'error',
    'jsx-a11y/heading-has-content': 'error',
    'jsx-a11y/html-has-lang': 'error',
    'jsx-a11y/img-redundant-alt': 'error',
    'jsx-a11y/interactive-supports-focus': 'error',
    'jsx-a11y/label-has-associated-control': 'error',
    'jsx-a11y/mouse-events-have-key-events': 'error',
    'jsx-a11y/no-access-key': 'error',
    'jsx-a11y/no-autofocus': 'warn',
    'jsx-a11y/no-noninteractive-element-interactions': 'error',
    'jsx-a11y/no-noninteractive-tabindex': 'error',
    'jsx-a11y/no-redundant-roles': 'error',
    'jsx-a11y/role-has-required-aria-props': 'error',
    'jsx-a11y/role-supports-aria-props': 'error',
    'jsx-a11y/tabindex-no-positive': 'error',
    
    // React
    'react/jsx-key': 'error',
    'react/no-array-index-key': 'warn',
    'react/no-danger': 'warn',
    'react/self-closing-comp': 'error',
  },
  settings: {
    react: {
      version: 'detect',
    },
  },
};
```

### 4.2 Pre-commit Hook

**Installation:**
```bash
npm install --save-dev husky lint-staged
npx husky install
```

**Configuration (package.json):**
```json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{css,scss}": [
      "stylelint --fix",
      "prettier --write"
    ]
  }
}
```

**Husky hook (.husky/pre-commit):**
```bash
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"
npx lint-staged
```

---

## 5. CSS Quality: Stylelint

### 5.1 Configuration

**Installation:**
```bash
npm install --save-dev stylelint stylelint-config-standard
```

**Configuration (.stylelintrc.js):**
```javascript
module.exports = {
  extends: ['stylelint-config-standard'],
  rules: {
    // Design system enforcement
    'color-no-hex': true, // Force CSS variables
    'declaration-property-value-allowed-list': {
      'font-size': ['/^var\\(--text-/', '/^inherit$/'],
      'font-family': ['/^var\\(--font-/', '/^inherit$/'],
      'line-height': ['/^var\\(--leading-/', '/^[0-9.]+$/'],
    },
    
    // Maintainability
    'max-nesting-depth': 3,
    'selector-max-specificity': '0,3,0',
    'selector-max-id': 0,
    
    // Consistency
    'color-function-notation': 'modern',
    'alpha-value-notation': 'percentage',
    
    // Prevent common errors
    'no-descending-specificity': true,
    'no-duplicate-selectors': true,
    'shorthand-property-no-redundant-values': true,
  },
};
```

### 5.2 Design Token Enforcement

```javascript
// Custom Stylelint plugin for design tokens
const stylelint = require('stylelint');

const ruleName = 'custom/use-design-tokens';
const messages = stylelint.utils.ruleMessages(ruleName, {
  expected: (prop, value) => `Use design token for ${prop}: ${value}`,
});

const tokenPatterns = {
  color: /^var\(--color-/,
  'background-color': /^var\(--color-/,
  'border-color': /^var\(--color-/,
  'font-size': /^var\(--text-/,
  'font-family': /^var\(--font-/,
  padding: /^var\(--space-/,
  margin: /^var\(--space-/,
  gap: /^var\(--space-/,
  'border-radius': /^var\(--radius-/,
  'box-shadow': /^var\(--shadow-/,
};

module.exports = stylelint.createPlugin(ruleName, (primary) => {
  return (root, result) => {
    root.walkDecls((decl) => {
      const pattern = tokenPatterns[decl.prop];
      if (pattern && !pattern.test(decl.value) && decl.value !== 'inherit') {
        stylelint.utils.report({
          message: messages.expected(decl.prop, decl.value),
          node: decl,
          result,
          ruleName,
        });
      }
    });
  };
});
```

---

## 6. Visual Regression: BackstopJS

### 6.1 Configuration

**Installation:**
```bash
npm install --save-dev backstopjs
npx backstop init
```

**Configuration (backstop.json):**
```json
{
  "id": "project-name",
  "viewports": [
    { "label": "phone", "width": 375, "height": 812 },
    { "label": "tablet", "width": 768, "height": 1024 },
    { "label": "desktop", "width": 1440, "height": 900 }
  ],
  "scenarios": [
    {
      "label": "Homepage",
      "url": "http://localhost:3000",
      "selectors": ["document"],
      "delay": 500,
      "misMatchThreshold": 0.1
    },
    {
      "label": "Homepage - Hero",
      "url": "http://localhost:3000",
      "selectors": ["[data-testid='hero']"],
      "delay": 500
    },
    {
      "label": "Button States",
      "url": "http://localhost:3000/components/button",
      "selectors": ["[data-testid='button-showcase']"],
      "hoverSelector": "[data-testid='button-primary']",
      "delay": 300
    }
  ],
  "paths": {
    "bitmaps_reference": "backstop_data/bitmaps_reference",
    "bitmaps_test": "backstop_data/bitmaps_test",
    "html_report": "backstop_data/html_report"
  },
  "engine": "puppeteer",
  "engineOptions": {
    "args": ["--no-sandbox"]
  },
  "report": ["browser", "CI"],
  "debug": false
}
```

### 6.2 Commands

```bash
# Create reference screenshots
npx backstop reference

# Run comparison test
npx backstop test

# Approve changes (update reference)
npx backstop approve

# Open report
npx backstop openReport
```

### 6.3 CI Integration

```yaml
# .github/workflows/visual-regression.yml
name: Visual Regression
on: [pull_request]

jobs:
  visual-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node
        uses: actions/setup-node@v3
        
      - name: Install dependencies
        run: npm ci
        
      - name: Build and start
        run: |
          npm run build
          npm start &
          npx wait-on http://localhost:3000
          
      - name: Run BackstopJS
        run: npx backstop test
        
      - name: Upload report
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: backstop-report
          path: backstop_data/html_report
```

---

## 7. CI/CD Pipeline Integration

### 7.1 Complete GitHub Actions Workflow

```yaml
# .github/workflows/quality.yml
name: Quality Checks

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm run lint:css

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: 'npm'
      - run: npm ci
      - run: npm test -- --coverage
      - name: Upload coverage
        uses: codecov/codecov-action@v3

  accessibility:
    runs-on: ubuntu-latest
    needs: [lint, test]
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: 'npm'
      - run: npm ci
      - run: npm run build
      - run: npm start &
      - run: npx wait-on http://localhost:3000
      - run: npx axe http://localhost:3000 --tags wcag2aa --exit

  lighthouse:
    runs-on: ubuntu-latest
    needs: [lint, test]
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: 'npm'
      - run: npm ci
      - run: npm run build
      - run: npm start &
      - run: npx wait-on http://localhost:3000
      - name: Run Lighthouse
        uses: treosh/lighthouse-ci-action@v10
        with:
          urls: |
            http://localhost:3000
            http://localhost:3000/about
          budgetPath: ./budget.json
          uploadArtifacts: true
```

### 7.2 Quality Budget (budget.json)

```json
[
  {
    "path": "/*",
    "timings": [
      { "metric": "largest-contentful-paint", "budget": 2500 },
      { "metric": "first-contentful-paint", "budget": 1800 },
      { "metric": "total-blocking-time", "budget": 300 },
      { "metric": "cumulative-layout-shift", "budget": 0.1 }
    ],
    "resourceCounts": [
      { "resourceType": "script", "budget": 10 },
      { "resourceType": "total", "budget": 50 }
    ],
    "resourceSizes": [
      { "resourceType": "script", "budget": 300 },
      { "resourceType": "image", "budget": 500 },
      { "resourceType": "total", "budget": 1000 }
    ]
  }
]
```

---

## 8. Reporting Dashboard

### 8.1 Quality Metrics to Track

```javascript
// quality-report.js
const metrics = {
  // Automated scores
  lighthouse: {
    performance: 0,
    accessibility: 0,
    bestPractices: 0,
    seo: 0,
  },
  
  // Violation counts
  axe: {
    critical: 0,
    serious: 0,
    moderate: 0,
    minor: 0,
  },
  
  // Code quality
  eslint: {
    errors: 0,
    warnings: 0,
  },
  
  // Visual regression
  backstop: {
    passed: 0,
    failed: 0,
    new: 0,
  },
  
  // Timestamp
  timestamp: new Date().toISOString(),
};
```

### 8.2 Trend Tracking

Store metrics over time to track improvement:

```javascript
// Track in JSON file or database
{
  "history": [
    {
      "date": "2024-01-15",
      "lighthouse": { "performance": 82 },
      "axe": { "violations": 3 }
    },
    {
      "date": "2024-01-22",
      "lighthouse": { "performance": 87 },
      "axe": { "violations": 1 }
    }
  ]
}
```

---

## References

- `accessibility-audit.md` - Manual accessibility testing
- `performance-budget.md` - Performance targets
- `PROCESS/quality-gates.md` - Gate criteria
- `PATTERNS/accessibility.md` - Accessibility patterns

---

*Version: 0.1.0*
