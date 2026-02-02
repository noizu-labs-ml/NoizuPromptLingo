# Next.js Implementation Guide

> Production-ready patterns for implementing designs in Next.js 14+ with App Router.

---

## 1. Project Structure

### 1.1 Recommended Architecture

```
app/
├── (marketing)/           # Marketing pages group
│   ├── page.tsx          # Landing page
│   ├── pricing/
│   │   └── page.tsx
│   └── layout.tsx        # Marketing layout (minimal nav)
├── (app)/                # Application pages group
│   ├── dashboard/
│   │   └── page.tsx
│   ├── settings/
│   │   └── page.tsx
│   └── layout.tsx        # App layout (full nav, auth)
├── layout.tsx            # Root layout
├── globals.css           # Global styles + Tailwind
└── not-found.tsx         # 404 page

components/
├── ui/                   # Primitive components
│   ├── button.tsx
│   ├── input.tsx
│   ├── card.tsx
│   └── index.ts          # Barrel export
├── layout/               # Layout components
│   ├── header.tsx
│   ├── footer.tsx
│   ├── sidebar.tsx
│   └── nav.tsx
├── sections/             # Page sections
│   ├── hero.tsx
│   ├── features.tsx
│   ├── testimonials.tsx
│   └── cta.tsx
└── forms/                # Form components
    ├── signup-form.tsx
    ├── contact-form.tsx
    └── waitlist-form.tsx

lib/
├── utils.ts              # Utility functions
├── cn.ts                 # className merger (clsx + twMerge)
└── constants.ts          # Site-wide constants

styles/
└── tokens.css            # Design tokens as CSS variables
```

### 1.2 Essential Dependencies

```json
{
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "clsx": "^2.0.0",
    "tailwind-merge": "^2.0.0"
  },
  "devDependencies": {
    "tailwindcss": "^3.4.0",
    "autoprefixer": "^10.0.0",
    "postcss": "^8.0.0",
    "typescript": "^5.0.0",
    "@types/react": "^18.0.0",
    "@types/node": "^20.0.0"
  }
}
```

---

## 2. Design Token Integration

### 2.1 CSS Custom Properties

```css
/* styles/tokens.css */
:root {
  /* Colors */
  --color-primary: 220 90% 56%;
  --color-primary-foreground: 0 0% 100%;
  --color-secondary: 220 14% 96%;
  --color-secondary-foreground: 220 9% 46%;
  --color-accent: 24 100% 50%;
  --color-accent-foreground: 0 0% 100%;
  
  --color-background: 0 0% 100%;
  --color-foreground: 222 47% 11%;
  --color-muted: 220 14% 96%;
  --color-muted-foreground: 220 9% 46%;
  
  --color-border: 220 13% 91%;
  --color-ring: 220 90% 56%;
  
  /* Semantic */
  --color-success: 142 76% 36%;
  --color-warning: 38 92% 50%;
  --color-error: 0 84% 60%;
  
  /* Spacing scale */
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;
  --space-6: 1.5rem;
  --space-8: 2rem;
  --space-12: 3rem;
  --space-16: 4rem;
  --space-24: 6rem;
  
  /* Typography */
  --font-sans: var(--font-inter), system-ui, sans-serif;
  --font-mono: var(--font-mono), ui-monospace, monospace;
  
  /* Radii */
  --radius-sm: 0.25rem;
  --radius-md: 0.375rem;
  --radius-lg: 0.5rem;
  --radius-xl: 0.75rem;
  --radius-full: 9999px;
  
  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);
}

.dark {
  --color-background: 222 47% 11%;
  --color-foreground: 0 0% 100%;
  --color-muted: 217 33% 17%;
  --color-muted-foreground: 215 20% 65%;
  --color-border: 217 33% 17%;
}
```

### 2.2 Tailwind Configuration

```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: 'hsl(var(--color-primary))',
          foreground: 'hsl(var(--color-primary-foreground))',
        },
        secondary: {
          DEFAULT: 'hsl(var(--color-secondary))',
          foreground: 'hsl(var(--color-secondary-foreground))',
        },
        accent: {
          DEFAULT: 'hsl(var(--color-accent))',
          foreground: 'hsl(var(--color-accent-foreground))',
        },
        background: 'hsl(var(--color-background))',
        foreground: 'hsl(var(--color-foreground))',
        muted: {
          DEFAULT: 'hsl(var(--color-muted))',
          foreground: 'hsl(var(--color-muted-foreground))',
        },
        border: 'hsl(var(--color-border))',
        ring: 'hsl(var(--color-ring))',
        success: 'hsl(var(--color-success))',
        warning: 'hsl(var(--color-warning))',
        error: 'hsl(var(--color-error))',
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
      },
      borderRadius: {
        sm: 'var(--radius-sm)',
        md: 'var(--radius-md)',
        lg: 'var(--radius-lg)',
        xl: 'var(--radius-xl)',
      },
      fontFamily: {
        sans: ['var(--font-sans)'],
        mono: ['var(--font-mono)'],
      },
    },
  },
  plugins: [],
}

export default config
```

---

## 3. Component Patterns

### 3.1 Button Component

```tsx
// components/ui/button.tsx
import { forwardRef } from 'react'
import { cn } from '@/lib/cn'

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost' | 'destructive'
  size?: 'sm' | 'md' | 'lg'
  loading?: boolean
}

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'primary', size = 'md', loading, children, disabled, ...props }, ref) => {
    return (
      <button
        ref={ref}
        disabled={disabled || loading}
        className={cn(
          // Base styles
          'inline-flex items-center justify-center font-medium transition-colors',
          'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
          'disabled:pointer-events-none disabled:opacity-50',
          // Variants
          {
            'bg-primary text-primary-foreground hover:bg-primary/90': variant === 'primary',
            'bg-secondary text-secondary-foreground hover:bg-secondary/80': variant === 'secondary',
            'hover:bg-muted': variant === 'ghost',
            'bg-error text-white hover:bg-error/90': variant === 'destructive',
          },
          // Sizes
          {
            'h-8 px-3 text-sm rounded-md': size === 'sm',
            'h-10 px-4 text-sm rounded-md': size === 'md',
            'h-12 px-6 text-base rounded-lg': size === 'lg',
          },
          className
        )}
        {...props}
      >
        {loading ? (
          <>
            <svg
              className="mr-2 h-4 w-4 animate-spin"
              fill="none"
              viewBox="0 0 24 24"
            >
              <circle
                className="opacity-25"
                cx="12"
                cy="12"
                r="10"
                stroke="currentColor"
                strokeWidth="4"
              />
              <path
                className="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
              />
            </svg>
            Loading...
          </>
        ) : (
          children
        )}
      </button>
    )
  }
)

Button.displayName = 'Button'

export { Button }
```

### 3.2 Input Component

```tsx
// components/ui/input.tsx
import { forwardRef } from 'react'
import { cn } from '@/lib/cn'

export interface InputProps
  extends React.InputHTMLAttributes<HTMLInputElement> {
  error?: string
  label?: string
}

const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ className, type = 'text', error, label, id, ...props }, ref) => {
    const inputId = id || props.name
    
    return (
      <div className="space-y-1.5">
        {label && (
          <label
            htmlFor={inputId}
            className="text-sm font-medium text-foreground"
          >
            {label}
          </label>
        )}
        <input
          type={type}
          id={inputId}
          ref={ref}
          className={cn(
            'flex h-10 w-full rounded-md border bg-background px-3 py-2 text-sm',
            'placeholder:text-muted-foreground',
            'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring',
            'disabled:cursor-not-allowed disabled:opacity-50',
            error ? 'border-error' : 'border-border',
            className
          )}
          aria-invalid={error ? 'true' : 'false'}
          aria-describedby={error ? `${inputId}-error` : undefined}
          {...props}
        />
        {error && (
          <p id={`${inputId}-error`} className="text-sm text-error">
            {error}
          </p>
        )}
      </div>
    )
  }
)

Input.displayName = 'Input'

export { Input }
```

### 3.3 Card Component

```tsx
// components/ui/card.tsx
import { cn } from '@/lib/cn'

interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'default' | 'bordered' | 'elevated'
}

function Card({ className, variant = 'default', ...props }: CardProps) {
  return (
    <div
      className={cn(
        'rounded-lg bg-background',
        {
          'border border-border': variant === 'default' || variant === 'bordered',
          'shadow-lg': variant === 'elevated',
        },
        className
      )}
      {...props}
    />
  )
}

function CardHeader({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={cn('p-6 pb-0', className)} {...props} />
}

function CardTitle({ className, ...props }: React.HTMLAttributes<HTMLHeadingElement>) {
  return <h3 className={cn('text-lg font-semibold', className)} {...props} />
}

function CardDescription({ className, ...props }: React.HTMLAttributes<HTMLParagraphElement>) {
  return <p className={cn('text-sm text-muted-foreground', className)} {...props} />
}

function CardContent({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={cn('p-6', className)} {...props} />
}

function CardFooter({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={cn('p-6 pt-0 flex items-center', className)} {...props} />
}

export { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter }
```

---

## 4. Layout Patterns

### 4.1 Root Layout

```tsx
// app/layout.tsx
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import '@/styles/tokens.css'
import './globals.css'

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
})

export const metadata: Metadata = {
  title: {
    default: 'Product Name',
    template: '%s | Product Name',
  },
  description: 'Your product description',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={inter.variable}>
      <body className="min-h-screen bg-background font-sans antialiased">
        {children}
      </body>
    </html>
  )
}
```

### 4.2 Marketing Layout

```tsx
// app/(marketing)/layout.tsx
import { Header } from '@/components/layout/header'
import { Footer } from '@/components/layout/footer'

export default function MarketingLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="flex min-h-screen flex-col">
      <Header />
      <main className="flex-1">{children}</main>
      <Footer />
    </div>
  )
}
```

### 4.3 App Layout with Sidebar

```tsx
// app/(app)/layout.tsx
import { Sidebar } from '@/components/layout/sidebar'
import { AppHeader } from '@/components/layout/app-header'

export default function AppLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="flex min-h-screen">
      <Sidebar className="hidden lg:flex w-64 flex-col fixed inset-y-0" />
      <div className="flex-1 lg:pl-64">
        <AppHeader />
        <main className="p-6">{children}</main>
      </div>
    </div>
  )
}
```

---

## 5. Section Patterns

### 5.1 Hero Section

```tsx
// components/sections/hero.tsx
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

interface HeroProps {
  headline: string
  subheadline: string
  ctaText: string
  showEmailCapture?: boolean
  socialProof?: string
}

export function Hero({
  headline,
  subheadline,
  ctaText,
  showEmailCapture = false,
  socialProof,
}: HeroProps) {
  return (
    <section className="relative py-24 lg:py-32">
      <div className="container mx-auto px-4">
        <div className="mx-auto max-w-3xl text-center">
          <h1 className="text-4xl font-bold tracking-tight sm:text-5xl lg:text-6xl">
            {headline}
          </h1>
          <p className="mt-6 text-lg text-muted-foreground lg:text-xl">
            {subheadline}
          </p>
          
          <div className="mt-10">
            {showEmailCapture ? (
              <form className="flex flex-col sm:flex-row gap-3 justify-center max-w-md mx-auto">
                <Input
                  type="email"
                  placeholder="Enter your email"
                  className="flex-1"
                  required
                />
                <Button type="submit" size="lg">
                  {ctaText}
                </Button>
              </form>
            ) : (
              <Button size="lg">{ctaText}</Button>
            )}
          </div>
          
          {socialProof && (
            <p className="mt-6 text-sm text-muted-foreground">
              {socialProof}
            </p>
          )}
        </div>
      </div>
    </section>
  )
}
```

### 5.2 Features Grid (Bento)

```tsx
// components/sections/features.tsx
import { Card, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'

interface Feature {
  title: string
  description: string
  icon?: React.ReactNode
  span?: 'default' | 'wide' | 'tall'
}

interface FeaturesProps {
  title?: string
  subtitle?: string
  features: Feature[]
}

export function Features({ title, subtitle, features }: FeaturesProps) {
  return (
    <section className="py-24">
      <div className="container mx-auto px-4">
        {(title || subtitle) && (
          <div className="mx-auto max-w-2xl text-center mb-16">
            {title && (
              <h2 className="text-3xl font-bold tracking-tight sm:text-4xl">
                {title}
              </h2>
            )}
            {subtitle && (
              <p className="mt-4 text-lg text-muted-foreground">{subtitle}</p>
            )}
          </div>
        )}
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {features.map((feature, index) => (
            <Card
              key={index}
              className={cn(
                'transition-shadow hover:shadow-md',
                {
                  'md:col-span-2': feature.span === 'wide',
                  'md:row-span-2': feature.span === 'tall',
                }
              )}
            >
              <CardHeader>
                {feature.icon && (
                  <div className="mb-4 inline-flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10 text-primary">
                    {feature.icon}
                  </div>
                )}
                <CardTitle>{feature.title}</CardTitle>
                <CardDescription>{feature.description}</CardDescription>
              </CardHeader>
            </Card>
          ))}
        </div>
      </div>
    </section>
  )
}
```

### 5.3 Testimonials

```tsx
// components/sections/testimonials.tsx
interface Testimonial {
  quote: string
  author: string
  role: string
  company?: string
  avatar?: string
}

interface TestimonialsProps {
  title?: string
  testimonials: Testimonial[]
}

export function Testimonials({ title, testimonials }: TestimonialsProps) {
  return (
    <section className="py-24 bg-muted/50">
      <div className="container mx-auto px-4">
        {title && (
          <h2 className="text-3xl font-bold tracking-tight text-center mb-16">
            {title}
          </h2>
        )}
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {testimonials.map((testimonial, index) => (
            <blockquote
              key={index}
              className="relative rounded-lg bg-background p-6 shadow-sm"
            >
              <p className="text-foreground">"{testimonial.quote}"</p>
              <footer className="mt-4 flex items-center gap-3">
                {testimonial.avatar && (
                  <img
                    src={testimonial.avatar}
                    alt={testimonial.author}
                    className="h-10 w-10 rounded-full object-cover"
                  />
                )}
                <div>
                  <cite className="font-medium not-italic">
                    {testimonial.author}
                  </cite>
                  <p className="text-sm text-muted-foreground">
                    {testimonial.role}
                    {testimonial.company && `, ${testimonial.company}`}
                  </p>
                </div>
              </footer>
            </blockquote>
          ))}
        </div>
      </div>
    </section>
  )
}
```

---

## 6. Form Patterns

### 6.1 Waitlist Form with Server Action

```tsx
// components/forms/waitlist-form.tsx
'use client'

import { useFormState, useFormStatus } from 'react-dom'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { submitWaitlist } from '@/app/actions'

function SubmitButton() {
  const { pending } = useFormStatus()
  
  return (
    <Button type="submit" loading={pending}>
      Join Waitlist
    </Button>
  )
}

export function WaitlistForm() {
  const [state, formAction] = useFormState(submitWaitlist, {
    success: false,
    error: null,
  })

  if (state.success) {
    return (
      <div className="rounded-lg bg-success/10 p-4 text-success">
        <p className="font-medium">You're on the list!</p>
        <p className="text-sm">We'll notify you when we launch.</p>
      </div>
    )
  }

  return (
    <form action={formAction} className="space-y-4">
      <Input
        name="email"
        type="email"
        placeholder="Enter your email"
        required
        error={state.error || undefined}
      />
      <SubmitButton />
    </form>
  )
}
```

```tsx
// app/actions.ts
'use server'

import { z } from 'zod'

const waitlistSchema = z.object({
  email: z.string().email('Please enter a valid email'),
})

export async function submitWaitlist(
  prevState: { success: boolean; error: string | null },
  formData: FormData
) {
  const result = waitlistSchema.safeParse({
    email: formData.get('email'),
  })

  if (!result.success) {
    return { success: false, error: result.error.errors[0].message }
  }

  try {
    // Save to database or send to email service
    // await db.waitlist.create({ data: { email: result.data.email } })
    
    return { success: true, error: null }
  } catch (error) {
    return { success: false, error: 'Something went wrong. Please try again.' }
  }
}
```

---

## 7. Performance Patterns

### 7.1 Image Optimization

```tsx
// Always use next/image for images
import Image from 'next/image'

// Hero image
<Image
  src="/hero-image.jpg"
  alt="Descriptive alt text"
  width={1200}
  height={630}
  priority // Only for above-fold images
  className="rounded-lg"
/>

// Avatar/thumbnail
<Image
  src={user.avatar}
  alt={user.name}
  width={48}
  height={48}
  className="rounded-full"
/>

// Background image with fill
<div className="relative aspect-video">
  <Image
    src="/background.jpg"
    alt=""
    fill
    className="object-cover"
    sizes="(max-width: 768px) 100vw, 50vw"
  />
</div>
```

### 7.2 Dynamic Imports

```tsx
// Lazy load heavy components
import dynamic from 'next/dynamic'

const HeavyChart = dynamic(() => import('@/components/chart'), {
  loading: () => <div className="h-64 animate-pulse bg-muted rounded-lg" />,
  ssr: false, // If component uses browser APIs
})

// Lazy load below-fold sections
const Testimonials = dynamic(() => import('@/components/sections/testimonials'))
const FAQ = dynamic(() => import('@/components/sections/faq'))
```

### 7.3 Metadata for SEO

```tsx
// app/(marketing)/page.tsx
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Your Product - Tagline Here',
  description: 'Clear value proposition in 155 characters or less for search results.',
  openGraph: {
    title: 'Your Product - Tagline Here',
    description: 'Social sharing description',
    images: [
      {
        url: '/og-image.jpg',
        width: 1200,
        height: 630,
        alt: 'Product preview',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Your Product - Tagline Here',
    description: 'Twitter-specific description',
    images: ['/og-image.jpg'],
  },
}
```

---

## 8. Accessibility Checklist

### Required for Every Component

- [ ] Semantic HTML elements (`button`, `nav`, `main`, `section`)
- [ ] Focus styles visible (`:focus-visible` ring)
- [ ] Color contrast 4.5:1 minimum for text
- [ ] Interactive elements have accessible names
- [ ] Form inputs have associated labels
- [ ] Error messages linked with `aria-describedby`
- [ ] Loading states announced to screen readers

### Testing Commands

```bash
# Run Lighthouse
npx lighthouse http://localhost:3000 --view

# Axe accessibility audit
npm install -D @axe-core/react
# Add to development: <ReactAxe />
```

---

## 9. Deployment Checklist

### Pre-Launch

- [ ] Environment variables configured
- [ ] Analytics/tracking installed (respect DNT)
- [ ] Error monitoring setup (Sentry, etc.)
- [ ] Favicon and app icons
- [ ] Open Graph images
- [ ] robots.txt and sitemap
- [ ] 404 and error pages styled
- [ ] Forms tested end-to-end
- [ ] Mobile responsive verified
- [ ] Performance budget met (LCP < 2.5s)

### Vercel Deploy

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy preview
vercel

# Deploy production
vercel --prod
```

---

## References

- `CORE.md` - Design principles and quality defaults
- `PATTERNS/components.md` - Component patterns
- `PATTERNS/layout.md` - Layout patterns
- `STYLES/INDEX.md` - Style selection
- `landing-pages.md` - Conversion-focused patterns

---

*Version: 0.1.0*
