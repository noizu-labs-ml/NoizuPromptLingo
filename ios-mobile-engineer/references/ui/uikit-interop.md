# UIKit Interop for Web Developers

SwiftUI cannot do everything. Camera capture, complex attributed text editing, MapKit with full customization, WKWebView, and many third-party SDKs still require UIKit. SwiftUI provides two bridge protocols to wrap UIKit components and use them as native SwiftUI views.

Think of this like wrapping a jQuery plugin in a React component — you manage the lifecycle imperatively inside a declarative wrapper.

---

## When to Use UIKit

| Need | SwiftUI Native? | UIKit Bridge? |
|------|-----------------|---------------|
| Basic text, images, buttons | Yes | No |
| Camera / photo picker | `PhotosPicker` (iOS 16+) | `UIImagePickerController` for camera |
| Web content | No | `WKWebView` via `UIViewRepresentable` |
| Maps with annotations | `Map` (basic) | `MKMapView` for full control |
| Rich text editing | `TextEditor` (basic) | `UITextView` for attributed text |
| PDF rendering | No | `PDFView` via `UIViewRepresentable` |
| Video player | `VideoPlayer` (basic) | `AVPlayerViewController` for full control |
| Third-party SDK views | No | Wrap with `UIViewRepresentable` |
| Complex gesture recognizers | Limited | `UIGestureRecognizer` subclasses |

---

## UIViewRepresentable — Wrapping UIKit Views

This protocol wraps a `UIView` subclass for use in SwiftUI. It has two required methods and one optional update method.

**Pattern: Wrapping a UIKit view (like wrapping a DOM element in React)**

```swift
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    // 1. Create the UIKit view (componentDidMount)
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    // 2. Update when SwiftUI state changes (componentDidUpdate)
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Called when `url` changes
        let currentURL = webView.url
        if currentURL != url {
            webView.load(URLRequest(url: url))
        }
    }
}

// Usage in SwiftUI — looks like any other view
struct ContentView: View {
    var body: some View {
        WebView(url: URL(string: "https://apple.com")!)
            .frame(height: 400)
    }
}
```

### Lifecycle Mapping

| React | UIViewRepresentable |
|-------|-------------------|
| `componentDidMount` / `useEffect([], ...)` | `makeUIView(context:)` |
| `componentDidUpdate` / `useEffect([deps], ...)` | `updateUIView(_:context:)` |
| `componentWillUnmount` | `dismantleUIView(_:coordinator:)` (static) |
| `ref` / imperative handle | `Coordinator` class |

---

## Coordinator — Handling Delegates and Callbacks

UIKit uses the delegate pattern extensively (like event listeners in the DOM). The `Coordinator` acts as the delegate, forwarding events back to SwiftUI.

```swift
struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator  // coordinator is the delegate
        return picker
    }

    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {
        // Nothing to update
    }

    // Coordinator handles delegate callbacks
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            parent.capturedImage = info[.originalImage] as? UIImage
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// Usage
struct PhotoScreen: View {
    @State private var image: UIImage?
    @State private var showCamera = false

    var body: some View {
        VStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            Button("Take Photo") { showCamera = true }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(capturedImage: $image)
        }
    }
}
```

---

## UIViewControllerRepresentable — Wrapping View Controllers

For UIKit screens that are full view controllers (not just views). Same pattern as `UIViewRepresentable` but for `UIViewController`.

```swift
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .plainText])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ controller: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.selectedURL = urls.first
        }
    }
}
```

---

## Passing Data Between UIKit and SwiftUI

### SwiftUI to UIKit (props down)

Data flows through the representable's properties. When SwiftUI state changes, `updateUIView` is called.

```swift
struct ColoredBox: UIViewRepresentable {
    var color: UIColor        // SwiftUI passes this in
    var cornerRadius: CGFloat

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.layer.cornerRadius = cornerRadius
        view.backgroundColor = color
        return view
    }

    func updateUIView(_ view: UIView, context: Context) {
        // React to state changes from SwiftUI
        UIView.animate(withDuration: 0.3) {
            view.backgroundColor = color
            view.layer.cornerRadius = cornerRadius
        }
    }
}

// SwiftUI side
struct DemoView: View {
    @State private var isRed = true

    var body: some View {
        ColoredBox(
            color: isRed ? .red : .blue,
            cornerRadius: 12
        )
        .frame(width: 200, height: 200)

        Button("Toggle") { isRed.toggle() }
    }
}
```

### UIKit to SwiftUI (events up)

Use `@Binding` or closures to send data back. The Coordinator captures these and calls them from delegate methods.

```swift
struct RatingSlider: UIViewRepresentable {
    @Binding var value: Float    // two-way binding back to SwiftUI

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 5
        slider.value = value
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )
        return slider
    }

    func updateUIView(_ slider: UISlider, context: Context) {
        slider.value = value
    }

    class Coordinator: NSObject {
        let parent: RatingSlider

        init(_ parent: RatingSlider) {
            self.parent = parent
        }

        @objc func valueChanged(_ slider: UISlider) {
            parent.value = slider.value    // push value back to SwiftUI
        }
    }
}
```

---

## Hosting SwiftUI Inside UIKit Apps

For brownfield adoption — adding SwiftUI views into an existing UIKit codebase. This is the reverse direction.

```swift
import UIKit
import SwiftUI

class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a SwiftUI view
        let swiftUIView = SettingsPanel(userName: "Keith")

        // Wrap it in a hosting controller
        let hostingController = UIHostingController(rootView: swiftUIView)

        // Add as child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        // Layout with Auto Layout
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// The SwiftUI view being hosted
struct SettingsPanel: View {
    let userName: String

    var body: some View {
        Form {
            Section("Profile") {
                Text("Hello, \(userName)")
            }
            Section("Preferences") {
                Toggle("Dark Mode", isOn: .constant(false))
            }
        }
    }
}
```

### Sharing State Between UIKit Host and SwiftUI Guest

Use `@ObservableObject` to share mutable state:

```swift
class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userName = ""
}

// UIKit side owns the state
class MainViewController: UIViewController {
    let appState = AppState()

    func showProfile() {
        let profileView = ProfileView()
            .environmentObject(appState)
        let hosting = UIHostingController(rootView: profileView)
        navigationController?.pushViewController(hosting, animated: true)
    }
}

// SwiftUI side reads and writes it
struct ProfileView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack {
            Text("Welcome, \(appState.userName)")
            Button("Log Out") {
                appState.isLoggedIn = false
            }
        }
    }
}
```

---

## Common Pitfalls

**1. Forgetting `updateUIView`:** If you only set values in `makeUIView`, SwiftUI state changes will not propagate to the UIKit view. Always handle updates.

**2. Strong reference cycles in Coordinator:** The coordinator holds a reference to `parent` (the representable struct). Since structs are value types, this is safe. But if you store closures that capture `self`, be careful.

**3. Auto Layout conflicts:** `UIHostingController.view` has its own sizing. Set `translatesAutoresizingMaskIntoConstraints = false` and pin edges explicitly.

**4. Sizing mismatches:** UIKit views may not report their intrinsic content size correctly to SwiftUI. Use `.frame()` on the SwiftUI side or override `intrinsicContentSize` on the UIKit side.

**5. Thread safety:** UIKit updates must happen on the main thread. SwiftUI calls `makeUIView` and `updateUIView` on the main thread, but if your Coordinator receives callbacks on background threads (e.g., from network delegates), dispatch back to main before updating `@Binding` values.
