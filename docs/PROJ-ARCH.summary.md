# Project Architecture Summary

## Overview
NPL MCP server built on FastMCP 2.x using a meta tool pattern: 2 discovery tools registered (ToolSummary, ToolSearch), 96 tools in static catalog. FastAPI + Next.js frontend, LiteLLM proxy for LLM features, PostgreSQL for storage.

## Components
- **Launcher** (`launcher.py`): create_app() + create_asgi_app(), CLI, Uvicorn
- **Meta Tools** (`meta_tools/`): ToolSummary, ToolSearch, static catalog (96 tools, 15 categories)
- **Markdown** (`markdown/`): Converter, viewer, CSS/heading/xpath filters, image descriptions
- **NPL Parser** (`npl/`): YAML loader, syntax parser, reference resolver
- **PM Tools** (`pm_tools/`): PRD, user story, persona access (8 catalog tools)
- **Frontend** (`frontend/`): Next.js + Tailwind, static export to `web/static/`
- Stub modules: artifacts, browser, chat, executors, scripts, sessions, storage, tasks

## Stack
MCP protocol, FastMCP 2.x, FastAPI, Uvicorn, SSE transport, PostgreSQL (asyncpg, port 5111), Liquibase migrations, LiteLLM proxy (port 4111), Next.js + Tailwind frontend

## Infrastructure
- NPL MCP Server: port 8765 (MCP SSE + web UI)
- LiteLLM Proxy: port 4111 (LLM routing)
- PostgreSQL: port 5111 (database `npl`)
- Docker Compose for PostgreSQL, Liquibase for schema

## Agent Orchestration
5-agent TDD pipeline: npl-idea-to-spec → npl-prd-editor → npl-tdd-tester → npl-tdd-coder → npl-tdd-debugger (on failure)
