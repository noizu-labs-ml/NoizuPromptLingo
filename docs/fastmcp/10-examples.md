# Examples

> Progressive examples from simple to complex in FastMCP 2.x

## Level 1: Minimal Server

```python
from fastmcp import FastMCP

mcp = FastMCP("Hello Server")

@mcp.tool
def hello(name: str) -> str:
    """Say hello."""
    return f"Hello, {name}!"

if __name__ == "__main__":
    mcp.run()
```

Run:
```bash
fastmcp run hello.py:mcp
```

## Level 2: Multiple Components

```python
from fastmcp import FastMCP

mcp = FastMCP("Multi-Component Server")

# Tools
@mcp.tool
def add(a: int, b: int) -> int:
    """Add two numbers."""
    return a + b

@mcp.tool
def multiply(a: float, b: float) -> float:
    """Multiply two numbers."""
    return a * b

# Resources
@mcp.resource("config://version")
def get_version() -> str:
    return "1.0.0"

@mcp.resource("data://users/{user_id}")
def get_user(user_id: int) -> dict:
    return {"id": user_id, "name": f"User {user_id}"}

# Prompts
@mcp.prompt
def analyze(topic: str) -> str:
    """Request analysis of a topic."""
    return f"Please analyze: {topic}"

if __name__ == "__main__":
    mcp.run()
```

## Level 3: Async with Context

```python
import httpx
from fastmcp import FastMCP
from fastmcp.server.context import Context
from fastmcp.dependencies import CurrentContext

mcp = FastMCP("Async Server")

@mcp.tool
async def fetch_url(url: str, ctx: Context = CurrentContext()) -> dict:
    """Fetch data from a URL."""
    await ctx.info(f"Fetching: {url}")

    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        await ctx.report_progress(1, 1, "Complete")
        return {"status": response.status_code, "length": len(response.content)}

@mcp.tool
async def process_items(
    items: list[str],
    ctx: Context = CurrentContext()
) -> dict:
    """Process multiple items with progress."""
    results = []
    for i, item in enumerate(items):
        await ctx.report_progress(i + 1, len(items), f"Processing {item}")
        results.append(f"Processed: {item}")
    return {"results": results}

if __name__ == "__main__":
    mcp.run()
```

## Level 4: Pydantic Models

```python
from fastmcp import FastMCP
from pydantic import BaseModel, EmailStr

mcp = FastMCP("Typed Server")

class User(BaseModel):
    name: str
    email: EmailStr
    age: int

class CreateUserResult(BaseModel):
    id: int
    user: User
    created: bool

@mcp.tool
def create_user(user: User) -> CreateUserResult:
    """Create a new user."""
    return CreateUserResult(
        id=123,
        user=user,
        created=True
    )

class SearchParams(BaseModel):
    query: str
    limit: int = 10
    filters: dict[str, str] = {}

@mcp.tool
def search(params: SearchParams) -> list[dict]:
    """Search with structured parameters."""
    return [{"id": 1, "match": params.query}]

if __name__ == "__main__":
    mcp.run()
```

## Level 5: Lifespan Management

```python
from contextlib import asynccontextmanager
from dataclasses import dataclass
from collections.abc import AsyncIterator
from fastmcp import FastMCP
from fastmcp.server.dependencies import get_lifespan_state

# Mock database
class Database:
    @classmethod
    async def connect(cls):
        print("Database connected")
        return cls()

    async def disconnect(self):
        print("Database disconnected")

    async def query(self, sql: str) -> list:
        return [{"id": 1, "data": "result"}]

@dataclass
class AppState:
    db: Database

@asynccontextmanager
async def lifespan(server: FastMCP) -> AsyncIterator[AppState]:
    db = await Database.connect()
    try:
        yield AppState(db=db)
    finally:
        await db.disconnect()

mcp = FastMCP("Lifespan Server", lifespan=lifespan)

@mcp.tool
async def query_db(sql: str) -> list:
    """Query the database."""
    state = get_lifespan_state()
    return await state["db"].query(sql)

if __name__ == "__main__":
    mcp.run()
```

## Level 6: Server Composition

```python
from fastmcp import FastMCP

# Weather service
weather = FastMCP("Weather")

@weather.tool
def get_forecast(city: str) -> dict:
    return {"city": city, "temp": 72, "condition": "sunny"}

@weather.resource("weather://{city}/current")
def current_weather(city: str) -> dict:
    return {"city": city, "temp": 72}

# News service
news = FastMCP("News")

@news.tool
def get_headlines() -> list[str]:
    return ["Breaking: FastMCP 2.x released", "Weather update"]

@news.resource("news://latest")
def latest_news() -> list[str]:
    return ["Headline 1", "Headline 2"]

# Composite server
main = FastMCP("Composite Server")

main.import_server(weather, prefix="weather")
main.import_server(news, prefix="news")

@main.tool
def ping() -> str:
    return "Composite OK"

# Available tools: weather_get_forecast, news_get_headlines, ping
# Available resources: weather://weather/{city}/current, news://news/latest

if __name__ == "__main__":
    main.run()
```

## Level 7: Authentication

```python
from fastmcp import FastMCP
from fastmcp.server.auth import BearerAuthProvider

auth = BearerAuthProvider(
    jwks_uri="https://auth.example.com/.well-known/jwks.json",
    issuer="https://auth.example.com",
    audience="mcp-server",
)

mcp = FastMCP("Authenticated Server", auth=auth)

@mcp.tool
def protected_operation() -> str:
    """Only accessible with valid authentication."""
    return "Secret data"

@mcp.resource("secure://config")
def secure_config() -> dict:
    return {"api_key": "***"}

if __name__ == "__main__":
    mcp.run(transport="http", port=8000)
```

## Level 8: Middleware

```python
from fastmcp import FastMCP
from fastmcp.server.middleware import Middleware, MiddlewareContext
import time

class TimingMiddleware(Middleware):
    async def on_request(self, context: MiddlewareContext, call_next):
        start = time.time()
        result = await call_next(context)
        duration = time.time() - start
        print(f"[{context.method}] {duration:.3f}s")
        return result

class LoggingMiddleware(Middleware):
    async def on_request(self, context: MiddlewareContext, call_next):
        print(f"Request: {context.method}")
        result = await call_next(context)
        print(f"Response: {context.method}")
        return result

mcp = FastMCP("Middleware Server")
mcp.add_middleware(TimingMiddleware())
mcp.add_middleware(LoggingMiddleware())

@mcp.tool
def slow_operation() -> str:
    import time
    time.sleep(0.5)
    return "Done"

if __name__ == "__main__":
    mcp.run()
```

## Level 9: OpenAPI Integration

```python
from fastapi import FastAPI
from fastmcp import FastMCP
from fastmcp.server.openapi import RouteMap, MCPType

# Existing FastAPI app
api = FastAPI()

@api.get("/users/{user_id}")
def get_user(user_id: int):
    return {"id": user_id, "name": "Alice"}

@api.post("/users")
def create_user(name: str):
    return {"id": 123, "name": name}

@api.get("/health")
def health():
    return {"status": "ok"}

# Convert to MCP with custom route mapping
mcp = FastMCP.from_fastapi(
    app=api,
    route_maps=[
        RouteMap(
            methods=["GET"],
            pattern=r".*\{.*\}.*",
            mcp_type=MCPType.RESOURCE_TEMPLATE
        ),
        RouteMap(
            methods=["GET"],
            pattern=r".*",
            mcp_type=MCPType.RESOURCE
        ),
    ],
)

if __name__ == "__main__":
    mcp.run()
```

## Level 10: Production Server

```python
from contextlib import asynccontextmanager
from dataclasses import dataclass
from collections.abc import AsyncIterator

from fastmcp import FastMCP
from fastmcp.server.context import Context
from fastmcp.dependencies import CurrentContext
from fastmcp.server.middleware import Middleware, MiddlewareContext
from fastmcp.server.auth import BearerAuthProvider
from fastmcp.server.http import custom_route
from fastmcp.server.dependencies import get_lifespan_state
from starlette.responses import JSONResponse
import os

# Database
class Database:
    @classmethod
    async def connect(cls):
        return cls()
    async def disconnect(self):
        pass
    async def query(self, sql: str) -> list:
        return []

@dataclass
class AppState:
    db: Database

# Lifespan
@asynccontextmanager
async def lifespan(server: FastMCP) -> AsyncIterator[AppState]:
    db = await Database.connect()
    try:
        yield AppState(db=db)
    finally:
        await db.disconnect()

# Middleware
class RequestLogger(Middleware):
    async def on_request(self, context: MiddlewareContext, call_next):
        print(f"[{context.method}]")
        return await call_next(context)

# Auth
auth = BearerAuthProvider(
    jwks_uri=os.environ.get("JWKS_URI", "https://auth.example.com/.well-known/jwks.json"),
    issuer=os.environ.get("AUTH_ISSUER", "https://auth.example.com"),
    audience=os.environ.get("AUTH_AUDIENCE", "mcp-server"),
)

# Server
mcp = FastMCP(
    "Production Server",
    lifespan=lifespan,
    auth=auth
)
mcp.add_middleware(RequestLogger())

# Health check
@custom_route("/health", methods=["GET"])
async def health(request):
    return JSONResponse({"status": "healthy"})

# Tools
@mcp.tool
async def get_users(ctx: Context = CurrentContext()) -> list[dict]:
    """Fetch all users."""
    await ctx.info("Fetching users...")
    state = get_lifespan_state()
    return await state["db"].query("SELECT * FROM users")

@mcp.tool
async def process_data(
    data: str,
    validate: bool = True,
    ctx: Context = CurrentContext()
) -> dict:
    """Process input data."""
    await ctx.info(f"Processing: {data[:50]}...")

    if validate:
        await ctx.report_progress(1, 2, "Validating")

    await ctx.report_progress(2, 2, "Processing")

    return {"processed": True, "length": len(data)}

# Resources
@mcp.resource("config://app")
def app_config() -> dict:
    return {
        "version": "2.0.0",
        "environment": os.environ.get("ENV", "development")
    }

@mcp.resource("users://{user_id}/profile")
async def user_profile(user_id: int, ctx: Context = CurrentContext()) -> dict:
    await ctx.info(f"Fetching profile for {user_id}")
    return {"id": user_id, "name": f"User {user_id}"}

# Prompts
@mcp.prompt
def analyze_data(data_type: str, depth: str = "summary") -> str:
    return f"Analyze the {data_type} data with {depth} depth."

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    mcp.run(transport="http", host="0.0.0.0", port=port)
```

## Client Example

```python
import asyncio
from fastmcp import Client

async def main():
    client = Client("http://localhost:8000/mcp")

    async with client:
        # List tools
        tools = await client.list_tools()
        print(f"Tools: {[t.name for t in tools]}")

        # Call tool
        result = await client.call_tool("process_data", {
            "data": "Hello, World!",
            "validate": True
        })
        print(f"Result: {result.content}")

        # Read resource
        config = await client.read_resource("config://app")
        print(f"Config: {config}")

        # Get prompt
        prompts = await client.list_prompts()
        if prompts:
            prompt = await client.get_prompt("analyze_data", {
                "data_type": "sales"
            })
            print(f"Prompt: {prompt}")

asyncio.run(main())
```

## Testing Example

```python
import asyncio
from fastmcp import FastMCP, Client

# Server
mcp = FastMCP("Test Server")

@mcp.tool
def add(a: int, b: int) -> int:
    return a + b

@mcp.resource("test://value")
def test_value() -> str:
    return "test"

# Tests
async def test_tool():
    async with Client(mcp) as client:
        result = await client.call_tool("add", {"a": 5, "b": 3})
        assert "8" in str(result.content)
        print("Tool test passed!")

async def test_resource():
    async with Client(mcp) as client:
        content = await client.read_resource("test://value")
        assert content
        print("Resource test passed!")

async def run_tests():
    await test_tool()
    await test_resource()
    print("All tests passed!")

if __name__ == "__main__":
    asyncio.run(run_tests())
```

---

**Previous**: [Migration](09-migration.md) | **Index**: [README](README.md)
