import Metal

/// Protocol for creating Metal textures with common configurations.
protocol MetalTextureFactory {
    var device: MTLDevice { get }
}

extension MetalTextureFactory {

    /// Create an empty 2D texture with the given format, size, usage, and storage mode.
    func makeTexture2D(
        width: Int,
        height: Int,
        pixelFormat: MTLPixelFormat,
        usage: MTLTextureUsage = [.shaderRead, .shaderWrite],
        storageMode: MTLStorageMode = .private
    ) -> MTLTexture? {
        Self.makeTexture2D(device: device, width: width, height: height,
                           pixelFormat: pixelFormat, usage: usage, storageMode: storageMode)
    }

    /// Create an empty 2D texture, throwing on failure.
    func makeTexture2DOrThrow(
        width: Int,
        height: Int,
        pixelFormat: MTLPixelFormat,
        usage: MTLTextureUsage = [.shaderRead, .shaderWrite],
        storageMode: MTLStorageMode = .private
    ) throws -> MTLTexture {
        try Self.makeTexture2DOrThrow(device: device, width: width, height: height,
                                      pixelFormat: pixelFormat, usage: usage, storageMode: storageMode)
    }

    /// Static variant usable before `self` is fully initialized.
    static func makeTexture2D(
        device: MTLDevice,
        width: Int,
        height: Int,
        pixelFormat: MTLPixelFormat,
        usage: MTLTextureUsage = [.shaderRead, .shaderWrite],
        storageMode: MTLStorageMode = .private
    ) -> MTLTexture? {
        let desc = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: pixelFormat, width: width, height: height, mipmapped: false
        )
        desc.usage = usage
        desc.storageMode = storageMode
        return device.makeTexture(descriptor: desc)
    }

    /// Static variant usable before `self` is fully initialized.
    static func makeTexture2DOrThrow(
        device: MTLDevice,
        width: Int,
        height: Int,
        pixelFormat: MTLPixelFormat,
        usage: MTLTextureUsage = [.shaderRead, .shaderWrite],
        storageMode: MTLStorageMode = .private
    ) throws -> MTLTexture {
        guard let tex = makeTexture2D(device: device, width: width, height: height,
                                      pixelFormat: pixelFormat, usage: usage, storageMode: storageMode) else {
            throw MetalTextureError.allocationFailed
        }
        return tex
    }
}

enum MetalTextureError: Error {
    case allocationFailed
}
