# Swift Essentials for JS/TS Developers

A crash course in Swift for developers fluent in JavaScript or TypeScript. Focuses on what's different, what's similar, and what will trip you up.

---

## Variables and Constants

```swift
let name = "Alice"      // Immutable (like const)
var count = 0           // Mutable (like let)
```

| JS/TS | Swift | Notes |
|---|---|---|
| `const x = 5` | `let x = 5` | `let` means immutable in Swift (opposite of JS!) |
| `let x = 5` | `var x = 5` | `var` means mutable |
| `var x = 5` | N/A | No hoisting, no `var` weirdness |

Swift infers types like TypeScript, but you can be explicit:

```swift
let name: String = "Alice"
var count: Int = 0
let price: Double = 9.99
let active: Bool = true
```

---

## Type System: TS Generics vs Swift Generics

Both languages have powerful generics. The syntax is nearly identical.

### TypeScript

```typescript
function first<T>(array: T[]): T | undefined {
    return array[0];
}

interface Container<T> {
    value: T;
    transform<U>(fn: (val: T) => U): Container<U>;
}
```

### Swift

```swift
func first<T>(_ array: [T]) -> T? {
    return array.first
}

struct Container<T> {
    let value: T
    func transform<U>(_ fn: (T) -> U) -> Container<U> {
        Container<U>(value: fn(value))
    }
}
```

### Key Differences

| Feature | TypeScript | Swift |
|---|---|---|
| Constraint syntax | `<T extends Comparable>` | `<T: Comparable>` |
| Type erasure | Full erasure at runtime | Types are real at runtime |
| Union types | `string \| number` | No direct equivalent — use enums or protocols |
| Intersection types | `A & B` | Protocol composition: `A & B` (only for protocols) |
| Conditional types | `T extends U ? X : Y` | No equivalent — use overloads or protocol extensions |
| `any` | `any` (escape hatch) | `Any` exists but is heavily discouraged |

### Protocol Constraints (Swift's `extends`)

```swift
// TypeScript: <T extends Equatable>
// Swift:
func findIndex<T: Equatable>(of item: T, in array: [T]) -> Int? {
    array.firstIndex(of: item)
}

// Multiple constraints
func process<T: Codable & Hashable>(_ item: T) { ... }
```

---

## Optionals: Nullable Types Done Right

Swift's `Optional` is TypeScript's `T | null | undefined` — but enforced by the compiler, not just a type annotation.

```swift
var name: String = "Alice"   // MUST have a value. Cannot be nil.
var nickname: String? = nil  // Optional. Can be nil.
```

### Unwrapping Optionals

You cannot use an optional directly. You must unwrap it first. This is the #1 thing that annoys JS developers — and the #1 thing that prevents crashes.

```swift
let nickname: String? = fetchNickname()

// 1. Optional binding (like if-let) — MOST COMMON
if let nickname {
    print("Hi, \(nickname)")  // nickname is String here, not String?
}

// 2. Guard (early return pattern)
guard let nickname else {
    print("No nickname")
    return
}
print("Hi, \(nickname)")  // nickname is String for rest of scope

// 3. Nil coalescing (like ?? in JS/TS)
let displayName = nickname ?? "Anonymous"

// 4. Optional chaining (like ?. in JS/TS)
let uppercased = nickname?.uppercased()  // String? — still optional

// 5. Force unwrap (like TypeScript's ! postfix) — AVOID
let forced = nickname!  // Crashes if nil. Almost never use this.
```

### Comparison to TypeScript

| TypeScript | Swift | Notes |
|---|---|---|
| `x: string \| null` | `x: String?` | Optional type |
| `x ?? "default"` | `x ?? "default"` | Nil coalescing — identical |
| `x?.method()` | `x?.method()` | Optional chaining — identical |
| `x!` (non-null assertion) | `x!` (force unwrap) | Both crash/fail if wrong, but Swift crashes at runtime |
| `if (x !== null)` | `if let x` | Swift narrows the type automatically |
| `x as string` (type assertion) | `x as? String` or `x as! String` | `as?` returns optional, `as!` force casts |

---

## Functions

```swift
// Named parameters (external + internal names)
func greet(person name: String, from city: String) -> String {
    return "Hello \(name) from \(city)"
}
greet(person: "Alice", from: "NYC")

// Underscore to omit external name (like JS positional args)
func add(_ a: Int, _ b: Int) -> Int {
    a + b
}
add(3, 5)

// Default values
func connect(host: String, port: Int = 443) { ... }

// Returning tuples (no equivalent in JS without objects)
func dimensions() -> (width: Double, height: Double) {
    (1920, 1080)
}
let size = dimensions()
print(size.width)  // 1920
```

### Argument Labels

This is unique to Swift. Functions have two names for each parameter: an **external label** (at the call site) and an **internal name** (inside the function body).

```swift
func move(from source: String, to destination: String) { ... }
move(from: "/tmp", to: "/home")  // Reads like English
```

Web developers find this verbose at first. After a week, you'll miss it in every other language.

---

## Closures vs Arrow Functions

Swift closures are arrow functions with different syntax.

```swift
// TypeScript
const double = (x: number): number => x * 2
const nums = [1, 2, 3].map(x => x * 2)

// Swift
let double: (Int) -> Int = { x in x * 2 }
let nums = [1, 2, 3].map { x in x * 2 }

// Shorthand (like $0, $1 for params)
let nums = [1, 2, 3].map { $0 * 2 }
```

### Trailing Closure Syntax

When the last parameter of a function is a closure, you can write it outside the parentheses. This is used everywhere in SwiftUI.

```swift
// These are equivalent:
Button(action: { doSomething() }, label: { Text("Tap me") })

Button(action: { doSomething() }) {
    Text("Tap me")
}

// With only one closure parameter:
Button("Tap me") {
    doSomething()
}
```

### `@escaping` Closures

If a closure outlives the function call (stored for later, used in async), it must be marked `@escaping`. No JS equivalent — all JS callbacks are escaping by default.

```swift
func fetchData(completion: @escaping (Data) -> Void) {
    DispatchQueue.global().async {
        let data = downloadData()
        completion(data)  // Called later — escaping
    }
}
```

---

## Async/Await

Swift's async/await is nearly identical to JavaScript's.

### JavaScript

```javascript
async function fetchUser(id) {
    const response = await fetch(`/api/users/${id}`);
    const user = await response.json();
    return user;
}

try {
    const user = await fetchUser(123);
} catch (error) {
    console.error(error);
}
```

### Swift

```swift
func fetchUser(id: Int) async throws -> User {
    let (data, _) = try await URLSession.shared.data(
        from: URL(string: "https://api.example.com/users/\(id)")!
    )
    return try JSONDecoder().decode(User.self, from: data)
}

do {
    let user = try await fetchUser(id: 123)
} catch {
    print(error)
}
```

### Key Differences

| Feature | JavaScript | Swift |
|---|---|---|
| Error handling | `try/catch` (optional) | `try/catch` (enforced by compiler) |
| Throwing | `throw new Error()` | `throw SomeError.case` |
| Task creation | `Promise`, implicit | `Task { }` — explicit structured concurrency |
| Parallel | `Promise.all([...])` | `async let` or `TaskGroup` |
| Cancellation | `AbortController` | Built-in. Tasks check `Task.isCancelled`. |

### Parallel Execution

```swift
// Like Promise.all
async let profile = fetchProfile(id)
async let posts = fetchPosts(userId: id)
async let followers = fetchFollowers(userId: id)

let (p, ps, fs) = try await (profile, posts, followers)
```

---

## Enums with Associated Values

This is the single most powerful Swift feature with no JavaScript equivalent. TypeScript discriminated unions are the closest analogy, but Swift enums are far more capable.

### TypeScript Discriminated Union

```typescript
type Result =
    | { status: "success"; data: User }
    | { status: "error"; message: string }
    | { status: "loading" };

function handle(result: Result) {
    switch (result.status) {
        case "success": console.log(result.data); break;
        case "error": console.log(result.message); break;
        case "loading": console.log("..."); break;
    }
}
```

### Swift Enum

```swift
enum Result {
    case success(User)
    case error(String)
    case loading
}

func handle(_ result: Result) {
    switch result {
    case .success(let user):
        print(user)
    case .error(let message):
        print(message)
    case .loading:
        print("...")
    }
}
```

### Why Enums Matter

1. **Exhaustive switching.** The compiler forces you to handle every case. Add a new case and every `switch` in your codebase errors until updated. TypeScript can do this with `never`, but it's opt-in.

2. **Associated values.** Each case can carry different data. This replaces the pattern of `type: string` + optional fields.

3. **Methods on enums.** Enums can have computed properties and methods:

```swift
enum Direction {
    case north, south, east, west

    var opposite: Direction {
        switch self {
        case .north: .south
        case .south: .north
        case .east: .west
        case .west: .east
        }
    }
}
```

4. **Pattern matching.** `if case` and `guard case` let you match and extract:

```swift
if case .success(let user) = result {
    print(user.name)
}
```

### Real-World Enum Patterns

```swift
// Network state (replaces boolean flags)
enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case failed(Error)
}

// Route definition (replaces string-based routing)
enum Route: Hashable {
    case home
    case profile(userId: String)
    case settings
    case post(id: String, commentId: String?)
}

// API error classification
enum APIError: Error {
    case networkFailure(URLError)
    case decodingFailure(DecodingError)
    case unauthorized
    case notFound
    case serverError(statusCode: Int, body: String)
}
```

---

## Structs vs Classes

JavaScript only has classes (and plain objects). Swift has both structs and classes, and they behave differently.

| Feature | Struct (value type) | Class (reference type) |
|---|---|---|
| Assignment | Copies the value | Copies the reference (pointer) |
| Mutation | Must use `mutating` keyword | Mutate freely |
| Inheritance | No | Yes |
| Identity (`===`) | No | Yes |
| Default choice | Preferred in Swift | Use when you need identity or inheritance |

```swift
// Struct — copied on assignment
struct Point {
    var x: Double
    var y: Double
}
var a = Point(x: 1, y: 2)
var b = a       // b is a COPY
b.x = 99
print(a.x)     // Still 1

// Class — shared reference
class Counter {
    var count = 0
}
let a = Counter()
let b = a       // b points to SAME object
b.count = 99
print(a.count)  // 99
```

**Rule of thumb:** Use structs by default. Use classes when you need shared mutable state (which is what `@Observable` classes are for in SwiftUI).

---

## Protocols (Interfaces)

Swift protocols are TypeScript interfaces — but they can also provide default implementations.

```swift
// TypeScript interface
// interface Describable {
//     description: string;
//     summarize(): string;
// }

// Swift protocol
protocol Describable {
    var description: String { get }
    func summarize() -> String
}

// Default implementation via extension
extension Describable {
    func summarize() -> String {
        "Summary: \(description)"
    }
}

// Conformance (like `implements`)
struct Article: Describable {
    var description: String
    // summarize() comes free from the extension
}
```

---

## Error Handling

Swift uses typed, compiler-enforced error handling. No silent failures.

```swift
enum ValidationError: Error {
    case tooShort(minimum: Int)
    case invalidCharacters
    case alreadyTaken
}

func validate(username: String) throws -> String {
    guard username.count >= 3 else {
        throw ValidationError.tooShort(minimum: 3)
    }
    return username
}

// Must handle with do/try/catch
do {
    let name = try validate(username: "ab")
} catch ValidationError.tooShort(let min) {
    print("Must be at least \(min) characters")
} catch {
    print("Unknown error: \(error)")
}

// Or convert to optional
let name = try? validate(username: "ab")  // nil if throws
```

| JS/TS | Swift |
|---|---|
| `throw new Error("msg")` | `throw SomeError.case` |
| `try { } catch (e) { }` | `do { try x() } catch { }` |
| Errors are untyped | Errors conform to `Error` protocol |
| `catch` is optional | `try` is required by compiler |
| Errors are often ignored | Compiler won't let you ignore them |

---

## Collections

```swift
// Array (like JS array, but typed)
var names: [String] = ["Alice", "Bob"]
names.append("Charlie")
let first = names.first  // Optional<String> — safe

// Dictionary (like JS object / Map)
var ages: [String: Int] = ["Alice": 30, "Bob": 25]
let age = ages["Alice"]  // Optional<Int>

// Set (like JS Set)
var tags: Set<String> = ["swift", "ios"]
tags.insert("swiftui")
```

### Functional Methods

```swift
// Identical to JS
let doubled = [1, 2, 3].map { $0 * 2 }           // [2, 4, 6]
let evens = [1, 2, 3, 4].filter { $0 % 2 == 0 }  // [2, 4]
let sum = [1, 2, 3].reduce(0, +)                   // 6

// Chaining works the same way
let result = users
    .filter { $0.isActive }
    .map { $0.name }
    .sorted()
```

---

## String Interpolation

```swift
// JS:   `Hello ${name}, you are ${age} years old`
// Swift:
let message = "Hello \(name), you are \(age) years old"
```

Multiline strings use triple quotes:

```swift
let html = """
    <div>
        <h1>\(title)</h1>
    </div>
    """
```

---

## Quick Reference Card

| JS/TS | Swift |
|---|---|
| `console.log()` | `print()` |
| `===` (strict equality) | `==` (always strict) |
| `typeof x` | `type(of: x)` |
| `x instanceof Foo` | `x is Foo` |
| `x as Foo` | `x as? Foo` (safe) or `x as! Foo` (force) |
| `[...arr1, ...arr2]` | `arr1 + arr2` |
| `{ ...obj, key: val }` | No spread — copy struct and mutate |
| Template literals | `"text \(expr)"` |
| `null` / `undefined` | `nil` (one concept, not two) |
| `for (const x of arr)` | `for x in arr` |
| `arr.length` | `arr.count` |
| `str.length` | `str.count` |
| `arr.push(x)` | `arr.append(x)` |
| `arr.includes(x)` | `arr.contains(x)` |
| `Object.keys(obj)` | `dict.keys` |
| Ternary `a ? b : c` | `a ? b : c` (identical) |
| `import { x } from "y"` | `import ModuleName` (imports everything) |
