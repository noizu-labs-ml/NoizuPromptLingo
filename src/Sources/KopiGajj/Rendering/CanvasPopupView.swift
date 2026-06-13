import SwiftUI
import AppKit

/// Sample clipboard item for Stage 0.5 demo.
/// Replaced by real ClipboardItem in Stage 1.
private struct SampleItem: Identifiable {
    let id: Int
    let content: String
    let typeIcon: String
    let age: TimeInterval   // seconds since copy
}

/// Main popup view for Stage 0.5 — demonstrates the canvas render engine.
///
/// The Kuwahara filter is applied to the ENTIRE composited popup (background +
/// cards + text) as a single post-process pass. This is what produces the
/// oil-painting look — flat color regions with brush-stroke boundaries.
///
/// The filtered result is rendered once as a static image. Interactive elements
/// (close button) overlay on top.
struct CanvasPopupView: View {
    let onClose: () -> Void

    /// Full popup rendered through Kuwahara (computed once on appear).
    @State private var paintedImage: NSImage?
    @State private var isRendering = true

    private let sampleItems: [SampleItem] = [
        SampleItem(id: 0,
                   content: "let canvas = MTLCreateSystemDefaultDevice()",
                   typeIcon: "chevron.left.forwardslash.chevron.right",
                   age: 5),
        SampleItem(id: 1,
                   content: "https://developer.apple.com/metal/",
                   typeIcon: "link",
                   age: 300),
        SampleItem(id: 2,
                   content: "Meeting notes: discussed canvas render engine phasing — 0.5a textures first, 0.5b shaders second",
                   typeIcon: "doc.text",
                   age: 1800),
        SampleItem(id: 3,
                   content: "~/Documents/design-spec.pdf",
                   typeIcon: "folder",
                   age: 3600),
    ]

    var body: some View {
        ZStack {
            if let painted = paintedImage {
                // Kuwahara-filtered full popup (oil painting effect)
                Image(nsImage: painted)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: CanvasTheme.popupWidth, height: CanvasTheme.popupHeight)
            } else {
                // Show unfiltered while rendering (brief flash)
                popupContent
            }

            // Interactive overlay (always on top, unfiltered)
            VStack {
                Spacer()
                footer
            }
            .padding(.bottom, 16)
        }
        .frame(width: CanvasTheme.popupWidth, height: CanvasTheme.popupHeight)
        .task { await renderPainted() }
    }

    // MARK: - The full popup content (rendered to image then filtered)

    private var popupContent: some View {
        ZStack {
            CanvasBackground()

            VStack(spacing: 0) {
                header
                    .padding(.bottom, 12)

                cardStack
                    .padding(.horizontal, 16)

                Spacer(minLength: 40)
            }
            .padding(.top, 24)
        }
        .frame(width: CanvasTheme.popupWidth, height: CanvasTheme.popupHeight)
    }

    // MARK: - Render pipeline

    @MainActor
    private func renderPainted() async {
        // Capture the full popup as an image
        let renderer = ImageRenderer(content: popupContent)
        renderer.scale = 2.0  // Retina

        guard let captured = renderer.nsImage else { return }

        // Apply Kuwahara on background thread
        if let metalRenderer = CanvasMetalRenderer.shared {
            let filtered = await Task.detached {
                metalRenderer.applyKuwahara(to: captured, radius: CanvasTheme.kuwaharaRadius)
            }.value

            if let filtered {
                paintedImage = filtered
                isRendering = false
                return
            }
        }

        // Fallback: show unfiltered
        paintedImage = captured
        isRendering = false
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 4) {
            Text("Smart Clipboard")
                .font(CanvasTheme.titleFont)
                .foregroundStyle(.primary)

            Text("Canvas Render Engine — Stage 0.5")
                .font(CanvasTheme.subtitleFont)
                .foregroundStyle(.secondary)
        }
    }

    private var cardStack: some View {
        VStack(spacing: 10) {
            ForEach(sampleItems) { item in
                StrokeCard(
                    content: item.content,
                    typeIcon: item.typeIcon,
                    age: item.age,
                    cardIndex: item.id
                )
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 16) {
            Label("Escape to close", systemImage: "escape")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.7))

            if CanvasTheme.metalAvailable {
                Label("Metal active", systemImage: "gpu")
                    .font(.system(size: 11))
                    .foregroundStyle(.green.opacity(0.8))
            }

            Spacer()

            Button(action: onClose) {
                Text("Close")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .keyboardShortcut(.escape)
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 16)
    }
}
