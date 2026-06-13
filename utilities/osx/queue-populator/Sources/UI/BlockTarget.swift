import AppKit

final class BlockTarget: NSObject {
    private let block: () -> Void
    init(_ block: @escaping () -> Void) { self.block = block }
    @objc func invoke() { block() }
}
