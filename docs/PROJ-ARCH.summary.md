# Project Architecture Summary

## Overview
NPL MCP is a Model Context Protocol server built on FastMCP 2.x using a three-tier tool pattern: 11 MCP-visible tools at startup (5 discovery + 1 NPL spec + 2 session + 3 instruction), ~22 hidden tools callable via ToolCall, ~93 stub tools for planned features. Unified catalog of ~126 tools. FastAPI for routing and Next.js frontend, LiteLLM proxy for LLM-powered features, PostgreSQL for persistent storage.

## Components
- **Launcher** (`launcher.py`): create_app() + create_asgi_app(), CLI, Uvicorn
- **Meta Tools** (`meta_tools/`): ToolSummary, ToolSearch, ToolDefinition, ToolHelp, ToolCall — discovery layer, catalog builder, stub catalog
- **NPL Spec** (`convention_formatter.py`): NPLSpec tool — NPL definition generation from convention YAMLs
- **Markdown** (`markdown/`): Converter, viewer, CSS/heading/xpath filters, image descriptions
- **NPL Parser** (`npl/`): YAML loader, syntax parser, reference resolver
- **PM Tools** (`pm_tools/`): PRD/story/persona access — file-based + DB-backed CRUD (13 hidden tools)
- **Instructions** (`instructions/`): Versioned instruction documents with embeddings (3 registered + 3 hidden)
- **Tool Sessions** (`tool_sessions/`): Session tracking by (project, agent, task) triple (2 registered)
- **Browser** (`browser/`): ToMarkdown, Ping, Download, Screenshot, Rest, Secret (5 hidden + stubs)
- **Storage** (`storage/`): PostgreSQL async connection pool (asyncpg)
- **Frontend** (`frontend/`): Next.js + Tailwind, static export to `web/static/`
- Stub modules: artifacts, chat, executors, scripts, sessions, tasks

## Stack
MCP protocol, FastMCP 2.x, FastAPI, Uvicorn, SSE transport, PostgreSQL (asyncpg, port 5111), Liquibase migrations, LiteLLM proxy (port 4111), Next.js + Tailwind frontend

## Infrastructure
- NPL MCP Server: port 8765 (MCP SSE + web UI)
- LiteLLM Proxy: port 4111 (LLM routing)
- PostgreSQL: port 5111 (database `npl`)
- Docker Compose for PostgreSQL, Liquibase for schema

## Agent Orchestration
5-agent TDD pipeline: npl-idea-to-spec → npl-prd-editor → npl-tdd-tester → npl-tdd-coder → npl-tdd-debugger (on failure)
