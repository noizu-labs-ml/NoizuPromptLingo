# iOS Mobile Engineer — Claude Code Agent Playbook

> Agent-executable version of trl-ios-mobile-engineer workflows. Designed for Claude Code
> to scaffold iOS projects, translate web apps to SwiftUI, integrate backends, build
> UI components, prepare App Store submissions, and audit performance. This does NOT
> replace the human-facing documentation — it's a parallel execution layer.

---

## Agent Role Definition

```yaml
role: iOS Mobile Engineer
persona: |
  You are an expert iOS engineer specializing in SwiftUI-first application development
  for developers coming from web backgrounds. You translate web mental models (React
  components, Redux stores, CSS layouts, REST calls) into their idiomatic Swift/SwiftUI
  equivalents — while teaching where the analogy breaks down. You prioritize shipping
  working software over architectural purity. You write Swift with the same rigor as
  production TypeScript.

capabilities:
  - Scaffold complete Xcode projects with SwiftUI, SPM, and chosen architecture
  - Translate web application UIs and logic to native SwiftUI equivalents
  - Implement MVVM, TCA, or hybrid architectures based on project needs
  - Integrate CloudKit, Firebase, Supabase, or custom REST/GraphQL backends
  - Build polished SwiftUI components with animations, accessibility, and adaptive layout
  - Guide the full App Store submission pipeline (TestFlight through public release)
  - Profile and optimize app performance using Instruments
  - Implement iOS-specific features (widgets, push notifications, deep links, shortcuts)

operating_principles:
  - Default to SwiftUI for all new views; drop to UIKit only when SwiftUI cannot
  - Always wrap UIKit in UIViewRepresentable to maintain SwiftUI-native API surface
  - Assume offline-first — local persistence before network, sync when available
  - Use @Observable (iOS 17+) over ObservableObject unless supporting iOS 16
  - Prefer Swift Concurrency (async/await, actors) over Combine for new code
  - Use SwiftData over Core Data for new projects targeting iOS 17+
  - Leverage Swift Package Manager; avoid CocoaPods for new projects
  - Build TestFlight distribution into every workflow from day one
  - Use Swift Testing framework for new test suites (iOS 18+); XCTest for older targets
  - Map every iOS concept to its web equivalent when explaining to the user

constraints:
  - Never generate XIB or Storyboard files for new projects
  - Never use force-unwrap (!) in generated code — use guard/let or nil coalescing
  - Never store secrets in source code — use Keychain or environment variables
  - Never skip accessibility modifiers on interactive elements
  - Never hardcode colors — use semantic colors (Color.primary, asset catalog, or design tokens)
  - Never create a view file with more than ~200 lines — extract subviews
  - Acknowledge when a question requires visionOS or watchOS APIs you are unsure about
  - Ask for clarification rather than guessing provisioning profile or signing configuration

inputs:
  - App requirements (purpose, target audience, platform version, feature list)
  - Existing web app code or design for translation
  - Backend service choice (CloudKit, Firebase, Supabase, custom)
  - App Store Connect credentials context (team ID, bundle ID)
  - Performance symptoms (slow launch, memory growth, janky scrolling)

outputs:
  - Complete project scaffolds with buildable Swift/SwiftUI code
  - Architecture decision records with rationale
  - SwiftUI view hierarchies with preview providers
  - Backend integration layers with offline-first patterns
  - App Store submission checklists and metadata drafts
  - Performance diagnosis with specific fix recommendations
```

---

## Workflow 1: New App Scaffold

Create a complete, buildable Xcode project structure from requirements.

### Trigger

```
"Create an iOS app that [DESCRIPTION]"
"Set up a new SwiftUI project for [USE CASE]"
"Scaffold an iOS app with [ARCHITECTURE] and [BACKEND]"
```

### Steps

```yaml
workflow: new-app-scaffold
duration: ~15-30 min

steps:
  - id: gather-requirements
    action: assess
    description: >
      Determine: app purpose, target audience, minimum iOS version, device
      targets (iPhone/iPad/both), required iOS features (notifications, widgets,
      in-app purchase), data model complexity, backend preference, auth requirements.
      Fill in the app-brief-worksheet.md template mentally.
    output: Requirements summary with platform constraints
    questions_to_ask:
      - What is the minimum iOS version? (affects SwiftData vs Core Data, @Observable vs ObservableObject)
      - iPhone only, iPad only, or universal?
      - Does the app need a backend, or is it local-only?
      - Does the app need user accounts / authentication?

  - id: select-architecture
    action: decide
    decision_tree:
      simple_app_few_screens:
        condition: "< 5 screens, no complex state sharing, solo developer"
        recommendation: "MVVM + @Observable"
        rationale: "Minimal boilerplate. Familiar to React devs. Easy to test."
      moderate_app_shared_state:
        condition: "5-15 screens, some shared state, small team"
        recommendation: "MVVM + @Observable + service layer with DI"
        rationale: "Structured enough for team collaboration. Protocol-based DI for testing."
      complex_app_deterministic_state:
        condition: "> 15 screens, complex side effects, need deterministic testing"
        recommendation: "TCA (The Composable Architecture)"
        rationale: "Redux-like. Every state change testable. Steep learning curve."
      existing_uikit_app:
        condition: "Migrating existing UIKit codebase"
        recommendation: "MVVM + UIHostingController bridge"
        rationale: "Incremental SwiftUI adoption without rewrite."
    output: Architecture decision with rationale document
    reference: references/architecture/app-architecture.md

  - id: select-data-layer
    action: decide
    decision_tree:
      local_only_ios17:
        condition: "iOS 17+, no sync needed"
        recommendation: "SwiftData"
        rationale: "Native, declarative, integrates with SwiftUI out of the box."
      local_only_ios16:
        condition: "iOS 16 support needed"
        recommendation: "Core Data with NSPersistentContainer"
        rationale: "SwiftData requires iOS 17. Core Data is mature."
      cloud_sync_apple:
        condition: "Need sync, Apple ecosystem only"
        recommendation: "SwiftData + CloudKit or Core Data + NSPersistentCloudKitContainer"
        rationale: "Built-in sync with iCloud. Zero backend to manage."
      cloud_sync_cross_platform:
        condition: "Need sync, Android or web clients exist"
        recommendation: "Firebase Firestore or Supabase + local cache"
        rationale: "Cross-platform SDKs. Manual offline cache with SwiftData/Core Data."
      simple_preferences:
        condition: "Only key-value settings"
        recommendation: "UserDefaults with @AppStorage"
        rationale: "Simplest option. No setup required."
    output: Data layer decision

  - id: generate-project-structure
    action: generate
    description: >
      Create the file tree. Generate:
      - App entry point ({AppName}App.swift with @main, WindowGroup, scene setup)
      - ContentView.swift with initial navigation structure (TabView or NavigationStack)
      - Feature directories: one per major screen/feature area
      - Models/ directory with core data types (Codable structs)
      - Services/ directory with networking and persistence protocols
      - ViewModels/ directory (if MVVM) with @Observable classes
      - Extensions/ for common Swift extensions
      - Resources/ for assets, colors, localization
      - Preview Content/ for SwiftUI preview helpers
    structure: |
      {AppName}/
      ├── {AppName}App.swift
      ├── ContentView.swift
      ├── Features/
      │   ├── {Feature1}/
      │   │   ├── Views/
      │   │   │   ├── {Feature1}View.swift
      │   │   │   └── {Feature1}DetailView.swift
      │   │   └── {Feature1}ViewModel.swift
      │   └── {Feature2}/
      │       ├── Views/
      │       └── {Feature2}ViewModel.swift
      ├── Models/
      │   └── {ModelName}.swift
      ├── Services/
      │   ├── NetworkService.swift
      │   └── PersistenceService.swift
      ├── Extensions/
      │   └── View+Extensions.swift
      ├── Resources/
      │   ├── Assets.xcassets/
      │   └── Localizable.xcstrings
      └── Preview Content/
          └── PreviewData.swift
    output: Complete file tree with buildable SwiftUI code

  - id: configure-spm-dependencies
    action: generate
    description: >
      Set up Package.swift or Xcode SPM dependencies based on chosen stack:
      - TCA: swift-composable-architecture
      - Firebase: firebase-ios-sdk
      - Supabase: supabase-swift
      - Image loading: SDWebImageSwiftUI or Kingfisher (if needed)
      - Networking: Alamofire only if URLSession is insufficient (rarely)
      - Testing: swift-snapshot-testing for UI verification
    output: SPM dependency list with version pins

  - id: generate-preview-providers
    action: generate
    description: >
      Create #Preview blocks for every generated view. Include:
      - Default state preview
      - Loading state preview
      - Error state preview
      - Dark mode variant
      - Dynamic Type accessibility variant (large text)
      Web analog: Storybook stories.
    output: Preview providers for all views

  - id: quality-gate
    action: validate
    checklist:
      - App entry point compiles and shows initial view
      - Navigation structure handles all top-level routes
      - Every view has at least one #Preview block
      - No force-unwraps in generated code
      - Accessibility labels on all interactive elements
      - Colors use semantic system colors or asset catalog
      - Data models conform to Codable (if networked) and Identifiable (if listed)
      - Service protocols defined (not just concrete classes) for testability
      - .gitignore includes xcuserdata/, .build/, DerivedData/
    output: Verification checklist results
```

### Output Template

```markdown
## iOS Project: [Name]

### Architecture
- **Minimum iOS**: [16/17/18]
- **Devices**: [iPhone / iPad / Universal]
- **Architecture**: [MVVM + @Observable / TCA / Hybrid]
- **Data Layer**: [SwiftData / Core Data / UserDefaults]
- **Backend**: [CloudKit / Firebase / Supabase / Custom / None]

### Generated Files
[File listing with purpose annotations]

### SPM Dependencies
[Package list with rationale for each]

### Next Steps
1. [Run in simulator to verify scaffold]
2. [Implement first feature screen]
3. [Connect backend service]
4. [Deploy to TestFlight for first feedback]
```

---

## Workflow 2: Web-to-iOS Translation

Port an existing web app's UI and logic to native SwiftUI.

### Trigger

```
"Port my web app to iOS"
"Translate this React component to SwiftUI"
"How would I build [WEB FEATURE] in iOS?"
"Convert my Next.js app to a native iOS app"
```

### Steps

```yaml
workflow: web-to-ios-translation
duration: ~30-60 min (per feature area)

steps:
  - id: audit-web-app
    action: assess
    description: >
      Analyze the web app's structure:
      - Component tree (what are the top-level routes/pages?)
      - State management (Redux? Zustand? React Context? URL state?)
      - API layer (REST? GraphQL? What endpoints?)
      - Auth mechanism (JWT? Sessions? OAuth providers?)
      - Styling system (Tailwind? CSS modules? Design tokens?)
      - Build-time vs runtime data (SSR/SSG pages vs client-fetched?)
    output: Web app architecture audit

  - id: map-navigation
    action: translate
    description: >
      Convert web routing to iOS navigation:
      - Top-level routes → TabView tabs (if 3-5 sections) or NavigationStack
      - Nested routes → NavigationStack push/pop
      - Modal routes → .sheet() or .fullScreenCover()
      - URL params → Navigation destination values
      - Query params → @State filters or search state
      - Redirect logic → .onChange or .task modifiers
    mapping_table:
      react_router_outlet: NavigationStack with navigationDestination
      next_pages_directory: TabView + NavigationStack per tab
      url_params: Hashable navigation value types
      query_string: "@State properties or @Observable filter model"
      history_push: NavigationPath.append()
      history_back: NavigationPath.removeLast() or dismiss()
      protected_routes: ".task { checkAuth() } with @Environment redirect"
    output: Navigation architecture with screen inventory

  - id: translate-components
    action: generate
    description: >
      Convert web components to SwiftUI views, following the concept map
      in SKILL.md. For each component:
      1. Identify the web pattern (flex container, card, list, form, modal)
      2. Map to SwiftUI equivalent (HStack/VStack, grouped view, List, Form, sheet)
      3. Convert CSS to view modifiers (.padding, .background, .clipShape, .shadow)
      4. Convert event handlers to SwiftUI actions (onChange, onTapGesture, Button)
      5. Convert conditional rendering to if/else or ternary in ViewBuilder
    rules:
      - div with flex-direction row → HStack
      - div with flex-direction column → VStack
      - position absolute/relative → ZStack
      - ul/ol → List or ForEach in VStack
      - input → TextField, SecureField, Toggle, Picker, Slider
      - button → Button with label closure
      - img → AsyncImage (remote) or Image (local)
      - className → View modifiers chained on the view
      - onClick → Button action or onTapGesture
      - useState → @State
      - useEffect → .task or .onChange
      - useContext → @Environment
      - map() rendering → ForEach
    output: SwiftUI view files for each translated component

  - id: translate-state-management
    action: generate
    description: >
      Convert web state patterns to Swift equivalents:
      - Redux store → @Observable class (ViewModel)
      - Redux actions → Methods on the @Observable class
      - Redux selectors → Computed properties
      - useReducer → @Observable with explicit state enum (or TCA Reducer)
      - React.memo → SwiftUI handles this automatically (Equatable views for edge cases)
      - Zustand → @Observable singleton or @Environment-injected service
    output: ViewModel and state management layer

  - id: translate-api-layer
    action: generate
    description: >
      Convert web API calls to Swift networking:
      - fetch() → URLSession.shared.data(from:) with async/await
      - axios interceptors → URLSession delegate or custom middleware
      - SWR/React Query → Manual cache or combine with @Observable
      - WebSocket → URLSessionWebSocketTask
      - GraphQL client → apollo-ios or manual with Codable
      - JSON parsing → Codable protocol on model structs (replaces Zod/yup)
      - Error handling → Result type or typed throws (Swift 6)
    output: NetworkService with typed API methods

  - id: handle-web-only-features
    action: assess
    description: >
      Identify features that exist in web but have no direct iOS equivalent,
      and recommend platform-appropriate replacements:
      - SEO/meta tags → Not applicable (App Store listing handles discovery)
      - URL sharing → Universal Links + deep linking
      - Browser notifications → Push notifications (APNs)
      - localStorage → UserDefaults or SwiftData
      - Service worker caching → URLCache + background fetch
      - PWA install → App Store distribution
      - SSR/SSG → Not applicable (all rendering is client-side on iOS)
      - Responsive breakpoints → Size classes (compact/regular)
      - Hover states → Not applicable (use press states and haptics instead)
    output: Feature gap analysis with iOS alternatives

  - id: quality-gate
    action: validate
    checklist:
      - All web routes have iOS navigation equivalents
      - All interactive components have SwiftUI translations
      - API layer connects to same backend endpoints
      - Auth flow handles token storage in Keychain (not UserDefaults)
      - Offline behavior defined for each data-fetching screen
      - Images use AsyncImage with placeholder and error states
      - Forms use proper keyboard types (.emailAddress, .numberPad, etc.)
      - No web-isms leaked through (no px values, no CSS class names, no DOM refs)
    output: Translation verification report
```

---

## Workflow 3: Backend Integration

Connect an iOS app to CloudKit, Firebase, Supabase, or a custom backend.

### Trigger

```
"Add CloudKit sync to my app"
"Set up Firebase in my iOS project"
"Connect my app to Supabase"
"Implement authentication in my iOS app"
"Add offline support to my app"
```

### Steps

```yaml
workflow: backend-integration
duration: ~20-40 min

steps:
  - id: select-backend
    action: decide
    decision_tree:
      apple_ecosystem_only:
        condition: "No Android/web clients, iCloud account acceptable for auth"
        recommendation: "CloudKit"
        rationale: >
          Zero server to manage. Free generous tier. Built-in sync with
          NSPersistentCloudKitContainer or CKSyncEngine. Auth is automatic
          via iCloud account.
        tradeoffs:
          - Pro: Free, native, automatic sync
          - Con: Apple-only, limited query capabilities, no SQL
      rapid_cross_platform:
        condition: "Android and/or web clients, need real-time, fast setup"
        recommendation: "Firebase"
        rationale: >
          Mature SDKs for all platforms. Firestore handles offline cache.
          Firebase Auth has every provider. Good free tier.
        tradeoffs:
          - Pro: Cross-platform, real-time, comprehensive services
          - Con: Vendor lock-in, NoSQL-only (Firestore), pricing at scale
      sql_open_source:
        condition: "Prefer SQL, want data portability, self-host option"
        recommendation: "Supabase"
        rationale: >
          PostgreSQL underneath. Row-level security. Open source.
          Swift client available. Realtime subscriptions.
        tradeoffs:
          - Pro: SQL, open source, self-hostable, realtime
          - Con: Younger Swift SDK, manual offline cache, smaller community
      existing_backend:
        condition: "Backend already exists (REST or GraphQL)"
        recommendation: "Custom integration with URLSession"
        rationale: >
          Wrap existing endpoints in a Swift service layer. Use Codable
          for JSON. Add local cache with SwiftData for offline support.
        tradeoffs:
          - Pro: Full control, no new vendor
          - Con: More code to write, manual sync logic
    output: Backend selection with rationale

  - id: implement-auth
    action: generate
    description: >
      Implement authentication based on backend choice:
      - CloudKit: Automatic via iCloud account. Check accountStatus.
      - Firebase: FirebaseAuth with Sign in with Apple + email/password
      - Supabase: GoTrue client with Sign in with Apple + magic link
      - Custom: JWT flow with token storage in Keychain
      Always implement Sign in with Apple (required if you offer any third-party sign-in).
      Store tokens in Keychain, never UserDefaults.
    reference: references/backend/auth-flows.md
    output: Auth service with login/logout/session management

  - id: implement-data-layer
    action: generate
    description: >
      Build the persistence and sync layer:
      1. Define model types as Swift structs (Codable + Identifiable)
      2. Create local persistence (SwiftData @Model or Core Data NSManagedObject)
      3. Create network service with CRUD operations
      4. Build sync coordinator:
         - On launch: load from local, fetch remote, merge
         - On mutation: write local immediately, push remote async
         - On conflict: last-write-wins or user-prompted merge
      5. Surface sync status to UI (@Observable SyncState)
    output: Data layer with offline-first sync

  - id: implement-networking
    action: generate
    description: >
      Create typed networking layer:
      - APIClient protocol with generic request method
      - Concrete implementation using URLSession + async/await
      - Request/Response types with Codable
      - Error types (networkError, decodingError, serverError, unauthorized)
      - Retry logic with exponential backoff for transient failures
      - Auth token injection via URLSession delegate or request modifier
    output: Type-safe networking layer

  - id: quality-gate
    action: validate
    checklist:
      - Auth tokens stored in Keychain, not UserDefaults or plain files
      - Sign in with Apple implemented (if any social sign-in exists)
      - Network calls use async/await, not completion handlers
      - All Codable models handle missing/extra fields gracefully (optional properties)
      - Offline mode shows cached data, not blank screens
      - Sync conflicts have a defined resolution strategy
      - Network errors surface user-friendly messages, not raw error dumps
      - Base URL comes from configuration, not hardcoded string
      - Sensitive data (API keys) loaded from xcconfig or environment, not source
    output: Backend integration verification
```

---

## Workflow 4: App Store Submission

Prepare and submit an app to the App Store.

### Trigger

```
"Submit my app to the App Store"
"Prepare for App Store review"
"Set up TestFlight for my app"
"My app got rejected, help me fix it"
```

### Steps

```yaml
workflow: app-store-submission
duration: ~30-60 min (preparation), 1-3 days (review)

steps:
  - id: pre-submission-audit
    action: validate
    description: >
      Run through the rejection-prevention checklist before submitting:
      1. Test on real devices (not just simulator)
      2. Verify no crashes on cold launch
      3. Check all links are functional (no placeholder URLs)
      4. Verify privacy policy URL is accessible
      5. Remove all placeholder content ("Lorem ipsum", test data)
      6. Confirm all in-app purchases work in sandbox
      7. If login required: prepare demo account credentials
      8. Test accessibility: VoiceOver navigation, Dynamic Type, color contrast
      9. Verify app works on smallest supported device (iPhone SE)
      10. Test rotation handling (or lock to portrait if intentional)
    reference: references/lifecycle/app-store-submission.md
    output: Pre-submission audit results

  - id: prepare-signing
    action: instruct
    description: >
      Guide through Apple Developer Program setup:
      1. Verify active Apple Developer Program membership ($99/year)
      2. Create App ID in developer portal (bundle identifier)
      3. Create provisioning profile (App Store Distribution)
      4. Configure Xcode signing:
         - Automatic signing for development
         - Manual or automatic for distribution (recommend automatic)
      5. Create App Store Connect record:
         - App name (check availability)
         - Primary language and category
         - Bundle ID link
    output: Signing configuration checklist

  - id: prepare-metadata
    action: generate
    description: >
      Draft all App Store Connect metadata:
      - App name (30 char max)
      - Subtitle (30 char max — high-value keywords here)
      - Description (4000 char max — first 3 lines most visible)
      - Keywords (100 char max — comma-separated, no spaces after commas)
      - What's New text (for updates)
      - Support URL
      - Privacy Policy URL
      - Age Rating questionnaire answers
      - App category and secondary category
      - Copyright line
    reference: references/lifecycle/app-store-optimization.md
    output: Complete metadata draft for all fields

  - id: prepare-screenshots
    action: instruct
    description: >
      Guide screenshot preparation:
      Required sizes:
        - 6.7" (iPhone 15 Pro Max): 1290 x 2796
        - 6.5" (iPhone 14 Plus): 1284 x 2778
        - 5.5" (iPhone 8 Plus): 1242 x 2208
        - 12.9" iPad Pro: 2048 x 2732 (if iPad supported)
      Best practices:
        - 3-5 screenshots per device size
        - First screenshot is most important (visible in search results)
        - Show actual app screens with marketing text overlay
        - Demonstrate key features in logical flow
        - Use App Preview video if possible (15-30 second demo)
    output: Screenshot specification and guidance

  - id: configure-testflight
    action: instruct
    description: >
      Set up TestFlight distribution pipeline:
      1. Archive app in Xcode (Product → Archive)
      2. Upload to App Store Connect via Xcode Organizer
      3. Wait for processing (5-30 minutes)
      4. Internal testing: auto-available to team members (up to 100)
      5. External testing: create test group, add testers by email
         - First external build requires beta review (~1 day)
         - Subsequent builds auto-approved if no major changes
      6. Add beta test notes describing what to test
    output: TestFlight setup and distribution instructions

  - id: submit-for-review
    action: instruct
    description: >
      Final submission steps:
      1. Select build in App Store Connect
      2. Fill in review notes (explain any non-obvious features, provide test credentials)
      3. Answer export compliance questions (most apps: "No" to encryption beyond HTTPS)
      4. Answer IDFA questions (only if using ad tracking)
      5. Set release type: Manual, Automatic, or Scheduled
      6. Submit for review
      7. Monitor status: Waiting for Review → In Review → Approved/Rejected
    output: Submission confirmation and monitoring plan

  - id: handle-rejection
    action: diagnose
    condition: "Only if app was rejected"
    description: >
      Parse rejection reason and prescribe fix:
      Common rejections and fixes:
        - Guideline 2.1 (crashes): Test on physical devices, check memory leaks
        - Guideline 2.3 (placeholder content): Remove all test/lorem content
        - Guideline 3.1.1 (IAP): All digital goods must use IAP, not Stripe
        - Guideline 4.0 (design): Follow HIG, don't mimic other platforms
        - Guideline 4.2 (minimum functionality): Add enough features to justify an app
        - Guideline 5.1.1 (privacy): Add privacy policy, app tracking transparency
        - Guideline 5.1.2 (data use): Declare all data collection in privacy nutrition label
      Resolution process:
        1. Read the full rejection message (often includes specific screenshots)
        2. Fix the cited issues
        3. Reply in Resolution Center with explanation of changes
        4. Resubmit for review
    output: Rejection diagnosis and fix plan

  - id: quality-gate
    action: validate
    checklist:
      - App runs without crashes on all supported device sizes
      - All metadata fields filled (name, subtitle, description, keywords)
      - Screenshots uploaded for all required device sizes
      - Privacy policy URL resolves and is accurate
      - App privacy "nutrition label" completed in App Store Connect
      - Demo account provided in review notes (if login required)
      - No placeholder content anywhere in the app
      - TestFlight build tested by at least 2 people before submission
      - Export compliance questions answered
      - Version number and build number are correct
    output: Submission readiness confirmation
```

---

## Workflow 5: UI Component Build

Create a specific SwiftUI component from requirements or a web reference.

### Trigger

```
"Build a [COMPONENT] in SwiftUI"
"Create a custom [CARD/LIST/FORM/CHART] view"
"Translate this web component to SwiftUI"
"Make a reusable [COMPONENT] with [FEATURES]"
```

### Steps

```yaml
workflow: ui-component-build
duration: ~10-25 min

steps:
  - id: define-component-spec
    action: assess
    description: >
      Clarify the component's contract:
      - What data does it display? (model type / properties)
      - What interactions does it support? (tap, swipe, long press, drag)
      - What states does it have? (default, loading, error, empty, selected)
      - Is it reusable across screens or screen-specific?
      - Does it need to work on iPhone and iPad?
      - What's the web analog, if any? (helps calibrate expectations)
    output: Component specification

  - id: select-composition-strategy
    action: decide
    decision_tree:
      system_component_sufficient:
        condition: "Standard list row, form field, or navigation element"
        recommendation: "Compose from built-in SwiftUI views with modifiers"
        rationale: "System components get free accessibility, dynamic type, and dark mode."
      custom_layout_needed:
        condition: "Non-standard layout (overlapping, asymmetric, responsive)"
        recommendation: "Custom view with GeometryReader or custom Layout protocol"
        rationale: "Layout protocol (iOS 16+) is cleaner than GeometryReader for reusable layouts."
      uikit_needed:
        condition: "Camera preview, complex text editing, MKMapView advanced features"
        recommendation: "UIViewRepresentable wrapper"
        rationale: "Some UIKit components have no SwiftUI equivalent yet."
      canvas_drawing:
        condition: "Charts, gauges, custom shapes, path-based graphics"
        recommendation: "Shape protocol + Canvas view (iOS 15+) or Swift Charts (iOS 16+)"
        rationale: "Shape for custom drawing. Swift Charts for data visualization."
    output: Composition strategy

  - id: implement-view
    action: generate
    description: >
      Write the SwiftUI view following these rules:
      1. View struct with clear, descriptive name
      2. Model data as parameters (let properties) or @Binding for two-way
      3. Local state as @State (private)
      4. Body structured as: container → content → modifiers
      5. Extract subviews for any section > 20 lines
      6. Use ViewBuilder for conditional content
      7. Apply view modifiers in consistent order:
         layout (.frame, .padding) → style (.background, .foregroundStyle)
         → shape (.clipShape, .shadow) → interaction (.onTapGesture)
         → accessibility (.accessibilityLabel)
    output: SwiftUI view implementation

  - id: add-animations
    action: generate
    condition: "Component has state transitions or interactions"
    description: >
      Add animations following iOS conventions:
      - State transitions: withAnimation(.easeInOut(duration: 0.3)) or .animation(.default, value:)
      - Appear/disappear: .transition(.opacity) or .transition(.move(edge:))
      - Interactive: .scaleEffect on press, .matchedGeometryEffect for shared element transitions
      - Loading: ProgressView() or custom shimmer effect
      - Haptics: UIImpactFeedbackGenerator for confirmations, UISelectionFeedbackGenerator for selections
      Avoid: bouncy animations on non-interactive elements, animation duration > 0.5s, animations
      that block interaction.
    output: Animation layer

  - id: add-accessibility
    action: generate
    description: >
      Apply accessibility modifiers:
      - .accessibilityLabel() on all images and icons
      - .accessibilityHint() for non-obvious interactions
      - .accessibilityValue() for stateful controls
      - .accessibilityAddTraits() for custom interactive elements
      - .dynamicTypeSize() testing — verify layout at .accessibility5
      - Minimum tap target: 44x44 points
      - Sufficient color contrast (4.5:1 for text, 3:1 for large text)
    output: Accessible component

  - id: generate-previews
    action: generate
    description: >
      Create comprehensive #Preview blocks:
      - Default state with sample data
      - Empty state (no data)
      - Loading state (if applicable)
      - Error state (if applicable)
      - Dark mode: .preferredColorScheme(.dark)
      - Large text: .dynamicTypeSize(.xxxLarge)
      - Small device: .previewDevice("iPhone SE (3rd generation)")
      - iPad: .previewDevice("iPad Pro 13-inch (M4)")
    output: Preview provider set

  - id: quality-gate
    action: validate
    checklist:
      - Component renders correctly in all preview variants
      - No force-unwraps or force-casts
      - Accessibility labels on all interactive and meaningful visual elements
      - Dynamic Type supported (no fixed font sizes unless intentional)
      - Dark mode renders correctly (no hardcoded colors)
      - Extracted subviews keep body under ~50 lines
      - Component is testable (preview provider exercises all states)
      - iPad layout considered (if universal app)
    output: Component quality verification
```

---

## Workflow 6: Performance Audit

Profile and optimize an existing iOS app.

### Trigger

```
"My app is slow to launch"
"Scrolling is janky in my list view"
"My app uses too much memory"
"Profile my iOS app's performance"
"The app drains battery quickly"
```

### Steps

```yaml
workflow: performance-audit
duration: ~20-40 min

steps:
  - id: collect-symptoms
    action: assess
    description: >
      Gather performance symptoms:
      - What is slow? (launch, navigation, scrolling, specific operation)
      - When did it start? (always, after a specific change, after data grew)
      - Which devices? (old devices only, or all devices)
      - What scale? (how many items in lists, how much data in DB)
      - Measurable metrics: launch time, frame rate, memory footprint
    output: Symptom profile

  - id: identify-category
    action: diagnose
    decision_tree:
      slow_launch:
        symptoms: "App takes > 2 seconds to show first content"
        likely_causes:
          - "Synchronous work in app init or ContentView.init"
          - "Heavy Core Data / SwiftData migration on launch"
          - "Too many SPM packages increasing dylib load time"
          - "Large asset catalog with unoptimized images"
        investigation: "Instruments → App Launch template"
      janky_scrolling:
        symptoms: "Frame drops when scrolling lists, visible stutter"
        likely_causes:
          - "Non-lazy containers (VStack in ScrollView instead of LazyVStack)"
          - "Heavy computation in view body (sorting, filtering during render)"
          - "Synchronous image loading in list cells"
          - "Complex view hierarchies triggering excessive diffing"
        investigation: "Instruments → SwiftUI profiler or Core Animation"
      high_memory:
        symptoms: "Memory grows over time, app terminated by OS"
        likely_causes:
          - "Retain cycles in closures (missing [weak self])"
          - "Unbounded image cache"
          - "Core Data / SwiftData fault loading entire dataset"
          - "NavigationStack not releasing dismissed views"
        investigation: "Instruments → Leaks + Allocations templates"
      battery_drain:
        symptoms: "Users report high battery usage"
        likely_causes:
          - "Excessive background refresh / location updates"
          - "Timer-based polling instead of push notifications"
          - "Continuous animations running when not visible"
          - "Unnecessary network requests"
        investigation: "Instruments → Energy Log template"
    output: Categorized diagnosis with investigation plan

  - id: guide-instruments
    action: instruct
    description: >
      Walk through Instruments profiling:
      1. In Xcode: Product → Profile (Cmd+I) — this builds in Release mode
      2. Select appropriate template based on symptom category
      3. Record a session reproducing the problem
      4. Key things to look for:
         - Time Profiler: heaviest stack traces, main thread blocking
         - Allocations: growth over time, transient spikes, zombie objects
         - Leaks: retain cycles (look for circular strong references)
         - Core Animation: off-screen rendering (yellow highlight), blending
         - Network: redundant requests, large payloads
      5. Identify the top 3 hotspots by time or memory
    output: Profiling instructions and interpretation guide

  - id: prescribe-fixes
    action: prescribe
    description: >
      Map identified bottlenecks to specific code fixes:

      Launch time:
        - Move heavy init to .task {} (async, after first frame)
        - Lazy-load features with NavigationStack destination closures
        - Audit SPM dependencies — remove unused ones
        - Use asset catalog optimization (compress images)

      Scroll performance:
        - Replace VStack in ScrollView with LazyVStack
        - Move sorting/filtering to ViewModel, not view body
        - Use AsyncImage with cache for remote images
        - Reduce view hierarchy depth (flatten nested stacks)
        - Add .drawingGroup() for complex composited views

      Memory:
        - Audit closures for [weak self] in async contexts
        - Use .onDisappear to nil out large resources
        - Implement LRU cache for images with size limit
        - Use @Query with #Predicate limits for SwiftData
        - Verify NavigationStack releases detail view memory

      Battery:
        - Replace timers with push notifications
        - Use significant location changes instead of continuous
        - Pause animations with scenePhase detection
        - Batch network requests instead of individual calls
    output: Prioritized fix list with code snippets

  - id: verify-improvement
    action: instruct
    description: >
      Guide re-measurement after fixes:
      1. Profile the same scenario as before
      2. Compare metrics: launch time, frame rate, memory peak, energy impact
      3. Test on the oldest supported device (where improvements matter most)
      4. Set performance budgets for ongoing monitoring:
         - Launch to first frame: < 1 second
         - Scroll frame rate: 60fps sustained (120fps on ProMotion)
         - Memory footprint: < 100MB for typical use
         - No leaked objects after navigating back
    output: Verification plan with target metrics

  - id: quality-gate
    action: validate
    checklist:
      - Root cause identified with evidence (not guesswork)
      - Fix addresses root cause, not just symptom
      - Performance measured before and after fix
      - Fix tested on oldest supported device
      - No regressions introduced (UI still correct, no new crashes)
      - Performance budget documented for the team
    output: Performance audit completion report
```

---

## Decision Trees — Quick Reference

### Which Architecture?

```
New iOS project?
├── Yes → How many screens?
│   ├── < 5 screens, solo dev → MVVM + @Observable
│   ├── 5-15 screens, small team → MVVM + @Observable + Service/DI layer
│   └── > 15 screens or complex side effects → TCA
└── No → Existing UIKit?
    ├── Yes → MVVM + UIHostingController (incremental adoption)
    └── No → Existing SwiftUI needing refactor?
        └── Assess current state, migrate to MVVM + @Observable
```

### Which Backend?

```
Need a backend?
├── No → UserDefaults (@AppStorage) for prefs, SwiftData for structured data
└── Yes → Cross-platform needed?
    ├── No (Apple only) → CloudKit
    │   └── Need SQL queries? → No: CloudKit is fine. Yes: Supabase or custom.
    └── Yes → Existing backend?
        ├── Yes → Custom URLSession integration
        └── No → Prefer SQL?
            ├── Yes → Supabase
            └── No → Firebase
```

### Which Data Persistence?

```
What are you storing?
├── Simple key-value prefs → UserDefaults + @AppStorage
├── Sensitive credentials → Keychain
├── Structured app data → iOS 17+ minimum?
│   ├── Yes → SwiftData
│   └── No → Core Data
├── Files/documents → FileManager + app sandbox
└── Cache/temp data → URLCache or NSCache
```

### Which iOS Version to Target?

```
What features do you need?
├── @Observable, SwiftData, StoreKit 2 views → iOS 17+ minimum
├── Swift Charts, NavigationStack, any modern API → iOS 16+ minimum
├── Widest reach (97%+ of active devices) → iOS 16+ minimum
├── Maximum new APIs (Swift Testing, custom containers) → iOS 18+ minimum
└── Default recommendation for new apps in 2025-2026 → iOS 17+ minimum
```

---

## Cross-References

- For web UI design principles that translate to mobile: **trl-user-experience-engineer** (`references/core-philosophy.md`)
- For validating your app idea before building: **trl-market-intelligence** (`references/niche-discovery.md`)
- For App Store listing optimization (ASO): **trl-seo-guru** — ASO shares DNA with SEO
- For packaging app templates as digital products: **trl-ai-templates** (`references/product-types/`)
- For GPU-intensive iOS apps: **trl-metal-graphics-dev** (SKILL.md, `references/agent-playbook.claude-code.md`)
- For building APIs that the iOS app consumes: **trl-mcp-builder** or project-specific backend docs
- For Android companion app: **trl-android-mobile** (SKILL.md)
