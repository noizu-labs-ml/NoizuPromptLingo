import XCTest
import Metal

struct TestMetalHelper: Sendable {
    let device: MTLDevice

    static func requireDevice() throws -> TestMetalHelper {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw XCTSkip("Metal is not available on this device")
        }
        return TestMetalHelper(device: device)
    }
}
