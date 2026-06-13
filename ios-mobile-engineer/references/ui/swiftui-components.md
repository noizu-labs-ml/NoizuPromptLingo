# SwiftUI Components for Web Developers

A component-by-component mapping from HTML/React to SwiftUI. Every UI element in SwiftUI is a `View` struct — there are no CSS classes, no `className` props, no separate stylesheet. Styling happens through **view modifiers** chained onto the view.

---

## Mental Model Shift

| Web | SwiftUI |
|-----|---------|
| `<div>`, `<span>`, `<p>` | `Text`, `VStack`, `HStack` |
| CSS properties | View modifiers (`.font()`, `.foregroundColor()`) |
| `className="btn primary"` | `.buttonStyle(.borderedProminent)` |
| React component props | Swift struct init parameters |
| `children` / `props.children` | `@ViewBuilder` closures |

---

## Text

**Web:**
```html
<p style="font-size: 24px; font-weight: bold; color: #333;">Hello</p>
```

**React:**
```jsx
<Text style={{ fontSize: 24, fontWeight: 'bold', color: '#333' }}>Hello</Text>
```

**SwiftUI:**
```swift
Text("Hello")
    .font(.title)           // system semantic size
    .fontWeight(.bold)
    .foregroundStyle(.primary)

// Custom font size (avoid when possible — prefer semantic sizes)
Text("Custom")
    .font(.system(size: 24, weight: .bold, design: .rounded))

// Markdown support built in
Text("This is **bold** and *italic*")

// Attributed strings
Text(verbatim: "Price: ") + Text("$9.99").bold().foregroundStyle(.green)
```

Semantic font sizes (`.largeTitle`, `.title`, `.headline`, `.body`, `.caption`) adapt to Dynamic Type automatically. Hardcoded sizes do not.

---

## Image

**Web:**
```html
<img src="/photo.jpg" alt="A photo" style="width: 200px; border-radius: 10px;" />
```

**SwiftUI:**
```swift
// Asset catalog image
Image("photo")
    .resizable()
    .aspectRatio(contentMode: .fill)
    .frame(width: 200, height: 200)
    .clipShape(RoundedRectangle(cornerRadius: 10))

// SF Symbols (icon library — no npm install needed)
Image(systemName: "heart.fill")
    .font(.title)
    .foregroundStyle(.red)

// Async remote image (like <img src="https://...">)
AsyncImage(url: URL(string: "https://example.com/photo.jpg")) { image in
    image.resizable().aspectRatio(contentMode: .fit)
} placeholder: {
    ProgressView()
}
.frame(width: 200, height: 200)
```

Key difference: images are **not resizable by default**. You must call `.resizable()` before applying `.frame()`.

---

## Button

**Web:**
```html
<button onclick="handleTap()" class="btn-primary">Save</button>
```

**React:**
```jsx
<button onClick={handleSave} className="btn-primary">Save</button>
```

**SwiftUI:**
```swift
// Basic
Button("Save") {
    handleSave()
}

// With icon
Button("Save", systemImage: "square.and.arrow.down") {
    handleSave()
}

// Custom content
Button(action: handleSave) {
    HStack {
        Image(systemName: "square.and.arrow.down")
        Text("Save")
    }
    .padding()
    .background(.blue)
    .foregroundStyle(.white)
    .clipShape(RoundedRectangle(cornerRadius: 8))
}

// Built-in styles (no custom CSS needed)
Button("Prominent") { }
    .buttonStyle(.borderedProminent)

Button("Bordered") { }
    .buttonStyle(.bordered)

Button("Delete", role: .destructive) { }  // auto-styled red
```

---

## TextField

**Web:**
```html
<input type="text" placeholder="Email" value={email} onChange={e => setEmail(e.target.value)} />
```

**SwiftUI:**
```swift
@State private var email = ""

TextField("Email", text: $email)          // $email is a two-way binding
    .textFieldStyle(.roundedBorder)
    .keyboardType(.emailAddress)
    .textContentType(.emailAddress)        // autofill hint
    .autocorrectionDisabled()
    .textInputAutocapitalization(.never)

// Secure field (password input)
SecureField("Password", text: $password)
    .textFieldStyle(.roundedBorder)
    .textContentType(.password)

// Multi-line (like <textarea>)
TextEditor(text: $bio)
    .frame(height: 120)
    .border(Color.gray.opacity(0.3))
```

The `$` prefix creates a `Binding` — SwiftUI's equivalent of controlled components. The state and the UI stay in sync automatically.

---

## Toggle

**Web:**
```html
<input type="checkbox" checked={isDark} onChange={e => setIsDark(e.target.checked)} />
```

**SwiftUI:**
```swift
@State private var isDark = false

Toggle("Dark Mode", isOn: $isDark)

// Custom label
Toggle(isOn: $isDark) {
    Label("Dark Mode", systemImage: "moon.fill")
}

// Styled
Toggle("Notifications", isOn: $notify)
    .toggleStyle(.switch)     // default on iOS
    .tint(.purple)            // switch color
```

---

## Picker

**Web:**
```html
<select value={color} onChange={e => setColor(e.target.value)}>
    <option value="red">Red</option>
    <option value="blue">Blue</option>
</select>
```

**SwiftUI:**
```swift
@State private var color = "red"

Picker("Color", selection: $color) {
    Text("Red").tag("red")
    Text("Blue").tag("blue")
    Text("Green").tag("green")
}
.pickerStyle(.menu)              // dropdown (default on iOS)

// Segmented control (like radio buttons)
Picker("Color", selection: $color) {
    Text("Red").tag("red")
    Text("Blue").tag("blue")
}
.pickerStyle(.segmented)

// Full-screen wheel
Picker("Color", selection: $color) {
    Text("Red").tag("red")
    Text("Blue").tag("blue")
}
.pickerStyle(.wheel)
```

---

## List

**Web:**
```jsx
<ul>{items.map(item => <li key={item.id}>{item.name}</li>)}</ul>
```

**SwiftUI:**
```swift
// Basic list (renders like UITableView — performant for large data)
List(items) { item in
    Text(item.name)
}

// Sections (like grouped table view)
List {
    Section("Favorites") {
        ForEach(favorites) { item in
            Text(item.name)
        }
    }
    Section("All Items") {
        ForEach(allItems) { item in
            Text(item.name)
        }
    }
}

// Swipe actions
List(items) { item in
    Text(item.name)
        .swipeActions(edge: .trailing) {
            Button("Delete", role: .destructive) {
                delete(item)
            }
        }
}

// Pull to refresh
List(items) { item in
    Text(item.name)
}
.refreshable {
    await fetchItems()
}
```

`List` is not a styled `<ul>`. It is a native, recycling scroll view — closer to `react-window` or `FlatList` than a plain HTML list.

---

## Form

**Web:**
```html
<form onSubmit={handleSubmit}>
    <label>Name<input type="text" /></label>
    <label>Email<input type="email" /></label>
    <button type="submit">Save</button>
</form>
```

**SwiftUI:**
```swift
Form {
    Section("Profile") {
        TextField("Name", text: $name)
        TextField("Email", text: $email)
            .keyboardType(.emailAddress)
    }

    Section("Preferences") {
        Toggle("Notifications", isOn: $notificationsOn)
        Picker("Theme", selection: $theme) {
            Text("Light").tag("light")
            Text("Dark").tag("dark")
            Text("System").tag("system")
        }
    }

    Section {
        Button("Save") {
            handleSave()
        }
    }
}
```

`Form` gives you a grouped-inset table layout automatically. No CSS grid, no flexbox, no `<label>` wiring.

---

## Custom Components

**React pattern:**
```jsx
function Card({ title, children }) {
    return (
        <div className="card">
            <h3>{title}</h3>
            {children}
        </div>
    );
}
```

**SwiftUI equivalent:**
```swift
struct Card<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Usage
Card(title: "Settings") {
    Toggle("Dark Mode", isOn: $isDark)
    Toggle("Notifications", isOn: $notify)
}
```

`@ViewBuilder` is the SwiftUI equivalent of `children` — it lets callers pass multiple views in a closure.

---

## View Modifier Cheat Sheet

Common CSS-to-modifier translations:

| CSS | SwiftUI Modifier |
|-----|-----------------|
| `padding: 16px` | `.padding(16)` |
| `background: blue` | `.background(.blue)` |
| `border-radius: 8px` | `.clipShape(RoundedRectangle(cornerRadius: 8))` |
| `opacity: 0.5` | `.opacity(0.5)` |
| `box-shadow` | `.shadow(radius: 4)` |
| `border: 1px solid gray` | `.border(.gray, width: 1)` or `.overlay(RoundedRectangle(...).stroke(.gray))` |
| `display: none` | Conditional rendering with `if` |
| `max-width: 400px` | `.frame(maxWidth: 400)` |
| `width: 100%` | `.frame(maxWidth: .infinity)` |

**Modifier order matters.** Unlike CSS, where properties are unordered, SwiftUI applies modifiers sequentially:

```swift
// Background covers the padding
Text("Hello").padding().background(.blue)

// Background does NOT cover the padding
Text("Hello").background(.blue).padding()
```

This is the single most common source of confusion for web developers.
