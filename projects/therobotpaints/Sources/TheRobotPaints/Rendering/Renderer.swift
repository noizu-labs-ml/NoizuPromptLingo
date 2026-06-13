import Metal
import MetalKit
import simd

final class Renderer: NSObject, @unchecked Sendable, MTKViewDelegate {
    private let engine = MetalEngine.shared

    let canvasWidth: Int
    let canvasHeight: Int

    let viewport: ViewportController
    let brushEngine: BrushEngine
    let inputRouter: InputRouter
    let simulation: SimulationPipeline
    let layerManager = LayerManager()
    let paintUndo = PaintUndoManager()

    private var canvasPropsTexture: MTLTexture?
    private var volumeLayersBuffer: MTLBuffer?

    private var canvasInitPipeline: MTLComputePipelineState!
    private var volumeInitPipeline: MTLComputePipelineState!
    private var renderPipeline: MTLComputePipelineState!
    private var depositPipeline: MTLComputePipelineState!
    private var depositWithParticlesPipeline: MTLComputePipelineState!

    private var brushPointBuffer: MTLBuffer?
    private var particleCounterBuffer: MTLBuffer?
    private let maxBrushPoints = 4096

    private var canvasInitialized = false
    private var needsUndoSnapshot = false

    var lightDirX: Float = 0.3
    var lightDirY: Float = 0.5
    var lightDirZ: Float = 0.8
    var simSpeed: Float = 1.0

    private let threadgroupSize = MTLSize(width: 16, height: 16, depth: 1)

    init(canvasWidth: Int = 2048, canvasHeight: Int = 1536) {
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.viewport = ViewportController(canvasWidth: canvasWidth, canvasHeight: canvasHeight)
        self.brushEngine = BrushEngine()
        self.inputRouter = InputRouter(brushEngine: brushEngine, viewport: viewport)
        self.simulation = SimulationPipeline(canvasWidth: canvasWidth, canvasHeight: canvasHeight)
        super.init()
        compilePipelines()
        allocateResources()
        inputRouter.onUndo = { [weak self] in self?.performUndo() }
        inputRouter.onRedo = { [weak self] in self?.performRedo() }
        inputRouter.onStrokeStart = { [weak self] in self?.needsUndoSnapshot = true }
    }

    private func compilePipelines() {
        do {
            canvasInitPipeline = try engine.compilePipeline(
                source: ShaderSource.canvasInit, functionName: "canvasInit")
            volumeInitPipeline = try engine.compilePipeline(
                source: ShaderSource.volumeInit, functionName: "volumeInit")
            renderPipeline = try engine.compilePipeline(
                source: ShaderSource.render, functionName: "render")
            depositPipeline = try engine.compilePipeline(
                source: ShaderSource.deposit, functionName: "deposit")
            depositWithParticlesPipeline = try engine.compilePipeline(
                source: ShaderSource.depositWithParticles, functionName: "depositWithParticles")
        } catch {
            fatalError("Shader compilation failed: \(error)")
        }
    }

    private func allocateResources() {
        let pixelCount = canvasWidth * canvasHeight
        let bufferSize = pixelCount * VolumeLayer.layerCount * MemoryLayout<VolumeLayer>.stride
        volumeLayersBuffer = engine.device.makeBuffer(length: bufferSize, options: .storageModeShared)
        canvasPropsTexture = engine.makeTexture(
            width: canvasWidth, height: canvasHeight, pixelFormat: .rgba16Float)
        brushPointBuffer = engine.device.makeBuffer(
            length: maxBrushPoints * MemoryLayout<BrushPoint>.stride,
            options: .storageModeShared)
        particleCounterBuffer = engine.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride,
            options: .storageModeShared)
    }

    func draw(in view: MTKView) {
        let drawableSize = view.drawableSize
        let dw = Int(drawableSize.width)
        let dh = Int(drawableSize.height)

        viewport.updateDrawableSize(width: dw, height: dh)

        guard dw > 0, dh > 0,
              let drawable = view.currentDrawable,
              let commandBuffer = engine.commandQueue.makeCommandBuffer(),
              let volumeBuffer = volumeLayersBuffer,
              let canvasProps = canvasPropsTexture else { return }

        let canvasThreadgroups = MTLSize(
            width: (canvasWidth + 15) / 16,
            height: (canvasHeight + 15) / 16,
            depth: 1)

        if !canvasInitialized {
            if let enc = commandBuffer.makeComputeCommandEncoder() {
                enc.setComputePipelineState(canvasInitPipeline)
                enc.setTexture(canvasProps, index: 0)
                enc.dispatchThreadgroups(canvasThreadgroups, threadsPerThreadgroup: threadgroupSize)
                enc.endEncoding()
            }

            if let enc = commandBuffer.makeComputeCommandEncoder() {
                enc.setComputePipelineState(volumeInitPipeline)
                enc.setBuffer(volumeBuffer, offset: 0, index: 0)
                var params = SimParams(
                    canvasWidth: UInt32(canvasWidth),
                    canvasHeight: UInt32(canvasHeight),
                    layerCount: UInt32(VolumeLayer.layerCount),
                    dt: 0.016)
                enc.setBytes(&params, length: MemoryLayout<SimParams>.size, index: 1)
                enc.dispatchThreadgroups(canvasThreadgroups, threadsPerThreadgroup: threadgroupSize)
                enc.endEncoding()
            }

            canvasInitialized = true
        }

        let points = brushEngine.flushPoints()
        if !points.isEmpty, let bpBuffer = brushPointBuffer {
            if needsUndoSnapshot, let volBuf = volumeLayersBuffer {
                paintUndo.saveSnapshot(
                    buffer: volBuf,
                    brushPoints: points,
                    brushSize: brushEngine.brushParams.size,
                    activeLayer: layerManager.activeLayer,
                    canvasWidth: canvasWidth,
                    canvasHeight: canvasHeight)
                needsUndoSnapshot = false
            }
            let count = min(points.count, maxBrushPoints)
            let byteCount = count * MemoryLayout<BrushPoint>.stride
            points.withUnsafeBufferPointer { ptr in
                memcpy(bpBuffer.contents(), ptr.baseAddress!, byteCount)
            }
            simulation.wetPaintExists = true

            var brushParams = brushEngine.brushParams
            brushParams.activeLayer = UInt32(layerManager.activeLayer)
            let isWetMedia = brushParams.mediaType <= 2 && brushParams.isEraser == 0

            if let enc = commandBuffer.makeComputeCommandEncoder() {
                let threadgroups = MTLSize(width: (count + 63) / 64, height: 1, depth: 1)
                let threadsPerGroup = MTLSize(width: 64, height: 1, depth: 1)

                if isWetMedia, let particleBuf = simulation.currentParticleBuffer,
                   let counterBuf = particleCounterBuffer {
                    enc.setComputePipelineState(depositWithParticlesPipeline)
                    enc.setBuffer(volumeBuffer, offset: 0, index: 0)
                    enc.setBuffer(bpBuffer, offset: 0, index: 1)
                    enc.setBytes(&brushParams, length: MemoryLayout<BrushParams>.size, index: 2)
                    var depositParams = DepositParams(
                        canvasWidth: UInt32(canvasWidth),
                        canvasHeight: UInt32(canvasHeight),
                        layerCount: UInt32(VolumeLayer.layerCount),
                        pointCount: UInt32(count))
                    enc.setBytes(&depositParams, length: MemoryLayout<DepositParams>.size, index: 3)
                    counterBuf.contents().assumingMemoryBound(to: UInt32.self).pointee = simulation.particleCount
                    enc.setBuffer(particleBuf, offset: 0, index: 4)
                    enc.setBuffer(counterBuf, offset: 0, index: 5)
                    var maxP = UInt32(simulation.maxParticles)
                    enc.setBytes(&maxP, length: MemoryLayout<UInt32>.size, index: 6)
                    enc.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadsPerGroup)
                    enc.endEncoding()

                    commandBuffer.addCompletedHandler { [weak self] _ in
                        guard let self else { return }
                        let newCount = counterBuf.contents().assumingMemoryBound(to: UInt32.self).pointee
                        self.simulation.particleCount = min(newCount, UInt32(self.simulation.maxParticles))
                    }
                } else {
                    enc.setComputePipelineState(depositPipeline)
                    enc.setBuffer(volumeBuffer, offset: 0, index: 0)
                    enc.setBuffer(bpBuffer, offset: 0, index: 1)
                    enc.setBytes(&brushParams, length: MemoryLayout<BrushParams>.size, index: 2)
                    var depositParams = DepositParams(
                        canvasWidth: UInt32(canvasWidth),
                        canvasHeight: UInt32(canvasHeight),
                        layerCount: UInt32(VolumeLayer.layerCount),
                        pointCount: UInt32(count))
                    enc.setBytes(&depositParams, length: MemoryLayout<DepositParams>.size, index: 3)
                    enc.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadsPerGroup)
                    enc.endEncoding()
                }
            }
        }

        simulation.dispatch(
            commandBuffer: commandBuffer,
            volumeBuffer: volumeBuffer,
            canvasProps: canvasProps,
            canvasWidth: canvasWidth,
            canvasHeight: canvasHeight,
            dt: 0.016 * simSpeed)

        let drawableThreadgroups = MTLSize(
            width: (dw + 15) / 16,
            height: (dh + 15) / 16,
            depth: 1)

        if let enc = commandBuffer.makeComputeCommandEncoder() {
            enc.setComputePipelineState(renderPipeline)
            enc.setBuffer(volumeBuffer, offset: 0, index: 0)
            enc.setTexture(canvasProps, index: 0)
            enc.setTexture(drawable.texture, index: 1)

            var renderParams = RenderParams(
                canvasWidth: UInt32(canvasWidth),
                canvasHeight: UInt32(canvasHeight),
                layerCount: UInt32(VolumeLayer.layerCount))
            enc.setBytes(&renderParams, length: MemoryLayout<RenderParams>.size, index: 1)

            let ld = simd_normalize(simd_float3(lightDirX, lightDirY, lightDirZ))
            var lightParams = LightParams(
                lightDirX: ld.x,
                lightDirY: ld.y,
                lightDirZ: ld.z,
                ambient: 0.15)
            enc.setBytes(&lightParams, length: MemoryLayout<LightParams>.size, index: 2)

            var viewParams = viewport.makeViewParams(drawableWidth: dw, drawableHeight: dh)
            enc.setBytes(&viewParams, length: MemoryLayout<ViewParams>.size, index: 3)

            var layerState = LayerState(
                activeLayer: UInt32(layerManager.activeLayer),
                visibilityMask: UInt32(layerManager.visibility))
            enc.setBytes(&layerState, length: MemoryLayout<LayerState>.size, index: 4)

            enc.dispatchThreadgroups(drawableThreadgroups, threadsPerThreadgroup: threadgroupSize)
            enc.endEncoding()
        }

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    private func performUndo() {
        guard let buf = volumeLayersBuffer else { return }
        paintUndo.undo(buffer: buf, canvasWidth: canvasWidth, canvasHeight: canvasHeight)
    }

    private func performRedo() {
        guard let buf = volumeLayersBuffer else { return }
        paintUndo.redo(buffer: buf, canvasWidth: canvasWidth, canvasHeight: canvasHeight)
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
