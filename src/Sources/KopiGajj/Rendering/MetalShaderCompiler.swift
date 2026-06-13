import Metal

/// Protocol for compiling Metal shaders from source strings into compute pipeline states.
protocol MetalShaderCompiler {
    var device: MTLDevice { get }
}

extension MetalShaderCompiler {

    /// Compile a single compute kernel from Metal source code.
    /// source string -> MTLLibrary -> MTLFunction -> MTLComputePipelineState
    func compileComputePipeline(source: String, functionName: String) throws -> MTLComputePipelineState {
        try Self.compileComputePipeline(device: device, source: source, functionName: functionName)
    }

    /// Compile multiple compute kernels from a single Metal source string.
    /// Returns a dictionary mapping function names to pipeline states.
    func compileComputePipelines(source: String, functionNames: [String]) throws -> [String: MTLComputePipelineState] {
        try Self.compileComputePipelines(device: device, source: source, functionNames: functionNames)
    }

    /// Static variant usable before `self` is fully initialized.
    static func compileComputePipeline(device: MTLDevice, source: String, functionName: String) throws -> MTLComputePipelineState {
        let library = try device.makeLibrary(source: source, options: nil)
        guard let fn = library.makeFunction(name: functionName) else {
            throw MetalShaderError.functionNotFound(functionName)
        }
        return try device.makeComputePipelineState(function: fn)
    }

    /// Static variant usable before `self` is fully initialized.
    static func compileComputePipelines(device: MTLDevice, source: String, functionNames: [String]) throws -> [String: MTLComputePipelineState] {
        let library = try device.makeLibrary(source: source, options: nil)
        var pipelines: [String: MTLComputePipelineState] = [:]
        for name in functionNames {
            guard let fn = library.makeFunction(name: name) else {
                throw MetalShaderError.functionNotFound(name)
            }
            pipelines[name] = try device.makeComputePipelineState(function: fn)
        }
        return pipelines
    }
}

enum MetalShaderError: Error {
    case functionNotFound(String)
}
