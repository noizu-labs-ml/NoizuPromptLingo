import SwiftUI
import AppKit

// MARK: - Left pane mode

/// Left pane mode toggle between preview and interactive painting.
private enum PaneMode: String, CaseIterable {
    case preview = "Preview"
    case paint = "Paint"
}

// MARK: - Main Tuning View

struct CanvasTuningView: View {
    @StateObject private var tuning = CanvasTuningState()
    @State private var paintedImage: NSImage?
    @State private var isRendering = false
    @State private var showFiltered = false
    @State private var renderSize: CGSize = .zero

    // Paint simulation
    @State private var paintSimImages: [PaintRenderMode: NSImage] = [:]
    @State private var showPaintSim = false
    @State private var isSimulating = false
    @State private var simElapsed: String = ""

    // Interactive painting
    @State private var paneMode: PaneMode = .preview
    @StateObject private var paintState = PaintCanvasState()

    // Config management
    @State private var savedConfigs: [String] = []
    @State private var selectedConfig: String = defaultThemeName
    @State private var newConfigName: String = ""
    @State private var showSaveField = false

    /// The baseline config — per-slider reset returns to these values.
    @State private var baselineConfig: CanvasConfig = .default

    let onClose: () -> Void

    private let previewWidth: CGFloat = 420
    private let previewHeight: CGFloat = 520

    var body: some View {
        HStack(spacing: 0) {
            // Left pane
            VStack(spacing: 0) {
                // Mode tabs
                Picker("", selection: $paneMode) {
                    ForEach(PaneMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 4)

                // Content
                if paneMode == .paint {
                    CanvasInteractivePaintPane(paintState: paintState)
                } else {
                    CanvasPreviewPane(
                        showPaintSim: $showPaintSim,
                        showFiltered: $showFiltered,
                        paintedImage: $paintedImage,
                        isRendering: $isRendering,
                        renderSize: $renderSize,
                        simElapsed: $simElapsed,
                        paintSimImages: paintSimImages
                    )
                }
            }
            .frame(minWidth: 360, idealWidth: previewWidth, minHeight: 460, idealHeight: previewHeight)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Right: Slider panel (shows brush controls when in paint mode)
            if paneMode == .paint {
                CanvasPaintControlPanel(paintState: paintState, onClose: onClose)
                    .frame(minWidth: 320, idealWidth: 380)
            } else {
                CanvasTuningSliders(
                    baselineConfig: baselineConfig,
                    onClose: onClose,
                    showFiltered: $showFiltered,
                    isRendering: $isRendering,
                    showPaintSim: $showPaintSim,
                    isSimulating: $isSimulating,
                    simElapsed: $simElapsed,
                    paintSimImages: $paintSimImages,
                    savedConfigs: $savedConfigs,
                    selectedConfig: $selectedConfig,
                    newConfigName: $newConfigName,
                    showSaveField: $showSaveField,
                    baselineConfigBinding: $baselineConfig,
                    onRenderFilter: renderFilter,
                    onRunPaintSim: runPaintSim,
                    onResetToTheme: resetToTheme,
                    onLoadTheme: loadTheme,
                    onSaveNewConfig: saveNewConfig,
                    onRefreshConfigList: refreshConfigList
                )
                .frame(minWidth: 320, idealWidth: 380)
            }
        }
        .environmentObject(tuning)
        .onAppear {
            ensureDefaultThemeExists()
            refreshConfigList()
        }
    }

    // MARK: - Config management

    private func refreshConfigList() {
        savedConfigs = refreshedConfigList()
    }

    private func loadTheme(_ name: String) {
        guard let config = CanvasConfigStore.load(name) else { return }
        tuning.apply(config)
        baselineConfig = config
        showFiltered = false
    }

    private func saveNewConfig() {
        let name = newConfigName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        try? CanvasConfigStore.save(tuning.asConfig, name: name)
        refreshConfigList()
        selectedConfig = name
        baselineConfig = tuning.asConfig
        newConfigName = ""
        showSaveField = false
    }

    private func resetToTheme() {
        tuning.apply(baselineConfig)
        showFiltered = false
        showPaintSim = false
        paintSimImages = [:]
    }

    // MARK: - Paint simulation

    @MainActor
    private func runPaintSim() {
        guard CanvasTheme.metalAvailable else { return }
        isSimulating = true
        showPaintSim = false

        // Config uses Double; convert to Float here at the Metal boundary
        let s = tuning.config.sim
        let strokeCount = s.simStrokeCount
        let seed = UInt64(s.simSeed)
        let ridgeHeight = Float(s.simRidgeHeight)
        let weaveScale = Float(s.simWeaveScale)
        let flowSteps = s.simFlowSteps
        let drySteps = s.simDrySteps
        let flowStrength = Float(s.simFlowStrength)
        let diffusionRate = Float(s.simDiffusionRate)
        let dryRate = Float(s.simDryRate)
        let lightAz = Float(s.simLightAzimuth)
        let lightEl = Float(s.simLightElevation)
        let ambient = Float(s.simAmbient)
        let specular = Float(s.simSpecular)
        let heightScale = Float(s.simHeightScale)
        let renderMode = tuning.simRenderMode

        Task.detached {
            let start = CFAbsoluteTimeGetCurrent()
            do {
                let sim = try PaintSimulator(width: 1024, height: 1024)
                let strokes = ProceduralStrokes.generateBackground(
                    fieldSize: 1024, strokeCount: strokeCount, seed: seed
                )
                sim.initCanvas(spacing: weaveScale, ridgeHeight: ridgeHeight, seed: UInt32(seed))

                for stroke in strokes {
                    let metalPoints = stroke.points.map { $0.asBrushPoint }
                    sim.applyStroke(metalPoints, mode: stroke.mode)
                    sim.simulate(flowSteps: flowSteps, drySteps: drySteps,
                                 flowStrength: flowStrength, diffusionRate: diffusionRate,
                                 dryRate: dryRate)
                }

                // Render the currently selected mode first (show immediately)
                let primaryImage = sim.render(
                    lightAzimuth: lightAz, lightElevation: lightEl,
                    ambient: ambient, specular: specular,
                    heightScale: heightScale,
                    renderMode: Int32(renderMode.rawValue)
                )

                let elapsed = CFAbsoluteTimeGetCurrent() - start
                let elapsedStr = String(format: "%.0fms", elapsed * 1000)

                await MainActor.run {
                    if let primaryImage {
                        paintSimImages[renderMode] = primaryImage
                        showPaintSim = true
                        simElapsed = elapsedStr
                    }
                    isSimulating = false
                }

                // Render remaining modes in background
                for mode in PaintRenderMode.tuningModes where mode != renderMode {
                    let img = sim.render(
                        lightAzimuth: lightAz, lightElevation: lightEl,
                        ambient: ambient, specular: specular,
                        heightScale: heightScale,
                        renderMode: Int32(mode.rawValue)
                    )
                    await MainActor.run {
                        if let img { paintSimImages[mode] = img }
                    }
                }
            } catch {
                NSLog("Paint sim failed: \(error)")
                await MainActor.run { isSimulating = false }
            }
        }
    }

    // MARK: - Filter rendering

    @MainActor
    private func renderFilter() {
        guard let renderer = CanvasMetalRenderer.shared, tuning.config.filter.filterEnabled else { return }
        isRendering = true

        // Render paintable layer at the ACTUAL current preview size
        let w = renderSize.width > 10 ? renderSize.width : previewWidth
        let h = renderSize.height > 10 ? renderSize.height : previewHeight
        let imageRenderer = ImageRenderer(content:
            CanvasPaintableLayer()
                .environmentObject(tuning)
                .frame(width: w, height: h)
        )
        imageRenderer.scale = 1.0

        guard let captured = imageRenderer.nsImage else {
            isRendering = false
            return
        }

        let filterType = tuning.config.filter.filterType
        let radius = tuning.config.filter.filterRadius
        let p1 = tuning.config.filter.filterParam1
        let p2 = tuning.config.filter.filterParam2
        Task.detached {
            let filtered = renderer.applyFilter(filterType, to: captured, radius: radius, param1: p1, param2: p2)
            await MainActor.run {
                if let filtered {
                    paintedImage = filtered
                    showFiltered = true
                }
                isRendering = false
            }
        }
    }
}
