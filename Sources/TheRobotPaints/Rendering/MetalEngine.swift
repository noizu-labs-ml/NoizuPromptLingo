import Metal

final class MetalEngine: @unchecked Sendable {
    static let shared = MetalEngine()

    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    private init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }
        self.device = device
        guard let queue = device.makeCommandQueue() else {
            fatalError("Failed to create Metal command queue")
        }
        self.commandQueue = queue
    }

    func compilePipeline(source: String, functionName: String) throws -> MTLComputePipelineState {
        try Self.compilePipeline(device: device, source: source, functionName: functionName)
    }

    static func compilePipeline(device: MTLDevice, source: String, functionName: String) throws -> MTLComputePipelineState {
        let library = try device.makeLibrary(source: source, options: nil)
        guard let fn = library.makeFunction(name: functionName) else {
            throw ShaderError.functionNotFound(functionName)
        }
        return try device.makeComputePipelineState(function: fn)
    }

    func makeTexture(width: Int, height: Int, pixelFormat: MTLPixelFormat,
                     usage: MTLTextureUsage = [.shaderRead, .shaderWrite],
                     storageMode: MTLStorageMode = .private) -> MTLTexture? {
        let desc = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: pixelFormat, width: width, height: height, mipmapped: false)
        desc.usage = usage
        desc.storageMode = storageMode
        return device.makeTexture(descriptor: desc)
    }

    enum ShaderError: Error, Sendable {
        case functionNotFound(String)
    }
}
