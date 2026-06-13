import SwiftUI
import AppKit

// MARK: - Sample data

let canvasSampleItems: [(String, String, TimeInterval)] = [
    ("let canvas = MTLCreateSystemDefaultDevice()", "chevron.left.forwardslash.chevron.right", 5),
    ("https://developer.apple.com/metal/", "link", 300),
    ("Meeting notes: canvas render engine phasing — textures first, shaders second", "doc.text", 1800),
    ("~/Documents/design-spec.pdf", "folder", 3600),
]

// MARK: - Canvas Preview Pane

/// The preview area showing the canvas with cards — used in the left pane of CanvasTuningView.
struct CanvasPreviewPane: View {
    @EnvironmentObject var tuning: CanvasTuningState

    @Binding var showPaintSim: Bool
    @Binding var showFiltered: Bool
    @Binding var paintedImage: NSImage?
    @Binding var isRendering: Bool
    @Binding var renderSize: CGSize
    @Binding var simElapsed: String
    let paintSimImages: [PaintRenderMode: NSImage]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if showPaintSim, let simImage = paintSimImages[tuning.simRenderMode] {
                    // GPU paint simulation output
                    Image(nsImage: simImage)
                        .resizable()
                        .interpolation(.high)
                } else if showFiltered, let painted = paintedImage {
                    // 3-layer composite
                    canvasBase
                    Image(nsImage: painted)
                        .interpolation(.high)
                    canvasCardLayout(mode: .textOnly)
                        .environmentObject(tuning)
                } else {
                    canvasPreview
                }

                    if isRendering {
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.black.opacity(0.2))
                    }

                    // Mode indicator
                    VStack {
                        Spacer()
                        HStack {
                            if showPaintSim {
                                Label("Paint Sim \(simElapsed)", systemImage: "paintpalette.fill")
                                    .font(.system(size: 10, weight: .medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                            } else if showFiltered {
                                Label("Filter applied", systemImage: "paintbrush.pointed.fill")
                                    .font(.system(size: 10, weight: .medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                            }
                            Spacer()
                        }
                        .padding(8)
                    }
                }
                .onChange(of: geo.size) { _, newSize in
                    // Auto-clear filter when window resizes (image would be wrong size)
                    if showFiltered && (abs(newSize.width - renderSize.width) > 2
                                     || abs(newSize.height - renderSize.height) > 2) {
                        showFiltered = false
                    }
                    renderSize = newSize
                }
                .onAppear { renderSize = geo.size }
            }
        }

    // MARK: - Canvas base (gradients + weave texture, NO impasto)

    private var canvasBase: some View {
        let _ = tuning.textureVersion
        return ZStack {
            LinearGradient(
                colors: [CanvasTheme.canvasBase, CanvasTheme.canvasEdge],
                startPoint: .top,
                endPoint: .bottom
            )

            // Crisp canvas weave (never filtered)
            Image(nsImage: CanvasTextureGenerator.shared.texture(
                threadWeight: tuning.config.background.textureThreadWeight,
                threadSpacing: tuning.config.background.textureThreadSpacing,
                appearance: .light
            ))
                .resizable(resizingMode: .tile)
                .blendMode(.multiply)
                .opacity(tuning.config.background.textureOpacity)

            RadialGradient(
                colors: [Color.orange.opacity(tuning.config.background.warmWashOpacity), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 500
            )
            RadialGradient(
                colors: [Color.indigo.opacity(tuning.config.background.coolWashOpacity), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 400
            )
        }
    }

    // MARK: - Canvas preview (full, live)

    private var canvasPreview: some View {
        ZStack {
            CanvasBackground()
            canvasCardLayout(mode: .full)
        }
        .environmentObject(tuning)
    }
}

// MARK: - Shared card layout

/// Single source of truth for card positions. The renderMode parameter
/// controls which sub-layers are visible — layout is always identical.
func canvasCardLayout(mode: StrokeCardRenderMode) -> some View {
    VStack(spacing: 0) {
        VStack(spacing: 4) {
            Text("KopiGajj")
                .font(CanvasTheme.titleFont)
                .foregroundStyle(mode == .chromeOnly ? .clear : .primary)
                .shadow(color: mode == .textOnly ? .white.opacity(0.8) : .clear, radius: 2)
            Text("Canvas Render Engine — Stage 0.5")
                .font(CanvasTheme.subtitleFont)
                .foregroundStyle(mode == .chromeOnly ? .clear : .secondary)
                .shadow(color: mode == .textOnly ? .white.opacity(0.6) : .clear, radius: 1)
        }
        .padding(.bottom, 12)

        VStack(spacing: 10) {
            ForEach(0..<canvasSampleItems.count, id: \.self) { i in
                let (content, icon, age) = canvasSampleItems[i]
                StrokeCard(content: content, typeIcon: icon, age: age,
                           cardIndex: i, renderMode: mode)
            }
        }
        .padding(.horizontal, 16)

        Spacer()
    }
    .padding(.top, 24)
}

// MARK: - Paintable layer (texture + impasto + card chrome — filter input)

/// The paintable layer used as Kuwahara filter input. Needs tuning as EnvironmentObject.
struct CanvasPaintableLayer: View {
    @EnvironmentObject var tuning: CanvasTuningState

    var body: some View {
        let _ = tuning.textureVersion
        let bg = tuning.config.background

        ZStack {
            // Impasto ovoid marks on transparent background (paint only, no weave)
            Image(nsImage: CanvasTextureGenerator.shared.impastoOverlay(
                impasto: .init(
                    count: bg.impastoMarkCount,
                    minWidth: bg.impastoMinWidth,
                    maxWidth: bg.impastoMaxWidth,
                    heightRatio: bg.impastoHeightRatio,
                    taper: bg.impastoTaper,
                    minAlpha: bg.impastoMinAlpha,
                    maxAlpha: bg.impastoMaxAlpha,
                    colorShift: bg.impastoColorShift,
                    highlight: bg.impastoHighlight,
                    rotation: bg.impastoRotation,
                    seed: bg.impastoSeed
                ),
                appearance: .light
            ))
                .resizable(resizingMode: .tile)

            // Card chrome (fills, borders, shadows — no text)
            canvasCardLayout(mode: .chromeOnly)
        }
    }
}
