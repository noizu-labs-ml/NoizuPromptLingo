# Code Review Style Guide

## Introduction

Full-stack projects using **Next.js 15** (App Router, React 19, Tailwind CSS 4) on the frontend and **Phoenix 1.8** (Elixir, Ecto, Guardian JWT) on the backend. Deployed on Kubernetes with nginx reverse proxy, PostgreSQL, and Redis. Reviews should prioritize security, correctness, and operational safety over style nitpicks.

## Priority Order

1. Security vulnerabilities (CRITICAL)
2. Correctness bugs, race conditions, data loss (HIGH)
3. Missing error handling, unhandled failure modes (HIGH)
4. Performance issues, N+1 queries, memory leaks (MEDIUM)
5. Missing input validation at system boundaries (MEDIUM)
6. Style, naming, formatting (LOW — defer to linters)

## Security Rules

- Never hardcode secrets, API keys, or credentials — all secrets via environment variables or Infisical
- Flag any `.env` files or secrets committed to source
- JWT tokens must have expiration; never accept unsigned tokens
- All API endpoints must validate authentication (Guardian plugs on Phoenix, middleware on Next.js)
- Flag raw SQL or Ecto fragment() calls without parameterized inputs
- React: flag dangerouslySetInnerHTML and unescaped user content (XSS vectors)
- CORS configuration must be explicit, never wildcard in production

## TypeScript / Next.js 15

- Strict TypeScript — flag `any` types
- React components must be functional (no class components)
- Use App Router conventions: `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`
- API routes must validate input (zod or equivalent)
- Server Components by default; only use `"use client"` when necessary
- Server Actions must validate and sanitize inputs
- Image optimization: use `next/image`, flag raw `<img>` tags
- No `console.log` in committed code — use structured logging

## Elixir / Phoenix 1.8

- Follow standard Elixir formatting (`mix format`)
- Use pattern matching over conditional chains where appropriate
- Ecto changesets must validate all user-facing inputs
- Flag missing `Repo.transaction` around multi-step database operations
- All controller actions need proper error clauses (not just happy path)
- Plugs should halt the connection on auth failure, not fall through
- Use `Logger` module, never `IO.puts` or `IO.inspect` in production code
- GenServer/process work: flag missing handle_info catch-alls and supervision strategies
- Migrations: flag destructive changes (column drops, table drops) without explicit confirmation

## Database / Ecto

- All migrations must be reversible where possible
- Flag missing indexes on foreign keys and frequently queried columns
- Flag N+1 query patterns — use preloads or explicit joins
- Changesets must cast and validate; flag `cast` without corresponding `validate_required`

## Docker / Kubernetes / nginx

- Dockerfiles must pin base image versions (no `:latest`)
- Multi-stage builds expected — flag single-stage production images
- nginx config: flag missing rate limiting, missing security headers
- Health check endpoints must exist (`/health` or `/api/health`)
- Resource requests/limits should be set on all containers

## What NOT to Flag

- Import ordering (handled by prettier / mix format)
- Trailing whitespace or minor formatting
- Tailwind class ordering (handled by prettier plugin)
- Test file naming conventions
- Comments in test files
- YAML indentation style (2-space is fine)
