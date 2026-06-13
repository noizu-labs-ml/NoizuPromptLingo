# React/Next.js Security Advisories

## Critical CVEs

---

### CVE-2025-66478 (December 2025) - CVSS 10.0

**Unauthenticated Remote Code Execution in React Server Components Protocol**

| Field | Detail |
|:------|:-------|
| **Severity** | CRITICAL (CVSS 10.0) |
| **Affected** | Next.js 15.x, 16.x using React Server Components (RSC) |
| **Fixed in** | React 19.0.1, 19.1.2, 19.2.1; Next.js patched releases |
| **Attack vector** | Network (unauthenticated) |
| **Impact** | Full remote code execution on the server |

**Description:**
A flaw in the RSC flight protocol allowed an attacker to craft a malicious serialized payload that, when deserialized on the server, executed arbitrary code. The vulnerability exploited insufficient input validation in the RSC wire format decoder, enabling an attacker to instantiate arbitrary server-side objects and invoke methods on them.

**Exploit Scenario:**
1. Attacker sends a crafted HTTP request with a malicious RSC payload to any endpoint that processes Server Component requests
2. The server deserializes the payload, instantiating attacker-controlled classes
3. Attained code execution with the privileges of the Node.js process

**Mitigation:**

```bash
# Immediate: upgrade to patched versions
npm update react react-dom next

# Verify versions
npx npm ls react next
# Ensure: react >= 19.0.1 (or 19.1.2, or 19.2.1 depending on your minor)
# Ensure: next >= latest patched release
```

**Detection:**

```bash
# Check if your deployment is vulnerable
npx next info
# Review server logs for unusual POST requests to RSC endpoints
# Look for: unusual content-type headers containing "text/x-component"
```

**Workaround (if immediate upgrade is not possible):**

```tsx
// middleware.ts - Block suspicious RSC requests at the edge
import { NextRequest, NextResponse } from 'next/server';

export function middleware(request: NextRequest) {
  const rscHeader = request.headers.get('RSC');
  const contentType = request.headers.get('Content-Type');

  // Only allow RSC requests from same-origin navigation
  if (rscHeader || contentType?.includes('x-component')) {
    const origin = request.headers.get('Origin');
    const host = request.headers.get('Host');

    if (origin && origin !== `${request.nextUrl.protocol}//${host}`) {
      return new NextResponse('Forbidden', { status: 403 });
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
};
```

---

### CVE-2025-55184 (December 2025) - HIGH Severity

**Denial of Service in RSC Protocol**

| Field | Detail |
|:------|:-------|
| **Severity** | HIGH (CVSS 7.5) |
| **Affected** | Next.js 15.x, 16.x with RSC enabled |
| **Fixed in** | Next.js patched releases (same as CVE-2025-66478) |
| **Attack vector** | Network (unauthenticated) |
| **Impact** | Server resource exhaustion, service unavailability |

**Description:**
An attacker could send specially crafted RSC payloads that triggered excessive memory allocation during deserialization. The RSC protocol decoder did not enforce limits on nested object depth or total payload complexity, allowing a relatively small request to consume disproportionate server resources.

**Exploit Scenario:**
1. Attacker sends a request with deeply nested or cyclic RSC payload structures
2. Server attempts to deserialize, consuming excessive memory and CPU
3. Legitimate requests fail due to resource exhaustion

**Mitigation:**
Upgrade to patched Next.js release. Apply the middleware workaround from CVE-2025-66478 to filter malicious requests at the edge.

---

### CVE-2025-55183 (December 2025) - MEDIUM Severity

**Source Code Exposure via RSC Protocol**

| Field | Detail |
|:------|:-------|
| **Severity** | MEDIUM (CVSS 5.3) |
| **Affected** | Next.js 15.x, 16.x with RSC in development mode or misconfigured production |
| **Fixed in** | Next.js patched releases |
| **Attack vector** | Network (unauthenticated) |
| **Impact** | Exposure of server-side source code, environment variables |

**Description:**
In certain configurations, error responses from RSC endpoints included stack traces and source code snippets that were intended only for development mode. A misconfiguration in the error boundary between development and production builds allowed this information to leak in production when specific error conditions were triggered.

**Mitigation:**
```js
// next.config.js - Ensure production mode suppresses error details
const nextConfig = {
  // Never expose error details in production
  productionBrowserSourceMaps: false,
};

// Verify your build is running in production mode
// next build automatically sets NODE_ENV=production
// Never run `next dev` in production
```

---

## Server Actions Security

### Input Validation

```tsx
// BAD: Server Action without validation
'use server';
export async function updateUser(formData: FormData) {
  const name = formData.get('name') as string;
  const email = formData.get('email') as string;
  // Directly using user input - SQL injection, XSS, etc.
  await db.user.update({ where: { id: userId }, data: { name, email } });
}

// GOOD: Server Action with Zod validation
import { z } from 'zod';

const updateUserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  userId: z.string().uuid(),
});

'use server';
export async function updateUser(formData: FormData) {
  const raw = {
    name: formData.get('name'),
    email: formData.get('email'),
    userId: formData.get('userId'),
  };

  const result = updateUserSchema.safeParse(raw);
  if (!result.success) {
    return { error: 'Invalid input', details: result.error.flatten() };
  }

  // userId should come from the session, not the form data
  const session = await getServerSession();
  if (!session?.user?.id) {
    return { error: 'Unauthorized' };
  }

  await db.user.update({
    where: { id: session.user.id }, // Use session ID, not form data
    data: { name: result.data.name, email: result.data.email },
  });

  return { success: true };
}
```

### CSRF Protection

Server Actions in Next.js have built-in CSRF protection via the `Origin` header check. However, additional layers are recommended:

```tsx
// middleware.ts - Additional CSRF protection
import { NextRequest, NextResponse } from 'next/server';

export function middleware(request: NextRequest) {
  // Server Actions use POST requests
  if (request.method === 'POST') {
    const origin = request.headers.get('Origin');
    const host = request.headers.get('Host');

    // Verify Origin matches Host
    if (!origin || !host) {
      return new NextResponse('Missing Origin or Host header', { status: 403 });
    }

    const allowedOrigins = [
      `https://${host}`,
      `http://localhost:${host.split(':')[1] || '3000'}`,
    ];

    if (!allowedOrigins.some((allowed) => origin.startsWith(allowed))) {
      return new NextResponse('Invalid Origin', { status: 403 });
    }
  }

  return NextResponse.next();
}
```

### Authorization Checks

```tsx
// Every Server Action must verify authorization
'use server';

export async function deleteProduct(productId: string) {
  // 1. Authenticate
  const session = await getServerSession();
  if (!session?.user) {
    throw new Error('Unauthorized');
  }

  // 2. Authorize
  const userRole = await getUserRole(session.user.id);
  if (userRole !== 'admin') {
    throw new Error('Forbidden');
  }

  // 3. Validate input
  if (!z.string().uuid().safeParse(productId).success) {
    throw new Error('Invalid product ID');
  }

  // 4. Execute
  await db.product.delete({ where: { id: productId } });

  // 5. Audit log
  await auditLog({
    action: 'delete_product',
    userId: session.user.id,
    resourceId: productId,
    timestamp: new Date(),
  });
}
```

---

## RSC Best Practices

### Never Trust Client-Sent Data

```tsx
// BAD: Server Component trusting client parameters
export default async function Dashboard({ searchParams }: PageProps) {
  const { userId } = await searchParams;
  // Attacker can set userId to any value
  const data = await db.user.findUnique({ where: { id: userId } });
  return <DashboardView data={data} />;
}

// GOOD: Derive identity from session, use params only for non-sensitive data
export default async function Dashboard({ searchParams }: PageProps) {
  const session = await getServerSession();
  if (!session?.user) redirect('/login');

  const { tab } = await searchParams; // Non-sensitive: which tab to show
  const data = await getUserDashboard(session.user.id, tab as string);
  return <DashboardView data={data} />;
}
```

### Validate All Inputs Server-Side

```tsx
// Every entry point to the server must validate inputs
// Server Actions, Route Handlers, Server Components with dynamic params

// Server Component
export default async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;

  // Validate the ID format
  if (!/^[a-f0-9-]{36}$/.test(id)) {
    notFound();
  }

  const product = await db.product.findUnique({ where: { id } });
  if (!product) notFound();

  return <ProductView product={product} />;
}
```

---

## Middleware Security

### Auth Patterns

```tsx
// middleware.ts - Route-level authentication
import { NextRequest, NextResponse } from 'next/server';
import { verifyToken } from './lib/auth';

const publicRoutes = ['/', '/login', '/register', '/products'];
const apiPublicRoutes = ['/api/auth/login', '/api/auth/register'];

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // Skip public routes
  if (publicRoutes.some((route) => pathname === route || pathname.startsWith('/products'))) {
    return NextResponse.next();
  }

  // Check for auth token
  const token = request.cookies.get('auth-token')?.value;

  if (!token) {
    // API routes return 401
    if (pathname.startsWith('/api/')) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    // Page routes redirect to login
    return NextResponse.redirect(new URL('/login', request.url));
  }

  // Verify token
  const payload = await verifyToken(token);
  if (!payload) {
    const response = pathname.startsWith('/api/')
      ? NextResponse.json({ error: 'Invalid token' }, { status: 401 })
      : NextResponse.redirect(new URL('/login', request.url));

    response.cookies.delete('auth-token');
    return response;
  }

  // Add user info to request headers for downstream use
  const requestHeaders = new Headers(request.headers);
  requestHeaders.set('x-user-id', payload.userId);
  requestHeaders.set('x-user-role', payload.role);

  return NextResponse.next({
    request: { headers: requestHeaders },
  });
}

export const config = {
  matcher: [
    '/((!?_next/static|_next/image|favicon.ico|robots.txt|sitemap.xml).*)',
  ],
};
```

### Injection Prevention

```tsx
// NEVER interpolate user input into headers, redirects, or database queries

// BAD: Header injection
const userInput = req.headers.get('x-custom');
response.headers.set('X-Custom', userInput); // Header injection!

// GOOD: Sanitize or validate
const allowedValues = ['option-a', 'option-b'];
const userInput = req.headers.get('x-custom');
if (userInput && allowedValues.includes(userInput)) {
  response.headers.set('X-Custom', userInput);
}

// BAD: Open redirect
const redirectUrl = request.nextUrl.searchParams.get('redirect');
return NextResponse.redirect(redirectUrl); // Open redirect!

// GOOD: Validate redirect URL
const redirectUrl = request.nextUrl.searchParams.get('redirect');
if (redirectUrl && redirectUrl.startsWith('/') && !redirectUrl.startsWith('//')) {
  return NextResponse.redirect(new URL(redirectUrl, request.url));
}
return NextResponse.redirect(new URL('/', request.url));
```

---

## General React Security

### XSS Prevention

```tsx
// React automatically escapes JSX expressions - this is safe:
const userInput = '<script>alert("xss")</script>';
return <div>{userInput}</div>; // Rendered as text, not HTML

// DANGEROUS: dangerouslySetInnerHTML
const userInput = '<img src=x onerror=alert(1)>';
return <div dangerouslySetInnerHTML={{ __html: userInput }} />; // XSS!

// If you MUST use dangerouslySetInnerHTML (e.g., rich text from CMS):
import DOMPurify from 'dompurify';

function SafeHTML({ html }: { html: string }) {
  const clean = DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br', 'ul', 'ol', 'li'],
    ALLOWED_ATTR: ['href', 'target', 'rel'],
    ALLOW_DATA_ATTR: false,
  });
  return <div dangerouslySetInnerHTML={{ __html: clean }} />;
}
```

### dangerouslySetInnerHTML Guidelines

1. **Never** use with user-generated content without sanitization
2. **Only** use for trusted CMS content or markdown output
3. **Always** sanitize with DOMPurify before rendering
4. **Configure** DOMPurify with the minimum necessary tag/attribute allowlist

```tsx
// Acceptable: server-sanitized CMS content
function RichTextBlock({ content }: { content: string }) {
  // Content came from CMS, sanitized server-side
  // Verify sanitization happened:
  if (content.includes('<script') || content.includes('onerror=')) {
    return null; // Reject suspicious content
  }
  return <div dangerouslySetInnerHTML={{ __html: content }} />;
}
```

### Supply Chain Security

```bash
# Regularly audit dependencies
npm audit

# Check for known vulnerabilities
npx better-npm-audit audit

# Pin exact versions in package.json (no ranges)
# "react": "19.2.1" not "react": "^19.2.1"

# Use lockfile integrity
npm ci # Uses exact lockfile, no updates

# Review new dependencies before adding
npx npm-consider install <package>
```
