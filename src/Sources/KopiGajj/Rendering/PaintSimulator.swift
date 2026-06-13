import Metal
import AppKit
import Foundation

/// Orchestrates the paint simulation pipeline.
/// Architecture: Canvas (height+material) → Solid (dried) → Wet (active, double-buffered)
final class PaintSimulator: MetalShaderCompiler, MetalTextureFactory {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let field: PaintField

    private let canvasInitPipeline: MTLComputePipelineState
    private let brushStrokePipeline: MTLComputePipelineState
    private let flowStepPipeline: MTLComputePipelineState
    private let dryStepPipeline: MTLComputePipelineState
    private let renderPipeline: MTLComputePipelineState

    private let threadgroupSize = MTLSize(width: 16, height: 16, depth: 1)

    init(width: Int = 1024, height: Int = 1024) throws {
        guard let device = MTLCreateSystemDefaultDevice() else { throw SimError.noDevice }
        self.device = device
        guard let queue = device.makeCommandQueue() else { throw SimError.noQueue }
        self.commandQueue = queue
        self.field = try PaintField(device: device, width: width, height: height)

        self.canvasInitPipeline  = try Self.compileComputePipeline(device: device, source: PaintShaderSource.canvasInit, functionName: "canvasInit")
        self.brushStrokePipeline = try Self.compileComputePipeline(device: device, source: PaintShaderSource.brushStroke, functionName: "brushStroke")
        self.flowStepPipeline    = try Self.compileComputePipeline(device: device, source: PaintShaderSource.flowStep, functionName: "flowStep")
        self.dryStepPipeline     = try Self.compileComputePipeline(device: device, source: PaintShaderSource.dryStep, functionName: "dryStep")
        self.renderPipeline      = try Self.compileComputePipeline(device: device, source: PaintShaderSource.render, functionName: "paintRender")

        NSLog("✅ Paint simulator ready (\(width)×\(height), 5 kernels, solid+wet layers)")
    }

    private var threadgroups: MTLSize {
        MTLSize(width: (field.width + 15) / 16, height: (field.height + 15) / 16, depth: 1)
    }

    // MARK: - Canvas Init

    func initCanvas(spacing: Float = 4, weight: Float = 2, ridgeHeight: Float = 0.04, seed: UInt32 = 42,
                    absorbency: Float = 0.5, roughness: Float = 0.6, porosity: Float = 0.4) {
        guard let buf = commandQueue.makeCommandBuffer(),
              let enc = buf.makeComputeCommandEncoder() else { return }

        var params = CanvasGPUParams(
            threadSpacing: spacing, threadWeight: weight, ridgeHeight: ridgeHeight,
            seed: seed, width: Int32(field.width), height: Int32(field.height),
            absorbency: absorbency, roughness: roughness, porosity: porosity
        )

        enc.setComputePipelineState(canvasInitPipeline)
        enc.setTexture(field.wetAbsorbTex, index: 0)
        enc.setTexture(field.solidAbsorbTex, index: 1)
        enc.setTexture(field.propsTex, index: 2)
        enc.setTexture(field.heightTex, index: 3)
        enc.setTexture(field.canvasPropsTex, index: 4)
        enc.setBytes(&params, length: MemoryLayout<CanvasGPUParams>.size, index: 0)
        enc.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadgroupSize)
        enc.endEncoding()
        buf.commit()
        buf.waitUntilCompleted()
        field.phase = 0
    }

    // MARK: - Brush Stroke

    func applyStroke(_ points: [BrushPoint], mode: BrushMode) {
        guard !points.isEmpty else { return }
        guard let buf = commandQueue.makeCommandBuffer(),
              let enc = buf.makeComputeCommandEncoder() else { return }

        let pointBuffer = device.makeBuffer(bytes: points, length: points.count * BrushPoint.stride,
                                            options: .storageModeShared)
        var count = Int32(points.count)
        var modeVal = mode.modeIndex

        enc.setComputePipelineState(brushStrokePipeline)
        enc.setTexture(field.readWetAbsorb, index: 0)
        enc.setTexture(field.readProps, index: 1)
        enc.setTexture(field.heightTex, index: 2)
        enc.setTexture(field.canvasPropsTex, index: 3)
        enc.setTexture(field.solidAbsorbTex, index: 4)
        enc.setBuffer(pointBuffer, offset: 0, index: 0)
        enc.setBytes(&count, length: 4, index: 1)
        enc.setBytes(&modeVal, length: 4, index: 2)
        enc.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadgroupSize)
        enc.endEncoding()
        buf.commit()
        buf.waitUntilCompleted()
    }

    // MARK: - Time Tick (virtual zero-pressure strokes)

    /// Injects a grid of zero-pressure brush points across the canvas.
    /// These trigger the brushStroke kernel's time-tick path (pressure < 0.001)
    /// which evolves height, viscosity, hardness, and color without depositing paint.
    func injectTimeTick(mode: BrushMode = .oil) {
        let spacing = 64
        var points: [BrushPoint] = []
        for y in stride(from: 0, to: field.height, by: spacing) {
            for x in stride(from: 0, to: field.width, by: spacing) {
                points.append(BrushPoint(
                    x: Float(x), y: Float(y),
                    pressure: 0, radius: Float(spacing),
                    absR: 0, absG: 0, absB: 0, concentration: 0,
                    viscosity: 0, tipType: 0, angle: 0,
                    dirX: 0, dirY: 0, wetness: 0
                ))
            }
        }
        applyStroke(points, mode: mode)
    }

    // MARK: - Simulate

    func simulate(flowSteps: Int = 8, drySteps: Int = 4,
                  flowStrength: Float = 0.5, diffusionRate: Float = 0.3,
                  dryRate: Float = 0.1, edgeDarken: Float = 0.3) {
        var simParams = SimGPUParams(flowStrength: flowStrength, diffusionRate: diffusionRate,
                                     dryRate: dryRate, edgeDarken: edgeDarken, dt: 0.1)

        for _ in 0..<flowSteps {
            guard let buf = commandQueue.makeCommandBuffer(),
                  let enc = buf.makeComputeCommandEncoder() else { continue }
            enc.setComputePipelineState(flowStepPipeline)
            enc.setTexture(field.readWetAbsorb, index: 0)
            enc.setTexture(field.readProps, index: 1)
            enc.setTexture(field.heightTex, index: 2)
            enc.setTexture(field.canvasPropsTex, index: 3)
            enc.setTexture(field.writeWetAbsorb, index: 4)
            enc.setTexture(field.writeProps, index: 5)
            enc.setBytes(&simParams, length: MemoryLayout<SimGPUParams>.size, index: 0)
            enc.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadgroupSize)
            enc.endEncoding()
            buf.commit()
            buf.waitUntilCompleted()
            field.flip()
        }

        for _ in 0..<drySteps {
            guard let buf = commandQueue.makeCommandBuffer(),
                  let enc = buf.makeComputeCommandEncoder() else { continue }
            enc.setComputePipelineState(dryStepPipeline)
            enc.setTexture(field.readWetAbsorb, index: 0)
            enc.setTexture(field.readProps, index: 1)
            enc.setTexture(field.solidAbsorbTex, index: 2)
            enc.setTexture(field.writeWetAbsorb, index: 3)
            enc.setTexture(field.writeProps, index: 4)
            enc.setTexture(field.heightTex, index: 5)
            enc.setBytes(&simParams, length: MemoryLayout<SimGPUParams>.size, index: 0)
            enc.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadgroupSize)
            enc.endEncoding()
            buf.commit()
            buf.waitUntilCompleted()
            field.flip()
        }
    }

    // MARK: - Render

    /// Modes: 0=lit, 1=height, 2=wetness, 3=normals, 4=solid only, 5=wet only
    func render(lightAzimuth: Float = 45, lightElevation: Float = 60,
                ambient: Float = 0.3, specular: Float = 0.4,
                canvasColor: (Float, Float, Float, Float) = (0.94, 0.91, 0.86, 1.0),
                heightScale: Float = 8.0, renderMode: Int32 = 0) -> NSImage? {
        guard let buf = commandQueue.makeCommandBuffer(),
              let enc = buf.makeComputeCommandEncoder() else { return nil }

        let az = lightAzimuth * .pi / 180
        let el = lightElevation * .pi / 180

        var params = RenderGPUParams(
            lightDirX: cos(el) * cos(az), lightDirY: cos(el) * sin(az), lightDirZ: sin(el),
            ambient: ambient, specular: specular,
            canvasR: canvasColor.0, canvasG: canvasColor.1, canvasB: canvasColor.2, canvasA: canvasColor.3,
            heightScale: heightScale, renderMode: renderMode
        )

        enc.setComputePipelineState(renderPipeline)
        enc.setTexture(field.readWetAbsorb, index: 0)
        enc.setTexture(field.solidAbsorbTex, index: 1)
        enc.setTexture(field.readProps, index: 2)
        enc.setTexture(field.heightTex, index: 3)
        enc.setTexture(field.outputTex, index: 4)
        enc.setBytes(&params, length: MemoryLayout<RenderGPUParams>.size, index: 0)
        enc.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadgroupSize)
        enc.endEncoding()
        buf.commit()
        buf.waitUntilCompleted()

        return readbackOutput()
    }

    // MARK: - Readback

    private func readbackOutput() -> NSImage? {
        let w = field.width, h = field.height, bpr = w * 4
        guard let staging = makeTexture2D(
            width: w, height: h, pixelFormat: .rgba8Unorm,
            usage: [.shaderWrite], storageMode: .managed
        ) else { return nil }
        guard let buf = commandQueue.makeCommandBuffer(), let blit = buf.makeBlitCommandEncoder() else { return nil }
        blit.copy(from: field.outputTex, sourceSlice: 0, sourceLevel: 0,
                  sourceOrigin: MTLOrigin(), sourceSize: MTLSize(width: w, height: h, depth: 1),
                  to: staging, destinationSlice: 0, destinationLevel: 0, destinationOrigin: MTLOrigin())
        blit.synchronize(resource: staging)
        blit.endEncoding()
        buf.commit()
        buf.waitUntilCompleted()

        var pixels = [UInt8](repeating: 0, count: h * bpr)
        staging.getBytes(&pixels, bytesPerRow: bpr,
                         from: MTLRegion(origin: MTLOrigin(), size: MTLSize(width: w, height: h, depth: 1)),
                         mipmapLevel: 0)
        guard let ctx = CGContext(data: &pixels, width: w, height: h, bitsPerComponent: 8, bytesPerRow: bpr,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let cgImage = ctx.makeImage() else { return nil }
        return NSImage(cgImage: cgImage, size: NSSize(width: w, height: h))
    }

    // MARK: - GPU structs

    struct CanvasGPUParams {
        var threadSpacing: Float
        var threadWeight: Float
        var ridgeHeight: Float
        var seed: UInt32
        var width: Int32
        var height: Int32
        var absorbency: Float
        var roughness: Float
        var porosity: Float
        var _pad: Float = 0
    }

    struct SimGPUParams {
        var flowStrength: Float
        var diffusionRate: Float
        var dryRate: Float
        var edgeDarken: Float
        var dt: Float
    }

    struct RenderGPUParams {
        var lightDirX: Float
        var lightDirY: Float
        var lightDirZ: Float
        var ambient: Float
        var specular: Float
        var canvasR: Float
        var canvasG: Float
        var canvasB: Float
        var canvasA: Float
        var heightScale: Float
        var renderMode: Int32
        var _pad: Float = 0
    }

    enum SimError: Error {
        case noDevice, noQueue, functionNotFound(String)
    }
}
