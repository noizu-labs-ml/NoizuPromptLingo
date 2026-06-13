# Infrastructure

## Technology Stack

| Layer | Technology | Version | Rationale |
|-------|-----------|---------|-----------|
| Frontend | Next.js (App Router) | 16.1 | SSR for screen reader first-paint, App Router layouts map to game regions |
| UI Framework | React | 19.2 | Component model for ARIA live region management |
| Styling | Tailwind CSS | 4 | Utility classes for responsive, accessible layouts |
| Backend | Elixir / Phoenix | 1.15+ / 1.8 | OTP process isolation for game entities, Channels for real-time |
| ORM | Ecto | 3.13 | Schema-driven persistence with migration support |
| Auth | Guardian + bcrypt | 2.3 / 3.0 | JWT-based stateless authentication |
| Database | TimescaleDB (PostgreSQL 17 + AGE) | pg17.9-ts2.25.2 | Time-series + graph extensions |
| Cache | Redis | 7-alpine | Session cache, pub/sub, rate limiting |
| AI | GenAI (Noizu) | 0.2.4 | Narrative generation pipeline |
| Entities | noizu_labs_entities | 0.2.2 | Entity framework for game objects |
| E2E Testing | Cypress + Cucumber | 15.11 | BDD feature specs with Gherkin syntax |
| Dev Services | Docker Compose | — | Local PostgreSQL + Redis |

## Local Development

```bash
# Start backing services
docker compose up -d

# Backend
cd backend && mix deps.get && mix ecto.setup && mix phx.server

# Frontend
cd web && npm install && npm run dev
```

## Docker Images

Two Dockerfiles exist for containerized deployment:

- `web/Dockerfile` — Next.js production build
- `backend/Dockerfile` — Elixir release build

## Database

Custom Docker image: `noizu/timescaledb-ha-with-age:pg17.9-ts2.25.2-all-age1.7.0`

Combines:
- **PostgreSQL 17** — Core relational store
- **TimescaleDB** — Time-series hypertables for game telemetry, analytics, event logs
- **Apache AGE** — Graph database extension for NPC relationships, faction networks, quest dependency graphs

Database: `blade_of_eternity_dev`, user: `boe`

## Backend Contexts

Phoenix contexts encapsulate domain logic:

| Context | Responsibility |
|---------|---------------|
| `Boe.Accounts` | User registration, authentication, profile management |
| `Boe.Game` | Character management, game state |
| `Boe.Guardian` | JWT token generation and validation |
| `Boe.Mailer` | Transactional email (Swoosh) |

## Frontend Routes

| Route | Purpose |
|-------|---------|
| `/` | Landing page |
| `/login` | Authentication |
| `/signup` | Registration |
| `/create-character` | Character creation |
| `/game` | Main game interface |
| `/contact`, `/privacy`, `/terms`, `/cookie` | Legal/info pages |

## Testing Strategy

- **E2E**: Cypress with Cucumber/Gherkin BDD specs (`web/e2e/`)
- **Unit**: ExUnit for backend (`backend/test/`)
- **Cypress attributes**: Co-located `.cy.yaml` sidecar files document test selectors per page (see `docs/cypress-attributes.md`)
- **Precommit**: `mix precommit` runs compile warnings, dep check, format, and tests
