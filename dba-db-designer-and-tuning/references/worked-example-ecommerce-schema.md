# Worked Example: Multi-Tenant E-Commerce Schema

> A complete end-to-end database design walkthrough for a SaaS e-commerce platform on PostgreSQL 16. This reads like a senior DBA walking a team through a design review — every decision is justified, every trade-off is named, and every query is optimized against real access patterns.

---

## Scenario Brief

**Product:** A SaaS e-commerce platform where each tenant operates an independent storefront. Tenants share a single PostgreSQL 16 database with row-level security (RLS) providing isolation.

**Core requirements:**
- Multi-tenancy via row-level security (`tenant_id` on every table)
- Product catalog with arbitrary variants (size, color, material — varies by tenant)
- Orders with line items and order-level status tracking
- Real-time inventory tracking at the variant level
- Customer accounts scoped to a single tenant
- Product review system with aggregate rating caching

**Scale expectations:**
- 500 tenants
- 1M products (across all tenants, ~2K per tenant average, power-law distribution)
- ~3M product variants
- 10M orders/year (~27K/day)
- ~30M line items/year
- ~5M reviews total

**Non-functional constraints:**
- Sub-100ms for product catalog reads
- Sub-200ms for order placement (insert order + line items + decrement inventory)
- Nightly analytics queries are acceptable at seconds-scale
- Must support zero-downtime schema migrations

---

## Phase 1: Requirements Analysis

### Entities Identified

| Entity | Description | Estimated Row Count |
|--------|-------------|-------------------|
| `tenants` | SaaS customer organizations | 500 |
| `products` | Catalog items, one per base product | 1M |
| `product_variants` | Specific SKUs (size/color combos) | 3M |
| `customers` | End-user accounts, scoped to tenant | 5M |
| `orders` | Purchase transactions | 10M/year, ~30M total after 3 years |
| `order_items` | Line items within an order | ~90M after 3 years |
| `inventory` | Stock levels per variant per location | 3M |
| `reviews` | Product reviews by customers | 5M |

### Key Relationships

| Relationship | Cardinality | Notes |
|-------------|-------------|-------|
| tenant → products | 1:N | ~2K avg, some tenants have 50K+ |
| product → variants | 1:N | 1-50 variants per product |
| tenant → customers | 1:N | Customers belong to exactly one tenant |
| customer → orders | 1:N | Order history grows unbounded |
| order → order_items | 1:N | 1-20 items per order, avg 3 |
| order_item → product_variant | N:1 | Variant may appear in many orders |
| product_variant → inventory | 1:1 | One stock record per variant (single-warehouse for v1) |
| customer → reviews | 1:N | One review per product per customer |
| product → reviews | 1:N | Aggregate rating cached on product |

### Access Patterns (ranked by frequency)

| # | Pattern | Frequency | Latency Target |
|---|---------|-----------|----------------|
| 1 | Browse product catalog (paginated, filtered by category/price) | 100K/day | <100ms |
| 2 | View single product with variants and reviews | 50K/day | <100ms |
| 3 | Place an order (insert order + items, decrement inventory) | 27K/day | <200ms |
| 4 | View order history for a customer | 10K/day | <100ms |
| 5 | Check inventory for a variant | 30K/day | <50ms |
| 6 | Submit a review | 2K/day | <200ms |
| 7 | Sales report by tenant (daily/monthly aggregation) | 500/day | <5s |
| 8 | Admin: list all tenants with order counts | 50/day | <2s |

### Constraints Discovered

- **Uniqueness:** One review per customer per product. SKU unique within tenant.
- **Inventory:** Stock cannot go negative (CHECK constraint + application logic).
- **Order immutability:** Once placed, order items are append-only. Status transitions are forward-only.
- **Soft deletes:** Products can be archived (hidden from catalog) but must remain for order history.
- **Tenant isolation:** RLS must prevent any cross-tenant data access, even from application bugs.

---

## Phase 2: Conceptual Design

### Entity-Relationship Table

| Parent Entity | Relationship | Child Entity | FK Column | Semantics |
|--------------|-------------|-------------|-----------|-----------|
| `tenants` | has many | `products` | `tenant_id` | Tenant owns all their products |
| `tenants` | has many | `customers` | `tenant_id` | Customers scoped to storefront |
| `tenants` | has many | `orders` | `tenant_id` | Denormalized for RLS (could derive from customer, but direct FK is faster for RLS) |
| `products` | has many | `product_variants` | `product_id` | Variants are SKU-level children |
| `products` | has many | `reviews` | `product_id` | Reviews attached to base product |
| `customers` | has many | `orders` | `customer_id` | Customer order history |
| `customers` | has many | `reviews` | `customer_id` | Customer wrote the review |
| `orders` | has many | `order_items` | `order_id` | Line items in the order |
| `product_variants` | referenced by | `order_items` | `variant_id` | Which variant was purchased |
| `product_variants` | has one | `inventory` | `variant_id` | Stock level for this variant |

### Design Decisions Made at Conceptual Stage

1. **`tenant_id` on every table** — Even where it's derivable (e.g., `order_items` could get tenant from `orders`), we denormalize `tenant_id` onto every table. This is the standard RLS pattern: the policy checks a single column, no joins required during policy evaluation.

2. **Dual ID strategy** — Internal `bigint` primary keys for joins and indexes (compact, fast). Public-facing `uuid` column for API exposure (non-guessable, safe for URLs).

3. **JSONB for variant attributes** — Product variants have arbitrary attributes (size, color, material, wattage — whatever the tenant sells). This is a classic EAV problem. JSONB with GIN indexing beats a rigid column set or an EAV table here because: attributes vary by tenant, the set of attributes changes frequently, and we query them but don't join on them.

4. **Aggregate rating on products** — `avg_rating` and `review_count` cached directly on `products`. Updated by trigger on `reviews` insert/update/delete. Avoids a `COUNT(*) + AVG()` on every product page view.

5. **Single-warehouse inventory** — v1 simplification. One `inventory` row per variant. Multi-warehouse is a future migration (add `warehouse_id` to make a composite key).

---

## Phase 3: Logical Design

### Prerequisite: Extensions and Shared Infrastructure

```sql
-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Shared function: auto-update updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Table: `tenants`

```sql
CREATE TABLE tenants (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    public_id   uuid NOT NULL DEFAULT gen_random_uuid(),
    name        text NOT NULL,
    slug        text NOT NULL,
    plan        text NOT NULL DEFAULT 'free'
                CHECK (plan IN ('free', 'starter', 'pro', 'enterprise')),
    settings    jsonb NOT NULL DEFAULT '{}',
    is_active   boolean NOT NULL DEFAULT true,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_tenants_public_id UNIQUE (public_id),
    CONSTRAINT uq_tenants_slug UNIQUE (slug)
);

CREATE TRIGGER trg_tenants_updated_at
    BEFORE UPDATE ON tenants
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

### Table: `customers`

```sql
CREATE TABLE customers (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    public_id   uuid NOT NULL DEFAULT gen_random_uuid(),
    tenant_id   bigint NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    email       text NOT NULL,
    name        text NOT NULL,
    password_hash text NOT NULL,
    metadata    jsonb NOT NULL DEFAULT '{}',
    is_active   boolean NOT NULL DEFAULT true,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_customers_public_id UNIQUE (public_id),
    CONSTRAINT uq_customers_tenant_email UNIQUE (tenant_id, email)
);

CREATE TRIGGER trg_customers_updated_at
    BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

### Table: `products`

```sql
CREATE TABLE products (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    public_id   uuid NOT NULL DEFAULT gen_random_uuid(),
    tenant_id   bigint NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name        text NOT NULL,
    slug        text NOT NULL,
    description text NOT NULL DEFAULT '',
    category    text NOT NULL DEFAULT 'uncategorized',
    base_price  numeric(12,2) NOT NULL CHECK (base_price >= 0),
    currency    text NOT NULL DEFAULT 'USD' CHECK (length(currency) = 3),
    attributes  jsonb NOT NULL DEFAULT '{}',
    avg_rating  numeric(3,2) NOT NULL DEFAULT 0.00
                CHECK (avg_rating >= 0 AND avg_rating <= 5),
    review_count integer NOT NULL DEFAULT 0 CHECK (review_count >= 0),
    is_active   boolean NOT NULL DEFAULT true,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_products_public_id UNIQUE (public_id),
    CONSTRAINT uq_products_tenant_slug UNIQUE (tenant_id, slug)
);

CREATE TRIGGER trg_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

### Table: `product_variants`

```sql
CREATE TABLE product_variants (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    public_id   uuid NOT NULL DEFAULT gen_random_uuid(),
    tenant_id   bigint NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    product_id  bigint NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    sku         text NOT NULL,
    name        text NOT NULL,                    -- e.g., "Large / Red"
    price_override numeric(12,2)                  -- NULL means use product base_price
                CHECK (price_override IS NULL OR price_override >= 0),
    attributes  jsonb NOT NULL DEFAULT '{}',      -- {"size": "L", "color": "red"}
    is_active   boolean NOT NULL DEFAULT true,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_variants_public_id UNIQUE (public_id),
    CONSTRAINT uq_variants_tenant_sku UNIQUE (tenant_id, sku)
);

CREATE TRIGGER trg_variants_updated_at
    BEFORE UPDATE ON product_variants
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

### Table: `inventory`

```sql
CREATE TABLE inventory (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id   bigint NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    variant_id  bigint NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
    quantity    integer NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    reserved    integer NOT NULL DEFAULT 0 CHECK (reserved >= 0),
    reorder_point integer NOT NULL DEFAULT 0,
    updated_at  timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_inventory_variant UNIQUE (variant_id),
    CONSTRAINT chk_reserved_lte_quantity CHECK (reserved <= quantity)
);

CREATE TRIGGER trg_inventory_updated_at
    BEFORE UPDATE ON inventory
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

### Table: `orders`

```sql
CREATE TYPE order_status AS ENUM (
    'pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded'
);

CREATE TABLE orders (
    id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    public_id       uuid NOT NULL DEFAULT gen_random_uuid(),
    tenant_id       bigint NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    customer_id     bigint NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
    status          order_status NOT NULL DEFAULT 'pending',
    subtotal        numeric(12,2) NOT NULL CHECK (subtotal >= 0),
    tax             numeric(12,2) NOT NULL DEFAULT 0.00 CHECK (tax >= 0),
    total           numeric(12,2) NOT NULL CHECK (total >= 0),
    currency        text NOT NULL DEFAULT 'USD' CHECK (length(currency) = 3),
    shipping_address jsonb NOT NULL DEFAULT '{}',
    metadata        jsonb NOT NULL DEFAULT '{}',
    placed_at       timestamptz NOT NULL DEFAULT now(),
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_orders_public_id UNIQUE (public_id)
);

CREATE TRIGGER trg_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

### Table: `order_items`

```sql
CREATE TABLE order_items (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id   bigint NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    order_id    bigint NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    variant_id  bigint NOT NULL REFERENCES product_variants(id) ON DELETE RESTRICT,
    quantity    integer NOT NULL CHECK (quantity > 0),
    unit_price  numeric(12,2) NOT NULL CHECK (unit_price >= 0),
    total_price numeric(12,2) NOT NULL CHECK (total_price >= 0),
    -- Snapshot variant details at time of purchase (prices change, variants get archived)
    variant_snapshot jsonb NOT NULL DEFAULT '{}',
    created_at  timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT chk_total_price CHECK (total_price = unit_price * quantity)
);
```

### Table: `reviews`

```sql
CREATE TABLE reviews (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    public_id   uuid NOT NULL DEFAULT gen_random_uuid(),
    tenant_id   bigint NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    product_id  bigint NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    customer_id bigint NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    rating      smallint NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title       text NOT NULL DEFAULT '',
    body        text NOT NULL DEFAULT '',
    is_verified boolean NOT NULL DEFAULT false,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_reviews_public_id UNIQUE (public_id),
    CONSTRAINT uq_reviews_customer_product UNIQUE (customer_id, product_id)
);

CREATE TRIGGER trg_reviews_updated_at
    BEFORE UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

### Review Aggregate Trigger

```sql
CREATE OR REPLACE FUNCTION update_product_review_stats()
RETURNS TRIGGER AS $$
DECLARE
    target_product_id bigint;
BEGIN
    -- Determine which product to update
    IF TG_OP = 'DELETE' THEN
        target_product_id := OLD.product_id;
    ELSE
        target_product_id := NEW.product_id;
    END IF;

    UPDATE products
    SET avg_rating = COALESCE(
            (SELECT ROUND(AVG(rating)::numeric, 2)
             FROM reviews WHERE product_id = target_product_id),
            0),
        review_count = (SELECT COUNT(*)
                        FROM reviews WHERE product_id = target_product_id)
    WHERE id = target_product_id;

    IF TG_OP = 'DELETE' THEN RETURN OLD; ELSE RETURN NEW; END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_reviews_update_product_stats
    AFTER INSERT OR UPDATE OF rating OR DELETE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_product_review_stats();
```

### Row-Level Security Setup

```sql
-- Create the application role
CREATE ROLE app_user;

-- Enable RLS on all tenant-scoped tables
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Policy pattern: app sets current_setting('app.tenant_id') on each connection
-- from the connection pool before executing queries.

CREATE POLICY tenant_isolation ON customers
    FOR ALL TO app_user
    USING (tenant_id = current_setting('app.tenant_id')::bigint)
    WITH CHECK (tenant_id = current_setting('app.tenant_id')::bigint);

CREATE POLICY tenant_isolation ON products
    FOR ALL TO app_user
    USING (tenant_id = current_setting('app.tenant_id')::bigint)
    WITH CHECK (tenant_id = current_setting('app.tenant_id')::bigint);

CREATE POLICY tenant_isolation ON product_variants
    FOR ALL TO app_user
    USING (tenant_id = current_setting('app.tenant_id')::bigint)
    WITH CHECK (tenant_id = current_setting('app.tenant_id')::bigint);

CREATE POLICY tenant_isolation ON inventory
    FOR ALL TO app_user
    USING (tenant_id = current_setting('app.tenant_id')::bigint)
    WITH CHECK (tenant_id = current_setting('app.tenant_id')::bigint);

CREATE POLICY tenant_isolation ON orders
    FOR ALL TO app_user
    USING (tenant_id = current_setting('app.tenant_id')::bigint)
    WITH CHECK (tenant_id = current_setting('app.tenant_id')::bigint);

CREATE POLICY tenant_isolation ON order_items
    FOR ALL TO app_user
    USING (tenant_id = current_setting('app.tenant_id')::bigint)
    WITH CHECK (tenant_id = current_setting('app.tenant_id')::bigint);

CREATE POLICY tenant_isolation ON reviews
    FOR ALL TO app_user
    USING (tenant_id = current_setting('app.tenant_id')::bigint)
    WITH CHECK (tenant_id = current_setting('app.tenant_id')::bigint);

-- Grant table access to app_user (RLS policies control row visibility)
GRANT SELECT, INSERT, UPDATE, DELETE ON
    customers, products, product_variants, inventory,
    orders, order_items, reviews
    TO app_user;

-- tenants table: read-only for app_user (admin operations use a different role)
GRANT SELECT ON tenants TO app_user;
```

**How it works at runtime:** The application's connection middleware executes `SET LOCAL app.tenant_id = '42'` inside each transaction. PostgreSQL's RLS policies then filter every query automatically. Even a rogue `SELECT * FROM orders` returns only tenant 42's orders. `SET LOCAL` scopes the setting to the current transaction, which is critical for connection-pooled environments.

---

## Phase 4: Indexing Strategy

### Index Plan

Every index below is justified by a specific query pattern from Phase 1. Indexes without a clear consumer are not created — they cost write performance and vacuum time for no benefit.

| Table | Index | Query It Serves | Type | Rationale |
|-------|-------|----------------|------|-----------|
| `products` | `ix_products_tenant_category` (`tenant_id, category, is_active`) | Catalog browsing filtered by category | B-tree | Most common read. RLS filters on `tenant_id`, then category narrows. `is_active` in index avoids heap visits for archived products. |
| `products` | `ix_products_tenant_slug` | Already covered by `uq_products_tenant_slug` | Unique B-tree | Product detail page lookup by slug. |
| `products` | `ix_products_tenant_price` (`tenant_id, base_price`) WHERE `is_active` | Price range filtering in catalog | Partial B-tree | Partial index excludes archived products, keeping the index small. |
| `products` | `ix_products_attributes` (`attributes`) | Attribute-based filtering ("show me red shirts") | GIN | GIN supports `@>` containment queries on JSONB. |
| `product_variants` | `ix_variants_product` (`product_id`) | Load variants when viewing a product | B-tree | Product detail page loads all variants. |
| `product_variants` | `ix_variants_attributes` (`attributes`) | Filter variants by attribute values | GIN | Same rationale as product attributes. |
| `customers` | `ix_customers_tenant_email` | Already covered by `uq_customers_tenant_email` | Unique B-tree | Login lookup. |
| `orders` | `ix_orders_customer` (`customer_id, placed_at DESC`) | Order history for a customer | B-tree | Sorted by recency. Customer pages always show newest first. |
| `orders` | `ix_orders_tenant_status` (`tenant_id, status, placed_at DESC`) | Admin order dashboard filtered by status | B-tree | Tenant admins filter by status ("show me pending orders"). |
| `orders` | `ix_orders_tenant_placed` (`tenant_id, placed_at`) | Sales reports by date range | B-tree | Analytics queries filter by tenant + date range. |
| `order_items` | `ix_order_items_order` (`order_id`) | Load line items for an order | B-tree | Order detail page. |
| `order_items` | `ix_order_items_variant` (`variant_id`) | Sales history for a product variant | B-tree | "How many of this SKU have we sold?" |
| `inventory` | `ix_inventory_variant` | Already covered by `uq_inventory_variant` | Unique B-tree | Inventory lookup by variant. |
| `inventory` | `ix_inventory_low_stock` (`tenant_id, quantity`) WHERE `quantity <= reorder_point` | Low-stock alerts | Partial B-tree | Only indexes rows that are below reorder point. Tiny index, fast scan. |
| `reviews` | `ix_reviews_product` (`product_id, created_at DESC`) | Load reviews for a product | B-tree | Product detail page, newest reviews first. |
| `reviews` | `ix_reviews_customer_product` | Already covered by `uq_reviews_customer_product` | Unique B-tree | Enforce one-review-per-customer-per-product. |

### Indexes NOT Created (and why)

| Candidate | Why Skipped |
|-----------|-------------|
| `ix_products_name` (full-text search) | Product search should use a dedicated search engine (Typesense, Meilisearch) or `pg_trgm` — not a basic B-tree on `name`. Deferred to v2. |
| `ix_orders_total` | No query pattern sorts or filters by order total. |
| `ix_order_items_tenant` | `tenant_id` on `order_items` is for RLS only. Queries always enter through `order_id`, which is already indexed. |
| BRIN on `orders.placed_at` | BRIN is great for append-only correlation with physical order. But `orders` will have updates (status changes), and the table is partitioned by `tenant_id` not time. B-tree is the safer choice. |

### Index Creation SQL

```sql
-- Products
CREATE INDEX ix_products_tenant_category
    ON products (tenant_id, category, is_active);

CREATE INDEX ix_products_tenant_price
    ON products (tenant_id, base_price)
    WHERE is_active = true;

CREATE INDEX ix_products_attributes
    ON products USING gin (attributes);

-- Product Variants
CREATE INDEX ix_variants_product
    ON product_variants (product_id);

CREATE INDEX ix_variants_attributes
    ON product_variants USING gin (attributes);

-- Orders
CREATE INDEX ix_orders_customer
    ON orders (customer_id, placed_at DESC);

CREATE INDEX ix_orders_tenant_status
    ON orders (tenant_id, status, placed_at DESC);

CREATE INDEX ix_orders_tenant_placed
    ON orders (tenant_id, placed_at);

-- Order Items
CREATE INDEX ix_order_items_order
    ON order_items (order_id);

CREATE INDEX ix_order_items_variant
    ON order_items (variant_id);

-- Inventory
CREATE INDEX ix_inventory_low_stock
    ON inventory (tenant_id, quantity)
    WHERE quantity <= reorder_point;

-- Reviews
CREATE INDEX ix_reviews_product
    ON reviews (product_id, created_at DESC);
```

---

## Phase 5: Common Queries + Optimization

### Query 1: Paginated Product Catalog

**Use case:** Customer browses a tenant's catalog, filtered by category, sorted by price.

**Naive version:**

```sql
SELECT p.*, array_agg(pv.name) AS variant_names
FROM products p
LEFT JOIN product_variants pv ON pv.product_id = p.id
WHERE p.tenant_id = 42
  AND p.category = 'electronics'
  AND p.is_active = true
GROUP BY p.id
ORDER BY p.base_price ASC
LIMIT 20 OFFSET 100;
```

**EXPLAIN problems:**
- `LEFT JOIN` + `array_agg` forces PostgreSQL to join ALL variants for ALL matching products, then group, then sort, then discard everything outside the LIMIT/OFFSET window. For a category with 5,000 products and 15,000 variants, this materializes ~15K rows before throwing away ~14,940 of them.
- `OFFSET 100` requires scanning and discarding 100 rows after sort — gets worse on deep pages.

**Optimized version:**

```sql
-- Step 1: Get product IDs with keyset pagination (no OFFSET)
WITH page AS (
    SELECT id, base_price, name
    FROM products
    WHERE tenant_id = 42
      AND category = 'electronics'
      AND is_active = true
      AND (base_price, id) > (29.99, 1042)  -- cursor from previous page
    ORDER BY base_price ASC, id ASC
    LIMIT 20
)
-- Step 2: Join variants only for the 20 products on this page
SELECT p.id, p.public_id, p.name, p.base_price, p.avg_rating, p.review_count,
       COALESCE(
           json_agg(json_build_object('name', pv.name, 'sku', pv.sku))
           FILTER (WHERE pv.id IS NOT NULL),
           '[]'
       ) AS variants
FROM page p
LEFT JOIN product_variants pv ON pv.product_id = p.id AND pv.is_active = true
GROUP BY p.id, p.public_id, p.name, p.base_price, p.avg_rating, p.review_count
ORDER BY p.base_price ASC, p.id ASC;
```

**Why it's better:**
- **Keyset pagination** replaces `OFFSET`. Uses `(base_price, id) > (cursor)` — constant-time regardless of page depth. The client sends the last seen `base_price` and `id` as the cursor.
- **CTE narrows first** — only 20 product IDs are selected before the variant join happens. The join touches ~60 variant rows instead of 15K.
- **Uses `ix_products_tenant_category`** — the index on `(tenant_id, category, is_active)` covers the WHERE clause, and `base_price` sort uses `ix_products_tenant_price`.

---

### Query 2: Customer Order History

**Use case:** Customer views their past orders with item summaries.

**Naive version:**

```sql
SELECT o.*, oi.*, pv.name AS variant_name, p.name AS product_name
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
JOIN product_variants pv ON pv.id = oi.variant_id
JOIN products p ON p.id = pv.product_id
WHERE o.customer_id = 7891
ORDER BY o.placed_at DESC;
```

**EXPLAIN problems:**
- Returns one row per order item, not one row per order. Application has to re-aggregate.
- Joins `product_variants` and `products` for every line item — but we snapshot variant data at purchase time in `variant_snapshot`. The live product data is stale for this use case anyway (product name may have changed since purchase).
- No LIMIT — returns entire order history. Customers with 500+ orders get a multi-second query.

**Optimized version:**

```sql
SELECT o.public_id,
       o.status,
       o.total,
       o.currency,
       o.placed_at,
       json_agg(
           json_build_object(
               'quantity', oi.quantity,
               'unit_price', oi.unit_price,
               'total_price', oi.total_price,
               'variant', oi.variant_snapshot
           ) ORDER BY oi.id
       ) AS items
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
WHERE o.customer_id = 7891
GROUP BY o.id, o.public_id, o.status, o.total, o.currency, o.placed_at
ORDER BY o.placed_at DESC
LIMIT 20;
```

**Why it's better:**
- **Uses `variant_snapshot`** instead of joining products/variants. The snapshot contains the product name, variant name, and price at time of purchase — which is the correct data for order history.
- **Aggregates items into JSON** — one row per order, items pre-grouped. No application-side re-grouping.
- **LIMIT 20** — paginated. Uses `ix_orders_customer(customer_id, placed_at DESC)` for an index-only scan on the outer query.
- Eliminated two joins entirely (products, product_variants), cutting I/O by ~60%.

---

### Query 3: Inventory Check with Availability

**Use case:** Product page checks stock for all variants of a product.

**Naive version:**

```sql
SELECT pv.id, pv.name, pv.sku, pv.attributes,
       i.quantity, i.reserved,
       CASE WHEN i.quantity - i.reserved > 0 THEN true ELSE false END AS in_stock
FROM product_variants pv
LEFT JOIN inventory i ON i.variant_id = pv.id
WHERE pv.product_id = 5432
  AND pv.tenant_id = 42;
```

**EXPLAIN analysis:** This query is already reasonably efficient. The `LEFT JOIN` on `inventory` uses `uq_inventory_variant` (unique index), and `pv.product_id` uses `ix_variants_product`. For a product with 10-20 variants, this scans 10-20 rows in each table.

**Optimized version (minor refinement):**

```sql
SELECT pv.public_id,
       pv.name,
       pv.sku,
       pv.attributes,
       COALESCE(pv.price_override, p.base_price) AS price,
       i.quantity - i.reserved AS available,
       (i.quantity - i.reserved) > 0 AS in_stock
FROM product_variants pv
JOIN products p ON p.id = pv.product_id
JOIN inventory i ON i.variant_id = pv.id
WHERE pv.product_id = 5432
  AND pv.tenant_id = 42
  AND pv.is_active = true;
```

**Why it's better:**
- Resolves price (base vs. override) in the query — avoids a second round-trip.
- Uses `INNER JOIN` on inventory (every active variant should have inventory; if it doesn't, that's a data bug we want to surface, not hide with `LEFT JOIN`).
- Filters inactive variants.
- Returns `available` as a computed integer — the UI can decide how to display it.

---

### Query 4: Monthly Sales Report by Category

**Use case:** Tenant admin wants revenue breakdown by product category for a given month.

**Naive version:**

```sql
SELECT p.category,
       COUNT(DISTINCT o.id) AS order_count,
       SUM(oi.total_price) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
JOIN product_variants pv ON pv.id = oi.variant_id
JOIN products p ON p.id = pv.product_id
WHERE o.tenant_id = 42
  AND o.placed_at >= '2026-04-01'
  AND o.placed_at < '2026-05-01'
  AND o.status NOT IN ('cancelled', 'refunded')
GROUP BY p.category
ORDER BY revenue DESC;
```

**EXPLAIN problems:**
- Four-table join across potentially large result sets. For a tenant with 2K orders/month and 6K line items, this is manageable — but the join through `product_variants` to `products` just to get `category` is expensive.
- `NOT IN` with a list forces PostgreSQL to check each value. Minor, but `!= ALL` or exclusion with a subquery can be worse.

**Optimized version:**

```sql
SELECT p.category,
       COUNT(DISTINCT o.id) AS order_count,
       SUM(oi.total_price) AS revenue,
       SUM(oi.quantity) AS units_sold
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
JOIN product_variants pv ON pv.id = oi.variant_id
JOIN products p ON p.id = pv.product_id
WHERE o.tenant_id = 42
  AND o.placed_at >= '2026-04-01'
  AND o.placed_at < '2026-05-01'
  AND o.status NOT IN ('cancelled', 'refunded')
GROUP BY p.category
ORDER BY revenue DESC;
```

**Honest assessment:** The naive query is already close to optimal for this use case. The real optimization here is not in the SQL — it's architectural:

```sql
-- Create a materialized view for the analytics dashboard
CREATE MATERIALIZED VIEW mv_daily_sales AS
SELECT o.tenant_id,
       DATE(o.placed_at) AS sale_date,
       p.category,
       COUNT(DISTINCT o.id) AS order_count,
       SUM(oi.quantity) AS units_sold,
       SUM(oi.total_price) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
JOIN product_variants pv ON pv.id = oi.variant_id
JOIN products p ON p.id = pv.product_id
WHERE o.status NOT IN ('cancelled', 'refunded')
GROUP BY o.tenant_id, DATE(o.placed_at), p.category;

CREATE UNIQUE INDEX ix_mv_daily_sales
    ON mv_daily_sales (tenant_id, sale_date, category);

-- Refresh nightly (or after batch order processing)
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_daily_sales;
```

Then the report query becomes:

```sql
SELECT category,
       SUM(order_count) AS order_count,
       SUM(units_sold) AS units_sold,
       SUM(revenue) AS revenue
FROM mv_daily_sales
WHERE tenant_id = 42
  AND sale_date >= '2026-04-01'
  AND sale_date < '2026-05-01'
GROUP BY category
ORDER BY revenue DESC;
```

**Why it's better:** Pre-aggregated by day. The monthly rollup scans ~30 rows per category instead of joining 6K+ order items. Refresh is concurrent (no read locks). Acceptable staleness for a dashboard.

---

### Query 5: Review Aggregation with Recent Reviews

**Use case:** Product detail page shows the rating distribution plus the 5 most recent reviews.

**Naive version:**

```sql
-- Two separate queries, or worse, one query that does both:
SELECT r.*, c.name AS customer_name,
       (SELECT AVG(rating) FROM reviews WHERE product_id = 9876) AS avg_rating,
       (SELECT COUNT(*) FROM reviews WHERE product_id = 9876) AS total_reviews
FROM reviews r
JOIN customers c ON c.id = r.customer_id
WHERE r.product_id = 9876
ORDER BY r.created_at DESC;
```

**EXPLAIN problems:**
- Correlated subqueries execute for every row (though PostgreSQL may optimize these to a single scan — it depends on the planner).
- Returns ALL reviews when the page only shows 5. For a product with 500 reviews, this is 495 wasted rows.
- The `avg_rating` and `review_count` are already cached on the `products` table (our trigger maintains them), so computing them here is redundant work.

**Optimized version:**

```sql
-- Rating stats come from the cached columns (zero cost)
SELECT p.avg_rating, p.review_count
FROM products p
WHERE p.id = 9876;

-- Recent reviews: separate query, LIMIT 5
SELECT r.public_id,
       r.rating,
       r.title,
       r.body,
       r.is_verified,
       r.created_at,
       c.name AS customer_name
FROM reviews r
JOIN customers c ON c.id = r.customer_id
WHERE r.product_id = 9876
ORDER BY r.created_at DESC
LIMIT 5;

-- Rating distribution (if showing a histogram)
SELECT rating, COUNT(*) AS count
FROM reviews
WHERE product_id = 9876
GROUP BY rating
ORDER BY rating DESC;
```

**Why it's better:**
- **Cached aggregates** — `avg_rating` and `review_count` are maintained by the trigger; no scan of the reviews table.
- **Three small queries** instead of one bloated query. Each is index-friendly: `ix_reviews_product(product_id, created_at DESC)` powers both the recent reviews and the distribution.
- The distribution query scans at most 5 groups (ratings 1-5), so even for a product with thousands of reviews, the `GROUP BY` is cheap after the index narrows to the product.
- Alternatively, these can be combined with a CTE if round-trip latency matters more than query simplicity.

---

## Phase 6: Migration Plan

### Migration Order

Foreign key dependencies dictate the creation order. The dependency graph is a DAG:

```
tenants (no deps)
  └── customers (depends on tenants)
  └── products (depends on tenants)
       └── product_variants (depends on products, tenants)
            └── inventory (depends on product_variants, tenants)
            └── order_items (depends on product_variants, orders)
       └── reviews (depends on products, customers, tenants)
  └── orders (depends on customers, tenants)
       └── order_items (depends on orders, product_variants, tenants)
```

### Migration Files

Using a numbered migration approach (framework-agnostic):

```
001_create_extensions.sql          -- uuid-ossp, pgcrypto
002_create_utility_functions.sql   -- set_updated_at()
003_create_tenants.sql
004_create_customers.sql
005_create_products.sql
006_create_product_variants.sql
007_create_inventory.sql
008_create_order_status_enum.sql
009_create_orders.sql
010_create_order_items.sql
011_create_reviews.sql
012_create_review_trigger.sql      -- update_product_review_stats()
013_create_indexes.sql             -- all non-unique indexes
014_setup_rls.sql                  -- roles, policies, grants
015_create_materialized_views.sql  -- mv_daily_sales
```

### Each Migration File Pattern

```sql
-- 003_create_tenants.sql
BEGIN;

CREATE TABLE IF NOT EXISTS tenants (
    -- ... (full DDL from Phase 3)
);

CREATE TRIGGER trg_tenants_updated_at
    BEFORE UPDATE ON tenants
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMIT;
```

Every migration is wrapped in a transaction. `CREATE TABLE IF NOT EXISTS` makes migrations idempotent for re-runs. Triggers and indexes use `IF NOT EXISTS` or equivalent guards.

### RLS Deployment Checklist

RLS must be deployed carefully — a mistake can expose all tenant data or lock out the application entirely.

1. **Deploy without enabling** — Create policies first, test them, then enable RLS.

```sql
-- Step 1: Create policies (RLS not yet enabled, policies are dormant)
CREATE POLICY tenant_isolation ON products ...;
-- ... all policies

-- Step 2: Verify the application sets app.tenant_id correctly
-- Test in staging by manually running:
SET LOCAL app.tenant_id = '42';
SELECT * FROM products;  -- should return all products (RLS not enabled yet)

-- Step 3: Enable RLS (now policies take effect)
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Step 4: Verify isolation
SET LOCAL app.tenant_id = '42';
SELECT * FROM products;  -- should return only tenant 42's products
SET LOCAL app.tenant_id = '99';
SELECT * FROM products;  -- should return only tenant 99's products
```

2. **Superuser bypass** — The database owner and superusers bypass RLS by default. The application must connect as `app_user`, not the superuser. Verify with:

```sql
-- This should be app_user, not postgres
SELECT current_user;
```

3. **Force RLS for table owner** (optional, defense-in-depth):

```sql
ALTER TABLE products FORCE ROW LEVEL SECURITY;
```

This makes RLS apply even to the table owner. Use this if you're paranoid (you should be).

### Seed Data Strategy

```sql
-- Seed a test tenant
INSERT INTO tenants (name, slug, plan) VALUES ('Demo Store', 'demo-store', 'pro');

-- Seed categories worth of products (use generate_series for volume testing)
INSERT INTO products (tenant_id, name, slug, category, base_price)
SELECT
    1,
    'Product ' || i,
    'product-' || i,
    (ARRAY['electronics', 'clothing', 'home', 'sports', 'books'])[1 + (i % 5)],
    ROUND((random() * 200 + 5)::numeric, 2)
FROM generate_series(1, 2000) AS i;

-- Seed variants for each product
INSERT INTO product_variants (tenant_id, product_id, sku, name, attributes)
SELECT
    p.tenant_id,
    p.id,
    p.slug || '-v' || v,
    'Variant ' || v,
    jsonb_build_object('option', 'value-' || v)
FROM products p
CROSS JOIN generate_series(1, 3) AS v
WHERE p.tenant_id = 1;

-- Seed inventory for every variant
INSERT INTO inventory (tenant_id, variant_id, quantity, reorder_point)
SELECT
    pv.tenant_id,
    pv.id,
    50 + (random() * 200)::int,
    10
FROM product_variants pv
WHERE pv.tenant_id = 1;
```

### Rollback Strategy

Each migration has a corresponding down file:

```sql
-- 003_create_tenants.down.sql
BEGIN;
DROP TABLE IF EXISTS tenants CASCADE;
COMMIT;
```

For production rollbacks, `CASCADE` is dangerous. Instead, check for dependents:

```sql
-- Safe rollback: verify no dependents exist
SELECT COUNT(*) FROM customers WHERE tenant_id IS NOT NULL;
-- If 0, safe to drop. If > 0, you need to drop dependents first (in reverse order).
```

The golden rule: **migrate forward, not backward.** If migration 005 has a bug, don't roll back to 004 — write migration 005a that fixes the issue. Rolling back in production with live data is how you lose data.

---

## Lessons Learned

1. **`tenant_id` everywhere is a feature, not a smell.** It feels like denormalization, and it is — but it's deliberate denormalization for security. RLS policies evaluate per-row, and adding a join to derive the tenant makes every query slower and every policy harder to audit. The storage cost of an extra `bigint` column is trivial compared to the cost of a cross-tenant data leak.

2. **Snapshot mutable data at transaction boundaries.** `order_items.variant_snapshot` captures the product name, variant attributes, and price at the time of purchase. Without this, changing a product name retroactively changes every historical order that referenced it — a violation of business reality and an accounting nightmare. Any time data crosses a "point of no return" boundary (order placed, invoice generated, contract signed), snapshot the referenced data.

3. **Cache aggregates with triggers, not application code.** The `avg_rating` / `review_count` pattern on `products` is a textbook example. Computing `AVG(rating)` on every product page view hits the reviews table 50K times per day. A trigger that updates two columns on insert/delete runs 2K times per day. The math is obvious. The risk (trigger bugs, stale data) is manageable with a periodic reconciliation job that recalculates from source.

4. **Keyset pagination is not optional at scale.** `OFFSET 500` means PostgreSQL scans and discards 500 rows. `OFFSET 50000` scans and discards 50,000 rows. Keyset pagination (`WHERE (sort_col, id) > (last_seen_sort, last_seen_id)`) is constant-time regardless of page depth. The cost is that you cannot jump to "page 47" — but users almost never do that, and your API shouldn't promise it.

5. **Materialized views are the honest answer to analytics on OLTP.** The temptation is to run complex aggregation queries against the live tables and hope indexes save you. They won't — not at 10M orders/year. A materialized view pre-computes the aggregation, refreshes on a schedule (nightly, hourly, whatever your staleness tolerance allows), and turns a 5-second dashboard query into a 50ms one. The trade-off is explicit and visible: the data is stale by at most N hours, and everyone knows it.
