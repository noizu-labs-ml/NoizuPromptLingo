import Metal

final class PaintUndoManager: @unchecked Sendable {
    struct Snapshot {
        let region: MTLRegion
        let layer: Int
        let data: Data
    }

    private var undoStack: [Snapshot] = []
    private var redoStack: [Snapshot] = []
    private let maxSnapshots = 10

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    func saveSnapshot(
        buffer: MTLBuffer,
        brushPoints: [BrushPoint],
        brushSize: Float,
        activeLayer: Int,
        canvasWidth: Int,
        canvasHeight: Int
    ) {
        guard !brushPoints.isEmpty else { return }

        var minX = Float.greatestFiniteMagnitude
        var minY = Float.greatestFiniteMagnitude
        var maxX: Float = 0
        var maxY: Float = 0

        for pt in brushPoints {
            let r = pt.size + 16
            minX = min(minX, pt.positionX - r)
            minY = min(minY, pt.positionY - r)
            maxX = max(maxX, pt.positionX + r)
            maxY = max(maxY, pt.positionY + r)
        }

        let x0 = max(0, Int(minX))
        let y0 = max(0, Int(minY))
        let x1 = min(canvasWidth - 1, Int(maxX))
        let y1 = min(canvasHeight - 1, Int(maxY))

        guard x1 > x0, y1 > y0 else { return }

        let regionWidth = x1 - x0 + 1
        let regionHeight = y1 - y0 + 1
        let layerStride = canvasWidth * canvasHeight
        let elementSize = MemoryLayout<VolumeLayer>.stride

        let regionBytes = regionWidth * regionHeight * elementSize
        var regionData = Data(count: regionBytes)

        let ptr = buffer.contents().assumingMemoryBound(to: UInt8.self)
        let layerOffset = activeLayer * layerStride * elementSize

        regionData.withUnsafeMutableBytes { dest in
            let destPtr = dest.baseAddress!.assumingMemoryBound(to: UInt8.self)
            var writeOffset = 0
            for row in y0...y1 {
                let srcOffset = layerOffset + (row * canvasWidth + x0) * elementSize
                let rowBytes = regionWidth * elementSize
                memcpy(destPtr + writeOffset, ptr + srcOffset, rowBytes)
                writeOffset += rowBytes
            }
        }

        let region = MTLRegion(
            origin: MTLOrigin(x: x0, y: y0, z: activeLayer),
            size: MTLSize(width: regionWidth, height: regionHeight, depth: 1))

        let snapshot = Snapshot(region: region, layer: activeLayer, data: regionData)

        undoStack.append(snapshot)
        if undoStack.count > maxSnapshots {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
    }

    func undo(buffer: MTLBuffer, canvasWidth: Int, canvasHeight: Int) {
        guard let snapshot = undoStack.popLast() else { return }

        let currentSnapshot = captureRegion(
            buffer: buffer, region: snapshot.region,
            layer: snapshot.layer,
            canvasWidth: canvasWidth, canvasHeight: canvasHeight)
        redoStack.append(currentSnapshot)

        restoreRegion(buffer: buffer, snapshot: snapshot,
                     canvasWidth: canvasWidth, canvasHeight: canvasHeight)
    }

    func redo(buffer: MTLBuffer, canvasWidth: Int, canvasHeight: Int) {
        guard let snapshot = redoStack.popLast() else { return }

        let currentSnapshot = captureRegion(
            buffer: buffer, region: snapshot.region,
            layer: snapshot.layer,
            canvasWidth: canvasWidth, canvasHeight: canvasHeight)
        undoStack.append(currentSnapshot)

        restoreRegion(buffer: buffer, snapshot: snapshot,
                     canvasWidth: canvasWidth, canvasHeight: canvasHeight)
    }

    private func captureRegion(
        buffer: MTLBuffer, region: MTLRegion,
        layer: Int, canvasWidth: Int, canvasHeight: Int
    ) -> Snapshot {
        let elementSize = MemoryLayout<VolumeLayer>.stride
        let layerStride = canvasWidth * canvasHeight
        let ptr = buffer.contents().assumingMemoryBound(to: UInt8.self)
        let layerOffset = layer * layerStride * elementSize

        let regionBytes = region.size.width * region.size.height * elementSize
        var data = Data(count: regionBytes)

        data.withUnsafeMutableBytes { dest in
            let destPtr = dest.baseAddress!.assumingMemoryBound(to: UInt8.self)
            var writeOffset = 0
            for row in 0..<region.size.height {
                let y = region.origin.y + row
                let srcOffset = layerOffset + (y * canvasWidth + region.origin.x) * elementSize
                let rowBytes = region.size.width * elementSize
                memcpy(destPtr + writeOffset, ptr + srcOffset, rowBytes)
                writeOffset += rowBytes
            }
        }

        return Snapshot(region: region, layer: layer, data: data)
    }

    private func restoreRegion(
        buffer: MTLBuffer, snapshot: Snapshot,
        canvasWidth: Int, canvasHeight: Int
    ) {
        let elementSize = MemoryLayout<VolumeLayer>.stride
        let layerStride = canvasWidth * canvasHeight
        let ptr = buffer.contents().assumingMemoryBound(to: UInt8.self)
        let layerOffset = snapshot.layer * layerStride * elementSize

        snapshot.data.withUnsafeBytes { src in
            let srcPtr = src.baseAddress!.assumingMemoryBound(to: UInt8.self)
            var readOffset = 0
            for row in 0..<snapshot.region.size.height {
                let y = snapshot.region.origin.y + row
                let dstOffset = layerOffset + (y * canvasWidth + snapshot.region.origin.x) * elementSize
                let rowBytes = snapshot.region.size.width * elementSize
                memcpy(ptr + dstOffset, srcPtr + readOffset, rowBytes)
                readOffset += rowBytes
            }
        }
    }
}
