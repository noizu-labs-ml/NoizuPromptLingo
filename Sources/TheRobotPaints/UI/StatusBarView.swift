import SwiftUI

struct StatusBarView: View {
    let canvasWidth: Int
    let canvasHeight: Int
    var zoomPercent: Int
    var activeLayerName: String
    var activeMediaType: MediaType
    @Binding var simSpeed: Float

    var body: some View {
        HStack(spacing: 16) {
            Text("\(canvasWidth) x \(canvasHeight)")
                .font(.caption.monospaced())

            Divider().frame(height: 12)

            Text("Zoom: \(zoomPercent)%")
                .font(.caption.monospaced())

            Divider().frame(height: 12)

            Text("\(activeLayerName) (\(mediaName))")
                .font(.caption)

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption2)
                Slider(value: $simSpeed, in: 0...5, step: 0.1)
                    .frame(width: 80)
                Text(simSpeedLabel)
                    .font(.caption.monospaced())
                    .frame(width: 36, alignment: .trailing)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var mediaName: String {
        switch activeMediaType {
        case .watercolor: return "Watercolor"
        case .oil: return "Oil"
        case .acrylic: return "Acrylic"
        case .charcoal: return "Charcoal"
        case .pastel: return "Pastel"
        }
    }

    private var simSpeedLabel: String {
        if simSpeed < 0.05 { return "Pause" }
        return String(format: "%.1fx", simSpeed)
    }
}
