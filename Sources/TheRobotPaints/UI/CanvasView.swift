import SwiftUI

struct CanvasView: View {
    @State private var lightDirX: Float = 0.3
    @State private var lightDirY: Float = 0.5
    @State private var lightDirZ: Float = 0.8

    @State private var activeTool: ActiveTool = .brush
    @State private var brushSize: Float = 20.0
    @State private var brushOpacity: Float = 1.0
    @State private var brushColor: Color = Color(red: 0.6, green: 0.15, blue: 0.08)
    @State private var mediaType: MediaType = .watercolor
    @State private var showLayerPanel: Bool = true
    @State private var showLightControls: Bool = false

    @State private var layerManager = LayerManager()
    @State private var zoomPercent: Int = 100
    @State private var simSpeed: Float = 1.0

    var body: some View {
        VStack(spacing: 0) {
            ToolbarView(
                activeTool: $activeTool,
                brushSize: $brushSize,
                brushOpacity: $brushOpacity,
                brushColor: $brushColor,
                mediaType: $mediaType,
                zoomPercent: $zoomPercent
            )

            HStack(spacing: 0) {
                if showLayerPanel {
                    LayerPanelView(layerManager: layerManager)
                        .transition(.move(edge: .leading))
                }

                MetalView(
                    lightDirX: lightDirX,
                    lightDirY: lightDirY,
                    lightDirZ: lightDirZ,
                    activeTool: $activeTool,
                    brushSize: $brushSize,
                    brushOpacity: $brushOpacity,
                    brushColor: $brushColor,
                    mediaType: $mediaType,
                    simSpeed: $simSpeed,
                    layerManager: layerManager,
                    zoomPercent: $zoomPercent
                )
                .frame(minWidth: 600, minHeight: 400)
            }

            StatusBarView(
                canvasWidth: 2048,
                canvasHeight: 1536,
                zoomPercent: zoomPercent,
                activeLayerName: layerManager.layers[layerManager.activeLayer].name,
                activeMediaType: layerManager.layers[layerManager.activeLayer].mediaType,
                simSpeed: $simSpeed
            )

            if showLightControls {
                VStack(spacing: 8) {
                    HStack {
                        Text("Light X")
                            .frame(width: 60, alignment: .trailing)
                        Slider(value: $lightDirX, in: -1...1)
                    }
                    HStack {
                        Text("Light Y")
                            .frame(width: 60, alignment: .trailing)
                        Slider(value: $lightDirY, in: -1...1)
                    }
                    HStack {
                        Text("Light Z")
                            .frame(width: 60, alignment: .trailing)
                        Slider(value: $lightDirZ, in: 0.1...1)
                    }
                }
                .padding(12)
                .background(Color(nsColor: .controlBackgroundColor))
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showLayerPanel.toggle()
                    }
                } label: {
                    Image(systemName: "sidebar.left")
                }
                .help("Toggle Layer Panel")
            }
            ToolbarItem {
                Button {
                    showLightControls.toggle()
                } label: {
                    Image(systemName: "light.max")
                }
                .help("Toggle Light Controls")
            }
        }
    }
}
