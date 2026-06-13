# Polyglot ORM & Migration Framework Reference

> Written from the DBA's chair. Every ORM is a SQL generator you didn't write,
> running queries you haven't reviewed, against a schema it thinks it owns.
> This guide is about taking that control back.

---

## Overview

ORMs are leaky abstractions over SQL. They trade query visibility for developer velocity, and that trade gets expensive in production. This reference covers 15 frameworks across 7 languages with a single lens: **what SQL does this thing actually generate, and how do I make it generate better SQL?**

Each framework section follows the same structure so you can compare apples to apples. The goal is not to teach you the ORM — it's to show you the database consequences of each ORM decision and give you the escape hatches when the abstraction fights you.

**How to use this guide:**
- If you're reviewing a PR that touches ORM code, check the relevant framework section for gotchas
- If you're debugging slow queries, start with "Setup & SQL logging" to see what's actually hitting PostgreSQL
- If you're choosing an ORM, read the "Common gotchas" sections — they tell you more than any feature matrix

---

## Universal ORM Anti-Patterns

These patterns appear in every ORM. The syntax differs; the damage to your database is the same.

### 1. N+1 Queries

**The pattern:** Load a list of parents, then loop over them and lazy-load children one at a time.

```
-- What you think you wrote:
"Get all orders with their items"

-- What the database sees:
SELECT * FROM orders;                    -- 1 query
SELECT * FROM items WHERE order_id = 1;  -- N queries
SELECT * FROM items WHERE order_id = 2;  --   (one per order)
SELECT * FROM items WHERE order_id = 3;
-- ... 997 more
```

**The cost:** 1 + N round trips. Each round trip has network latency, parse time, plan time. For 1000 orders, you're doing 1001 queries instead of 1-2.

**The fix (universal):** Every ORM has an eager loading mechanism. The specifics vary:

| Framework | N+1 Fix |
|-----------|---------|
| Ecto | `Repo.preload(orders, :items)` or `from o in Order, preload: [:items]` |
| SQLAlchemy | `joinedload(Order.items)` or `selectinload(Order.items)` |
| Django | `select_related()` (FK/OneToOne) / `prefetch_related()` (M2M/reverse FK) |
| Hibernate | `@EntityGraph`, `JOIN FETCH` in JPQL |
| Eloquent | `Order::with('items')->get()` |
| Prisma | `include: { items: true }` |
| Drizzle | `query.orders.findMany({ with: { items: true } })` |
| TypeORM | `relations: ['items']` or `leftJoinAndSelect` |
| Sequelize | `Order.findAll({ include: Item })` |
| GORM | `db.Preload("Items").Find(&orders)` |
| Diesel | Manual join + `belonging_to` |
| ent | `.WithItems()` on the query builder |

### 2. Eager Loading Everything (Cartesian Explosion)

**The pattern:** "N+1 is bad, so I'll eager load ALL associations." This creates a cartesian product when you join multiple has-many relationships.

```sql
-- You eager-loaded orders → items AND orders → shipments
SELECT o.*, i.*, s.*
FROM orders o
LEFT JOIN items i ON i.order_id = o.id
LEFT JOIN shipments s ON s.order_id = o.id;

-- If an order has 10 items and 3 shipments, that's 30 rows per order.
-- 1000 orders × 10 items × 3 shipments = 30,000 rows returned.
-- The actual data is 1000 + 10,000 + 3,000 = 14,000 rows.
```

**The fix:** Use separate queries (subquery loading) for multiple has-many associations. Only use JOIN-based eager loading for belongs-to / has-one relationships.

| Framework | Subquery/Separate Loading |
|-----------|--------------------------|
| SQLAlchemy | `selectinload()` instead of `joinedload()` for collections |
| Django | `prefetch_related()` (always uses separate query) |
| Hibernate | `@BatchSize`, `FetchMode.SUBSELECT` |
| Ecto | `Repo.preload()` (uses separate queries by default) |
| Prisma | Always uses separate queries (safe by default) |

### 3. Letting the ORM Manage Schema

**The problem:** ORM-generated migrations optimize for "it works," not for "it performs." Common issues:

- Missing partial indexes (ORMs create full b-tree indexes or nothing)
- Wrong index types (no GIN for JSONB, no GiST for geometry, no BRIN for time-series)
- No `CONCURRENTLY` on index creation (locks the table in production)
- VARCHAR(255) everywhere (MySQL legacy default leaking into PostgreSQL)
- Missing `NOT NULL` constraints (ORMs default to nullable)
- No check constraints (ORMs don't model them)
- No exclusion constraints
- Serial vs identity columns (ORMs often use deprecated `serial`)

**The fix:** Use the ORM for DML (queries). Use a migration tool you control for DDL (schema changes). If you must use the ORM's migration system, **always review the generated SQL before applying.**

### 4. Ignoring Generated SQL

**How to log SQL in each framework:**

| Framework | SQL Logging |
|-----------|-------------|
| Ecto | `config :logger, level: :debug` — Ecto logs all queries by default in dev |
| SQLAlchemy | `create_engine(echo=True)` or `logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)` |
| Django | `LOGGING` config with `django.db.backends` logger, or `django-debug-toolbar` |
| Hibernate | `hibernate.show_sql=true`, `hibernate.format_sql=true`, `org.hibernate.SQL=DEBUG` |
| Eloquent | `DB::listen(fn($q) => Log::info($q->sql))` or `->toSql()` |
| Prisma | `prisma.$on('query', (e) => console.log(e.query))` or `log: ['query']` in client |
| Drizzle | `logger: true` in drizzle config |
| TypeORM | `logging: true` in connection options, or `logging: ["query"]` |
| Sequelize | `logging: console.log` in options (on by default in dev) |
| Knex | `debug: true` in config |
| Diesel | `diesel::debug_query::<Pg, _>(&query)` — compile-time, prints to stderr |
| SQLx | `SQLX_LOG=info` env var, or `sqlx::query!` macro output |
| GORM | `db.Debug()` or global `logger.Default.LogMode(logger.Info)` |
| sqlc | N/A — you write the SQL; sqlc just generates Go code |
| ent | `ent.Debug()` option on client creation |

**Production logging:** Don't log all queries in production. Instead:
- PostgreSQL: `log_min_duration_statement = 100` (log queries > 100ms)
- pgBadger or pganalyze for query analysis
- `pg_stat_statements` extension for aggregate query metrics
- `auto_explain` extension with `auto_explain.log_min_duration`

### 5. Trusting ORM Defaults for Production

Every ORM ships with defaults tuned for "works on my laptop." Production needs different settings.

**Connection pool sizing:**
The formula that matters: `pool_size = (core_count * 2) + effective_spindle_count`. For SSDs, assume spindle count = 1. A 4-core server wants a pool of ~9, not 50.

**Common defaults that hurt you:**

| Setting | Typical Default | Production Value | Why |
|---------|----------------|-----------------|-----|
| Pool size | 5-10 | Calculate per formula | Too few = contention; too many = thrashing |
| Statement timeout | None | 30s | Runaway queries eat connections |
| Idle connection timeout | None/infinite | 300s | Dead connections exhaust pool |
| Prepared statements | Varies | Depends on pooler | PgBouncer transaction mode breaks named prepared statements |
| Lock timeout | None | 5s | DDL waiting for locks blocks everything behind it |

---

## Per-Framework Sections

---

### 1. Ecto (Elixir)

**Ecosystem:** Phoenix framework, Elixir. Repo pattern (not ActiveRecord). Explicitly opt-in to everything — Ecto does not hide SQL from you.

#### Setup & SQL Logging

Ecto logs all queries at `:debug` level by default. In `config/dev.exs`:

```elixir
config :my_app, MyApp.Repo,
  log: :debug  # default — logs SQL + timing

# For custom telemetry (production monitoring):
:telemetry.attach("repo-query", [:my_app, :repo, :query], &handle_event/4, nil)
```

#### Schema Definition

```elixir
defmodule MyApp.Order do
  use Ecto.Schema

  schema "orders" do
    field :status, :string
    field :total, :decimal
    has_many :items, MyApp.Item
    belongs_to :customer, MyApp.Customer
    timestamps()  # inserted_at, updated_at — uses utc_datetime_usec in modern Ecto
  end
end
```

**What it gets wrong:**
- `timestamps()` defaults to `naive_datetime` in older versions — always use `@timestamps_opts [type: :utc_datetime_usec]`
- No partial index support in schema definition (use raw migration SQL)
- `serial` primary keys by default in older Ecto — modern Ecto uses `bigserial`. Consider UUIDs: `@primary_key {:id, :binary_id, autogenerate: true}`

#### Query Patterns

```elixir
# Good: explicit select, explicit join
from o in Order,
  join: c in assoc(o, :customer),
  where: o.status == "pending",
  where: o.inserted_at > ^cutoff,
  select: %{id: o.id, total: o.total, customer_name: c.name}

# Good: composable queries
def pending(query \\ Order), do: where(query, [o], o.status == "pending")
def recent(query, days), do: where(query, [o], o.inserted_at > ago(^days, "day"))

Order |> pending() |> recent(7) |> Repo.all()
```

#### N+1 Prevention

```elixir
# Separate queries (default, usually best):
orders = Repo.all(Order) |> Repo.preload(:items)

# Single query with join (good for belongs_to, risky for has_many):
from(o in Order, join: i in assoc(o, :items), preload: [items: i])
|> Repo.all()

# Preload with custom query:
items_query = from i in Item, where: i.quantity > 0, order_by: i.name
Repo.preload(orders, items: items_query)
```

#### Escape Hatch

```elixir
# Raw SQL via Repo.query (returns {:ok, %Postgrex.Result{}}):
{:ok, result} = Repo.query("SELECT * FROM orders WHERE id = $1", [42])

# Raw SQL in Ecto query via fragment:
from o in Order,
  where: fragment("? @> ?", o.metadata, ^%{"priority" => "high"}),
  select: o

# Ecto.Adapters.SQL.query for truly raw access:
Ecto.Adapters.SQL.query(Repo, "EXPLAIN ANALYZE SELECT * FROM orders WHERE status = $1", ["pending"])
```

#### Migration Tool

Ecto.Migration — built-in, file-based, timestamped.

```elixir
defmodule MyApp.Repo.Migrations.AddOrdersIndex do
  use Ecto.Migration

  # ALWAYS disable the DDL transaction for concurrent index creation
  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    create index(:orders, [:status, :inserted_at],
      concurrently: true,
      where: "status = 'pending'",  # partial index — not possible via schema
      name: :orders_pending_status_idx
    )
  end
end
```

**When to bypass it:** For complex DDL (exclusion constraints, custom types, partitioning), write raw SQL in the migration via `execute/1`.

#### Common Gotchas

1. **Preload in a loop:** `Enum.map(orders, &Repo.preload(&1, :items))` — this is N+1. Preload the collection: `Repo.preload(orders, :items)`.
2. **Missing Repo.transaction for multi-step writes:** Use `Ecto.Multi` for multi-table writes. Individual `Repo.insert` calls are separate transactions.
3. **Schemaless queries forgotten:** `from("orders", select: [:id, :status]) |> Repo.all()` — lighter weight when you don't need the schema struct.
4. **Dynamic fields in fragments without pinning:** `fragment("? = ?", ^field, ^value)` — forgetting `^` silently interpolates Elixir vars.
5. **Not using `Ecto.Multi` for complex transactions:**
   ```elixir
   Multi.new()
   |> Multi.insert(:order, order_changeset)
   |> Multi.insert(:audit, fn %{order: order} -> audit_changeset(order) end)
   |> Repo.transaction()
   ```

---

### 2. SQLAlchemy (Python)

**Ecosystem:** Python. Two layers: Core (SQL expression language) and ORM (unit-of-work, identity map). Most people use the ORM and never learn Core, which is a mistake.

#### Setup & SQL Logging

```python
from sqlalchemy import create_engine
import logging

# Option 1: echo flag (dev only)
engine = create_engine("postgresql://...", echo=True)

# Option 2: logging (production-appropriate)
logging.getLogger("sqlalchemy.engine").setLevel(logging.INFO)

# Option 3: event-based (custom metrics)
from sqlalchemy import event

@event.listens_for(engine, "before_cursor_execute")
def receive_before_cursor_execute(conn, cursor, statement, parameters, context, executemany):
    conn.info.setdefault("query_start_time", []).append(time.time())

@event.listens_for(engine, "after_cursor_execute")
def receive_after_cursor_execute(conn, cursor, statement, parameters, context, executemany):
    total = time.time() - conn.info["query_start_time"].pop()
    if total > 0.1:
        logger.warning(f"Slow query ({total:.3f}s): {statement[:200]}")
```

#### Schema Definition

```python
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy import String, Numeric, ForeignKey, Index
from datetime import datetime

class Base(DeclarativeBase):
    pass

class Order(Base):
    __tablename__ = "orders"

    id: Mapped[int] = mapped_column(primary_key=True)
    status: Mapped[str] = mapped_column(String(50), nullable=False)
    total: Mapped[Decimal] = mapped_column(Numeric(12, 2))
    customer_id: Mapped[int] = mapped_column(ForeignKey("customers.id"))
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())

    customer: Mapped["Customer"] = relationship(back_populates="orders")
    items: Mapped[list["Item"]] = relationship(back_populates="order", lazy="select")

    __table_args__ = (
        Index("ix_orders_status_created", "status", "created_at",
              postgresql_where=text("status = 'pending'")),  # partial index
    )
```

**What it gets wrong:**
- Default `lazy="select"` on relationships causes N+1 — always set it explicitly
- `String()` without length maps to `TEXT` in PostgreSQL (fine) but `VARCHAR(MAX)` in SQL Server (sometimes bad)
- autoincrement uses `serial` by default — use `Identity()` for modern PostgreSQL

#### Query Patterns

```python
# Good: explicit loading strategy, explicit columns
from sqlalchemy.orm import joinedload, selectinload
from sqlalchemy import select

stmt = (
    select(Order)
    .options(joinedload(Order.customer))      # belongs_to: join is fine
    .options(selectinload(Order.items))        # has_many: separate query
    .where(Order.status == "pending")
    .order_by(Order.created_at.desc())
    .limit(100)
)
orders = session.scalars(stmt).unique().all()

# Good: Core for reporting (no ORM overhead)
from sqlalchemy import select, func
stmt = (
    select(Order.status, func.count(), func.sum(Order.total))
    .group_by(Order.status)
)
results = session.execute(stmt).all()
```

#### N+1 Prevention

```python
# joinedload — single query, LEFT JOIN. Good for to-one relationships.
select(Order).options(joinedload(Order.customer))

# selectinload — separate SELECT ... WHERE id IN (...). Good for to-many.
select(Order).options(selectinload(Order.items))

# subqueryload — separate correlated subquery. Legacy; prefer selectinload.
select(Order).options(subqueryload(Order.items))

# raiseload — explicitly blow up on lazy access (catch N+1 at dev time).
select(Order).options(raiseload(Order.items))

# contains_eager — when you've already written the join yourself.
stmt = (
    select(Order)
    .join(Order.items)
    .options(contains_eager(Order.items))
    .where(Item.quantity > 0)
)
```

#### Escape Hatch

```python
# Raw SQL via text()
from sqlalchemy import text
result = session.execute(text("SELECT * FROM orders WHERE id = :id"), {"id": 42})

# Raw SQL with ORM mapping
stmt = text("SELECT id, status, total FROM orders WHERE status = :s")
orders = session.execute(stmt.columns(Order.id, Order.status, Order.total), {"s": "pending"}).all()

# Connection-level raw (bypasses ORM entirely)
with engine.connect() as conn:
    result = conn.execute(text("EXPLAIN ANALYZE SELECT * FROM orders"))
    for row in result:
        print(row[0])
```

#### Migration Tool

**Alembic** — built by the SQLAlchemy author. Autogenerates migrations by diffing models against the database.

```bash
alembic init alembic
alembic revision --autogenerate -m "add orders index"
alembic upgrade head
```

**When to bypass it:** Alembic autogenerate misses: partial indexes (sometimes), custom types, triggers, row-level security policies, partitioning. Write these as `op.execute()` raw SQL in the migration.

```python
def upgrade():
    op.execute("""
        CREATE INDEX CONCURRENTLY ix_orders_pending
        ON orders (created_at)
        WHERE status = 'pending'
    """)
```

#### Common Gotchas

1. **Session identity map stale reads:** `session.query(Order).get(1)` returns the cached object, not a fresh DB read. Use `session.expire(obj)` or `session.refresh(obj)`.
2. **Implicit autoflush before queries:** SQLAlchemy flushes pending changes before `SELECT`s by default. This means your un-committed `INSERT` becomes visible to your own queries, which can cause confusion in tests.
3. **`lazy="dynamic"` is deprecated:** Use `WriteOnlyMapped` in SQLAlchemy 2.0+.
4. **Forgetting `.unique()` with joinedload:** Joined eager loads duplicate parent rows. Without `.unique()`, you get duplicate Order objects.
5. **Using `session.execute(select(...))` and expecting objects:** In 2.0, use `session.scalars()` to get ORM objects, `session.execute()` to get rows.

---

### 3. Django ORM (Python)

**Ecosystem:** Django framework. ActiveRecord pattern. Tightly coupled to the framework — you get the ORM whether you want it or not.

#### Setup & SQL Logging

```python
# settings.py
LOGGING = {
    'version': 1,
    'handlers': {'console': {'class': 'logging.StreamHandler'}},
    'loggers': {
        'django.db.backends': {
            'level': 'DEBUG',
            'handlers': ['console'],
        },
    },
}

# In shell/code — inspect a specific queryset:
qs = Order.objects.filter(status="pending")
print(qs.query)           # Shows the SQL (approximate, no params)
print(qs.explain())       # Runs EXPLAIN (Django 2.1+)
print(qs.explain(analyze=True))  # EXPLAIN ANALYZE

# django-debug-toolbar for dev (shows all queries per request)
```

#### Schema Definition

```python
class Order(models.Model):
    status = models.CharField(max_length=50, db_index=True)
    total = models.DecimalField(max_digits=12, decimal_places=2)
    customer = models.ForeignKey('Customer', on_delete=models.CASCADE, related_name='orders')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        indexes = [
            models.Index(fields=['status', 'created_at'], name='idx_orders_status_created'),
            # Partial index (Django 3.0+ with condition):
            models.Index(
                fields=['created_at'],
                name='idx_orders_pending',
                condition=models.Q(status='pending'),
            ),
        ]
        constraints = [
            models.CheckConstraint(
                check=models.Q(total__gte=0),
                name='orders_total_non_negative',
            ),
        ]
```

**What it gets wrong:**
- `CharField` requires `max_length` even on PostgreSQL where it's meaningless — use `TextField` to avoid arbitrary limits
- `auto_now_add=True` uses Python `datetime.now()`, not database `NOW()` — clock skew between app servers
- `BigAutoField` is now the default PK (Django 3.2+), but older projects are stuck on `AutoField` (32-bit)
- No support for `GENERATED ALWAYS AS` columns in the ORM

#### Query Patterns

```python
# Good: deferred fields for large columns
Order.objects.filter(status="pending").only('id', 'status', 'total')

# Good: annotation pushes computation to the database
from django.db.models import Count, Sum, F, Q
Order.objects.values('status').annotate(
    count=Count('id'),
    total_value=Sum('total'),
)

# Good: F() expressions avoid race conditions
Order.objects.filter(id=42).update(total=F('total') + 10)

# Good: Subquery for correlated lookups
from django.db.models import Subquery, OuterRef
latest_item = Item.objects.filter(order=OuterRef('pk')).order_by('-created_at')
Order.objects.annotate(latest_item_name=Subquery(latest_item.values('name')[:1]))
```

#### N+1 Prevention

```python
# select_related: follows FK/OneToOne with JOIN (single query)
Order.objects.select_related('customer').filter(status="pending")

# prefetch_related: separate query with IN clause (good for M2M, reverse FK)
Order.objects.prefetch_related('items').filter(status="pending")

# Prefetch with custom queryset:
from django.db.models import Prefetch
Order.objects.prefetch_related(
    Prefetch('items', queryset=Item.objects.filter(quantity__gt=0).only('id', 'name'))
)

# NEVER mix select_related and prefetch_related for the same relationship.
# Use select_related for FK/OneToOne, prefetch_related for reverse FK/M2M.
```

#### Escape Hatch

```python
# Raw SQL with model mapping:
Order.objects.raw('SELECT * FROM orders WHERE status = %s', ['pending'])

# Fully raw (no model):
from django.db import connection
with connection.cursor() as cursor:
    cursor.execute("SELECT * FROM orders WHERE id = %s", [42])
    row = cursor.fetchone()

# Extra() — deprecated, but you'll see it in legacy code. Don't use it.
# Instead, use RawSQL annotation:
from django.db.models.expressions import RawSQL
Order.objects.annotate(
    discount=RawSQL("SELECT rate FROM discounts WHERE customer_id = orders.customer_id", [])
)
```

#### Migration Tool

`django.db.migrations` — built-in, autogenerated via `makemigrations`.

```bash
python manage.py makemigrations
python manage.py sqlmigrate app_name 0042  # ALWAYS review the SQL
python manage.py migrate
```

**When to bypass it:** Django migrations don't support `CONCURRENTLY` for index creation. For large tables, write a `RunSQL` migration:

```python
from django.db import migrations

class Migration(migrations.Migration):
    atomic = False  # Required for CONCURRENTLY

    operations = [
        migrations.RunSQL(
            sql="CREATE INDEX CONCURRENTLY idx_orders_pending ON orders (created_at) WHERE status = 'pending'",
            reverse_sql="DROP INDEX CONCURRENTLY idx_orders_pending",
        ),
    ]
```

#### Common Gotchas

1. **`.count()` vs `len()`:** `Order.objects.filter(...).count()` runs `SELECT COUNT(*)`. `len(Order.objects.filter(...))` fetches all rows then counts in Python. Use `.count()` when you don't need the objects.
2. **QuerySet caching:** QuerySets are lazy and cached after first evaluation. But `qs.filter(...)` creates a NEW queryset (not cached). Assigning to a variable and reusing it avoids re-evaluation.
3. **`.all()` doesn't copy:** `Order.objects.all()` returns a new queryset but shares the underlying cache. Modifying one can affect the other in subtle ways.
4. **`update()` bypasses signals and `save()`:** `Order.objects.filter(...).update(status="done")` does not trigger `post_save` signals or custom `save()` logic.
5. **Migrations in wrong order across branches:** Two developers create migration 0042 on separate branches. Both succeed locally. The merge creates a diamond dependency. Fix: `python manage.py makemigrations --merge`.

---

### 4. Hibernate / JPA (Java)

**Ecosystem:** Java EE / Jakarta EE / Spring Data JPA. The original enterprise ORM. Extremely powerful, extremely easy to misuse.

#### Setup & SQL Logging

```properties
# application.properties (Spring Boot)
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

# Logging with bind parameters (show-sql alone hides params):
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE

# For Hibernate 6+ (Jakarta):
logging.level.org.hibernate.orm.jdbc.bind=TRACE

# Statistics (query counts per session — catches N+1):
spring.jpa.properties.hibernate.generate_statistics=true
```

#### Schema Definition

```java
@Entity
@Table(name = "orders", indexes = {
    @Index(name = "idx_orders_status", columnList = "status"),
    @Index(name = "idx_orders_customer", columnList = "customer_id")
})
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)  // Use IDENTITY, not SEQUENCE for PG 10+
    private Long id;

    @Column(nullable = false, length = 50)
    private String status;

    @Column(precision = 12, scale = 2)
    private BigDecimal total;

    @ManyToOne(fetch = FetchType.LAZY)  // ALWAYS set to LAZY
    @JoinColumn(name = "customer_id")
    private Customer customer;

    @OneToMany(mappedBy = "order", fetch = FetchType.LAZY)
    private List<Item> items;

    @Column(name = "created_at", updatable = false)
    private Instant createdAt;

    @PrePersist
    void prePersist() { this.createdAt = Instant.now(); }
}
```

**What it gets wrong:**
- `@ManyToOne` defaults to `FetchType.EAGER`. This is the #1 source of performance problems in Hibernate. **Always set `FetchType.LAZY`.**
- `@OneToMany` defaults to `FetchType.LAZY` (correct) but accessing `.getItems()` outside a session throws `LazyInitializationException`.
- `GenerationType.AUTO` picks `SEQUENCE` on PostgreSQL, which creates a `hibernate_sequence` table. Use `IDENTITY` or an explicit `@SequenceGenerator`.
- Hibernate generates DDL with VARCHAR(255) by default. Always specify `@Column(length = ...)` or use `columnDefinition = "text"`.

#### Query Patterns

```java
// JPQL (Hibernate Query Language)
List<Order> orders = em.createQuery(
    "SELECT o FROM Order o JOIN FETCH o.customer WHERE o.status = :status", Order.class)
    .setParameter("status", "pending")
    .setMaxResults(100)
    .getResultList();

// Criteria API (type-safe, verbose)
CriteriaBuilder cb = em.getCriteriaBuilder();
CriteriaQuery<Order> cq = cb.createQuery(Order.class);
Root<Order> root = cq.from(Order.class);
root.fetch("customer", JoinType.LEFT);
cq.where(cb.equal(root.get("status"), "pending"));
List<Order> orders = em.createQuery(cq).getResultList();

// Spring Data JPA derived queries (simple cases only)
List<Order> findByStatusOrderByCreatedAtDesc(String status, Pageable pageable);
```

#### N+1 Prevention

```java
// Option 1: JOIN FETCH in JPQL
"SELECT o FROM Order o JOIN FETCH o.items WHERE o.status = :status"

// Option 2: @EntityGraph (declarative, reusable)
@EntityGraph(attributePaths = {"items", "customer"})
List<Order> findByStatus(String status);

// Option 3: @BatchSize (lazy load in batches instead of one-by-one)
@OneToMany(mappedBy = "order")
@BatchSize(size = 25)  // loads items for 25 orders at once
private List<Item> items;

// Option 4: Hibernate.initialize() (explicit trigger)
orders.forEach(o -> Hibernate.initialize(o.getItems()));
```

#### Escape Hatch

```java
// Native SQL query
List<Object[]> results = em.createNativeQuery(
    "SELECT id, status, total FROM orders WHERE status = ?")
    .setParameter(1, "pending")
    .getResultList();

// Native query mapped to entity
List<Order> orders = em.createNativeQuery(
    "SELECT * FROM orders WHERE status = ?1", Order.class)
    .setParameter(1, "pending")
    .getResultList();

// JDBC via Hibernate Session
Session session = em.unwrap(Session.class);
session.doWork(connection -> {
    try (PreparedStatement ps = connection.prepareStatement("EXPLAIN ANALYZE SELECT ...")) {
        ResultSet rs = ps.executeQuery();
        while (rs.next()) { System.out.println(rs.getString(1)); }
    }
});
```

#### Migration Tool

Hibernate can auto-generate DDL (`hibernate.hbm2ddl.auto`), but **never use this in production.** Options:
- `validate` — check schema matches entities (safe for production)
- `update` — apply diff (dangerous: never drops columns, no rollback)
- `create-drop` — drop and recreate (tests only)

Use **Flyway** or **Liquibase** (see dedicated section below) for real migrations.

#### Common Gotchas

1. **`FetchType.EAGER` on `@ManyToOne`:** This is the default. It means every query that returns an Order also loads the Customer, even if you don't need it. Multiply this across 10 entities with eager associations and you get dozens of queries per request.
2. **Open Session in View (OSIV):** Spring Boot enables this by default (`spring.jpa.open-in-view=true`). It keeps the Hibernate session open during view rendering, allowing lazy loading in templates — but it holds database connections for the entire request lifecycle. **Disable it.**
3. **N+1 with `@EntityGraph` on pagination:** `JOIN FETCH` and `@EntityGraph` break `LIMIT`/`OFFSET` — Hibernate fetches all rows and paginates in memory. Use `@BatchSize` for paginated queries.
4. **`merge()` vs `persist()`:** `persist()` adds a new entity. `merge()` copies state from a detached entity. Using `merge()` when you mean `persist()` causes an extra `SELECT` to check existence.
5. **Missing `equals()`/`hashCode()`:** Hibernate uses the identity map. If your entities override `equals()`/`hashCode()` based on the `@Id` field, and the ID is null before persist, you get broken Set behavior.

---

### 5. Eloquent (PHP / Laravel)

**Ecosystem:** Laravel framework. ActiveRecord pattern. Convention over configuration.

#### Setup & SQL Logging

```php
// Listen to all queries (AppServiceProvider::boot)
DB::listen(function ($query) {
    Log::info($query->sql, ['bindings' => $query->bindings, 'time' => $query->time]);
});

// Per-query inspection:
$orders = Order::where('status', 'pending')->toSql();
// Returns: "select * from `orders` where `status` = ?"
// Note: bindings not included in toSql(). Use toRawSql() in Laravel 10.15+.

// Laravel Debugbar (dev):
// composer require barryvdh/laravel-debugbar --dev

// Laravel Telescope (dev/staging):
// Shows all queries, N+1 warnings, slow queries
```

#### Schema Definition

```php
// Migration (this IS the schema definition in Laravel)
Schema::create('orders', function (Blueprint $table) {
    $table->id();  // bigIncrements (BIGSERIAL)
    $table->string('status', 50)->index();
    $table->decimal('total', 12, 2);
    $table->foreignId('customer_id')->constrained()->cascadeOnDelete();
    $table->timestamps();  // created_at, updated_at

    // Partial index (PostgreSQL):
    $table->index('created_at', 'idx_orders_pending');
    // For actual partial index, use raw:
    DB::statement('CREATE INDEX idx_orders_pending ON orders (created_at) WHERE status = \'pending\'');
});
```

**What it gets wrong:**
- `$table->string('name')` defaults to `VARCHAR(255)` — the MySQL legacy lives on
- `$table->timestamps()` creates nullable columns — use `$table->timestamps(precision: 0)` or `->useCurrent()` for non-null defaults
- No built-in support for PostgreSQL-specific types (JSONB indexes, array columns, enum types) — use `DB::statement()` for these

#### Query Patterns

```php
// Good: chunking for large datasets (doesn't load everything into memory)
Order::where('status', 'pending')->chunk(1000, function ($orders) {
    foreach ($orders as $order) { /* process */ }
});

// Good: cursor for memory-efficient iteration (one row at a time via generator)
foreach (Order::where('status', 'pending')->cursor() as $order) {
    // processes one at a time, low memory
}

// Good: aggregate without loading models
Order::where('status', 'pending')->sum('total');
Order::where('status', 'pending')->count();

// Good: select only what you need
Order::select('id', 'status', 'total')->where('status', 'pending')->get();
```

#### N+1 Prevention

```php
// Eager load with with():
$orders = Order::with('items')->where('status', 'pending')->get();
// Generates: SELECT * FROM orders WHERE status = 'pending'
//            SELECT * FROM items WHERE order_id IN (1, 2, 3, ...)

// Nested eager loading:
$orders = Order::with('items.product', 'customer')->get();

// Constrained eager loading:
$orders = Order::with(['items' => function ($query) {
    $query->where('quantity', '>', 0)->select('id', 'order_id', 'name');
}])->get();

// withCount (loads count without loading the relationship):
$orders = Order::withCount('items')->get();
// $orders[0]->items_count

// Prevent lazy loading entirely (Laravel 9+):
// In AppServiceProvider::boot():
Model::preventLazyLoading(!app()->isProduction());
```

#### Escape Hatch

```php
// Raw expressions in queries:
Order::whereRaw("created_at > NOW() - INTERVAL '7 days'")->get();

// DB::raw in select:
Order::select(DB::raw('status, COUNT(*) as count, SUM(total) as total'))
    ->groupBy('status')
    ->get();

// Fully raw query:
$orders = DB::select('SELECT * FROM orders WHERE status = ?', ['pending']);

// Raw with named bindings:
DB::select('SELECT * FROM orders WHERE id = :id', ['id' => 42]);

// Raw insert/update/delete:
DB::statement('TRUNCATE TABLE orders RESTART IDENTITY CASCADE');
```

#### Migration Tool

Built-in Laravel migrations — PHP files, timestamped.

```bash
php artisan make:migration add_orders_pending_index
php artisan migrate
php artisan migrate:status
php artisan migrate:rollback --step=1
```

**When to bypass it:** Use `DB::statement()` inside a migration for:
- `CREATE INDEX CONCURRENTLY` (must also set `$withinTransaction = false` on the migration class)
- Partitioned tables
- Custom PostgreSQL types, functions, triggers

#### Common Gotchas

1. **Accessing relationships in Blade templates without eager loading:** `@foreach($orders as $order) {{ $order->customer->name }}` — classic N+1. Always eager load in the controller.
2. **`Model::all()` in production:** Loads every row into memory. Use `->paginate()`, `->chunk()`, or `->cursor()`.
3. **`$table->softDeletes()` without global scope awareness:** Soft deletes add a global scope. `Order::count()` silently excludes soft-deleted rows. Use `Order::withTrashed()->count()` for the real count.
4. **`firstOrCreate` race conditions:** Two requests can race past the `first` check and both try to `create`, hitting a unique constraint. Use `updateOrCreate` with unique constraints, or handle `QueryException`.
5. **Mutators/Accessors hiding queries:** A `getFullNameAttribute()` that loads a relationship triggers N+1 if used in a list view.

---

### 6. Prisma (Node.js / TypeScript)

**Ecosystem:** Node.js/TypeScript. Schema-first ORM with its own schema language. Generates a type-safe query client.

#### Setup & SQL Logging

```typescript
// In Prisma client initialization:
const prisma = new PrismaClient({
  log: [
    { level: 'query', emit: 'event' },
    { level: 'error', emit: 'stdout' },
    { level: 'warn', emit: 'stdout' },
  ],
});

prisma.$on('query', (e) => {
  console.log(`Query: ${e.query}`);
  console.log(`Params: ${e.params}`);
  console.log(`Duration: ${e.duration}ms`);
});

// For production, filter slow queries:
prisma.$on('query', (e) => {
  if (e.duration > 100) {
    logger.warn(`Slow query (${e.duration}ms): ${e.query}`);
  }
});
```

#### Schema Definition

```prisma
// schema.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

model Order {
  id         Int       @id @default(autoincrement())  // Uses SERIAL
  status     String    @db.VarChar(50)
  total      Decimal   @db.Decimal(12, 2)
  customerId Int       @map("customer_id")
  createdAt  DateTime  @default(now()) @map("created_at")

  customer   Customer  @relation(fields: [customerId], references: [id])
  items      Item[]

  @@index([status, createdAt])
  @@map("orders")
}
```

**What it gets wrong:**
- No partial index support in the schema — must use raw SQL migration
- No support for PostgreSQL-specific index types (GIN, GiST, BRIN) in schema — use `prisma migrate` with custom SQL
- `autoincrement()` uses `serial` not `GENERATED ALWAYS AS IDENTITY` — not configurable
- No composite types, no array of composites, limited enum support
- Connection pooling is internal and opaque — you need PgBouncer for serverless

#### Query Patterns

```typescript
// Good: select only what you need
const orders = await prisma.order.findMany({
  where: { status: 'pending' },
  select: { id: true, status: true, total: true },  // only these columns
  orderBy: { createdAt: 'desc' },
  take: 100,
});

// Good: aggregate without loading models
const stats = await prisma.order.aggregate({
  where: { status: 'pending' },
  _count: true,
  _sum: { total: true },
});

// Good: groupBy
const byStatus = await prisma.order.groupBy({
  by: ['status'],
  _count: true,
  _sum: { total: true },
});
```

#### N+1 Prevention

```typescript
// Prisma uses separate queries (not JOINs) for include — safe from cartesian explosion
const orders = await prisma.order.findMany({
  where: { status: 'pending' },
  include: {
    customer: true,                              // separate SELECT
    items: { where: { quantity: { gt: 0 } } },   // filtered separate SELECT
  },
});

// select + include cannot be mixed at the same level
// Use nested select inside include:
const orders = await prisma.order.findMany({
  select: {
    id: true,
    status: true,
    items: { select: { id: true, name: true } },
  },
});

// Prisma doesn't have lazy loading — all loading is explicit.
// This means N+1 requires you to write a loop with await inside:
// BAD:
for (const order of orders) {
  const items = await prisma.item.findMany({ where: { orderId: order.id } }); // N+1!
}
```

#### Escape Hatch

```typescript
// Raw query returning typed results:
const orders = await prisma.$queryRaw<Order[]>`
  SELECT id, status, total FROM orders WHERE status = ${status}
`;

// Raw query with Prisma.sql for dynamic parts:
const column = Prisma.sql`created_at`;
const result = await prisma.$queryRaw`SELECT ${column} FROM orders LIMIT 10`;

// Execute raw (INSERT/UPDATE/DELETE, returns affected row count):
const count = await prisma.$executeRaw`
  UPDATE orders SET status = 'done' WHERE status = 'pending' AND created_at < NOW() - INTERVAL '30 days'
`;

// Transaction:
const [order, audit] = await prisma.$transaction([
  prisma.order.create({ data: orderData }),
  prisma.auditLog.create({ data: auditData }),
]);

// Interactive transaction (sequential, with rollback):
await prisma.$transaction(async (tx) => {
  const order = await tx.order.update({ where: { id: 1 }, data: { status: 'processing' } });
  if (order.total > 10000) throw new Error('Needs approval');  // rolls back
  await tx.auditLog.create({ data: { orderId: order.id, action: 'process' } });
});
```

#### Migration Tool

`prisma migrate` — generates SQL migration files from schema diffs.

```bash
npx prisma migrate dev --name add_orders_index    # dev: generates + applies
npx prisma migrate deploy                          # production: applies pending
npx prisma migrate diff --from-schema-datamodel ... --to-schema-datamodel ...  # dry run
```

**When to bypass it:** Add custom SQL to the generated migration file (Prisma creates a `migration.sql` file you can edit before applying):

```sql
-- In migration.sql, add after Prisma's generated SQL:
CREATE INDEX CONCURRENTLY idx_orders_pending ON orders (created_at) WHERE status = 'pending';
```

Set the migration as applied without running it: `npx prisma migrate resolve --applied "20240115_add_index"`

#### Common Gotchas

1. **No JOIN-based eager loading:** Prisma always uses separate queries for `include`. This is usually fine but means you can't filter parents based on children's attributes in a single query. Use `$queryRaw` for complex joins.
2. **Connection pool exhaustion in serverless:** Each Prisma client instance opens its own pool. In serverless (Vercel, Lambda), each function invocation may create a new pool. Use PgBouncer or Prisma Accelerate.
3. **`$queryRaw` SQL injection:** Template literals with `$queryRaw` are parameterized. But `$queryRawUnsafe(userInput)` is not — never use it with user input.
4. **Interactive transactions hold connections:** `$transaction(async (tx) => {...})` holds a DB connection for the duration. Long-running logic inside kills your pool.
5. **Schema drift:** If you modify the database outside Prisma (raw DDL), `prisma migrate dev` will try to undo your changes. Use `prisma db pull` to sync the schema, or `prisma migrate diff` to reconcile.

---

### 7. Drizzle (Node.js / TypeScript)

**Ecosystem:** Node.js/TypeScript. Thin SQL wrapper with type safety. Closer to a query builder than a traditional ORM. The "SQL-friendly" alternative to Prisma.

#### Setup & SQL Logging

```typescript
import { drizzle } from 'drizzle-orm/node-postgres';

const db = drizzle(pool, {
  logger: true,  // logs all queries to console

  // Custom logger:
  // logger: {
  //   logQuery(query, params) {
  //     console.log({ query, params });
  //   }
  // }
});
```

#### Schema Definition

```typescript
import { pgTable, serial, varchar, decimal, integer, timestamp, index } from 'drizzle-orm/pg-core';

export const orders = pgTable('orders', {
  id: serial('id').primaryKey(),
  status: varchar('status', { length: 50 }).notNull(),
  total: decimal('total', { precision: 12, scale: 2 }),
  customerId: integer('customer_id').references(() => customers.id),
  createdAt: timestamp('created_at').defaultNow(),
}, (table) => ({
  statusIdx: index('idx_orders_status').on(table.status),
  statusCreatedIdx: index('idx_orders_status_created').on(table.status, table.createdAt),
}));

// Relations (separate from table definition):
import { relations } from 'drizzle-orm';

export const ordersRelations = relations(orders, ({ one, many }) => ({
  customer: one(customers, { fields: [orders.customerId], references: [customers.id] }),
  items: many(items),
}));
```

**What it gets wrong:**
- Schema is TypeScript — no partial index support in the helper functions (use raw SQL in migrations)
- `serial()` maps to PostgreSQL `serial`, not `GENERATED ALWAYS AS IDENTITY`
- Relations are separate from the table definition, which means they can drift out of sync
- Limited PostgreSQL-specific type support compared to writing DDL directly

#### Query Patterns

```typescript
import { eq, gt, and, sql, count, sum } from 'drizzle-orm';

// Select builder (SQL-like):
const pendingOrders = await db
  .select({ id: orders.id, status: orders.status, total: orders.total })
  .from(orders)
  .where(eq(orders.status, 'pending'))
  .orderBy(desc(orders.createdAt))
  .limit(100);

// Aggregate:
const stats = await db
  .select({ status: orders.status, count: count(), total: sum(orders.total) })
  .from(orders)
  .groupBy(orders.status);

// Relational queries (the ORM-like API):
const ordersWithItems = await db.query.orders.findMany({
  where: eq(orders.status, 'pending'),
  with: { items: true, customer: true },
  limit: 100,
});
```

#### N+1 Prevention

```typescript
// Relational queries handle eager loading:
const result = await db.query.orders.findMany({
  with: {
    items: {
      where: gt(items.quantity, 0),
      columns: { id: true, name: true },  // select specific columns
    },
    customer: true,
  },
});

// Manual join (when you need filter parents by children):
const result = await db
  .select()
  .from(orders)
  .leftJoin(items, eq(items.orderId, orders.id))
  .where(gt(items.quantity, 0));
// Note: this returns flat rows, not nested objects. You need to reshape manually.
```

#### Escape Hatch

```typescript
import { sql } from 'drizzle-orm';

// Raw SQL in expressions:
const result = await db
  .select()
  .from(orders)
  .where(sql`${orders.createdAt} > NOW() - INTERVAL '7 days'`);

// Fully raw query:
const raw = await db.execute(sql`
  SELECT id, status, total
  FROM orders
  WHERE status = ${status}
  ORDER BY created_at DESC
  LIMIT 100
`);

// Prepared statements (compile once, execute many):
const prepared = db
  .select()
  .from(orders)
  .where(eq(orders.status, sql.placeholder('status')))
  .prepare('get_by_status');

const result = await prepared.execute({ status: 'pending' });
```

#### Migration Tool

`drizzle-kit` — generates SQL migrations from schema diffs.

```bash
npx drizzle-kit generate   # generate migration from schema changes
npx drizzle-kit migrate     # apply migrations
npx drizzle-kit push        # push schema directly (dev only, no migration file)
npx drizzle-kit studio      # visual schema browser
```

**When to bypass it:** Edit the generated `.sql` file before applying. Drizzle-kit generates clean SQL that's easy to modify.

#### Common Gotchas

1. **Relational queries vs select builder:** `db.query.orders.findMany()` (relational) and `db.select().from(orders)` (select) are two different APIs with different capabilities. Relational queries support `with` for eager loading. Select queries support JOINs and raw SQL fragments.
2. **JOIN results are flat:** Unlike ORMs, `leftJoin` returns flat `{ orders: {...}, items: {...} }` rows. One parent with 10 children = 10 rows. You must reshape into nested structure yourself.
3. **No lazy loading:** Like Prisma, there's no implicit loading. You get what you ask for. This is actually a feature — no hidden queries.
4. **`sql` template injection safety:** `sql`...`` (tagged template) is parameterized. `sql.raw()` is NOT — never use with user input.

---

### 8. TypeORM (Node.js / TypeScript)

**Ecosystem:** Node.js/TypeScript. Supports both ActiveRecord and Data Mapper patterns. Decorator-based schema definition. Widely used, widely criticized.

#### Setup & SQL Logging

```typescript
// In DataSource configuration:
const dataSource = new DataSource({
  type: 'postgres',
  logging: true,                    // log all queries
  logging: ['query', 'error'],     // log only queries and errors
  logger: 'advanced-console',      // pretty-printed output
  maxQueryExecutionTime: 1000,     // log queries > 1s
});

// Per-query:
const orders = await orderRepo.find({
  where: { status: 'pending' },
  // No per-query logging toggle — use global setting
});
```

#### Schema Definition

```typescript
@Entity('orders')
@Index('idx_orders_status_created', ['status', 'createdAt'])
export class Order {
  @PrimaryGeneratedColumn('increment')  // SERIAL
  id: number;

  @Column({ type: 'varchar', length: 50 })
  status: string;

  @Column({ type: 'decimal', precision: 12, scale: 2 })
  total: string;  // Note: TypeORM returns decimals as strings

  @ManyToOne(() => Customer, { lazy: false })  // default: eager: false
  @JoinColumn({ name: 'customer_id' })
  customer: Customer;

  @OneToMany(() => Item, item => item.order)
  items: Item[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
```

**What it gets wrong:**
- Decimal columns returned as `string` — not `number` or `BigDecimal`. You must parse them.
- `@PrimaryGeneratedColumn()` uses `serial` — no `GENERATED ALWAYS AS IDENTITY` option
- `synchronize: true` in production **will drop data**. It diffs entities against DB and alters tables to match. Never enable this outside development.
- `@Index` decorator doesn't support partial indexes — use a migration with raw SQL

#### Query Patterns

```typescript
// Repository API:
const orders = await orderRepo.find({
  where: { status: 'pending' },
  relations: ['customer', 'items'],  // eager load
  select: ['id', 'status', 'total'],
  order: { createdAt: 'DESC' },
  take: 100,
});

// QueryBuilder (more control):
const orders = await orderRepo
  .createQueryBuilder('o')
  .leftJoinAndSelect('o.customer', 'c')
  .leftJoinAndSelect('o.items', 'i', 'i.quantity > :minQty', { minQty: 0 })
  .where('o.status = :status', { status: 'pending' })
  .orderBy('o.createdAt', 'DESC')
  .take(100)
  .getMany();
```

#### N+1 Prevention

```typescript
// Option 1: relations in find options
await orderRepo.find({ relations: ['items', 'customer'] });

// Option 2: QueryBuilder with leftJoinAndSelect
orderRepo.createQueryBuilder('o')
  .leftJoinAndSelect('o.items', 'items')
  .getMany();

// Option 3: eager: true on relationship (loads ALWAYS — usually a mistake)
@OneToMany(() => Item, item => item.order, { eager: true })
items: Item[];
// Don't do this. It's the Hibernate EAGER mistake all over again.

// There is no selectinload equivalent — TypeORM always JOINs.
// For large has-many relationships, consider manual separate queries.
```

#### Escape Hatch

```typescript
// Raw query via EntityManager:
const orders = await dataSource.query(
  'SELECT * FROM orders WHERE status = $1',
  ['pending']
);

// Raw in QueryBuilder:
orderRepo.createQueryBuilder('o')
  .where('o.created_at > NOW() - INTERVAL :interval', { interval: '7 days' })
  .getRawMany();  // returns plain objects, not entities

// Full raw with entity mapping:
const orders = await orderRepo.query('SELECT * FROM orders WHERE status = $1', ['pending']);
```

#### Migration Tool

Built-in migration generator (diffs entities against a database snapshot):

```bash
npx typeorm migration:generate -n AddOrdersIndex -d src/data-source.ts
npx typeorm migration:run -d src/data-source.ts
npx typeorm migration:revert -d src/data-source.ts
```

**When to bypass it:** The migration generator is unreliable with complex changes. Write manual migrations:

```typescript
export class AddPartialIndex1705000000000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE INDEX CONCURRENTLY idx_orders_pending
      ON orders (created_at)
      WHERE status = 'pending'
    `);
  }
  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP INDEX CONCURRENTLY idx_orders_pending');
  }
}
```

#### Common Gotchas

1. **`synchronize: true` in production:** This compares entities to the database and alters tables to match — including dropping columns. It will delete your data. **Never use in production.**
2. **Decimal as string:** `@Column({ type: 'decimal' })` returns values as `string`. Arithmetic on these values silently concatenates: `order.total + 10` = `"99.9910"`. Always `parseFloat()` or use a decimal library.
3. **QueryBuilder vs Find API:** `find()` returns entity instances with full lifecycle hooks. `createQueryBuilder().getRawMany()` returns plain objects. `getMany()` returns entities. Mixing them up causes subtle bugs.
4. **Circular relations and infinite loops:** If Order has Items and Item has Order, JSON serialization creates an infinite loop. Use `class-transformer`'s `@Exclude()` or custom serialization.
5. **Migration generator drift:** The generator compares against the current database, not the last migration. If you have un-applied migrations, it generates duplicates or conflicting changes.

---

### 9. Sequelize (Node.js)

**Ecosystem:** Node.js (JavaScript and TypeScript via `sequelize-typescript`). One of the oldest Node.js ORMs. ActiveRecord pattern.

#### Setup & SQL Logging

```javascript
const sequelize = new Sequelize('postgres://...', {
  logging: console.log,              // log all SQL
  logging: (sql, timing) => {        // custom logger
    if (timing > 100) logger.warn(`Slow query (${timing}ms): ${sql}`);
  },
  benchmark: true,                   // include timing in log output
});

// Per-query logging override:
await Order.findAll({
  where: { status: 'pending' },
  logging: console.log,              // enable for this query
  // or logging: false to suppress
});
```

#### Schema Definition

```javascript
const Order = sequelize.define('Order', {
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  status: { type: DataTypes.STRING(50), allowNull: false },
  total: { type: DataTypes.DECIMAL(12, 2) },
  customerId: { type: DataTypes.INTEGER, field: 'customer_id' },
}, {
  tableName: 'orders',
  timestamps: true,     // createdAt, updatedAt
  underscored: true,    // snake_case column names
  indexes: [
    { fields: ['status', 'created_at'], name: 'idx_orders_status_created' },
  ],
});

Order.belongsTo(Customer, { foreignKey: 'customer_id' });
Order.hasMany(Item, { foreignKey: 'order_id' });
```

**What it gets wrong:**
- `DataTypes.STRING` without length defaults to `VARCHAR(255)`
- `DECIMAL` returns strings (same as TypeORM) — arithmetic traps apply
- `timestamps: true` adds `createdAt`/`updatedAt` using JavaScript time, not DB time
- Association methods (`Order.belongsTo`) are imperative and order-dependent — define all models first, then all associations

#### Query Patterns

```javascript
// Good: attributes limits columns
const orders = await Order.findAll({
  where: { status: 'pending' },
  attributes: ['id', 'status', 'total'],
  order: [['createdAt', 'DESC']],
  limit: 100,
});

// Good: aggregate functions
const count = await Order.count({ where: { status: 'pending' } });
const total = await Order.sum('total', { where: { status: 'pending' } });

// Good: scopes for reusable query fragments
Order.addScope('pending', { where: { status: 'pending' } });
Order.addScope('recent', (days) => ({
  where: { createdAt: { [Op.gt]: new Date(Date.now() - days * 86400000) } }
}));
await Order.scope('pending').scope({ method: ['recent', 7] }).findAll();
```

#### N+1 Prevention

```javascript
// include for eager loading (generates JOINs or separate queries based on config):
const orders = await Order.findAll({
  where: { status: 'pending' },
  include: [
    { model: Customer },                                      // LEFT JOIN
    { model: Item, where: { quantity: { [Op.gt]: 0 } } },    // INNER JOIN (because of where)
    { model: Item, required: false },                          // LEFT JOIN (explicit)
  ],
});

// Separate queries (avoids cartesian explosion):
const orders = await Order.findAll({
  where: { status: 'pending' },
  include: [{ model: Item, separate: true }],  // uses separate SELECT ... WHERE IN
});

// subQuery option for pagination with includes:
const orders = await Order.findAll({
  include: [{ model: Item }],
  limit: 10,
  subQuery: false,  // applies LIMIT to the JOIN result, not a subquery
});
```

#### Escape Hatch

```javascript
// Raw query with model mapping:
const orders = await sequelize.query(
  'SELECT * FROM orders WHERE status = :status',
  {
    replacements: { status: 'pending' },
    type: QueryTypes.SELECT,
    model: Order,
    mapToModel: true,
  }
);

// Raw query, plain results:
const [results, metadata] = await sequelize.query('SELECT * FROM orders WHERE id = $1', {
  bind: [42],
  type: QueryTypes.SELECT,
});

// Sequelize.literal for raw SQL in queries:
Order.findAll({
  where: sequelize.literal("created_at > NOW() - INTERVAL '7 days'"),
});
```

#### Migration Tool

`sequelize-cli` with migration files:

```bash
npx sequelize-cli migration:generate --name add-orders-pending-index
npx sequelize-cli db:migrate
npx sequelize-cli db:migrate:undo
```

**When to bypass it:** Always use `queryInterface.sequelize.query()` inside the migration for PostgreSQL-specific DDL.

#### Common Gotchas

1. **`include` with `limit` produces wrong results:** When you `include` a has-many and use `limit`, Sequelize wraps the query in a subquery. This can produce unexpected results. Use `subQuery: false` and test carefully.
2. **`paranoid: true` (soft deletes) affects all queries silently:** Like Django, `findAll` excludes soft-deleted rows unless you pass `paranoid: false`. Aggregates are affected too.
3. **`DECIMAL` returns strings:** Same as TypeORM — `order.total + 10` will give you string concatenation.
4. **Scopes stack, and stacking can conflict:** Two scopes with different `where` clauses on the same column produce `AND`. This is usually correct but can be surprising.
5. **`findOrCreate` race condition:** Similar to Eloquent's `firstOrCreate` — two concurrent calls can both pass the `find` and attempt `create`. Wrap in a transaction or handle the unique constraint error.

---

### 10. Knex (Node.js)

**Ecosystem:** Node.js. Query builder, NOT an ORM. No models, no relationships, no identity map. You write SQL with a fluent API and get plain objects back. Often used as the foundation under higher-level ORMs (Objection.js, Bookshelf).

#### Setup & SQL Logging

```javascript
const knex = require('knex')({
  client: 'pg',
  connection: 'postgres://...',
  debug: true,       // logs all queries
  pool: { min: 2, max: 10 },

  // Custom logging:
  log: {
    warn(message) { logger.warn(message); },
    error(message) { logger.error(message); },
    deprecate(message) { logger.info(message); },
    debug(message) { logger.debug(message); },
  },
});

// Per-query with .toSQL():
const { sql, bindings } = knex('orders').where('status', 'pending').toSQL();
console.log(sql, bindings);
```

#### Schema Definition

Knex doesn't define schemas in application code. It's purely a migration/query tool:

```javascript
// Migration:
exports.up = function(knex) {
  return knex.schema.createTable('orders', (table) => {
    table.increments('id');  // SERIAL PRIMARY KEY
    table.string('status', 50).notNullable().index();
    table.decimal('total', 12, 2);
    table.integer('customer_id').references('customers.id').onDelete('CASCADE');
    table.timestamps(true, true);  // created_at, updated_at with defaults
  });
};

exports.down = function(knex) {
  return knex.schema.dropTable('orders');
};
```

#### Query Patterns

```javascript
// Select with conditions:
const orders = await knex('orders')
  .select('id', 'status', 'total')
  .where('status', 'pending')
  .orderBy('created_at', 'desc')
  .limit(100);

// Join:
const result = await knex('orders as o')
  .join('customers as c', 'o.customer_id', 'c.id')
  .select('o.id', 'o.total', 'c.name as customer_name')
  .where('o.status', 'pending');

// Aggregate:
const [{ count, total }] = await knex('orders')
  .where('status', 'pending')
  .count('* as count')
  .sum('total as total');

// Insert returning:
const [order] = await knex('orders')
  .insert({ status: 'pending', total: 99.99, customer_id: 1 })
  .returning('*');

// Upsert (PostgreSQL onConflict):
await knex('orders')
  .insert({ id: 1, status: 'done' })
  .onConflict('id')
  .merge();  // UPDATE on conflict
```

#### N+1 Prevention

Knex doesn't have relationships, so N+1 is your responsibility:

```javascript
// Manual eager loading pattern:
const orders = await knex('orders').where('status', 'pending');
const orderIds = orders.map(o => o.id);
const items = await knex('items').whereIn('order_id', orderIds);

// Group items by order:
const itemsByOrder = items.reduce((acc, item) => {
  (acc[item.order_id] = acc[item.order_id] || []).push(item);
  return acc;
}, {});

const ordersWithItems = orders.map(o => ({ ...o, items: itemsByOrder[o.id] || [] }));
```

#### Escape Hatch

```javascript
// knex.raw() — parameterized:
const orders = await knex.raw(
  'SELECT * FROM orders WHERE status = ? AND created_at > NOW() - INTERVAL ?',
  ['pending', '7 days']
);

// Raw in where clause:
knex('orders').whereRaw("metadata @> ?::jsonb", [JSON.stringify({ priority: 'high' })]);

// Raw in select:
knex('orders').select(knex.raw('status, COUNT(*) as count')).groupBy('status');
```

#### Migration Tool

Built-in, file-based:

```bash
npx knex migrate:make add_orders_pending_index
npx knex migrate:latest
npx knex migrate:rollback
npx knex migrate:status
```

Knex gives you raw schema access in migrations, so there's rarely a need to bypass it — just use `knex.raw()` inside the migration.

#### Common Gotchas

1. **Forgetting `.first()` for single-row queries:** `knex('orders').where('id', 1)` returns an array. Use `.first()` to get a single object.
2. **Connection pool exhaustion:** Knex uses `tarn.js` for pooling. If you `await knex(...)` without ever releasing connections (e.g., unhandled promise rejections), the pool drains.
3. **Transaction scope:** `knex.transaction(async (trx) => {...})` — if you forget to use `trx` instead of `knex` inside the callback, queries run outside the transaction.
4. **`.returning('*')` is PostgreSQL-specific:** Won't work on MySQL/SQLite. Not an issue for this guide but matters if you're multi-database.

---

### 11. Diesel (Rust)

**Ecosystem:** Rust. Compile-time query validation. No runtime reflection. Type-safe schema derived from your database.

#### Setup & SQL Logging

```rust
// diesel.toml or environment variable:
// DIESEL_LOG=1 (logs all queries)

// Print a query without executing:
use diesel::debug_query;
let query = orders::table
    .filter(orders::status.eq("pending"))
    .select((orders::id, orders::status));
println!("{}", debug_query::<diesel::pg::Pg, _>(&query));

// Custom logger middleware:
// Use diesel-logger crate or implement Connection wrapper
```

#### Schema Definition

Diesel generates a `schema.rs` from your database:

```bash
diesel setup                # creates database + migrations directory
diesel migration generate add_orders
diesel migration run        # applies migrations, regenerates schema.rs
diesel print-schema         # outputs current schema.rs
```

```rust
// schema.rs (auto-generated — do NOT edit)
diesel::table! {
    orders (id) {
        id -> Int4,
        status -> Varchar,
        total -> Numeric,
        customer_id -> Int4,
        created_at -> Timestamptz,
    }
}

// models.rs (you write this)
#[derive(Queryable, Selectable)]
#[diesel(table_name = orders)]
pub struct Order {
    pub id: i32,
    pub status: String,
    pub total: BigDecimal,
    pub customer_id: i32,
    pub created_at: DateTime<Utc>,
}

#[derive(Insertable)]
#[diesel(table_name = orders)]
pub struct NewOrder<'a> {
    pub status: &'a str,
    pub total: BigDecimal,
    pub customer_id: i32,
}
```

**What it gets wrong:**
- Diesel's schema generation only captures column types and primary keys — no indexes, constraints, or triggers appear in `schema.rs`
- `Numeric` maps to `BigDecimal` which requires the `bigdecimal` crate
- No built-in connection pooling — use `r2d2` or `deadpool-diesel`

#### Query Patterns

```rust
use diesel::prelude::*;

// Filtered select:
let pending: Vec<Order> = orders::table
    .filter(orders::status.eq("pending"))
    .order(orders::created_at.desc())
    .limit(100)
    .load::<Order>(&mut conn)?;

// Select specific columns:
let ids: Vec<(i32, String)> = orders::table
    .select((orders::id, orders::status))
    .filter(orders::status.eq("pending"))
    .load(&mut conn)?;

// Join:
let results: Vec<(Order, Customer)> = orders::table
    .inner_join(customers::table)
    .filter(orders::status.eq("pending"))
    .load(&mut conn)?;
```

#### N+1 Prevention

```rust
// Diesel has no lazy loading — all queries are explicit.
// Manual approach (same as Knex):

// 1. Load parents
let parent_orders: Vec<Order> = orders::table
    .filter(orders::status.eq("pending"))
    .load(&mut conn)?;

// 2. Load children in one query
let order_ids: Vec<i32> = parent_orders.iter().map(|o| o.id).collect();
let order_items: Vec<Item> = items::table
    .filter(items::order_id.eq_any(&order_ids))
    .load(&mut conn)?;

// 3. Group using belonging_to:
let grouped: Vec<Vec<Item>> = Item::belonging_to(&parent_orders)
    .load::<Item>(&mut conn)?
    .grouped_by(&parent_orders);

let orders_with_items: Vec<(Order, Vec<Item>)> =
    parent_orders.into_iter().zip(grouped).collect();
```

#### Escape Hatch

```rust
use diesel::sql_query;

// Raw SQL with typed results:
let orders: Vec<Order> = sql_query("SELECT * FROM orders WHERE status = $1")
    .bind::<Text, _>("pending")
    .load::<Order>(&mut conn)?;

// Raw SQL fragment in a Diesel query:
use diesel::dsl::sql;
orders::table
    .filter(sql::<Bool>("created_at > NOW() - INTERVAL '7 days'"))
    .load::<Order>(&mut conn)?;

// Execute raw without mapping:
diesel::sql_query("ANALYZE orders").execute(&mut conn)?;
```

#### Migration Tool

Built-in `diesel migration` — generates up.sql/down.sql files:

```bash
diesel migration generate create_orders
# Edit up.sql and down.sql with raw SQL
diesel migration run
diesel migration revert
diesel migration redo  # revert + run (useful for testing)
```

Migrations are raw SQL by default — you have full control. This is arguably the best migration system because it doesn't try to be clever.

#### Common Gotchas

1. **Schema.rs drift:** If you modify the database outside Diesel migrations, `schema.rs` won't match. Run `diesel print-schema > src/schema.rs` to resync.
2. **No async by default:** Diesel is synchronous. For async, use `deadpool-diesel` or `diesel-async` (separate crate). Mixing sync Diesel with async Tokio without a spawn_blocking wrapper will block the runtime.
3. **Boxed queries for dynamic conditions:** Diesel queries are generic types. Dynamic filters require `into_boxed()`:
   ```rust
   let mut query = orders::table.into_boxed();
   if let Some(s) = status_filter {
       query = query.filter(orders::status.eq(s));
   }
   ```
4. **Compile times:** Diesel's type-level query validation is powerful but makes compile times significantly slower on large schemas.

---

### 12. SQLx (Rust)

**Ecosystem:** Rust. NOT an ORM — compile-time checked raw SQL. You write SQL, SQLx verifies it against your database at compile time.

#### Setup & SQL Logging

```rust
// SQLX_LOG=info environment variable
// Or use tracing:
let pool = PgPoolOptions::new()
    .max_connections(10)
    .connect("postgres://...")
    .await?;

// sqlx queries are logged via the `tracing` crate at DEBUG level.
// Enable with:
tracing_subscriber::fmt()
    .with_env_filter("sqlx=debug")
    .init();
```

#### Schema Definition

SQLx doesn't define schemas. You write SQL migrations:

```bash
sqlx migrate add create_orders
# Edit the generated .sql file
sqlx migrate run
```

```sql
-- migrations/20240115_create_orders.sql
CREATE TABLE orders (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    status VARCHAR(50) NOT NULL,
    total NUMERIC(12, 2),
    customer_id BIGINT REFERENCES customers(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_status_created ON orders (status, created_at);
CREATE INDEX idx_orders_pending ON orders (created_at) WHERE status = 'pending';
```

#### Query Patterns

```rust
// Compile-time checked query (requires DATABASE_URL at compile time):
let orders = sqlx::query_as!(
    Order,
    r#"
    SELECT id, status, total, customer_id, created_at
    FROM orders
    WHERE status = $1
    ORDER BY created_at DESC
    LIMIT $2
    "#,
    "pending",
    100i64
)
.fetch_all(&pool)
.await?;

// Dynamic query (runtime, not compile-time checked):
let orders = sqlx::query_as::<_, Order>(
    "SELECT * FROM orders WHERE status = $1"
)
.bind("pending")
.fetch_all(&pool)
.await?;

// Streaming results (for large datasets):
let mut stream = sqlx::query_as!(Order, "SELECT * FROM orders WHERE status = $1", "pending")
    .fetch(&pool);

while let Some(order) = stream.try_next().await? {
    process(order);
}
```

#### N+1 Prevention

SQLx doesn't have relationships. Write your SQL to avoid N+1:

```rust
// Option 1: JOIN
let results = sqlx::query!(
    r#"
    SELECT o.id, o.status, o.total,
           i.id as "item_id?", i.name as "item_name?"
    FROM orders o
    LEFT JOIN items i ON i.order_id = o.id
    WHERE o.status = $1
    "#,
    "pending"
)
.fetch_all(&pool)
.await?;
// Reshape flat rows into nested structs manually.

// Option 2: Separate queries with IN
let orders = sqlx::query_as!(Order, "SELECT * FROM orders WHERE status = $1", "pending")
    .fetch_all(&pool)
    .await?;

let ids: Vec<i64> = orders.iter().map(|o| o.id).collect();
let items = sqlx::query_as!(Item, "SELECT * FROM items WHERE order_id = ANY($1)", &ids)
    .fetch_all(&pool)
    .await?;
```

#### Escape Hatch

SQLx IS the escape hatch. You're already writing SQL. Everything is raw.

```rust
// Execute without returning rows:
sqlx::query("ANALYZE orders").execute(&pool).await?;

// Untyped query (returns generic Row):
let rows = sqlx::query("SELECT * FROM orders WHERE id = $1")
    .bind(42i64)
    .fetch_all(&pool)
    .await?;
for row in rows {
    let id: i64 = row.get("id");
    let status: String = row.get("status");
}
```

#### Migration Tool

Built-in `sqlx migrate`:

```bash
sqlx migrate add create_orders    # creates .sql file
sqlx migrate run                   # applies pending
sqlx migrate revert                # reverts last
sqlx migrate info                  # shows status
```

Migrations are plain SQL. Full PostgreSQL DDL support. No abstraction layer to fight.

#### Common Gotchas

1. **`DATABASE_URL` required at compile time for `query!` macro:** The compile-time checking connects to your database during `cargo build`. In CI, set `SQLX_OFFLINE=true` and use `cargo sqlx prepare` to generate a JSON cache of query metadata.
2. **Nullable columns require `Option<T>`:** If a column can be NULL, `query_as!` expects `Option<T>`. If you write a LEFT JOIN, the joined columns become nullable — annotate with `as "column?"`.
3. **No connection pooling configuration by default:** `PgPoolOptions::new()` defaults to 10 connections. Set it explicitly based on your workload.
4. **`fetch_one` panics on no rows:** Use `fetch_optional` when the query might return zero rows.

---

### 13. GORM (Go)

**Ecosystem:** Go. The most popular Go ORM. Convention-based, struct tag configuration.

#### Setup & SQL Logging

```go
import (
    "gorm.io/gorm"
    "gorm.io/gorm/logger"
    "gorm.io/driver/postgres"
)

db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
    Logger: logger.Default.LogMode(logger.Info),  // log all SQL
})

// Slow query threshold:
newLogger := logger.New(
    log.New(os.Stdout, "\r\n", log.LstdFlags),
    logger.Config{
        SlowThreshold: 200 * time.Millisecond,
        LogLevel:      logger.Warn,  // only log slow queries
    },
)

// Per-query debug:
db.Debug().Where("status = ?", "pending").Find(&orders)
```

#### Schema Definition

```go
type Order struct {
    ID         uint           `gorm:"primaryKey"`
    Status     string         `gorm:"type:varchar(50);not null;index"`
    Total      decimal.Decimal `gorm:"type:decimal(12,2)"`
    CustomerID uint           `gorm:"index"`
    Customer   Customer       `gorm:"foreignKey:CustomerID"`
    Items      []Item         `gorm:"foreignKey:OrderID"`
    CreatedAt  time.Time
    UpdatedAt  time.Time
}

// AutoMigrate (dev only):
db.AutoMigrate(&Order{})
```

**What it gets wrong:**
- `AutoMigrate` only adds columns/indexes — it never drops or modifies existing columns. Schema drift is invisible.
- `gorm:"primaryKey"` with `uint` uses `serial` — no `GENERATED ALWAYS AS IDENTITY`
- GORM creates foreign key constraints by default with `AutoMigrate` — this can surprise you in existing databases
- No support for partial indexes, GIN indexes, or other PostgreSQL-specific index types via struct tags

#### Query Patterns

```go
// Basic query:
var orders []Order
db.Where("status = ?", "pending").
    Order("created_at DESC").
    Limit(100).
    Find(&orders)

// Select specific columns:
db.Select("id", "status", "total").Where("status = ?", "pending").Find(&orders)

// Aggregate:
var count int64
db.Model(&Order{}).Where("status = ?", "pending").Count(&count)

// Group by:
type StatusCount struct {
    Status string
    Count  int64
    Total  float64
}
var results []StatusCount
db.Model(&Order{}).
    Select("status, COUNT(*) as count, SUM(total) as total").
    Group("status").
    Scan(&results)

// Scopes:
func Pending(db *gorm.DB) *gorm.DB {
    return db.Where("status = ?", "pending")
}
db.Scopes(Pending).Find(&orders)
```

#### N+1 Prevention

```go
// Preload (separate queries — safe from cartesian explosion):
db.Preload("Items").Preload("Customer").Where("status = ?", "pending").Find(&orders)

// Preload with conditions:
db.Preload("Items", "quantity > ?", 0).Find(&orders)

// Preload with custom query:
db.Preload("Items", func(db *gorm.DB) *gorm.DB {
    return db.Where("quantity > ?", 0).Order("name ASC")
}).Find(&orders)

// Joins (single query, but no auto-mapping to struct):
db.Joins("Customer").Where("orders.status = ?", "pending").Find(&orders)
// This populates order.Customer via JOIN, not a separate query.

// Nested preload:
db.Preload("Items.Product").Find(&orders)
```

#### Escape Hatch

```go
// Raw SQL:
var orders []Order
db.Raw("SELECT * FROM orders WHERE status = ?", "pending").Scan(&orders)

// Execute (INSERT/UPDATE/DELETE):
db.Exec("UPDATE orders SET status = ? WHERE created_at < NOW() - INTERVAL '30 days'", "archived")

// Raw in Where:
db.Where("created_at > NOW() - INTERVAL '7 days'").Find(&orders)

// Session for connection-level control:
tx := db.Session(&gorm.Session{PrepareStmt: true})
tx.Find(&orders)
```

#### Migration Tool

GORM has `AutoMigrate` (not suitable for production) and a community tool `gorm-migrate`.

For production, use a dedicated migration tool:
- **golang-migrate/migrate** — SQL file based, database-agnostic
- **goose** — SQL or Go-based migrations
- **atlas** — declarative schema management

```bash
# golang-migrate:
migrate create -ext sql -dir db/migrations -seq add_orders_index
migrate -database "postgres://..." -path db/migrations up

# goose:
goose -dir db/migrations postgres "postgres://..." up
```

#### Common Gotchas

1. **`AutoMigrate` in production:** It adds columns but never removes them. It changes column types but silently fails if the cast is impossible. It creates indexes but never drops them. Use a real migration tool.
2. **Soft deletes (`gorm.Model` includes `DeletedAt`):** Embedding `gorm.Model` adds a `deleted_at` column and a global WHERE clause. All queries silently exclude soft-deleted rows. Use `Unscoped()` to include them.
3. **`Find` with a primary key:** `db.Find(&order, 1)` looks clean but behaves differently than `db.First(&order, 1)`. `Find` does not error on not-found; `First` returns `ErrRecordNotFound`.
4. **Connection pool via `database/sql`:** GORM uses Go's `database/sql` under the hood. Set pool config via:
   ```go
   sqlDB, _ := db.DB()
   sqlDB.SetMaxOpenConns(25)
   sqlDB.SetMaxIdleConns(5)
   sqlDB.SetConnMaxLifetime(5 * time.Minute)
   ```
5. **`Save` does a full update:** `db.Save(&order)` updates ALL columns, not just changed ones. Use `db.Model(&order).Updates(map[string]interface{}{"status": "done"})` for partial updates.

---

### 14. sqlc (Go)

**Ecosystem:** Go. SQL-first code generation. You write SQL queries in `.sql` files, sqlc generates type-safe Go code. Not an ORM — the polar opposite.

#### Setup & SQL Logging

sqlc doesn't generate queries at runtime — you wrote them. To log execution:

```go
// Wrap the generated Queries struct with logging middleware:
// Or use pgx's query tracer:
import "github.com/jackc/pgx/v5/tracelog"

config.Tracer = &tracelog.TraceLog{
    Logger:   &myLogger{},
    LogLevel: tracelog.LogLevelDebug,
}
```

#### Schema Definition

```sql
-- schema.sql (or migrations/ directory)
CREATE TABLE orders (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    status VARCHAR(50) NOT NULL,
    total NUMERIC(12, 2),
    customer_id BIGINT REFERENCES customers(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_status_created ON orders (status, created_at);
CREATE INDEX idx_orders_pending ON orders (created_at) WHERE status = 'pending';
```

Full PostgreSQL DDL. No abstraction. No limitations.

#### Query Patterns

```sql
-- queries/orders.sql

-- name: GetPendingOrders :many
SELECT id, status, total, customer_id, created_at
FROM orders
WHERE status = 'pending'
ORDER BY created_at DESC
LIMIT $1;

-- name: GetOrderWithCustomer :one
SELECT o.id, o.status, o.total, c.name as customer_name
FROM orders o
JOIN customers c ON c.id = o.customer_id
WHERE o.id = $1;

-- name: CountByStatus :many
SELECT status, COUNT(*) as count, SUM(total) as total
FROM orders
GROUP BY status;

-- name: CreateOrder :one
INSERT INTO orders (status, total, customer_id)
VALUES ($1, $2, $3)
RETURNING *;
```

```bash
sqlc generate  # generates Go code from SQL
```

```go
// Generated code — type-safe, no runtime SQL generation:
orders, err := queries.GetPendingOrders(ctx, 100)
order, err := queries.GetOrderWithCustomer(ctx, 42)
stats, err := queries.CountByStatus(ctx)
```

#### N+1 Prevention

N+1 is impossible if you write proper SQL. sqlc forces you to think in SQL:

```sql
-- name: GetOrdersWithItems :many
SELECT o.id, o.status, o.total,
       i.id as item_id, i.name as item_name, i.quantity
FROM orders o
LEFT JOIN items i ON i.order_id = o.id
WHERE o.status = $1
ORDER BY o.id, i.id;
```

You still need to reshape flat rows into nested structs in Go, but the query is efficient.

#### Escape Hatch

sqlc IS raw SQL. There's no ORM to escape from. For truly dynamic queries that sqlc can't handle, use pgx directly:

```go
rows, err := pool.Query(ctx, "SELECT * FROM orders WHERE "+dynamicCondition, args...)
```

#### Migration Tool

sqlc doesn't manage migrations. Pair it with:
- **golang-migrate/migrate**
- **goose**
- **atlas**
- **Liquibase** or **Flyway**

#### Common Gotchas

1. **Flat results from JOINs:** sqlc generates a flat struct for JOIN queries. You get `[]GetOrdersWithItemsRow` where each row has order + item fields. Group them yourself.
2. **`sqlc.arg()` for named parameters:** Default parameters are positional (`$1`, `$2`). Use `sqlc.arg(name)` for named params in generated Go code.
3. **Schema changes require regeneration:** Any DDL change requires `sqlc generate`. If you forget, the generated code and the database are out of sync (but at least it fails at compile time if types changed).
4. **Limited dynamic query support:** sqlc works best with static queries. Dynamic WHERE clauses, optional filters, and variable column lists require workarounds (e.g., `CASE WHEN @filter_status::bool THEN status = @status ELSE true END`).

---

### 15. ent (Go)

**Ecosystem:** Go. Graph-based ORM from Meta (Facebook). Schema defined as Go code, generates type-safe CRUD, supports graph traversals.

#### Setup & SQL Logging

```go
import "entgo.io/ent/dialect/sql"

// Debug mode (logs all SQL):
client, err := ent.Open("postgres", dsn, ent.Debug())

// Custom logger:
client, err := ent.Open("postgres", dsn, ent.Log(func(args ...interface{}) {
    log.Println(args...)
}))
```

#### Schema Definition

```go
// ent/schema/order.go
package schema

import (
    "entgo.io/ent"
    "entgo.io/ent/schema/field"
    "entgo.io/ent/schema/edge"
    "entgo.io/ent/schema/index"
)

type Order struct {
    ent.Schema
}

func (Order) Fields() []ent.Field {
    return []ent.Field{
        field.String("status").MaxLen(50).NotEmpty(),
        field.Float("total"),     // no Decimal type — use string or custom type
        field.Time("created_at").Default(time.Now),
    }
}

func (Order) Edges() []ent.Edge {
    return []ent.Edge{
        edge.From("customer", Customer.Type).Ref("orders").Unique().Required(),
        edge.To("items", Item.Type),
    }
}

func (Order) Indexes() []ent.Index {
    return []ent.Index{
        index.Fields("status", "created_at"),
    }
}
```

```bash
go generate ./ent  # generates CRUD code from schema
```

**What it gets wrong:**
- No native `Decimal` field type — you lose precision using `Float` for money. Use `field.Other` with a custom type or store as integer cents.
- `Default(time.Now)` uses Go time, not database `NOW()` — use `SchemaType` map for `DEFAULT NOW()`
- No partial index support in the schema DSL
- Generated code is verbose — large schemas produce thousands of lines of generated Go

#### Query Patterns

```go
// Type-safe queries:
orders, err := client.Order.
    Query().
    Where(order.StatusEQ("pending")).
    Order(ent.Desc(order.FieldCreatedAt)).
    Limit(100).
    All(ctx)

// Aggregate:
count, err := client.Order.
    Query().
    Where(order.StatusEQ("pending")).
    Count(ctx)

// Graph traversal (ent's differentiator):
// "Get all items for pending orders from customers in California"
items, err := client.Customer.
    Query().
    Where(customer.StateEQ("CA")).
    QueryOrders().
    Where(order.StatusEQ("pending")).
    QueryItems().
    All(ctx)
```

#### N+1 Prevention

```go
// Eager loading with .With*():
orders, err := client.Order.
    Query().
    Where(order.StatusEQ("pending")).
    WithItems().          // eager load items
    WithCustomer().       // eager load customer
    All(ctx)

// With filtered eager loading:
orders, err := client.Order.
    Query().
    WithItems(func(q *ent.ItemQuery) {
        q.Where(item.QuantityGT(0))
    }).
    All(ctx)

// ent uses separate queries for eager loading (like Prisma), not JOINs.
```

#### Escape Hatch

```go
// Raw SQL via the underlying sql.DB:
rows, err := client.DB().QueryContext(ctx,
    "SELECT * FROM orders WHERE status = $1", "pending")

// Modifier for adding raw SQL to ent queries:
orders, err := client.Order.
    Query().
    Where(func(s *sql.Selector) {
        s.Where(sql.ExprP("created_at > NOW() - INTERVAL '7 days'"))
    }).
    All(ctx)

// Full SQL builder escape:
var results []struct {
    Status string
    Count  int
}
client.Order.
    Query().
    GroupBy(order.FieldStatus).
    Aggregate(ent.Count()).
    Scan(ctx, &results)
```

#### Migration Tool

ent has two migration modes:

```bash
# Auto-migration (dev only — same caveats as GORM):
client.Schema.Create(ctx)

# Versioned migrations (production):
# Uses Atlas under the hood
atlas migrate diff add_orders_index \
  --dir "file://ent/migrate/migrations" \
  --to "ent://ent/schema" \
  --dev-url "docker://postgres/15"
```

#### Common Gotchas

1. **Auto-migration in production:** Same as GORM — never drops columns, can't handle complex changes. Use Atlas versioned migrations.
2. **No decimal type:** `field.Float("total")` loses precision. For financial data, store as integer cents or use a custom `field.Other` type with `shopspring/decimal`.
3. **Generated code bloat:** Each schema entity generates ~1000 lines of Go. 20 entities = 20,000 lines of generated code. This is correct but affects IDE performance and build times.
4. **Edge (relationship) naming:** Edge names must be unique across the schema. Two entities with an edge named "items" will conflict. Use specific names.
5. **Graph traversals can generate multiple queries:** `client.Customer.Query().QueryOrders().QueryItems().All(ctx)` may generate separate queries for each hop. Check the SQL output to verify.

---

## Liquibase

Liquibase is a database-independent migration tool that tracks changes via a changelog. It's particularly valuable when you need multi-database support, complex rollback strategies, or audit-grade change tracking.

### Changelog Formats

Liquibase supports four changelog formats. Choose based on your team:

| Format | Best For | Example |
|--------|----------|---------|
| **SQL** | DBAs who think in SQL | Direct DDL, most control |
| **YAML** | Devs who want readability | Clean, mergeable |
| **XML** | Enterprise/legacy projects | Most documentation, most verbose |
| **JSON** | API-driven workflows | Machine-readable |

```yaml
# YAML example — db/changelog/changes/001-create-orders.yaml
databaseChangeLog:
  - changeSet:
      id: 001-create-orders
      author: dba-team
      changes:
        - createTable:
            tableName: orders
            columns:
              - column:
                  name: id
                  type: bigint
                  autoIncrement: true
                  constraints:
                    primaryKey: true
              - column:
                  name: status
                  type: varchar(50)
                  constraints:
                    nullable: false
              - column:
                  name: total
                  type: decimal(12,2)
              - column:
                  name: customer_id
                  type: bigint
                  constraints:
                    foreignKeyName: fk_orders_customer
                    references: customers(id)
              - column:
                  name: created_at
                  type: timestamptz
                  defaultValueComputed: NOW()
      rollback:
        - dropTable:
            tableName: orders
```

```sql
-- SQL example — db/changelog/changes/001-create-orders.sql
--liquibase formatted sql

--changeset dba-team:001-create-orders
CREATE TABLE orders (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    status VARCHAR(50) NOT NULL,
    total NUMERIC(12, 2),
    customer_id BIGINT REFERENCES customers(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
--rollback DROP TABLE orders;
```

### Changeset Best Practices

1. **One logical change per changeset:** Don't combine `CREATE TABLE` and `CREATE INDEX` in one changeset. If the index creation fails, you can't retry without re-running the table creation.

2. **Always include rollback blocks:** Even if you think you'll never rollback. Future you will thank present you.

3. **Use meaningful IDs:** `001-create-orders` not `1`. IDs are strings — use them.

4. **Never modify an applied changeset:** Liquibase checksums applied changesets. Modifying one causes a checksum mismatch error. Create a new changeset instead.

5. **Tag before risky changes:**
   ```yaml
   - changeSet:
       id: tag-before-partition
       author: dba-team
       changes:
         - tagDatabase:
             tag: pre-partition-refactor
   ```

### Contexts and Labels for Multi-Environment

```yaml
# Only runs in production:
- changeSet:
    id: 005-add-prod-index
    author: dba-team
    context: production
    changes:
      - sql:
          sql: CREATE INDEX CONCURRENTLY idx_orders_pending ON orders (created_at) WHERE status = 'pending'

# Labels for feature flags:
- changeSet:
    id: 006-add-audit-columns
    author: dba-team
    labels: "feature-audit,v2.0"
    changes:
      - addColumn: ...
```

```bash
# Apply only production context:
liquibase --contexts=production update

# Apply by label:
liquibase --label-filter="v2.0" update
```

### Preconditions

Guard changesets against unexpected database states:

```yaml
- changeSet:
    id: 010-add-column-if-missing
    author: dba-team
    preConditions:
      - onFail: MARK_RAN       # skip but record as applied
      - not:
          - columnExists:
              tableName: orders
              columnName: priority
    changes:
      - addColumn:
          tableName: orders
          columns:
            - column:
                name: priority
                type: int
                defaultValueNumeric: 0
```

Common preconditions:
- `tableExists` / `columnExists` / `indexExists`
- `dbms` (only run on specific databases)
- `runningAs` (only run as specific DB user)
- `sqlCheck` (run arbitrary SQL, check result)

### Custom SQL Changesets

For PostgreSQL-specific features that Liquibase's abstraction can't express:

```yaml
- changeSet:
    id: 020-partition-orders
    author: dba-team
    changes:
      - sql:
          sql: |
            -- Convert to partitioned table
            ALTER TABLE orders RENAME TO orders_old;
            CREATE TABLE orders (LIKE orders_old INCLUDING ALL) PARTITION BY RANGE (created_at);
            CREATE TABLE orders_2024 PARTITION OF orders
              FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
            INSERT INTO orders SELECT * FROM orders_old;
    rollback:
      - sql:
          sql: |
            DROP TABLE orders;
            ALTER TABLE orders_old RENAME TO orders;
```

### Liquibase vs Flyway Comparison

| Feature | Liquibase | Flyway |
|---------|-----------|--------|
| **Changelog format** | XML, YAML, SQL, JSON | SQL, Java |
| **Rollback support** | Built-in, per-changeset | Manual (undo migrations, paid feature) |
| **Preconditions** | Yes (table/column/DB checks) | No |
| **Contexts/Labels** | Yes (multi-env filtering) | No (use file naming conventions) |
| **Diff/snapshot** | Yes (compare DB to changelog) | No |
| **Complexity** | Higher — more features, more config | Lower — simpler model |
| **Best for** | Large teams, multi-DB, enterprise | Small-medium teams, PostgreSQL-only |
| **Checksum validation** | Yes | Yes |
| **Community edition** | Full-featured | Most features (undo is paid) |

**DBA recommendation:** If you're PostgreSQL-only and your team thinks in SQL, use Flyway. If you need multi-database support, complex rollback strategies, or precondition guards, use Liquibase.

### Integration with ORMs (Liquibase for DDL, ORM for DML)

The cleanest architecture: **Liquibase owns the schema, the ORM is read-only against it.**

```
                     ┌─────────────┐
                     │  Liquibase  │
                     │  (DDL only) │
                     └──────┬──────┘
                            │ CREATE TABLE, ALTER, INDEX
                            ▼
                     ┌─────────────┐
                     │  PostgreSQL │
                     └──────┬──────┘
                            │ SELECT, INSERT, UPDATE, DELETE
                            ▲
                     ┌──────┴──────┐
                     │   ORM/App   │
                     │  (DML only) │
                     └─────────────┘
```

**Per-framework configuration to disable ORM-managed DDL:**

| Framework | Disable DDL |
|-----------|-------------|
| Hibernate | `hibernate.hbm2ddl.auto=validate` (checks but doesn't modify) |
| Django | Don't run `migrate` — use `inspectdb` to generate models from existing tables |
| Ecto | Skip `mix ecto.migrate` — write schemas to match existing tables |
| GORM | Don't call `AutoMigrate` — define structs to match existing tables |
| Prisma | `prisma db pull` to introspect, don't `prisma migrate dev` |
| TypeORM | `synchronize: false` (must be false in production anyway) |
| Sequelize | Don't run `sequelize db:migrate` — define models to match existing tables |
| ent | Don't call `client.Schema.Create` — use Atlas migrations managed separately |

---

## Connection Pooling

### Per-Language Recommendations

| Language | Built-in Pooler | External Pooler | Default Pool Size | Production Recommendation |
|----------|----------------|-----------------|-------------------|---------------------------|
| **Elixir** (Ecto) | DBConnection | PgBouncer | 10 | 10-20 per node (Elixir handles concurrency via processes) |
| **Python** (SQLAlchemy) | SQLAlchemy pool | PgBouncer | 5 | `pool_size=5, max_overflow=10` per process; PgBouncer in front for multi-process |
| **Python** (Django) | Django `CONN_MAX_AGE` | PgBouncer | 0 (no pooling!) | Set `CONN_MAX_AGE=600`; PgBouncer for production |
| **Java** (Hibernate) | HikariCP | PgBouncer | 10 | HikariCP with `maximumPoolSize = (cores * 2) + 1` |
| **PHP** (Laravel) | None (per-request) | PgBouncer | N/A | PgBouncer is mandatory — PHP doesn't persist connections |
| **Node.js** (Prisma) | Internal pool | PgBouncer | `num_cpus * 2 + 1` | PgBouncer for serverless; `connection_limit` param for traditional |
| **Node.js** (Knex) | tarn.js | PgBouncer | 10 | `pool: { min: 2, max: 10 }` per process |
| **Node.js** (pg) | pg.Pool | PgBouncer | 10 | Match pool size to expected concurrent queries |
| **Rust** (Diesel) | r2d2 / deadpool | PgBouncer | varies | `deadpool-diesel` with `max_size` = `(cores * 2) + 1` |
| **Rust** (SQLx) | Built-in pool | PgBouncer | 10 | `max_connections` based on workload |
| **Go** (GORM/sqlc) | database/sql | PgBouncer | unlimited (!) | `SetMaxOpenConns(25)`, `SetMaxIdleConns(5)`, `SetConnMaxLifetime(5m)` |

### When to Use External Pooling (PgBouncer)

**Use PgBouncer when:**
- Multiple application instances connect to the same database
- Serverless / Lambda / Cloud Functions (each invocation opens connections)
- PHP applications (no persistent connections)
- Connection count exceeds PostgreSQL's `max_connections` (default 100)
- You need connection multiplexing (many app connections → few DB connections)

**PgBouncer modes:**

| Mode | Description | Prepared Statements | Use When |
|------|-------------|-------------------|----------|
| **session** | 1:1 mapping, client holds connection for session | Yes | Low connection count, need prepared statements |
| **transaction** | Connection returned to pool after each transaction | No (named) | Most production workloads |
| **statement** | Connection returned after each statement | No | Simple queries, maximum sharing |

**Transaction mode + prepared statements:** Named prepared statements break in transaction mode because the prepared statement lives on a connection that gets reassigned. Solutions:
- Use unnamed/protocol-level prepared statements (supported by most drivers)
- Prisma: set `pgbouncer=true` in connection string
- SQLAlchemy: `pool_pre_ping=True`, disable server-side cursors
- Ecto: Postgrex supports protocol-level prepared statements by default (safe with PgBouncer transaction mode)

### Connection Pool Sizing Formula

The authoritative formula from the PostgreSQL wiki:

```
pool_size = (core_count * 2) + effective_spindle_count
```

- For SSD: `effective_spindle_count = 1`
- For a 4-core server with SSD: `pool_size = (4 * 2) + 1 = 9`

**Common mistake:** Setting pool size to 50-100 "just in case." More connections than cores means more context switching, more lock contention, and more memory per connection (~10MB each in PostgreSQL). A smaller pool with a connection queue is faster than a large pool with contention.

**PostgreSQL side:**
```sql
-- Check current connections:
SELECT count(*) FROM pg_stat_activity;

-- Max connections (default 100):
SHOW max_connections;

-- Recommended: max_connections = (app_pool_size * num_app_instances) + superuser_reserved + monitoring_overhead
-- Example: (10 * 4 instances) + 3 reserved + 5 monitoring = 48
-- Leave headroom: set max_connections = 60
```

---

## Quick Reference: Choosing Your Stack

| If you want... | Use |
|----------------|-----|
| Maximum SQL control with type safety | sqlc (Go), SQLx (Rust), Knex (Node.js) |
| Full ORM with good defaults | Ecto (Elixir), Django ORM (Python) |
| Full ORM with maximum features | SQLAlchemy (Python), Hibernate (Java) |
| Type-safe Node.js with schema-first | Prisma |
| Type-safe Node.js close to SQL | Drizzle |
| Graph-based data modeling | ent (Go) |
| Compile-time SQL verification | Diesel (Rust), SQLx (Rust), sqlc (Go) |
| Legacy codebase you can't change | Learn the escape hatches above |

---

*This reference is part of the DBA skill module. For schema design patterns, see `schema-design-patterns.md`. For indexing strategies, see `indexing-strategy.md`.*
