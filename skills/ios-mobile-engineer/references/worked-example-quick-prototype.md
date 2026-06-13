# Worked Example: Weekend Prototype

Fast-path from idea to TestFlight in 48 hours — a recipe tracking app built with zero architecture, SwiftUI previews as the dev loop, and just enough polish to get useful feedback from real users.

> This example assumes you have an Apple Developer account ($99/year) and Xcode installed.

## Goal

Ship "QuickBite" — a recipe bookmarking app — to TestFlight in a weekend. Users save recipes with a photo, ingredients list, and cooking time. No backend, no sync, no architecture. Just a working thing on phones by Sunday night.

**Why this approach:** You have an idea and need to validate it with real users before investing weeks of engineering. The fastest feedback loop is a working app on someone's phone — not a Figma prototype, not a web mockup.

## Shortcuts Taken (Deliberately)

| Proper Way | Shortcut | Why It's Fine for Now |
|------------|----------|----------------------|
| MVVM with view models | Logic in views | < 10 views, no shared state to manage |
| SwiftData persistence | `@AppStorage` + JSON | Enough for 50-100 recipes |
| CloudKit sync | None | Single-device is fine for validation |
| Unit tests | None | Testing costs time; prototype tests user interest, not code correctness |
| Design system | SF Symbols + system styles | Apple's defaults look professional enough |
| Error handling | `try?` everywhere | Crash reports from TestFlight will surface real issues |
| Accessibility | Default VoiceOver labels | SwiftUI provides reasonable defaults for free |

**The rule:** every shortcut must be reversible without rewriting the whole app. JSON-encoded `@AppStorage` can migrate to SwiftData. Logic in views can extract to view models. These are refactors, not rewrites.

## Rapid UI: SwiftUI Previews as the Dev Loop

The entire development workflow runs through Xcode's preview canvas. No simulator launches, no build-wait-tap cycles.

### The Loop

1. Write a view
2. See it render instantly in the preview canvas (right panel in Xcode)
3. Tap into the interactive preview to test gestures, navigation, scrolling
4. Iterate on the code — preview updates in < 1 second

```swift
// This is the entire recipe list screen — view + data + preview
struct RecipeListView: View {
    @AppStorage("recipes") private var recipesData: Data = Data()
    @State private var showingAddRecipe = false
    
    private var recipes: [Recipe] {
        (try? JSONDecoder().decode([Recipe].self, from: recipesData)) ?? []
    }
    
    var body: some View {
        NavigationStack {
            List(recipes) { recipe in
                NavigationLink {
                    RecipeDetailView(recipe: recipe)
                } label: {
                    HStack {
                        Image(systemName: recipe.iconName)
                            .font(.title2)
                            .frame(width: 40)
                        VStack(alignment: .leading) {
                            Text(recipe.name).font(.headline)
                            Text("\(recipe.cookingMinutes) min")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .toolbar {
                Button("Add", systemImage: "plus") {
                    showingAddRecipe = true
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView(recipesData: $recipesData)
            }
        }
    }
}

#Preview {
    RecipeListView()
}

#Preview("Empty State") {
    // AppStorage is isolated per preview — starts empty automatically
    RecipeListView()
}
```

### Preview Tips That Save Hours

- **Multiple previews per file.** Add `#Preview("Dark Mode") { RecipeListView().preferredColorScheme(.dark) }` to catch contrast issues immediately.
- **Fixed data previews.** Pass mock data directly: `RecipeDetailView(recipe: .preview)` where `.preview` is a static property on your model.
- **Device variants.** `#Preview { RecipeListView().previewDevice("iPhone SE (3rd generation)") }` catches layout issues on small screens without switching simulators.
- **Interactive mode.** Click the play button on the preview canvas to enable tap, scroll, and navigation — no simulator needed.

## Key Trick: SF Symbols for Icons

SF Symbols is Apple's library of 5,000+ icons that ship with every iOS device. No downloads, no asset imports, no design skills needed.

```swift
// Instead of importing custom PNGs or SVGs:
Image(systemName: "fork.knife")           // Cooking
Image(systemName: "clock")                // Time
Image(systemName: "flame")                // Calories
Image(systemName: "heart.fill")           // Favorites
Image(systemName: "square.and.arrow.up")  // Share
Image(systemName: "magnifyingglass")      // Search
```

**Discovery workflow:** Open the SF Symbols app (free download from Apple) and search. Every symbol supports weight variants, color rendering modes, and accessibility labels out of the box. This replaces the "browse Heroicons for 20 minutes" step in web development.

**Pro tip for prototypes:** Let the user pick an icon for each recipe using `Label("Pasta", systemImage: "fork.knife")`. It looks polished and costs zero design time.

## TestFlight in 2 Hours

### Hour 1: Certificates and Provisioning (one-time setup)

This is the part web developers dread. It takes 45-60 minutes the first time and approximately zero minutes after that.

1. **Apple Developer account** — Sign in at [developer.apple.com](https://developer.apple.com) ($99/year, required for TestFlight)
2. **Xcode > Settings > Accounts** — Add your Apple ID. Xcode manages certificates automatically.
3. **Automatic Signing** — In Target > Signing & Capabilities, check "Automatically manage signing" and select your team. Xcode creates the provisioning profile.
4. **Register App ID** — Happens automatically when you first archive.

**That's it.** If Xcode says "No signing certificate" — go to Settings > Accounts > Manage Certificates > + Apple Distribution. If it says "No profiles" — toggle automatic signing off and back on.

### Hour 2: Archive and Upload

1. **Select "Any iOS Device (arm64)"** as the build destination (not a simulator)
2. **Product > Archive** — This builds a release binary. Takes 1-3 minutes.
3. **Window > Organizer** — Shows the archive. Click "Distribute App."
4. **Select "TestFlight & App Store"** > Next through the defaults > Upload.
5. **Wait 10-30 minutes** for Apple to process the build.
6. **App Store Connect** — Go to your app > TestFlight > add internal testers by email > enable the build.
7. Testers get a push notification in the TestFlight app. They tap Install.

### Minimum App Store Connect Metadata

Even for TestFlight, you need to fill in:
- App name
- Primary language
- Bundle ID (auto-populated from Xcode)
- SKU (any unique string, e.g., `quickbite-001`)

You do not need screenshots, descriptions, or review information for internal TestFlight. External TestFlight requires a brief description and contact info.

## The Data Model (Kept Simple)

```swift
struct Recipe: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var ingredients: [String]
    var instructions: String
    var cookingMinutes: Int
    var iconName: String  // SF Symbol name
    var isFavorite: Bool = false
    var createdAt: Date = .now
    
    static let preview = Recipe(
        name: "Spaghetti Carbonara",
        ingredients: ["Spaghetti", "Eggs", "Pecorino", "Guanciale", "Black pepper"],
        instructions: "Cook pasta. Fry guanciale. Mix eggs and cheese. Combine off heat.",
        cookingMinutes: 25,
        iconName: "fork.knife"
    )
}
```

No SwiftData, no Core Data, no database. The entire recipe collection serializes to JSON and lives in `@AppStorage` (which wraps `UserDefaults`). This caps out around a few hundred recipes before performance degrades — more than enough for a prototype.

## What to Clean Up Later

When the prototype validates and you decide to build for real, these are the refactors in priority order:

### Priority 1: Persistence (Week 1)
- Migrate from `@AppStorage` JSON to SwiftData
- Add `@Model` to Recipe, create a ModelContainer
- Existing data can be migrated on first launch with a one-time JSON-to-SwiftData import

### Priority 2: Architecture (Week 1-2)
- Extract view logic into `@Observable` view models
- Move save/delete/search operations out of views
- This is mechanical refactoring — extract method, move to new file, inject dependency

### Priority 3: Testing (Week 2)
- Add unit tests for view models using in-memory ModelContainer
- Add snapshot tests for key views
- Set up CI with `xcodebuild test` in GitHub Actions

### Priority 4: Sync (Week 3+)
- Enable CloudKit on the SwiftData ModelContainer
- Add conflict resolution UI if needed
- Consider whether users actually want sync (check TestFlight feedback first)

### Priority 5: Backend (If Needed)
- Only if you need features CloudKit cannot provide (sharing between users, server-side logic, web access)
- Supabase or Firebase are the fastest paths to a backend from a SwiftUI app

## When This Approach Is Appropriate

**Use the fast path when:**
- You are validating an idea and need user feedback within days
- The app is primarily UI with local data (recipes, notes, trackers, lists)
- You are the only developer and can hold the entire app in your head
- The feature set is small (< 10 screens, < 5 core actions)
- You have never shipped an iOS app and want to learn the TestFlight pipeline before investing in architecture

**Invest upfront when:**
- Multiple developers will work on the codebase simultaneously
- The app has complex state (real-time collaboration, multi-step workflows, undo/redo)
- Backend integration is required from day one (auth, payments, social features)
- You are building for a client who expects production-quality code
- The data model has relationships (workouts > exercises > sets) — SwiftData handles this well, `@AppStorage` does not
- You already know the idea is validated and are building for scale

**The meta-lesson:** iOS development has high fixed costs (Xcode setup, signing, App Store Connect) and low marginal costs (SwiftUI makes screens fast once you know the patterns). The prototype approach front-loads those fixed costs into a weekend so subsequent iterations are cheap. The worst outcome is spending three weeks on architecture for an app nobody wants.
