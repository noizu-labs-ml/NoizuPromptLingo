import Metal

final class SimulationPipeline: @unchecked Sendable {
    private let engine = MetalEngine.shared

    private var dryingPipeline: MTLComputePipelineState!
    private var instantDryPipeline: MTLComputePipelineState!
    private var gridFluidPipeline: MTLComputePipelineState!
    private var sphBuildHashPipeline: MTLComputePipelineState!
    private var sphComputeForcesPipeline: MTLComputePipelineState!
    private var particleToVolumePipeline: MTLComputePipelineState!

    private let threadgroupSize = MTLSize(width: 16, height: 16, depth: 1)

    let maxParticles = 500_000
    let gridWidth: Int
    let gridHeight: Int
    let cellSize: Float = 8.0

    private var particleBufferA: MTLBuffer?
    private var particleBufferB: MTLBuffer?
    private var cellCountsBuffer: MTLBuffer?
    private var cellsBuffer: MTLBuffer?
    private var sortedIndicesBuffer: MTLBuffer?

    var particleCount: UInt32 = 0
    var wetPaintExists = false
    private var useBufferA = true

    init(canvasWidth: Int, canvasHeight: Int) {
        self.gridWidth = (canvasWidth + 7) / 8
        self.gridHeight = (canvasHeight + 7) / 8
        compilePipelines()
        allocateResources()
    }

    private func compilePipelines() {
        do {
            dryingPipeline = try engine.compilePipeline(
                source: ShaderSource.drying, functionName: "drying")
            instantDryPipeline = try engine.compilePipeline(
                source: ShaderSource.drying, functionName: "instantDry")
            gridFluidPipeline = try engine.compilePipeline(
                source: ShaderSource.gridFluid, functionName: "gridFluid")
            sphBuildHashPipeline = try engine.compilePipeline(
                source: ShaderSource.sphBuildHash, functionName: "sphBuildHash")
            sphComputeForcesPipeline = try engine.compilePipeline(
                source: ShaderSource.sphComputeForces, functionName: "sphComputeForces")
            particleToVolumePipeline = try engine.compilePipeline(
                source: ShaderSource.particleToVolume, functionName: "particleToVolume")
        } catch {
            fatalError("Simulation shader compilation failed: \(error)")
        }
    }

    private func allocateResources() {
        let particleBytes = maxParticles * MemoryLayout<SPHParticle>.stride
        particleBufferA = engine.device.makeBuffer(length: particleBytes, options: .storageModeShared)
        particleBufferB = engine.device.makeBuffer(length: particleBytes, options: .storageModeShared)

        let gridCells = gridWidth * gridHeight
        cellCountsBuffer = engine.device.makeBuffer(
            length: gridCells * MemoryLayout<UInt32>.stride, options: .storageModeShared)
        cellsBuffer = engine.device.makeBuffer(
            length: gridCells * MemoryLayout<SpatialHashCell>.stride, options: .storageModeShared)
        sortedIndicesBuffer = engine.device.makeBuffer(
            length: maxParticles * MemoryLayout<UInt32>.stride, options: .storageModeShared)
    }

    var currentParticleBuffer: MTLBuffer? { useBufferA ? particleBufferA : particleBufferB }
    private var nextParticleBuffer: MTLBuffer? { useBufferA ? particleBufferB : particleBufferA }

    func dispatch(
        commandBuffer: MTLCommandBuffer,
        volumeBuffer: MTLBuffer,
        canvasProps: MTLTexture,
        canvasWidth: Int,
        canvasHeight: Int,
        dt: Float
    ) {
        guard wetPaintExists else { return }

        let gridThreadgroups = MTLSize(
            width: (canvasWidth + 15) / 16,
            height: (canvasHeight + 15) / 16,
            depth: 1)

        if particleCount > 0 {
            dispatchSPH(
                volumeBuffer: volumeBuffer,
                canvasProps: canvasProps,
                canvasWidth: canvasWidth,
                canvasHeight: canvasHeight,
                dt: dt)
        }

        // Grid fluid
        if let enc = commandBuffer.makeComputeCommandEncoder() {
            enc.setComputePipelineState(gridFluidPipeline)
            enc.setBuffer(volumeBuffer, offset: 0, index: 0)
            var fluidParams = FluidParams(
                canvasWidth: UInt32(canvasWidth),
                canvasHeight: UInt32(canvasHeight),
                layerCount: UInt32(VolumeLayer.layerCount),
                dt: dt,
                viscosity: 0.5)
            enc.setBytes(&fluidParams, length: MemoryLayout<FluidParams>.size, index: 1)
            enc.dispatchThreadgroups(gridThreadgroups, threadsPerThreadgroup: threadgroupSize)
            enc.endEncoding()
        }

        // Drying
        if let enc = commandBuffer.makeComputeCommandEncoder() {
            enc.setComputePipelineState(dryingPipeline)
            enc.setBuffer(volumeBuffer, offset: 0, index: 0)
            enc.setTexture(canvasProps, index: 0)
            var dryingParams = DryingParams(
                canvasWidth: UInt32(canvasWidth),
                canvasHeight: UInt32(canvasHeight),
                layerCount: UInt32(VolumeLayer.layerCount),
                dt: dt)
            enc.setBytes(&dryingParams, length: MemoryLayout<DryingParams>.size, index: 1)
            enc.dispatchThreadgroups(gridThreadgroups, threadsPerThreadgroup: threadgroupSize)
            enc.endEncoding()
        }
    }

    private func dispatchSPH(
        volumeBuffer: MTLBuffer,
        canvasProps: MTLTexture,
        canvasWidth: Int,
        canvasHeight: Int,
        dt: Float
    ) {
        guard let pBufIn = currentParticleBuffer,
              let pBufOut = nextParticleBuffer,
              let cellCounts = cellCountsBuffer,
              let cells = cellsBuffer,
              let sortedIdx = sortedIndicesBuffer else { return }

        var sphConst = SPHConstants(
            smoothingLength: cellSize,
            restDensity: 1000.0,
            stiffness: 200.0,
            gamma: 7.0,
            viscosityCoeff: 0.005,
            surfaceTensionCoeff: 0.072,
            dt: dt,
            particleCount: particleCount,
            gridWidth: UInt32(gridWidth),
            gridHeight: UInt32(gridHeight),
            cellSize: cellSize,
            canvasWidth: UInt32(canvasWidth),
            canvasHeight: UInt32(canvasHeight))

        // Phase A: GPU hash count
        let cellBytes = gridWidth * gridHeight * MemoryLayout<UInt32>.stride
        memset(cellCounts.contents(), 0, cellBytes)

        guard let cb1 = engine.commandQueue.makeCommandBuffer() else { return }
        if let enc = cb1.makeComputeCommandEncoder() {
            enc.setComputePipelineState(sphBuildHashPipeline)
            enc.setBuffer(pBufIn, offset: 0, index: 0)
            enc.setBuffer(cellCounts, offset: 0, index: 1)
            enc.setBytes(&sphConst, length: MemoryLayout<SPHConstants>.size, index: 2)
            let tg = MTLSize(width: (Int(particleCount) + 63) / 64, height: 1, depth: 1)
            enc.dispatchThreadgroups(tg, threadsPerThreadgroup: MTLSize(width: 64, height: 1, depth: 1))
            enc.endEncoding()
        }
        cb1.commit()
        cb1.waitUntilCompleted()

        // Phase B: CPU prefix-sum + sorted indices
        let countPtr = cellCounts.contents().assumingMemoryBound(to: UInt32.self)
        let cellPtr = cells.contents().assumingMemoryBound(to: SpatialHashCell.self)
        var offset: UInt32 = 0
        let totalCells = gridWidth * gridHeight
        for i in 0..<totalCells {
            cellPtr[i] = SpatialHashCell(offset: offset, count: countPtr[i])
            offset += countPtr[i]
        }

        let sortPtr = sortedIdx.contents().assumingMemoryBound(to: UInt32.self)
        memset(countPtr, 0, cellBytes)
        let pIn = pBufIn.contents().assumingMemoryBound(to: SPHParticle.self)
        for i in 0..<Int(particleCount) {
            let p = pIn[i]
            guard p.life > 0 else { continue }
            let cx = min(max(Int(p.positionX / cellSize), 0), gridWidth - 1)
            let cy = min(max(Int(p.positionY / cellSize), 0), gridHeight - 1)
            let cellIdx = cy * gridWidth + cx
            let slot = cellPtr[cellIdx].offset + countPtr[cellIdx]
            if Int(slot) < maxParticles {
                sortPtr[Int(slot)] = UInt32(i)
            }
            countPtr[cellIdx] += 1
        }

        // Phase C: GPU force computation + P→V
        guard let cb2 = engine.commandQueue.makeCommandBuffer() else { return }

        if let enc = cb2.makeComputeCommandEncoder() {
            enc.setComputePipelineState(sphComputeForcesPipeline)
            enc.setBuffer(pBufIn, offset: 0, index: 0)
            enc.setBuffer(pBufOut, offset: 0, index: 1)
            enc.setBuffer(cellCounts, offset: 0, index: 2)
            enc.setBuffer(sortedIdx, offset: 0, index: 3)
            enc.setBuffer(cells, offset: 0, index: 4)
            enc.setBytes(&sphConst, length: MemoryLayout<SPHConstants>.size, index: 5)
            let tg = MTLSize(width: (Int(particleCount) + 63) / 64, height: 1, depth: 1)
            enc.dispatchThreadgroups(tg, threadsPerThreadgroup: MTLSize(width: 64, height: 1, depth: 1))
            enc.endEncoding()
        }

        if let enc = cb2.makeComputeCommandEncoder() {
            enc.setComputePipelineState(particleToVolumePipeline)
            enc.setBuffer(pBufOut, offset: 0, index: 0)
            enc.setBuffer(volumeBuffer, offset: 0, index: 1)
            enc.setBytes(&sphConst, length: MemoryLayout<SPHConstants>.size, index: 2)
            let tg = MTLSize(width: (Int(particleCount) + 63) / 64, height: 1, depth: 1)
            enc.dispatchThreadgroups(tg, threadsPerThreadgroup: MTLSize(width: 64, height: 1, depth: 1))
            enc.endEncoding()
        }

        cb2.commit()
        cb2.waitUntilCompleted()

        useBufferA.toggle()
    }

    func dispatchInstantDry(
        commandBuffer: MTLCommandBuffer,
        volumeBuffer: MTLBuffer,
        canvasWidth: Int,
        canvasHeight: Int
    ) {
        let threadgroups = MTLSize(
            width: (canvasWidth + 15) / 16,
            height: (canvasHeight + 15) / 16,
            depth: 1)

        if let enc = commandBuffer.makeComputeCommandEncoder() {
            enc.setComputePipelineState(instantDryPipeline)
            enc.setBuffer(volumeBuffer, offset: 0, index: 0)
            var params = DryingParams(
                canvasWidth: UInt32(canvasWidth),
                canvasHeight: UInt32(canvasHeight),
                layerCount: UInt32(VolumeLayer.layerCount))
            enc.setBytes(&params, length: MemoryLayout<DryingParams>.size, index: 1)
            enc.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadgroupSize)
            enc.endEncoding()
        }

        particleCount = 0
        wetPaintExists = false
    }
}
