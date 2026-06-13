# Rust macOS Desktop Development — 2025 Reference

> Reference guide for building therobotbrowses as a native macOS application in Rust.

---

## GUI Frameworks

| Framework | Version | macOS Quality | Production-Ready | Approach | Used By |
|-----------|---------|---------------|------------------|----------|---------|
| **winit + wgpu** | 0.30 / 0.28 | Excellent | Yes | Window + GPU substrate | Most Rust GUIs |
| **GPUI** | pre-1.0 | Excellent | Zed only | Metal hybrid render | Zed editor |
| **Tauri v2** | 2.x | Excellent | Yes | WKWebView + Rust | 1Password (partial) |
| **Slint** | 1.x | Good | Yes | Declarative DSL | Embedded/IoT |
| **iced** | 0.14 | Good | Near | Elm architecture, wgpu | Cosmic desktop (System76) |
| **egui** | 0.29 | Good | Yes (tooling) | Immediate mode | Game dev tools |
| **Dioxus** | 0.6 | Good | Near | React-like, WebView | — |
| **Xilem/Masonry** | pre-alpha | Functional | No | SwiftUI-like (Linebender) | — |
| **Makepad** | pre-1.0 | Functional | No | Custom GPU/DSL | — |

### Recommended for therobotbrowses

**winit + wgpu** is the correct choice — we need full control over the rendering pipeline since we're building the renderer. GPUI and Tauri abstract away the rendering layer we're implementing.

- **Phase 0 (TUI)**: ratatui (no windowing needed)
- **Phase 2+ (GUI)**: winit (window) + wgpu (GPU, Metal backend) + skia-safe (2D graphics)
- **Accessibility**: accesskit (cross-platform a11y tree)

---

## Platform Integration Crates

### Current (use these)

| Crate | Purpose | Status |
|-------|---------|--------|
| **objc2** + framework crates | Safe Objective-C FFI, AppKit/Foundation/Metal bindings | Active, replaces old `objc` + `cocoa` |
| **objc2-app-kit** | AppKit bindings (NSWindow, NSView, NSMenu, etc.) | Part of objc2 ecosystem |
| **objc2-foundation** | Foundation bindings (NSString, NSURL, etc.) | Part of objc2 ecosystem |
| **accesskit** + **accesskit_macos** | NSAccessibility for VoiceOver | Active, presented at RustWeek 2025 |
| **core-foundation-rs** | CoreFoundation, CoreGraphics, CoreText | Maintained (Servo project) |
| **swift-bridge** | Bi-directional Rust ↔ Swift FFI | Active, pre-1.0 (0.1.x), Swift 6.0+ |
| **metal-rs** | Safe Metal GPU API bindings | Active, used by wgpu internally |
| **apple-codesign** / **rcodesign** | Code signing + notarization (pure Rust) | Production-quality (v0.29) |

### Deprecated (do not use)

| Crate | Replaced By |
|-------|-------------|
| **cocoa-rs** | objc2 + objc2-app-kit |
| **objc** (old) | objc2 |
| **icrate** | Split into individual objc2-* framework crates |

---

## Accessibility (VoiceOver)

**AccessKit** is the de facto path for Rust GUI accessibility on macOS.

- Implements `NSAccessibility` protocols from AppKit
- Enables VoiceOver support for custom-rendered UIs
- Cross-platform: same API drives NSAccessibility (macOS), AT-SPI2 (Linux), UIA (Windows)
- Integrated into egui and iced (partially)
- **Reality check**: 2025 GUI survey found 94.4% of Rust GUI crates lack production-ready accessibility. AccessKit bridges this gap but requires framework-level integration.

### What therobotbrowses must expose via AccessKit

| UI Element | AX Property | Required |
|-----------|-------------|----------|
| Tab strip | AXRole: TabGroup, AXTabs | Launch |
| Address bar | AXRole: TextField, AXValue: URL | Launch |
| Navigation buttons | AXRole: Button, AXLabel | Launch |
| Security indicator | AXRole: StaticText, AXValue | Launch |
| Content viewport | AXRole: WebArea (delegates to page a11y tree) | Phase 6 |
| Status bar | AXRole: Group, aria-live equivalent | Launch |

### Legal requirement

VoiceOver support is legally required for EU distribution (EN 301 549, European Accessibility Act effective June 2025) and US federal procurement (Section 508). See `docs/standards/accessibility-security.md`.

---

## App Bundling and Distribution

### Recommended workflow (non-Tauri)

```bash
# 1. Build for both architectures
cargo build --release --target aarch64-apple-darwin
cargo build --release --target x86_64-apple-darwin

# 2. Create universal binary
lipo -create \
  target/aarch64-apple-darwin/release/therobotbrowses \
  target/x86_64-apple-darwin/release/therobotbrowses \
  -output target/universal/therobotbrowses

# 3. Assemble .app bundle (via cargo-bundle or manual)
# cargo-bundle reads [package.metadata.bundle] from Cargo.toml

# 4. Sign with rcodesign (works on Linux CI — no macOS required)
rcodesign sign \
  --p12-file certificate.p12 \
  --p12-password-file password.txt \
  --code-signature-flags runtime \
  --entitlements-xml-file entitlements.plist \
  TheRobotBrowses.app

# 5. Create DMG
hdiutil create -volname "TheRobotBrowses" \
  -srcfolder TheRobotBrowses.app \
  -ov -format UDZO \
  TheRobotBrowses.dmg

# 6. Sign DMG
rcodesign sign --p12-file certificate.p12 TheRobotBrowses.dmg

# 7. Notarize (requires App Store Connect API Key)
rcodesign notary-submit \
  --api-key-path api-key.json \
  TheRobotBrowses.dmg

# 8. Staple
rcodesign staple TheRobotBrowses.dmg
```

### Bundling tools

| Tool | What it does | Notes |
|------|-------------|-------|
| **cargo-bundle** | Generates `.app` from Cargo.toml metadata | Maintained; Zed maintains a fork |
| **rcodesign** | Sign, notarize, staple — pure Rust, works on Linux CI | Production-quality, no Xcode needed |
| **tauri-bundler** | Full pipeline: .app, .dmg, signing, notarization | Best-integrated but Tauri-coupled |
| **create-dmg** | Pretty DMG creation with backgrounds/icons | Shell tool, not Rust |

### Key advantage of rcodesign

Signing and notarization work **from Linux CI** — no macOS runner required. This is significant for cost: GitHub Actions Apple Silicon runners cost 2-3x more than Linux.

---

## Code Signing and Notarization

### apple-codesign (rcodesign)

- **Author**: Gregory Szorc (indygreg)
- **Crate**: `apple-codesign` on crates.io (v0.29)
- **CLI**: `rcodesign`
- **Capabilities**: Sign Mach-O binaries, `.app` bundles, `.pkg`, `.dmg`; notarize via Apple Notary API; YubiKey/smart card support
- **Key feature**: Pure Rust — runs on Linux, macOS, Windows
- **CI**: `indygreg/apple-code-sign-action` GitHub Action
- **Requirements**: Apple Developer Program membership, App Store Connect API Key for notarization

### Entitlements

Minimum entitlements for a browser:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "...">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <false/>  <!-- Required false for non-App Store browser -->
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>   <!-- Required for JIT (JavaScript engine) -->
    <key>com.apple.security.cs.disable-library-validation</key>
    <true/>   <!-- Required for loading plugins/extensions -->
    <key>com.apple.security.network.client</key>
    <true/>   <!-- Required for HTTP/HTTPS requests -->
    <key>com.apple.security.device.camera</key>
    <false/>
    <key>com.apple.security.device.microphone</key>
    <false/>
</dict>
</plist>
```

**Note**: App Store distribution requires full sandbox (`com.apple.security.app-sandbox = true`), which is extremely restrictive for a browser. Direct distribution with notarization is the recommended path.

---

## Notable Rust macOS Apps (Reference)

| App | UI Approach | macOS-Specific Notes |
|-----|------------|---------------------|
| **Zed** | GPUI (custom Metal renderer) | macOS-first, Metal-native, exemplary performance |
| **Warp** | Custom Rust + GPU | Full browser-like rendering for terminal |
| **Alacritty** | winit + wgpu/OpenGL | GPU-accelerated terminal, minimal |
| **Lapce** | Floem (custom) | Code editor with GPU rendering |
| **WezTerm** | Custom Rust | GPU terminal, cross-platform |

**Not Rust**: Ghostty (Zig), Ladybird (C++).

---

## Browser Engines in Rust

### Servo

- **Status**: Active development, governed by Linux Foundation Europe
- **Releases**: v0.0.1 (Oct 2025, added Apple Silicon), v0.0.2 (Nov 2025), v0.0.4 (multi-window)
- **Reality**: Not a daily-driver engine. Many sites render incorrectly. Performance below Chromium/WebKit/Gecko.
- **Embedding**: Increasingly targeted for embedded webview use, not standalone browsing
- **Crates we can reuse**: `html5ever` (HTML parser), `cssparser` (CSS tokenizer), `selectors` (CSS selector matching), `webrender` (GPU compositor), `unicode-bidi`, `unicode-normalization`

### Verso

- **Repo**: `nicoinch/nicoverso` (was `piny940/nicoverso`, was `nicoverso/nicoverso`)
- **Status**: Experimental. Full browser built on Servo. v0.1 released.
- **Not suitable** for production or as our foundation — but worth tracking for API design inspiration.

### Servo Crates Relevant to therobotbrowses

| Crate | What it does | Our usage |
|-------|-------------|-----------|
| **html5ever** | HTML5-spec-compliant parser | Phase 1 (already planned) |
| **cssparser** | CSS tokenizer and parser framework | Phase 1 (evaluate vs lightningcss) |
| **selectors** | CSS selector matching engine | Phase 1 |
| **unicode-bidi** | Unicode bidirectional algorithm | Phase 1 (text layout) |
| **unicode-normalization** | NFC/NFD/NFKC/NFKD | Phase 1 |
| **url** | WHATWG URL Standard parser | Phase 0 |
| **encoding_rs** | WHATWG Encoding Standard | Phase 0 |
| **core-foundation-rs** | macOS CoreFoundation/CoreGraphics/CoreText | Phase 2 |

---

## Challenges and Gotchas

### Apple Silicon

- `aarch64-apple-darwin` target is first-class in Rust
- Universal binaries (arm64 + x86_64) via `lipo` — no single-step Cargo support
- GitHub Actions Apple Silicon runners available but at higher cost
- **Recommendation**: Build on Linux, sign with rcodesign, test on macOS CI

### Sandboxing

- App Store requires full sandbox — extremely restrictive for a browser (blocks JIT, plugin loading, arbitrary network access)
- **Recommendation**: Direct distribution with notarization, not App Store
- File access outside container requires security-scoped bookmarks

### IME / Internationalization

- Several GUI frameworks have broken or absent IME support
- Verify CJK input method support early (winit handles this, but custom text input requires NSTextInputClient protocol)

### Accessibility Gap

- 94.4% of Rust GUI crates lack production-ready accessibility (2025 survey)
- AccessKit is the solution but requires explicit integration work
- Budget significant effort for VoiceOver testing

---

## Key Resources

- [objc2 — madsmtm/objc2](https://github.com/madsmtm/objc2) — Modern Objective-C bindings
- [AccessKit](https://accesskit.dev/) — Cross-platform accessibility
- [apple-codesign docs](https://gregoryszorc.com/docs/apple-codesign/stable/) — Signing and notarization
- [swift-bridge](https://github.com/chinedufn/swift-bridge) — Rust ↔ Swift FFI
- [core-foundation-rs](https://github.com/servo/core-foundation-rs) — CoreFoundation/CoreGraphics/CoreText
- [2025 Survey of Rust GUI Libraries](https://www.boringcactus.com/2025/04/13/2025-survey-of-rust-gui-libraries.html)
- [Are We GUI Yet?](https://areweguiyet.com/)
- [Shipping Rust on macOS App Store](https://hannes.kaeufler.net/posts/shipping-rust-on-macos-app-store)
- [Servo Project](https://servo.org/)
- [Tauri v2](https://v2.tauri.app/)
- [Slint](https://slint.dev/)
