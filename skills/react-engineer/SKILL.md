---
name: react-engineer
description: Expert React engineering for production applications — React 19.x, Next.js 15–16 (App Router, RSC, Server Actions, Cache Components, Turbopack), Redux Toolkit 2.x with RTK Query, browser Navigation API / deep linking / history / back-button handling, View Transitions API, React Compiler, TypeScript integration, SSR/SSG/ISR/PPR rendering strategies, performance optimization, SEO, and cost control. Use this skill when building React components, implementing client or server routing, managing state with Redux or Zustand, debugging hydration mismatches, optimizing renders and Core Web Vitals, migrating from Pages Router to App Router, implementing optimistic updates, handling browser history/deep links/back-button, setting up SSR/SSG/ISR/PPR, reducing serverless costs, configuring middleware, or modernizing a React codebase — even if they don't say "React." Also trigger when users mention useActionState, useOptimistic, use(), React Server Components, RSC, cache components, use cache, navigation API, view transitions, useEffectEvent, Activity, Turbopack, React Compiler, App Router, Server Actions, parallel routes, intercepting routes, middleware, RTK Query, createAsyncThunk, Redux Toolkit, Zustand, TanStack Query, LCP, CLS, INP, Core Web Vitals, ISR, PPR, streaming SSR, serverless cost, edge runtime, SEO metadata, open graph, structured data, or React performance optimization.
---

# React Engineer

## Overview

- **Production-grade React** across React 18–19.x with full knowledge of post-training changes through May 2026
- **Next.js 15–16 expertise**: App Router, React Server Components, Cache Components, Turbopack, Build Adapters, navigation hooks
- **State management mastery**: Redux Toolkit 2.x / RTK Query, Zustand, TanStack Query — when to use which and how to combine them
- **Browser navigation deep cuts**: Navigation API, History API, deep linking, back-button handling, scroll restoration, URL state sync
- **Modern transitions and animations**: View Transitions API (SPA and cross-document), `startViewTransition`, CSS `@view-transition`
- **Performance at scale**: React Compiler v1.0, Server Components, streaming SSR, Partial Pre-Rendering, bundle optimization, Core Web Vitals
- **SSR/SSG/ISR/PPR rendering strategies**: When to use each, SEO metadata, structured data, sitemap generation, open graph
- **Cost control**: Serverless function optimization, caching to reduce compute, ISR tuning, edge runtime selection, database query reduction

## Core Philosophy

1. **Framework-first, not library-first** — Understand React as the runtime, Next.js as the framework, and the browser as the platform. Optimize at the right layer.
2. **Server by default, client when needed** — RSC is the baseline. Client components opt in. Never `'use client'` by habit.
3. **URL is state** — Deep-linkable URLs are not optional. Every navigable state change should be reflected in the URL. Browser back/forward must always work correctly.
4. **Progressive enhancement** — Use View Transitions, Navigation API, and modern APIs where supported, with graceful fallbacks.
5. **Type safety end-to-end** — TypeScript strict mode, typed routes, typed actions, typed API responses. No `any` unless there's a damn good reason.

## When to Use

- **Building new React/Next.js features**: Components, pages, layouts, API routes, middleware
- **State management decisions**: Choosing between Redux, Zustand, TanStack Query, URL state, or server state
- **Routing and navigation**: App Router patterns, deep linking, back-button behavior, scroll restoration, programmatic navigation
- **Performance optimization**: React Compiler, memoization, code splitting, streaming, suspense boundaries, Core Web Vitals
- **SSR/SSG/ISR/PPR strategy**: Choosing the right rendering strategy for each page, SEO metadata, structured data, sitemaps
- **Cost control**: Serverless function optimization, ISR tuning, edge runtime selection, caching strategy, bandwidth reduction
- **Migration work**: Pages Router → App Router, React 18 → 19, Next.js 14 → 15/16, CRA → Vite/Next.js
- **Debugging**: Hydration mismatches, stale closures, memory leaks, render loops, suspense waterfalls
- **Security**: RSC vulnerability mitigation (CVE-2025-66478, CVE-2025-55184, CVE-2025-55183), Server Action input validation, middleware auth

## Anti-Scope

This skill does NOT cover:
- React Native (mobile-specific concerns)
- Non-React frameworks (Vue, Svelte, Angular)
- Backend infrastructure (databases, message queues, container orchestration)
- Design system creation (see `user-experience-engineer`)

> For mobile React Native engineering, use a dedicated mobile skill.
> For backend API design beyond Next.js Route Handlers, use a backend engineering skill.
> For UI/UX design and component libraries, see `user-experience-engineer`.

## Quick Start Guides

### Building a New Next.js Feature
1. Read [nextjs-app-router-guide.md](references/nextjs-app-router-guide.md) for layout/routing patterns
2. Check [react-19-features.md](references/react-19-features.md) for applicable new hooks and APIs
3. Follow the workflow in [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md)

### Implementing Deep Linking / Browser History
1. Read [browser-navigation-guide.md](references/browser-navigation-guide.md) cover to cover
2. Check [url-state-patterns.md](references/url-state-patterns.md) for your specific pattern
3. Use the testing checklist in [browser-navigation-guide.md](references/browser-navigation-guide.md#testing-checklist)

### Migrating to React 19 / Next.js 16
1. Read [migration-guide.md](references/migration-guide.md) for breaking changes
2. Check [security-advisories.md](references/security-advisories.md) — there are critical CVEs you MUST patch
3. Follow the step-by-step migration workflow

### State Management Decision
1. Read [state-management-guide.md](references/state-management-guide.md) for the decision matrix
2. Check worked examples in [worked-example-state-management.md](references/worked-example-state-management.md)

### Optimizing Performance and Core Web Vitals
1. Read [performance-optimization-guide.md](references/performance-optimization-guide.md) for the full optimization playbook
2. Check [ssr-ssg-isp-guide.md](references/ssr-ssg-isp-guide.md) for rendering strategy decisions
3. Use [assets/performance-audit-template.md](assets/performance-audit-template.md) for structured audits

### Reducing Serverless Costs
1. Read [cost-control-guide.md](references/cost-control-guide.md) for cost optimization strategies
2. Review [ssr-ssg-isp-guide.md](references/ssr-ssg-isp-guide.md) for ISR/PPR patterns that reduce compute
3. Check [worked-example-ssr-performance.md](references/worked-example-ssr-performance.md) for a full cost/perf optimization walkthrough

### Setting Up SEO and SSR
1. Read [ssr-ssg-isp-guide.md](references/ssr-ssg-isp-guide.md) for SSR/SSG/ISR/PPR strategy
2. Follow the SEO checklist and structured data patterns
3. Use [assets/pr-review-checklist.md](assets/pr-review-checklist.md) to verify SEO items in PRs

## Reference Guide

| Task | Read This |
|------|-----------|
| React 19 new APIs and hooks | `references/react-19-features.md` |
| Next.js 15–16 App Router patterns | `references/nextjs-app-router-guide.md` |
| Browser Navigation API / history / deep links | `references/browser-navigation-guide.md` |
| URL-as-state patterns | `references/url-state-patterns.md` |
| View Transitions API integration | `references/view-transitions-guide.md` |
| Redux Toolkit / RTK Query patterns | `references/state-management-guide.md` |
| React Compiler and performance | `references/react-compiler-guide.md` |
| Performance optimization (bundle, caching, images) | `references/performance-optimization-guide.md` |
| SSR / SSG / ISR / PPR strategy | `references/ssr-ssg-isp-guide.md` |
| SEO (metadata, structured data, sitemaps) | `references/ssr-ssg-isp-guide.md` |
| Cost control (serverless, edge, DB optimization) | `references/cost-control-guide.md` |
| Migration guides (React 19, Next.js 16) | `references/migration-guide.md` |
| Security advisories and mitigations | `references/security-advisories.md` |
| TypeScript patterns for React | `references/typescript-patterns.md` |
| Testing (Vitest, RTL, Playwright, Server Actions) | `references/testing-guide.md` |

## Related Skills

- **user-experience-engineer** — Component library design, accessibility audits, UI mockups
- **kubernetes-engineer** — Deploying Next.js on Kubernetes with Helm charts
- **threat-modeler** — Security review of RSC endpoints and Server Actions

## Bundled Resources

### References

- [react-19-features.md](references/react-19-features.md) — React 19, 19.1, 19.2 features: Actions, useActionState, useOptimistic, use(), Activity, useEffectEvent, React Compiler v1.0
- [nextjs-app-router-guide.md](references/nextjs-app-router-guide.md) — Next.js 15–16: App Router, RSC, Server Actions, Cache Components, Turbopack, Build Adapters, navigation hooks
- [browser-navigation-guide.md](references/browser-navigation-guide.md) — Navigation API, History API, deep linking, back-button, scroll restoration, programmatic navigation
- [url-state-patterns.md](references/url-state-patterns.md) — URL search params as state, sync patterns, serialization, shallow routing
- [view-transitions-guide.md](references/view-transitions-guide.md) — View Transitions API: SPA and cross-document, CSS integration, React/Next.js integration
- [state-management-guide.md](references/state-management-guide.md) — Redux Toolkit 2.x, RTK Query, Zustand, TanStack Query: when to use which, patterns, anti-patterns
- [react-compiler-guide.md](references/react-compiler-guide.md) — React Compiler v1.0: setup, opt-out patterns, known limitations, Next.js integration
- [performance-optimization-guide.md](references/performance-optimization-guide.md) — Bundle optimization, caching, image perf, prefetching, edge runtime, monitoring, Core Web Vitals
- [ssr-ssg-isp-guide.md](references/ssr-ssg-isp-guide.md) — SSR/SSG/ISR/PPR decision matrix, streaming, SEO metadata, structured data, sitemaps, open graph
- [cost-control-guide.md](references/cost-control-guide.md) — Serverless cost optimization, ISR tuning, DB cost reduction, edge vs nodejs, self-hosting, bandwidth
- [migration-guide.md](references/migration-guide.md) — React 18->19, Next.js 14->15->16, Pages->App Router migration steps
- [security-advisories.md](references/security-advisories.md) — CVE-2025-66478, CVE-2025-55184, CVE-2025-55183: impact, affected versions, mitigations
- [typescript-patterns.md](references/typescript-patterns.md) — Strict React TypeScript: typed routes, typed actions, generic components, discriminated unions
- [testing-guide.md](references/testing-guide.md) — Vitest, React Testing Library, MSW, Server Action testing, API route testing, Playwright E2E
- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) — Agent role definition and execution workflows
- [worked-example-state-management.md](references/worked-example-state-management.md) — End-to-end state management decision and implementation
- [worked-example-deep-linking.md](references/worked-example-deep-linking.md) — End-to-end deep linking implementation with back-button support
- [worked-example-ssr-performance.md](references/worked-example-ssr-performance.md) — End-to-end: taking a slow page from 4s to <1s LCP with ISR, PPR, and cost reduction

### Assets

- [component-checklist.md](assets/component-checklist.md) — Pre-merge checklist for React components
- [performance-audit-template.md](assets/performance-audit-template.md) — React performance audit template
- [pr-review-checklist.md](assets/pr-review-checklist.md) — PR review checklist for React/Next.js pull requests

### Scripts

- (reserved for future automation)
