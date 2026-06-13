import SwiftUI

struct LayerPanelView: View {
    @Bindable var layerManager: LayerManager

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Layers")
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.top, 6)

            ForEach(0..<VolumeLayer.layerCount, id: \.self) { index in
                layerRow(index: index)
            }

            Divider()

            HStack(spacing: 8) {
                Button("Clear") {
                    layerManager.clearLayer(layerManager.activeLayer)
                }
                .font(.caption)
                .buttonStyle(.bordered)
                .controlSize(.small)

                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 6)
        }
        .frame(width: 160)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private func layerRow(index: Int) -> some View {
        HStack(spacing: 4) {
            Button {
                layerManager.toggleVisibility(index)
            } label: {
                Image(systemName: layerManager.isVisible(index) ? "eye.fill" : "eye.slash")
                    .font(.caption2)
                    .frame(width: 16)
            }
            .buttonStyle(.plain)

            Text("\(index + 1)")
                .font(.caption.monospaced())
                .frame(width: 14)

            mediaBadge(for: index)

            Text(layerManager.layers[index].name)
                .font(.caption)
                .lineLimit(1)

            Spacer()

            if layerManager.layers[index].isWet {
                Circle()
                    .fill(.blue)
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(layerManager.activeLayer == index ? Color.accentColor.opacity(0.2) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            layerManager.setActive(index)
        }
    }

    private func mediaBadge(for index: Int) -> some View {
        let badge: String = {
            switch layerManager.layers[index].mediaType {
            case .watercolor: return "W"
            case .oil: return "O"
            case .acrylic: return "A"
            case .charcoal: return "C"
            case .pastel: return "P"
            }
        }()
        return Text(badge)
            .font(.system(size: 8, weight: .bold, design: .monospaced))
            .foregroundStyle(.secondary)
            .frame(width: 12)
    }
}
