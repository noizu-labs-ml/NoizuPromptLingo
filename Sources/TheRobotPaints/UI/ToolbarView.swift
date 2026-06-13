import SwiftUI

struct ToolbarView: View {
    @Binding var activeTool: ActiveTool
    @Binding var brushSize: Float
    @Binding var brushOpacity: Float
    @Binding var brushColor: Color
    @Binding var mediaType: MediaType
    @Binding var zoomPercent: Int

    private let tools: [(tool: ActiveTool, icon: String, label: String, key: KeyEquivalent)] = [
        (.brush, "paintbrush.fill", "Brush (B)", "b"),
        (.eraser, "eraser.fill", "Eraser (E)", "e"),
        (.water, "drop.fill", "Water (W)", "w"),
        (.pan, "hand.raised.fill", "Pan (H)", "h"),
        (.zoom, "magnifyingglass", "Zoom (Z)", "z"),
    ]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(tools, id: \.tool) { item in
                Button {
                    activeTool = item.tool
                } label: {
                    Image(systemName: item.icon)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.bordered)
                .tint(activeTool == item.tool ? .accentColor : .secondary)
                .help(item.label)
                .keyboardShortcut(item.key, modifiers: [])
            }

            Divider().frame(height: 20)

            Picker("", selection: $mediaType) {
                ForEach(MediaType.allCases, id: \.self) { media in
                    Text(MediaRegistry.definition(for: media).displayName).tag(media)
                }
            }
            .frame(width: 110)

            Divider().frame(height: 20)

            HStack(spacing: 4) {
                Text("Size")
                    .font(.caption)
                    .frame(width: 28, alignment: .trailing)
                Slider(value: $brushSize, in: 1...200)
                    .frame(width: 120)
                Text("\(Int(brushSize))")
                    .font(.caption)
                    .frame(width: 24)
            }

            Divider().frame(height: 20)

            HStack(spacing: 4) {
                Text("Opacity")
                    .font(.caption)
                    .frame(width: 44, alignment: .trailing)
                Slider(value: $brushOpacity, in: 0...1)
                    .frame(width: 100)
            }

            Divider().frame(height: 20)
            ColorPicker("", selection: $brushColor, supportsOpacity: false)
                .frame(width: 30)
                .help("Brush Color")

            Divider().frame(height: 20)

            HStack(spacing: 4) {
                Image(systemName: "magnifyingglass")
                    .font(.caption2)
                Slider(value: zoomBinding, in: 10...3200)
                    .frame(width: 80)
                Text("\(zoomPercent)%")
                    .font(.caption.monospaced())
                    .frame(width: 44)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

extension ToolbarView {
    var zoomBinding: Binding<Float> {
        Binding(
            get: { Float(zoomPercent) },
            set: { zoomPercent = max(10, min(3200, Int($0))) }
        )
    }
}

extension ActiveTool: Hashable {}
