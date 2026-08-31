import SwiftUI

/// Quiet overlay while the local toolkit process comes up. No server list,
/// no "web" vs API — the window is the product.
struct StartingOverlay: View {
    var body: some View {
        VStack(spacing: 14) {
            WatchdogCompanionMark(size: 72)
            ProgressView()
                .controlSize(.small)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Nocturne.surface)
    }
}
