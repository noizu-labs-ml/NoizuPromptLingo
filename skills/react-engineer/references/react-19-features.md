# React 19.x Features Reference

> Comprehensive reference for React 19, 19.1, 19.2, React Compiler v1.0, and security advisories.
> Last updated: 2026-05-28

---

## Table of Contents

- [React 19.0 (December 2024)](#react-190-december-2024)
  - [Actions](#actions)
  - [use() Hook](#use-hook)
  - [React Server Components (RSC)](#react-server-components-rsc)
  - [ref as a Prop](#ref-as-a-prop)
  - [Document Metadata](#document-metadata)
  - [Stylesheet Support](#stylesheet-support)
  - [Async Scripts](#async-scripts)
  - [Suspense Improvements](#suspense-improvements)
  - [Custom Elements (Web Components)](#custom-elements-web-components)
  - [Other React 19 Changes](#other-react-19-changes)
- [React 19.1](#react-191)
- [React 19.2 (October 2025)](#react-192-october-2025)
  - [Activity Component](#activity-component)
  - [useEffectEvent()](#useeffectevent)
  - [React Performance Tracks](#react-performance-tracks)
  - [View Transitions Integration](#view-transitions-integration)
- [React Compiler v1.0 (October 2025)](#react-compiler-v10-october-2025)
- [React Foundation (February 2026)](#react-foundation-february-2026)
- [Security Advisories](#security-advisories)
- [Migration Guide](#migration-guide)

---

## React 19.0 (December 2024)

Released December 5, 2024. The first major release since React 18 (March 2022).

### Actions

Actions unify async mutations (form submissions, data mutations) with automatic pending state, error handling, and optimistic updates. An "Action" is any function passed to a form's `action` prop or invoked via `useActionState`.

#### `useActionState`

Replaces the Canary-era `useFormState` from `react-dom`. Wraps an async action function and returns the current state, an action dispatch function, and a pending flag.

```tsx
import { useActionState } from 'react';

async function createUser(prevState: FormState, formData: FormData): Promise<FormState> {
  const name = formData.get('name') as string;
  const email = formData.get('email') as string;

  // Validation
  if (!name || name.trim().length < 2) {
    return { ...prevState, error: 'Name must be at least 2 characters' };
  }

  try {
    const user = await api.createUser({ name, email });
    return { success: true, user, error: null };
  } catch (err) {
    return { ...prevState, error: (err as Error).message };
  }
}

function CreateUserForm() {
  const [state, submitAction, isPending] = useActionState(createUser, {
    success: false,
    user: null,
    error: null,
  });

  return (
    <form action={submitAction}>
      <input name="name" required />
      <input name="email" type="email" required />
      <button type="submit" disabled={isPending}>
        {isPending ? 'Creating...' : 'Create User'}
      </button>
      {state.error && <p className="error">{state.error}</p>}
      {state.success && <p className="success">User created: {state.user.name}</p>}
    </form>
  );
}
```

Key behaviors:
- `prevState` is `null` on the first call, then the return value of the previous call
- `isPending` is `true` from the moment the action starts until the state update is committed
- Works with both Progressive Enhancement (forms without JS) and client-only forms
- Error boundary integration: if the action throws, the nearest error boundary catches it

#### `useOptimistic`

Shows optimistic UI while an async operation is in flight. Automatically reverts to the real state when the operation completes or fails.

```tsx
import { useOptimistic, useState } from 'react';

interface Message {
  id: string;
  text: string;
  sending?: boolean;
}

function MessageThread({ messages: initialMessages }: { messages: Message[] }) {
  const [messages, setMessages] = useState(initialMessages);
  const [optimisticMessages, addOptimisticMessage] = useOptimistic(messages);

  async function handleSubmit(formData: FormData) {
    const text = formData.get('message') as string;
    const tempId = crypto.randomUUID();

    // Immediately show the optimistic message
    addOptimisticMessage({
      id: tempId,
      text,
      sending: true,
    });

    try {
      const savedMessage = await api.sendMessage({ text });
      setMessages((prev) => [...prev, savedMessage]);
    } catch {
      // Optimistic message is automatically removed on error
      // because setMessages was not called with it
      addOptimisticMessage(null); // triggers revert
    }
  }

  return (
    <>
      {optimisticMessages.map((msg) => (
        <div key={msg.id} className={msg.sending ? 'opacity-50' : ''}>
          {msg.text}
          {msg.sending && <span>Sending...</span>}
        </div>
      ))}
      <form action={handleSubmit}>
        <input name="message" />
        <button type="submit">Send</button>
      </form>
    </>
  );
}
```

Pattern: `addOptimisticMessage` appends to the current optimistic list. When the real `setMessages` fires, the optimistic state merges back to the real state.

#### `useFormStatus`

Gives a form's pending state to any descendant component without prop drilling. The component calling `useFormStatus` must be a descendant of the `<form>`.

```tsx
import { useFormStatus } from 'react-dom';

function SubmitButton() {
  const { pending, data, method, action } = useFormStatus();

  return (
    <button type="submit" disabled={pending}>
      {pending ? (
        <>
          <Spinner /> Saving...
        </>
      ) : (
        'Save Changes'
      )}
    </button>
  );
}

// Usage: SubmitButton reads form state without being passed any props
function EditProfileForm() {
  return (
    <form action={saveProfile}>
      <input name="username" />
      <input name="bio" />
      <SubmitButton /> {/* Knows if parent form is submitting */}
    </form>
  );
}
```

`useFormStatus` returns:
| Field | Type | Description |
|-------|------|-------------|
| `pending` | `boolean` | `true` if the parent form is actively submitting |
| `data` | `FormData \| null` | The FormData being submitted |
| `method` | `string` | Form method (`'get'` or `'post'`) |
| `action` | `string \| ((formData: FormData) => void) \| null` | The form's action handler |

---

### `use()` Hook

Reads a resource (Promise or Context) during render. Unlike hooks, `use()` can be called inside conditionals and loops because it integrates with Suspense.

#### Reading Promises

```tsx
import { use, Suspense } from 'react';

// The promise must be created outside the component (or cached)
// to avoid recreating it on every render.
let userPromise: Promise<User> | null = null;

function getUserPromise(id: string) {
  if (!userPromise) {
    userPromise = fetch(`/api/users/${id}`).then((r) => r.json());
  }
  return userPromise;
}

function UserProfile({ userId }: { userId: string }) {
  // Suspends until the promise resolves
  const user = use(getUserPromise(userId));
  return <h1>{user.name}</h1>;
}

function ProfilePage({ userId }: { userId: string }) {
  return (
    <Suspense fallback={<ProfileSkeleton />}>
      <UserProfile userId={userId} />
    </Suspense>
  );
}
```

#### Reading Context

```tsx
import { use, createContext } from 'react';

const ThemeContext = createContext<'light' | 'dark'>('light');

function ThemedButton() {
  // use() can read context just like useContext
  // but it can be called conditionally
  const theme = use(ThemeContext);
  return <button className={`btn-${theme}`}>Click me</button>;
}

function ConditionalThemedButton({ showTheme }: { showTheme: boolean }) {
  // This would be invalid with useContext, but works with use()
  if (showTheme) {
    const theme = use(ThemeContext);
    return <button className={`btn-${theme}`}>Themed</button>;
  }
  return <button>Default</button>;
}
```

Rules for `use()`:
- Must be called during render (like other hooks), but CAN be inside conditionals/loops
- When reading a Promise: the nearest `<Suspense>` boundary shows its fallback
- When a Promise rejects: the nearest `<ErrorBoundary>` catches the error
- Do NOT create Promises inside the component body during render -- cache them externally or use a data-fetching library that supports Suspense
- Reading Context with `use()` subscribes to context changes like `useContext`

---

### React Server Components (RSC)

Server Components run only on the server. They can directly access databases, file systems, and other server-only resources without sending that code to the client.

#### Directives

```tsx
// 'use client' — marks a component as client-only
// Must be at the top of the file (before any imports)
'use client';

import { useState } from 'react';

export function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(count + 1)}>{count}</button>;
}
```

```tsx
// 'use server' — marks a function as a Server Action
// Can be at the top of a file (all exports are server actions)
// or inline before an async function
'use server';

import { db } from '@/lib/db';

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string;
  const content = formData.get('content') as string;

  await db.post.create({
    data: { title, content, authorId: getCurrentUserId() },
  });

  revalidatePath('/posts');
}
```

#### Server Component Example

```tsx
// This file has NO directive — it's a Server Component by default
import { db } from '@/lib/db';
import { PostList } from './PostList';
import { CreatePostForm } from './CreatePostForm';

// This runs on the server. No serialized DB client sent to browser.
export default async function PostsPage() {
  const posts = await db.post.findMany({
    orderBy: { createdAt: 'desc' },
    take: 20,
  });

  return (
    <main>
      <h1>Recent Posts</h1>
      {/* Server Component renders the list */}
      <PostList posts={posts} />

      {/* Client Component handles the interactive form */}
      <CreatePostForm />
    </main>
  );
}
```

#### Server-Only Modules

```tsx
// server-only package prevents accidental client import
// npm install server-only
import 'server-only';

export async function getSecretConfig() {
  // This file CANNOT be imported in client components
  // It throws at build time if imported on the client
  return {
    apiKey: process.env.SECRET_API_KEY,
    dbUrl: process.env.DATABASE_URL,
  };
}
```

#### Client/Server Boundary Rules

| Rule | Server Component | Client Component |
|------|-----------------|-----------------|
| `useState`, `useEffect`, event handlers | No | Yes |
| Direct database/filesystem access | Yes | No |
| `async`/`await` in component body | Yes | No |
| Can import from `npm` packages | Yes | Yes |
| Can render Client Components | Yes | Yes |
| Can render Server Components | Only as children via `props` | No |
| Serialized across network | No (runs on server) | Yes (JS sent to client) |

---

### ref as a Prop

React 19 eliminates the need for `forwardRef`. You can now pass `ref` as a regular prop.

#### Before (React 18 and earlier)

```tsx
import { forwardRef } from 'react';

const FancyInput = forwardRef<HTMLInputElement, FancyInputProps>(
  function FancyInput({ label, ...props }, ref) {
    return (
      <div>
        <label>{label}</label>
        <input ref={ref} {...props} />
      </div>
    );
  }
);
```

#### After (React 19)

```tsx
function FancyInput({ label, ref, ...props }: FancyInputProps & { ref?: React.Ref<HTMLInputElement> }) {
  return (
    <div>
      <label>{label}</label>
      <input ref={ref} {...props} />
    </div>
  );
}

// Usage is the same
function Form() {
  const inputRef = useRef<HTMLInputElement>(null);
  return <FancyInput ref={inputRef} label="Name" />;
}
```

`forwardRef` still works for backwards compatibility but is deprecated for new code. Codemod available: `npx react-codemod@latest replace-forward-ref`.

Cleanup callbacks for refs are also now supported:

```tsx
function TextInput() {
  const ref = useCallback((node: HTMLInputElement | null) => {
    // Setup
    if (node) {
      node.focus();
    }

    // Cleanup — returned function runs when component unmounts or ref changes
    return () => {
      console.log('Input ref cleaned up');
    };
  }, []);

  return <input ref={ref} />;
}
```

---

### Document Metadata

React 19 natively renders `<title>`, `<meta>`, and `<link>` tags from any component. No more `react-helmet` or `next/head` for basic metadata. When components deep in the tree render these tags, React hoists them to `<head>` automatically.

```tsx
function BlogPost({ post }: { post: Post }) {
  return (
    <article>
      <title>{post.title} | My Blog</title>
      <meta name="description" content={post.excerpt} />
      <meta property="og:title" content={post.title} />
      <meta property="og:image" content={post.coverImage} />
      <meta name="twitter:card" content="summary_large_image" />
      <link rel="canonical" href={`https://example.com/posts/${post.slug}`} />

      <h1>{post.title}</h1>
      <p>{post.content}</p>
    </article>
  );
}

// Last-rendered metadata wins (leaf components override parent metadata)
function App() {
  return (
    <div>
      {/* This title is overridden by BlogPost's title */}
      <title>My Blog</title>
      <BlogPost post={currentPost} />
    </div>
  );
}
```

Deduplication: if multiple components render `<title>`, the last one in tree order wins. Same for `<meta>` tags with the same `name` or `property`.

---

### Stylesheet Support

React 19 adds declarative stylesheet hoisting with precedence control, ensuring stylesheets load in the correct order and are deduplicated.

```tsx
function ComponentA() {
  return (
    <>
      {/* Precedence controls insertion order */}
      <link rel="stylesheet" href="reset.css" precedence="reset" />
      <link rel="stylesheet" href="typography.css" precedence="base" />
      <link rel="stylesheet" href="layout.css" precedence="layout" />
      <link rel="stylesheet" href="components.css" precedence="components" />

      {/* Same href + precedence is deduplicated automatically */}
      <div className="styled-component">Content</div>
    </>
  );
}

function ComponentB() {
  // This is deduplicated — same href as ComponentA's reset.css
  return (
    <>
      <link rel="stylesheet" href="reset.css" precedence="reset" />
      <div className="other-component">Other content</div>
    </>
  );
}
```

Precedence is a string. React sorts stylesheets by precedence string order and inserts them into `<head>` accordingly. Lower precedence strings are inserted first.

---

### Async Scripts

React 19 supports `<script async>` with automatic deduplication. Scripts are hoisted to `<head>` and deduplicated by `src`.

```tsx
function AnalyticsWidget() {
  return (
    <>
      {/* Rendered once even if this component mounts multiple times */}
      <script async src="https://analytics.example.com/widget.js" />

      {/* Inline async scripts also supported */}
      <script async>
        {`console.log('Analytics initialized');`}
      </script>

      <div className="analytics-widget">Widget content</div>
    </>
  );
}
```

Key behaviors:
- Scripts with the same `src` are deduplicated across the component tree
- Scripts are hoisted to `<head>` during SSR
- Supports `crossOrigin`, `integrity`, and other security attributes

---

### Suspense Improvements

React 19 improves `<Suspense>` for better streaming SSR and progressive loading.

```tsx
import { Suspense } from 'react';

function Dashboard() {
  return (
    <div>
      {/* Shell renders immediately */}
      <DashboardHeader />

      {/* Each section loads independently */}
      <Suspense fallback={<ChartSkeleton />}>
        <RevenueChart />
      </Suspense>

      <Suspense fallback={<TableSkeleton />}>
        <RecentOrders />
      </Suspense>

      <Suspense fallback={<ActivitySkeleton />}>
        <ActivityFeed />
      </Suspense>
    </div>
  );
}
```

Improvements in React 19:
- **Streaming SSR**: Suspense boundaries stream independently. The server sends HTML for resolved sections immediately and injects script tags to fill in suspended sections as they resolve.
- **Concurrent rendering**: Suspended components do not block sibling components from rendering.
- **Better error isolation**: An error in one Suspense boundary does not crash others.

---

### Custom Elements (Web Components)

React 19 adds full support for Custom Elements. React now passes unknown props as attributes (instead of ignoring them), making it work seamlessly with Web Components.

```tsx
// Before React 19: Custom Element props were silently ignored
// After React 19: Props flow through as attributes/properties

function MyComponent() {
  return (
    <>
      {/* All props pass through to the custom element */}
      <my-custom-element
        label="Hello"
        count={42}
        onMyEvent={(e: CustomEvent) => console.log(e.detail)}
      />

      {/* Works with lit-based components */}
      <sl-dialog label="Confirm" open>
        <p>Are you sure?</p>
        <sl-button slot="footer" variant="primary">Confirm</sl-button>
      </sl-dialog>
    </>
  );
}
```

Key changes:
- Unknown props are rendered as HTML attributes (not just properties)
- Custom Element SSR support
- Event handling works with custom events
- `class` and `for` are handled correctly for custom elements (no need for `className`/`htmlFor`)

---

### Other React 19 Changes

#### `useContext` Returns `undefined` Without Provider

```tsx
const ThemeCtx = createContext<string>('light');

// React 18: throws if no provider found (in some cases)
// React 19: returns the default value cleanly
function ThemedComponent() {
  const theme = useContext(ThemeCtx); // 'light' if no provider
}
```

#### Strict Mode Improvements

In development, React 19 double-invokes effects more aggressively to catch impure cleanup logic. No changes to production behavior.

#### Hydration Error Improvements

React 19 logs fewer and more actionable hydration mismatch warnings. Some previously-logged mismatches are now silently corrected.

#### Removed APIs

| Removed | Replacement |
|---------|-------------|
| `propTypes` | TypeScript |
| `defaultProps` on functions | Default parameter values |
| `forwardRef` | `ref` as prop |
| `react-dom/test-utils` (most) | `@testing-library/react` |
| `ReactDOM.render` | `ReactDOM.createRoot` |
| `ReactDOM.hydrate` | `ReactDOM.hydrateRoot` |

---

## React 19.1

Patch release focused on stability and security.

### Changes

- **RSC protocol hardening**: Additional validation for the React Server Components wire protocol, closing edge cases that could cause unexpected behavior.
- **Bug fixes**: Addressed edge cases in `useActionState` with concurrent renders, Suspense retries, and streaming SSR under high load.
- **Performance**: Reduced memory overhead of Server Component serialization for large payload trees.

This version is a drop-in upgrade from 19.0 with no API changes.

---

## React 19.2 (October 2025)

Feature release adding four major capabilities.

### Activity Component

`<Activity>` keeps off-screen UI alive (mounted but hidden) instead of destroying it. Similar to Vue's `<KeepAlive>`. Useful for preserving scroll position, form state, and component state when switching between tabs or views.

```tsx
import { Activity, useState } from 'react';

function TabbedInterface() {
  const [activeTab, setActiveTab] = useState<'editor' | 'preview' | 'settings'>('editor');

  return (
    <div>
      <nav>
        <button onClick={() => setActiveTab('editor')}>Editor</button>
        <button onClick={() => setActiveTab('preview')}>Preview</button>
        <button onClick={() => setActiveTab('settings')}>Settings</button>
      </nav>

      {/* Each tab's state is preserved when switching away */}
      <Activity mode={activeTab === 'editor' ? 'visible' : 'hidden'}>
        <RichTextEditor /> {/* Scroll position, undo history preserved */}
      </Activity>

      <Activity mode={activeTab === 'preview' ? 'visible' : 'hidden'}>
        <PreviewPane /> {/* Rendered output preserved */}
      </Activity>

      <Activity mode={activeTab === 'settings' ? 'visible' : 'hidden'}>
        <SettingsForm /> {/* Form inputs preserved */}
      </Activity>
    </div>
  );
}
```

Activity modes:

| Mode | Behavior |
|------|----------|
| `'visible'` | Normal rendering — component is mounted and visible |
| `'hidden'` | Component stays mounted but is hidden via `display: none` or `aria-hidden`. Effects continue running. State is fully preserved. |
| `'inactive'` | Component stays mounted but effects are paused. State is preserved but timers, subscriptions, and network requests are suspended. |

```tsx
// Fine-grained control with mode switching
function ChatApp() {
  const [selectedRoom, setSelectedRoom] = useState('general');

  return (
    <div className="chat-layout">
      <RoomList onSelect={setSelectedRoom} />

      {/* Previous conversations stay alive so user doesn't lose context */}
      <Activity mode={selectedRoom === 'general' ? 'visible' : 'hidden'}>
        <ChatRoom roomId="general" />
      </Activity>
      <Activity mode={selectedRoom === 'random' ? 'visible' : 'hidden'}>
        <ChatRoom roomId="random" />
      </Activity>
      <Activity mode={selectedRoom === 'support' ? 'visible' : 'hidden'}>
        <ChatRoom roomId="support" />
      </Activity>
    </div>
  );
}
```

Performance considerations:
- Hidden components still consume memory. Use sparingly for heavy components.
- `inactive` mode pauses effects, reducing CPU/battery usage for off-screen content.
- Max-activity limits can be set to automatically evict the oldest hidden activity.

---

### useEffectEvent()

Stable hook for reading the latest values of props/state inside effects without adding them to the effect's dependency array. This replaces the experimental `useEvent` hook.

**The problem it solves:**

```tsx
// BEFORE useEffectEvent — the stale closure problem
function ChatRoom({ roomId, onMessage }) {
  useEffect(() => {
    const connection = createConnection(roomId);
    connection.on('message', (msg) => {
      onMessage(msg); // Stale if onMessage changes but effect doesn't re-run
    });
    return () => connection.disconnect();
  }, [roomId]); // onMessage NOT in deps — stale closure risk
  // vs. adding onMessage to deps — causes reconnect on every render
}
```

**The solution:**

```tsx
import { useEffectEvent } from 'react';

function ChatRoom({ roomId, onMessage }: ChatRoomProps) {
  // useEffectEvent captures the latest value without triggering re-subscription
  const onLatestMessage = useEffectEvent((msg: Message) => {
    onMessage(msg);
  });

  useEffect(() => {
    const connection = createConnection(roomId);
    connection.on('message', (msg) => {
      onLatestMessage(msg); // Always calls the latest onMessage
    });
    return () => connection.disconnect();
  }, [roomId]); // Only reconnects when roomId changes
}
```

Rules:
- `useEffectEvent` returns a stable function reference that always reads the latest values
- The returned function can only be called inside `useEffect`, `useLayoutEffect`, or event handlers
- Do NOT pass the `useEffectEvent` function as a prop to child components (it is not part of the component's reactive API)
- It is NOT for creating stable callbacks for child components. Use the React Compiler's auto-memoization for that.

More examples:

```tsx
// Logging with latest state
function SearchResults({ query }) {
  const [results, setResults] = useState([]);
  const logResults = useEffectEvent(() => {
    analytics.track('search_results', { query, count: results.length });
  });

  useEffect(() => {
    const controller = new AbortController();
    fetch(`/api/search?q=${query}`, { signal: controller.signal })
      .then((r) => r.json())
      .then((data) => {
        setResults(data);
        logResults(); // Always logs with latest results
      });
    return () => controller.abort();
  }, [query]);
}
```

---

### React Performance Tracks

Built-in integration with Chrome DevTools Performance panel. React 19.2 automatically annotates the Performance timeline with React-specific tracks.

```tsx
// No code changes needed — automatic when React DevTools is installed
// In Chrome DevTools > Performance tab, you now see:
//
// [React Commits]    | ██ ██ ██ ██ ██        |
// [React Rendering]  | ██████  ████          |
// [React Effects]    |    ████    ██          |
// [React Layout]     | ██                     |
//
// Each bar is clickable and shows:
// - Which components rendered and why
// - Which props/state changed
// - Effect execution order and duration
// - State update source (user event, effect, timer, etc.)
```

Features:
- **Commit track**: Shows each React commit with affected components
- **Rendering track**: Breaks down render time per component
- **Effects track**: Shows when effects fire and their duration
- **Layout effects track**: Shows `useLayoutEffect` timing
- **State update origins**: Traces back to what triggered the update (click, effect, timeout, etc.)

No API changes required. Install React DevTools browser extension and the tracks appear in Chrome DevTools automatically.

---

### View Transitions Integration

React 19.2 integrates with the View Transitions API (`document.startViewTransition`) for smooth animated transitions between DOM states.

```tsx
import { useState, useViewTransition } from 'react';

function ImageGallery({ images }: { images: Image[] }) {
  const [selectedId, setSelectedId] = useState<string | null>(null);

  function handleSelect(id: string) {
    // Wraps the state update in a view transition
    document.startViewTransition(() => {
      setSelectedId(id);
    });
  }

  return (
    <div>
      {selectedId ? (
        <div className="full-view">
          {/* view-transition-name triggers the browser animation */}
          <img
            src={images.find((i) => i.id === selectedId)!.url}
            style={{ viewTransitionName: `photo-${selectedId}` }}
          />
          <button onClick={() => {
            document.startViewTransition(() => setSelectedId(null));
          }}>
            Close
          </button>
        </div>
      ) : (
        <div className="grid">
          {images.map((img) => (
            <img
              key={img.id}
              src={img.thumbnail}
              style={{ viewTransitionName: `photo-${img.id}` }}
              onClick={() => handleSelect(img.id)}
            />
          ))}
        </div>
      )}
    </div>
  );
}
```

CSS for the transition:

```css
/* Animate the image from grid position to full-view */
::view-transition-old(photo-*),
::view-transition-new(photo-*) {
  animation-duration: 0.3s;
}

/* Cross-fade for the rest of the page */
::view-transition-old(root),
::view-transition-new(root) {
  animation-duration: 0.2s;
}
```

Integration patterns:

```tsx
// Router integration (e.g., with React Router)
function App() {
  const navigate = useNavigate();

  function handleNavigation(to: string) {
    document.startViewTransition(async () => {
      await navigate(to);
    });
  }

  return <Nav onNavigate={handleNavigation} />;
}
```

Note: View Transitions API requires Chrome 111+, Safari 18+, or Firefox with flag. Graceful degradation: the state update still happens, just without animation.

---

## React Compiler v1.0 (October 2025)

The React Compiler (formerly React Forget) automatically memoizes component renders, eliminating the need for manual `useMemo`, `useCallback`, and `React.memo`.

### Setup

#### Babel Plugin

```bash
npm install babel-plugin-react-compiler
```

```js
// babel.config.js
module.exports = {
  presets: ['@babel/preset-react'],
  plugins: ['babel-plugin-react-compiler'],
};
```

#### Vite Plugin

```bash
npm install @react-compiler/vite-plugin
```

```ts
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import reactCompiler from '@react-compiler/vite-plugin';

export default defineConfig({
  plugins: [
    react(),
    reactCompiler(),
  ],
});
```

#### Next.js Integration

```js
// next.config.js
const nextConfig = {
  compiler: {
    reactCompiler: true, // Enable React Compiler
  },
  // Or with options:
  experimental: {
    reactCompiler: {
      target: '19',        // Target React version
      compilationMode: 'all', // 'all' | 'annotation' | 'opt-in'
    },
  },
};

module.exports = nextConfig;
```

### What the Compiler Does

**Before (manual memoization):**

```tsx
import { memo, useMemo, useCallback } from 'react';

const ExpensiveList = memo(function ExpensiveList({ items, filter, onSelect }) {
  const filtered = useMemo(
    () => items.filter((item) => item.category === filter),
    [items, filter]
  );

  const handleClick = useCallback(
    (id: string) => onSelect(id),
    [onSelect]
  );

  return (
    <ul>
      {filtered.map((item) => (
        <li key={item.id} onClick={() => handleClick(item.id)}>
          {item.name}
        </li>
      ))}
    </ul>
  );
});
```

**After (compiler handles it):**

```tsx
// No memo, useMemo, or useCallback needed
function ExpensiveList({ items, filter, onSelect }: ExpensiveListProps) {
  const filtered = items.filter((item) => item.category === filter);

  return (
    <ul>
      {filtered.map((item) => (
        <li key={item.id} onClick={() => onSelect(item.id)}>
          {item.name}
        </li>
      ))}
    </ul>
  );
}
```

The compiler automatically:
1. Memoizes the `filtered` array (recalculates only when `items` or `filter` change)
2. Memoizes the `onClick` handler (stable reference unless `onSelect` changes)
3. Memoizes the component render (skips re-render if props are unchanged)

### Opt-Out Patterns

#### `'use no memo'` Directive

```tsx
// Opt out an entire file from compilation
'use no memo';

function ThisComponentIsNotCompiled() {
  // Compiler skips this file entirely
  // You manage memoization manually
}
```

#### Per-component opt-out

```tsx
function CompiledComponent() {
  // Compiler optimizes this
}

// eslint-disable-next-line react-compiler/opt-out
function ManualComponent() {
  // Compiler skips this function
}
```

#### Config-level filtering

```js
// babel.config.js
module.exports = {
  plugins: [
    ['babel-plugin-react-compiler', {
      // Only compile files matching this pattern
      sources: (filename) => {
        return filename.includes('src/components/');
      },
    }],
  ],
};
```

### Known Limitations

The compiler cannot automatically memoize in these cases:

| Pattern | Why | Workaround |
|---------|-----|------------|
| **Closures over mutable values** | Compiler cannot track mutations to `let` variables captured in closures | Use `useRef` or state for mutable values |
| **Side effects in render** | `console.log`, DOM manipulation, etc. during render break assumptions | Move side effects to `useEffect` |
| **External store mutations** | Compiler cannot track changes to objects outside React's control | Use `useSyncExternalStore` |
| **Dynamic property access** | `obj[dynamicKey]` may prevent memoization | Use explicit property names |
| **Higher-order components** | HOCs that modify component behavior can confuse the compiler | Use composition instead |
| **Prototype chain mutations** | Modifying `Object.prototype` or class prototypes | Don't do this |
| **Mutable arguments** | Functions that mutate their arguments | Use immutable patterns |

```tsx
// BAD: Closure over mutable value — compiler cannot optimize
function Counter() {
  let count = 0; // Mutable variable

  const increment = () => {
    count++; // Compiler cannot track this mutation
  };

  return <button onClick={increment}>{count}</button>;
}

// GOOD: Use state — compiler can optimize
function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount((c) => c + 1)}>{count}</button>;
}
```

### Compiler Diagnostics

```tsx
// Enable compiler diagnostics to see what was/wasn't optimized
// babel.config.js
module.exports = {
  plugins: [
    ['babel-plugin-react-compiler', {
      logger: {
        logEvent(filename, event) {
          if (event.kind === 'CompileError') {
            console.warn(`[React Compiler] Could not optimize ${event.fnLoc}: ${event.detail}`);
          }
        },
      },
    }],
  ],
};
```

---

## React Foundation (February 2026)

React was transferred to the Linux Foundation in February 2026 under a new governance structure.

Key points:
- **Neutral governance**: No single company controls React's roadmap. Meta remains a major contributor but decisions go through the foundation's technical steering committee.
- **Intellectual property**: All React trademarks, brand assets, and IP were transferred to the Linux Foundation.
- **Compatibility guarantee**: The foundation charter includes a commitment to backward compatibility and semantic versioning.
- **Community contributions**: Clear contribution guidelines and a public roadmap process.
- **No API changes**: This is an organizational change, not a technical one. React 19.x APIs are unaffected.

---

## Security Advisories

### CVE-2025-66478 (December 2025) — CRITICAL

| Field | Detail |
|-------|--------|
| **CVE** | CVE-2025-66478 |
| **CVSS** | 10.0 (Critical) |
| **Type** | Unauthenticated Remote Code Execution |
| **Component** | React Server Components (RSC) protocol |
| **Affected** | React 19.0.0, 19.1.0, 19.1.1 |
| **Fixed In** | 19.0.1, 19.1.2, 19.2.1 |
| **Description** | The RSC wire protocol had a deserialization vulnerability that allowed unauthenticated attackers to execute arbitrary code on the server by crafting a malicious RSC payload. |
| **Mitigation** | Update immediately. If unable to update, disable RSC endpoints or put a WAF rule in place to validate RSC request payloads. |

```bash
# Check your version
npm ls react

# Update immediately
npm install react@19.2.1 react-dom@19.2.1
```

### CVE-2025-55184 — DoS in RSC

| Field | Detail |
|-------|--------|
| **CVE** | CVE-2025-55184 |
| **Type** | Denial of Service |
| **Component** | RSC streaming deserialization |
| **Affected** | React 19.0.x, 19.1.x |
| **Fixed In** | 19.1.2, 19.2.0 |
| **Description** | Crafted RSC payloads could cause excessive memory allocation during streaming deserialization, leading to server crashes. |
| **Mitigation** | Update to 19.2.0+. Implement request body size limits on RSC endpoints. |

### CVE-2025-55183 — Source Code Exposure in RSC

| Field | Detail |
|-------|--------|
| **CVE** | CVE-2025-55183 |
| **Type** | Information Disclosure |
| **Component** | RSC error serialization |
| **Affected** | React 19.0.x, 19.1.x |
| **Fixed In** | 19.1.2, 19.2.0 |
| **Description** | Error objects thrown during RSC rendering could include source code snippets and file paths in the serialized response sent to the client. |
| **Mitigation** | Update to 19.2.0+. Ensure production error boundaries sanitize error messages. |

### Security Best Practices for RSC

```tsx
// 1. Sanitize errors in production error boundaries
class ProductionErrorBoundary extends React.Component<
  { children: React.ReactNode },
  { hasError: boolean }
> {
  state = { hasError: false };

  static getDerivedStateFromError() {
    return { hasError: true };
    // Do NOT include the error object in state in production
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    // Log full error server-side only
    serverLogger.error('React Error Boundary', { error, componentStack: info.componentStack });
    // Never send raw error details to the client
  }

  render() {
    if (this.state.hasError) {
      return <GenericErrorPage />;
    }
    return this.props.children;
  }
}

// 2. Validate Server Action inputs
'use server';
import { z } from 'zod';

const createPostSchema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().min(1).max(50000),
});

export async function createPost(formData: FormData) {
  const raw = {
    title: formData.get('title'),
    content: formData.get('content'),
  };

  // Always validate on the server
  const validated = createPostSchema.parse(raw);

  await db.post.create({ data: validated });
}

// 3. Rate-limit Server Actions
import { rateLimit } from '@/lib/rate-limit';

export async function contactForm(formData: FormData) {
  const allowed = await rateLimit.check('contact', { max: 5, window: '1m' });
  if (!allowed) {
    throw new Error('Rate limited');
  }
  // ... process form
}
```

---

## Migration Guide

### From React 18 to React 19

```bash
# 1. Update dependencies
npm install react@19 react-dom@19

# 2. Update typescript types
npm install -D @types/react@19 @types/react-dom@19

# 3. Run codemods
npx react-codemod@latest replace-forward-ref
npx react-codemod@latest replace-useformstate
npx react-codemod@latest remove-defaultprops
npx react-codemod@latest remove-proptypes
```

### Breaking Changes Checklist

- [ ] Replace `ReactDOM.render` with `ReactDOM.createRoot`
- [ ] Replace `ReactDOM.hydrate` with `ReactDOM.hydrateRoot`
- [ ] Remove `forwardRef` — use `ref` as a prop
- [ ] Replace `useFormState` (Canary) with `useActionState`
- [ ] Remove `defaultProps` on function components — use default parameters
- [ ] Remove `propTypes` — use TypeScript
- [ ] Update test utilities — replace `react-dom/test-utils` with `@testing-library/react`
- [ ] Audit string refs (removed) — replace with `useRef` or callback refs
- [ ] Update any legacy context API usage (removed)
- [ ] Install security patches (19.0.1+, 19.1.2+, or 19.2.1+)

### Feature Adoption Priority

| Priority | Feature | Effort | Impact |
|----------|---------|--------|--------|
| P0 | Security patches (CVE-2025-66478) | Low | Critical |
| P1 | `ref` as prop (remove `forwardRef`) | Low | Developer experience |
| P1 | Document metadata | Low | Removes library dependency |
| P2 | `useActionState` / Actions | Medium | Simplifies form handling |
| P2 | `useOptimistic` | Medium | Better UX for mutations |
| P2 | `use()` hook | Medium | Cleaner async data flow |
| P3 | React Compiler | Medium | Performance auto-tuning |
| P3 | `<Activity>` (19.2) | Medium | Tab/view state preservation |
| P3 | `useEffectEvent` (19.2) | Low | Fixes stale closure issues |
| P4 | View Transitions (19.2) | Medium | Animated transitions |
| P4 | RSC / Server Components | High | Architecture change |

---

## Quick Reference: New Hooks and APIs

| API | Version | Purpose |
|-----|---------|---------|
| `useActionState(action, initialState)` | 19.0 | Async form actions with state |
| `useOptimistic(state, updateFn)` | 19.0 | Optimistic UI during mutations |
| `useFormStatus()` | 19.0 | Form pending state for descendants |
| `use(resource)` | 19.0 | Read Promise/Context in render |
| `useEffectEvent(handler)` | 19.2 | Stable handler with latest values |
| `<Activity mode>` | 19.2 | Keep off-screen UI alive |
| View Transitions | 19.2 | Animated DOM state changes |
| Performance Tracks | 19.2 | Chrome DevTools integration |
| React Compiler | 19.2+ | Automatic memoization |
| `'use no memo'` | Compiler | Opt out of compilation |
| `'use client'` | 19.0 | Client component boundary |
| `'use server'` | 19.0 | Server action boundary |
