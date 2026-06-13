import Metal
import AppKit
import SwiftUI

/// Paint simulation render modes — maps to GPU renderMode int.
enum PaintRenderMode: Int, CaseIterable, Identifiable {
    case lit      = 0   // Full lit color output
    case height   = 1   // Height map visualization
    case wetness  = 2   // Wetness channel
    case normals  = 3   // Surface normals
    case solid    = 4   // Solid color (no lighting)
    case wetOnly  = 5   // Wet paint only
    case mediaMap = 6   // Media type diagnostic overlay

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .lit:      return "Lit"
        case .height:   return "Height"
        case .wetness:  return "Wet"
        case .normals:  return "Normal"
        case .solid:    return "Solid"
        case .wetOnly:  return "Wet Only"
        case .mediaMap: return "Media"
        }
    }

    /// Short label for tuning view (subset of modes).
    var tuningLabel: String {
        switch self {
        case .lit:     return "Lit Color"
        case .height:  return "Height Map"
        case .wetness: return "Wetness"
        case .normals: return "Normals"
        default:       return label
        }
    }

    /// The 4 modes shown in the tuning view sim picker.
    static let tuningModes: [PaintRenderMode] = [.lit, .height, .wetness, .normals]
}

/// Available paint-style filters.
enum PaintFilterType: String, Codable, CaseIterable, Identifiable {
    case kuwahara            = "Kuwahara"
    case anisotropicKuwahara = "Anisotropic Kuwahara"
    case pointillize         = "Pointillize"
    case watercolor          = "Watercolor"
    case oilPaint            = "Oil Paint"
    case posterize           = "Posterize"
    case bilateral           = "Bilateral"
    case voronoiMosaic       = "Voronoi Mosaic"

    var id: String { rawValue }

    /// What param1 means for this filter.
    var param1Label: String {
        switch self {
        case .kuwahara:            return ""
        case .anisotropicKuwahara: return "Sharpness"
        case .pointillize:         return "Randomness"
        case .watercolor:          return "Edge Darkening"
        case .oilPaint:            return "Iterations"
        case .posterize:           return "Smoothing"
        case .bilateral:           return "Color Sigma"
        case .voronoiMosaic:       return "Border Width"
        }
    }

    /// What param2 means for this filter (empty = not used).
    var param2Label: String {
        switch self {
        case .watercolor:    return "Bleed"
        case .voronoiMosaic: return "Jitter"
        default:             return ""
        }
    }

    var param1Default: Double {
        switch self {
        case .anisotropicKuwahara: return 0.5
        case .pointillize:         return 0.3
        case .watercolor:          return 0.4
        case .oilPaint:            return 4.0
        case .posterize:           return 0.0
        case .bilateral:           return 0.15
        case .voronoiMosaic:       return 0.8
        default:                   return 0.5
        }
    }

    var param2Default: Double {
        switch self {
        case .watercolor:    return 0.3
        case .voronoiMosaic: return 0.5
        default:             return 0.5
        }
    }

    var param1Range: ClosedRange<Double> {
        switch self {
        case .oilPaint: return 1...20
        default:        return 0...1
        }
    }

    /// Kernel function name in the Metal source.
    var kernelName: String {
        switch self {
        case .kuwahara:            return "kuwaharaCompute"
        case .anisotropicKuwahara: return "anisotropicKuwaharaCompute"
        case .pointillize:         return "pointillizeCompute"
        case .watercolor:          return "watercolorCompute"
        case .oilPaint:            return "oilPaintCompute"
        case .posterize:           return "posterizeCompute"
        case .bilateral:           return "bilateralCompute"
        case .voronoiMosaic:       return "voronoiMosaicCompute"
        }
    }
}

/// Runtime-compiled Metal compute pipelines for paint-style filters.
final class CanvasMetalRenderer: MetalShaderCompiler, MetalTextureFactory {
    static let shared: CanvasMetalRenderer? = {
        guard let device = MTLCreateSystemDefaultDevice() else {
            NSLog("⚠️ No Metal device available")
            return nil
        }
        do {
            let renderer = try CanvasMetalRenderer(device: device)
            NSLog("✅ Metal compute pipelines ready (\(renderer.pipelines.count) filters)")
            return renderer
        } catch {
            NSLog("❌ Metal pipeline init failed: \(error)")
            return nil
        }
    }()

    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    private var pipelines: [String: MTLComputePipelineState] = [:]

    private init(device: MTLDevice) throws {
        self.device = device
        guard let queue = device.makeCommandQueue() else {
            throw RendererError.noCommandQueue
        }
        self.commandQueue = queue

        let filterNames = PaintFilterType.allCases.map(\.kernelName)
        self.pipelines = try compileComputePipelines(
            source: PaintShaderSource.allFilterShaderSource,
            functionNames: filterNames
        )
    }

    // MARK: - Unified filter API

    /// Apply any paint filter. Accepts Double to match config/SwiftUI layer;
    /// converts to Float internally for Metal shader uniforms.
    func applyFilter(
        _ type: PaintFilterType,
        to image: NSImage,
        radius: Double = 6.0,
        param1: Double = 0.5,
        param2: Double = 0.5
    ) -> NSImage? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let width = cgImage.width
        let height = cgImage.height
        guard let inputTexture = makeTexture(from: cgImage, usage: [.shaderRead]) else { return nil }

        // Double → Float for GPU uniforms
        let fRadius = Float(radius)
        let fParam1 = Float(param1)
        let fParam2 = Float(param2)

        // Oil paint needs multiple iterations (ping-pong)
        if type == .oilPaint {
            return applyMultiPass(iterations: max(1, Int(param1)), width: width, height: height,
                                  input: inputTexture, radius: fRadius, param1: fParam1, param2: fParam2)
        }

        guard let outputTexture = makeEmptyTexture(width: width, height: height, usage: [.shaderWrite]),
              let pipeline = pipelines[type.kernelName]
        else { return nil }

        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder()
        else { return nil }

        encoder.setComputePipelineState(pipeline)
        encoder.setTexture(inputTexture, index: 0)
        encoder.setTexture(outputTexture, index: 1)
        var r = fRadius; var p1 = fParam1; var p2 = fParam2
        encoder.setBytes(&r, length: MemoryLayout<Float>.size, index: 0)
        encoder.setBytes(&p1, length: MemoryLayout<Float>.size, index: 1)
        encoder.setBytes(&p2, length: MemoryLayout<Float>.size, index: 2)

        dispatch(encoder, width: width, height: height)
        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        return makeNSImage(from: outputTexture)
    }

    /// Backward-compat wrapper.
    func applyKuwahara(to image: NSImage, radius: Double = 6.0) -> NSImage? {
        applyFilter(.kuwahara, to: image, radius: radius)
    }

    // MARK: - Multi-pass (oil paint diffusion)

    private func applyMultiPass(iterations: Int, width: Int, height: Int,
                                input: MTLTexture, radius: Float, param1: Float, param2: Float) -> NSImage? {
        guard let pipeline = pipelines[PaintFilterType.oilPaint.kernelName] else { return nil }

        let texA = input
        let texB: MTLTexture? = makeEmptyTexture(width: width, height: height, usage: [.shaderRead, .shaderWrite])
        guard texB != nil else { return nil }

        // Need texA to also be writable for ping-pong after first pass
        let texAWrite: MTLTexture? = makeEmptyTexture(width: width, height: height, usage: [.shaderRead, .shaderWrite])
        guard texAWrite != nil else { return nil }

        // Copy input to writable texA
        guard let copyBuf = commandQueue.makeCommandBuffer(),
              let blit = copyBuf.makeBlitCommandEncoder() else { return nil }
        blit.copy(from: texA, sourceSlice: 0, sourceLevel: 0,
                  sourceOrigin: MTLOrigin(), sourceSize: MTLSize(width: width, height: height, depth: 1),
                  to: texAWrite!, destinationSlice: 0, destinationLevel: 0, destinationOrigin: MTLOrigin())
        blit.endEncoding()
        copyBuf.commit()
        copyBuf.waitUntilCompleted()

        var current = texAWrite!
        var next = texB!

        // Conductance derived from radius
        var r = radius
        var conductance = radius * 3.0
        var p2 = param2

        for _ in 0..<iterations {
            guard let buf = commandQueue.makeCommandBuffer(),
                  let enc = buf.makeComputeCommandEncoder() else { return nil }
            enc.setComputePipelineState(pipeline)
            enc.setTexture(current, index: 0)
            enc.setTexture(next, index: 1)
            enc.setBytes(&r, length: MemoryLayout<Float>.size, index: 0)
            enc.setBytes(&conductance, length: MemoryLayout<Float>.size, index: 1)
            enc.setBytes(&p2, length: MemoryLayout<Float>.size, index: 2)
            dispatch(enc, width: width, height: height)
            enc.endEncoding()
            buf.commit()
            buf.waitUntilCompleted()
            swap(&current, &next)
        }

        return makeNSImage(from: current)
    }

    // MARK: - Helpers

    private func dispatch(_ encoder: MTLComputeCommandEncoder, width: Int, height: Int) {
        let tg = MTLSize(width: 16, height: 16, depth: 1)
        let groups = MTLSize(width: (width + 15) / 16, height: (height + 15) / 16, depth: 1)
        encoder.dispatchThreadgroups(groups, threadsPerThreadgroup: tg)
    }

    private func makeTexture(from cgImage: CGImage, usage: MTLTextureUsage) -> MTLTexture? {
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 4
        guard let texture = makeTexture2D(
            width: width, height: height, pixelFormat: .rgba8Unorm,
            usage: usage, storageMode: .managed
        ) else { return nil }

        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
        guard let ctx = CGContext(data: &pixels, width: width, height: height,
                                  bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { return nil }
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        texture.replace(region: MTLRegion(origin: MTLOrigin(),
                                          size: MTLSize(width: width, height: height, depth: 1)),
                        mipmapLevel: 0, withBytes: pixels, bytesPerRow: bytesPerRow)
        return texture
    }

    private func makeEmptyTexture(width: Int, height: Int, usage: MTLTextureUsage) -> MTLTexture? {
        makeTexture2D(width: width, height: height, pixelFormat: .rgba8Unorm,
                      usage: usage, storageMode: .managed)
    }

    private func makeNSImage(from texture: MTLTexture) -> NSImage? {
        let width = texture.width
        let height = texture.height
        let bytesPerRow = width * 4
        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
        texture.getBytes(&pixels, bytesPerRow: bytesPerRow,
                         from: MTLRegion(origin: MTLOrigin(),
                                         size: MTLSize(width: width, height: height, depth: 1)),
                         mipmapLevel: 0)
        guard let ctx = CGContext(data: &pixels, width: width, height: height,
                                  bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let cgImage = ctx.makeImage()
        else { return nil }
        return NSImage(cgImage: cgImage, size: NSSize(width: width, height: height))
    }

    enum RendererError: Error {
        case noCommandQueue
    }

}
