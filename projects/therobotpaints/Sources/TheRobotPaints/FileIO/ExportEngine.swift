import Metal
import AppKit

struct ExportEngine: Sendable {
    static func exportPNG(
        volumeBuffer: MTLBuffer,
        canvasPropsTexture: MTLTexture,
        renderer: Renderer,
        canvasWidth: Int,
        canvasHeight: Int,
        to url: URL
    ) throws {
        let engine = MetalEngine.shared
        let bpp = 4
        let rowBytes = canvasWidth * bpp

        guard let outputTexture = engine.makeTexture(
            width: canvasWidth, height: canvasHeight,
            pixelFormat: .bgra8Unorm,
            usage: [.shaderRead, .shaderWrite],
            storageMode: .shared) else {
            throw ExportError.textureCreationFailed
        }

        guard let commandBuffer = engine.commandQueue.makeCommandBuffer() else {
            throw ExportError.commandBufferFailed
        }

        guard let renderPipeline = try? engine.compilePipeline(
            source: ShaderSource.render, functionName: "render") else {
            throw ExportError.pipelineFailed
        }

        if let enc = commandBuffer.makeComputeCommandEncoder() {
            enc.setComputePipelineState(renderPipeline)
            enc.setBuffer(volumeBuffer, offset: 0, index: 0)
            enc.setTexture(canvasPropsTexture, index: 0)
            enc.setTexture(outputTexture, index: 1)

            var renderParams = RenderParams(
                canvasWidth: UInt32(canvasWidth),
                canvasHeight: UInt32(canvasHeight),
                layerCount: UInt32(VolumeLayer.layerCount))
            enc.setBytes(&renderParams, length: MemoryLayout<RenderParams>.size, index: 1)

            var lightParams = LightParams(
                lightDirX: 0.3, lightDirY: 0.5, lightDirZ: 0.8, ambient: 0.15)
            enc.setBytes(&lightParams, length: MemoryLayout<LightParams>.size, index: 2)

            var viewParams = ViewParams(
                zoomLevel: 1.0,
                canvasWidth: UInt32(canvasWidth),
                canvasHeight: UInt32(canvasHeight),
                drawableWidth: UInt32(canvasWidth),
                drawableHeight: UInt32(canvasHeight))
            enc.setBytes(&viewParams, length: MemoryLayout<ViewParams>.size, index: 3)

            var layerState = LayerState(activeLayer: 0, visibilityMask: 0xFF)
            enc.setBytes(&layerState, length: MemoryLayout<LayerState>.size, index: 4)

            let tg = MTLSize(
                width: (canvasWidth + 15) / 16,
                height: (canvasHeight + 15) / 16,
                depth: 1)
            enc.dispatchThreadgroups(tg, threadsPerThreadgroup: MTLSize(width: 16, height: 16, depth: 1))
            enc.endEncoding()
        }

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        var pixels = [UInt8](repeating: 0, count: canvasWidth * canvasHeight * bpp)
        let region = MTLRegion(origin: MTLOrigin(), size: MTLSize(width: canvasWidth, height: canvasHeight, depth: 1))
        outputTexture.getBytes(&pixels, bytesPerRow: rowBytes, from: region, mipmapLevel: 0)

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: &pixels,
                width: canvasWidth, height: canvasHeight,
                bitsPerComponent: 8, bytesPerRow: rowBytes,
                space: colorSpace,
                bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue),
              let cgImage = context.makeImage() else {
            throw ExportError.imageCreationFailed
        }

        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: canvasWidth, height: canvasHeight))
        guard let tiffData = nsImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw ExportError.encodingFailed
        }

        try pngData.write(to: url)
    }

    enum ExportError: Error {
        case textureCreationFailed
        case commandBufferFailed
        case pipelineFailed
        case imageCreationFailed
        case encodingFailed
    }
}
