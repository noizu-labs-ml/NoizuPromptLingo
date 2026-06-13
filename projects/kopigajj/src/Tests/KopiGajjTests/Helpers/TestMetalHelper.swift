import XCTest
import Metal
@testable import KopiGajj

/// Shared Metal device + texture readback utilities for GPU tests.
final class TestMetalHelper {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    private init(device: MTLDevice, commandQueue: MTLCommandQueue) {
        self.device = device
        self.commandQueue = commandQueue
    }

    /// Returns a helper or throws XCTSkip when no GPU is available.
    static func requireDevice(file: StaticString = #file, line: UInt = #line) throws -> TestMetalHelper {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw XCTSkip("No Metal device available")
        }
        guard let queue = device.makeCommandQueue() else {
            throw XCTSkip("Failed to create Metal command queue")
        }
        return TestMetalHelper(device: device, commandQueue: queue)
    }

    // MARK: - Readback helpers

    /// Read a single pixel from an rgba8Unorm texture (must be .managed or .shared).
    /// For .private textures, use `readbackRGBA8` which does a blit copy first.
    func readPixelRGBA8(from texture: MTLTexture, x: Int, y: Int) -> (r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        var pixel: [UInt8] = [0, 0, 0, 0]
        let region = MTLRegion(origin: MTLOrigin(x: x, y: y, z: 0),
                               size: MTLSize(width: 1, height: 1, depth: 1))
        texture.getBytes(&pixel, bytesPerRow: 4, from: region, mipmapLevel: 0)
        return (pixel[0], pixel[1], pixel[2], pixel[3])
    }

    /// Read a single pixel from a .private rgba8Unorm texture via blit copy.
    func readbackRGBA8(from texture: MTLTexture, x: Int, y: Int) -> (r: UInt8, g: UInt8, b: UInt8, a: UInt8)? {
        guard let staging = makeManagedTexture(matching: texture) else { return nil }
        blitCopy(from: texture, to: staging)

        var pixel: [UInt8] = [0, 0, 0, 0]
        let region = MTLRegion(origin: MTLOrigin(x: x, y: y, z: 0),
                               size: MTLSize(width: 1, height: 1, depth: 1))
        staging.getBytes(&pixel, bytesPerRow: 4, from: region, mipmapLevel: 0)
        return (pixel[0], pixel[1], pixel[2], pixel[3])
    }

    /// Read a single pixel (4 floats) from a .private rgba16Float texture via blit copy.
    func readbackFloat4(from texture: MTLTexture, x: Int, y: Int) -> (r: Float, g: Float, b: Float, a: Float)? {
        guard let staging = makeManagedTexture(matching: texture) else { return nil }
        blitCopy(from: texture, to: staging)

        // rgba16Float = 8 bytes per pixel (4 × Float16)
        var halfs: [UInt16] = [0, 0, 0, 0]
        let region = MTLRegion(origin: MTLOrigin(x: x, y: y, z: 0),
                               size: MTLSize(width: 1, height: 1, depth: 1))
        staging.getBytes(&halfs, bytesPerRow: 8, from: region, mipmapLevel: 0)
        return (float16ToFloat32(halfs[0]), float16ToFloat32(halfs[1]),
                float16ToFloat32(halfs[2]), float16ToFloat32(halfs[3]))
    }

    /// Read a single pixel (1 float) from a .private r32Float texture via blit copy.
    func readbackFloat(from texture: MTLTexture, x: Int, y: Int) -> Float? {
        guard let staging = makeManagedTexture(matching: texture) else { return nil }
        blitCopy(from: texture, to: staging)

        var value: Float = 0
        let region = MTLRegion(origin: MTLOrigin(x: x, y: y, z: 0),
                               size: MTLSize(width: 1, height: 1, depth: 1))
        staging.getBytes(&value, bytesPerRow: 4, from: region, mipmapLevel: 0)
        return value
    }

    // MARK: - Internal

    private func makeManagedTexture(matching source: MTLTexture) -> MTLTexture? {
        let desc = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: source.pixelFormat,
            width: source.width,
            height: source.height,
            mipmapped: false
        )
        desc.usage = [.shaderWrite]
        desc.storageMode = .managed
        return device.makeTexture(descriptor: desc)
    }

    private func blitCopy(from source: MTLTexture, to destination: MTLTexture) {
        guard let buf = commandQueue.makeCommandBuffer(),
              let blit = buf.makeBlitCommandEncoder() else { return }
        blit.copy(from: source, sourceSlice: 0, sourceLevel: 0,
                  sourceOrigin: MTLOrigin(),
                  sourceSize: MTLSize(width: source.width, height: source.height, depth: 1),
                  to: destination, destinationSlice: 0, destinationLevel: 0,
                  destinationOrigin: MTLOrigin())
        blit.synchronize(resource: destination)
        blit.endEncoding()
        buf.commit()
        buf.waitUntilCompleted()
    }

    /// Convert IEEE 754 half-precision (Float16) to Float32.
    private func float16ToFloat32(_ h: UInt16) -> Float {
        let sign     = UInt32(h >> 15) & 0x1
        let exponent = UInt32(h >> 10) & 0x1F
        let mantissa = UInt32(h)       & 0x3FF

        var f: UInt32
        if exponent == 0 {
            if mantissa == 0 {
                f = sign << 31  // ±0
            } else {
                // Denormalized
                var e = exponent
                var m = mantissa
                while (m & 0x400) == 0 { m <<= 1; e &-= 1 }
                e += 1; m &= 0x3FF
                f = (sign << 31) | ((e + 112) << 23) | (m << 13)
            }
        } else if exponent == 31 {
            f = (sign << 31) | 0x7F800000 | (mantissa << 13)  // Inf/NaN
        } else {
            f = (sign << 31) | ((exponent + 112) << 23) | (mantissa << 13)
        }
        return Float(bitPattern: f)
    }
}
