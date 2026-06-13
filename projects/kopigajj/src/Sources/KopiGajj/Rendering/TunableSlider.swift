import SwiftUI

// MARK: - Info Popover Button

/// Small info button that shows a popover with the description on click.
struct InfoButton: View {
    let text: String
    @State private var showing = false

    var body: some View {
        Button {
            showing.toggle()
        } label: {
            Image(systemName: "info.circle")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.borderless)
        .popover(isPresented: $showing, arrowEdge: .trailing) {
            Text(text)
                .font(.system(size: 12))
                .padding(10)
                .frame(maxWidth: 240)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Tunable Slider Row

struct TunableSlider: View {
    let label: String
    let desc: String
    @Binding var value: Double
    let baseline: Double
    let range: ClosedRange<Double>
    let format: String

    init(_ label: String, desc: String, value: Binding<Double>,
         baseline: Double, range: ClosedRange<Double>,
         format: String = "%.3f") {
        self.label = label
        self.desc = desc
        self._value = value
        self.baseline = baseline
        self.range = range
        self.format = format
    }

    private var isBaseline: Bool {
        abs(value - baseline) < 0.001
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))

                InfoButton(text: desc)

                Spacer()

                Text(String(format: format, value))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(isBaseline ? .secondary : .primary)

                if !isBaseline {
                    Text("(\(String(format: format, baseline)))")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.quaternary)
                }

                Button {
                    withAnimation(.easeOut(duration: 0.15)) { value = baseline }
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 9))
                }
                .buttonStyle(.borderless)
                .disabled(isBaseline)
            }
            Slider(value: $value, in: range)
                .controlSize(.small)
        }
    }
}

/// Integer version of TunableSlider.
struct TunableIntSlider: View {
    let label: String
    let desc: String
    @Binding var value: Int
    let baseline: Int
    let range: ClosedRange<Int>

    private var isBaseline: Bool { value == baseline }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))

                InfoButton(text: desc)

                Spacer()

                Text("\(value)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(isBaseline ? .secondary : .primary)

                if !isBaseline {
                    Text("(\(baseline))")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.quaternary)
                }

                Button {
                    withAnimation(.easeOut(duration: 0.15)) { value = baseline }
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 9))
                }
                .buttonStyle(.borderless)
                .disabled(isBaseline)
            }
            Slider(value: Binding(
                get: { Double(value) },
                set: { value = Int($0) }
            ), in: Double(range.lowerBound)...Double(range.upperBound), step: 1)
                .controlSize(.small)
        }
    }
}

// MARK: - Section Header

func tuningSectionHeader(_ title: String, desc: String) -> some View {
    HStack(spacing: 4) {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
        InfoButton(text: desc)
    }
}
